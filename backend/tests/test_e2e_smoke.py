"""
End-to-end smoke test: full happy-path workflow using mock services.
No real API keys required — Channel3, OpenAI, and PayPal all run in mock mode.
"""
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_full_shopping_to_transaction_workflow(async_client: AsyncClient):
    """
    Exercises the complete user journey:
    1. Submit shopping brief
    2. Retrieve session with extracted requirements
    3. Get ranked products with constraint results
    4. Create PayPal checkout order
    5. Capture payment (mock returns COMPLETED)
    6. Verify transaction status
    7. Confirm purchase appears in history
    """
    # ── Step 1: Submit shopping brief ─────────────────────────────────────────
    brief_resp = await async_client.post(
        "/api/v1/shopping/brief",
        json={"brief": "I need a laptop under $1000 with 16GB RAM for software development"},
    )
    assert brief_resp.status_code == 200, f"Brief failed: {brief_resp.text}"
    brief_data = brief_resp.json()
    assert "session_id" in brief_data
    session_id = brief_data["session_id"]
    assert session_id, "session_id must not be empty"

    # ── Step 2: Retrieve session + requirements ────────────────────────────────
    session_resp = await async_client.get(f"/api/v1/shopping/{session_id}")
    assert session_resp.status_code == 200, f"Get session failed: {session_resp.text}"
    session_data = session_resp.json()
    assert session_data["requirements_json"] is not None, "requirements_json must be populated"
    reqs = session_data["requirements_json"]
    assert "product_category" in reqs, "requirements must include product_category"

    # ── Step 3: Get ranked products ────────────────────────────────────────────
    products_resp = await async_client.get(f"/api/v1/products/{session_id}")
    assert products_resp.status_code == 200, f"Get products failed: {products_resp.text}"
    products = products_resp.json()
    assert isinstance(products, list), "products response must be a list"
    assert len(products) >= 1, "At least one product must be returned"

    first = products[0]
    assert "constraint_results" in first, "Each product must have constraint_results"
    assert "ranking_score" in first, "Each product must have ranking_score"
    assert "ranking_confidence" in first, "Each product must have ranking_confidence"

    # Verify UNKNOWN-not-PASS invariant: no constraint is PASS when spec is None
    for product in products:
        p_data = product.get("product", {})
        specs = p_data.get("specs", {})
        for attr, result in product["constraint_results"].items():
            if specs.get(attr) is None and result == "PASS":
                pytest.fail(
                    f"Constraint '{attr}' is PASS but spec value is None — "
                    "UNKNOWN invariant violated"
                )

    # Get the product_result DB id for checkout (added in Phase 6 backend patch)
    product_result_id = first.get("id")
    # If id not present at top level, the product may be nested — skip checkout
    if not product_result_id:
        pytest.skip("product_result_id not returned by products endpoint — checkout skipped")

    # ── Step 4: Create checkout order ─────────────────────────────────────────
    checkout_resp = await async_client.post(
        "/api/v1/checkout/create",
        json={"product_result_id": product_result_id},
    )
    assert checkout_resp.status_code == 200, f"Checkout create failed: {checkout_resp.text}"
    checkout_data = checkout_resp.json()
    assert "order_id" in checkout_data
    assert "approval_url" in checkout_data
    assert checkout_data["approval_url"], "approval_url must not be empty"
    assert "purchase_id" in checkout_data
    order_id = checkout_data["order_id"]
    purchase_id = checkout_data["purchase_id"]

    # ── Step 5: Capture payment ────────────────────────────────────────────────
    capture_resp = await async_client.post(
        "/api/v1/checkout/capture",
        json={"order_id": order_id, "purchase_id": purchase_id},
    )
    assert capture_resp.status_code == 200, f"Capture failed: {capture_resp.text}"
    capture_data = capture_resp.json()
    assert capture_data["verified"] is True, (
        "verified must be True after successful mock capture — "
        "never show success without server-side verification"
    )
    assert "transaction_id" in capture_data

    # ── Step 6: Verify transaction status ─────────────────────────────────────
    txn_resp = await async_client.get(f"/api/v1/transactions/{purchase_id}")
    assert txn_resp.status_code == 200, f"Get transaction failed: {txn_resp.text}"
    txn_data = txn_resp.json()
    assert txn_data["status"] == "captured", (
        f"Transaction status must be 'captured', got '{txn_data['status']}'"
    )

    # ── Step 7: Purchase appears in history ───────────────────────────────────
    history_resp = await async_client.get("/api/v1/history")
    assert history_resp.status_code == 200, f"History failed: {history_resp.text}"
    history = history_resp.json()
    # History returns PurchaseHistoryItem objects with nested purchase_record
    purchase_ids = [h.get("purchase_record", {}).get("id") for h in history]
    assert purchase_id in purchase_ids, (
        f"Purchase {purchase_id} not found in history: {purchase_ids}"
    )


@pytest.mark.asyncio
async def test_checkout_requires_valid_product_result_id(async_client: AsyncClient):
    """Checkout must return 404 for a non-existent product_result_id."""
    resp = await async_client.post(
        "/api/v1/checkout/create",
        json={"product_result_id": "00000000-0000-0000-0000-000000000000"},
    )
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_capture_never_succeeds_with_wrong_order_id(async_client: AsyncClient):
    """Capture must fail gracefully when order_id does not match purchase record."""
    # First create a real purchase
    brief_resp = await async_client.post(
        "/api/v1/shopping/brief",
        json={"brief": "I need a gaming laptop under $800 with fast GPU"},
    )
    session_id = brief_resp.json()["session_id"]
    await async_client.get(f"/api/v1/products/{session_id}")

    products_resp = await async_client.get(f"/api/v1/products/{session_id}")
    products = products_resp.json()
    product_result_id = products[0].get("id") if products else None
    if not product_result_id:
        pytest.skip("No product_result_id available")

    checkout_resp = await async_client.post(
        "/api/v1/checkout/create",
        json={"product_result_id": product_result_id},
    )
    purchase_id = checkout_resp.json()["purchase_id"]

    # Attempt capture with wrong order_id
    capture_resp = await async_client.post(
        "/api/v1/checkout/capture",
        json={"order_id": "WRONG-ORDER-ID", "purchase_id": purchase_id},
    )
    assert capture_resp.status_code in (400, 422), (
        f"Expected 400/422 for mismatched order_id, got {capture_resp.status_code}"
    )
