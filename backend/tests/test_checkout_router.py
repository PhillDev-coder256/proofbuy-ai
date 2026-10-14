from datetime import datetime, timezone
from uuid import uuid4

import pytest

from tests.conftest import TestSessionLocal
from app.models.shopping_session import ShoppingSession
from app.models.product_result import ProductResult
from app.models.purchase_record import PurchaseRecord
from app.models.transaction import Transaction


@pytest.fixture(autouse=True)
def force_mock_services(monkeypatch):
    """Force all external services into mock mode for router tests."""
    import app.config as cfg
    monkeypatch.setattr(cfg.settings, "paypal_client_id", "")
    monkeypatch.setattr(cfg.settings, "paypal_client_secret", "")
    monkeypatch.setattr(cfg.settings, "ai_provider_api_key", "")
    monkeypatch.setattr(cfg.settings, "channel3_api_key", "")


async def create_session_and_product(price: float = 49.99, currency: str = "USD"):
    """Insert a ShoppingSession + ProductResult and return their model instances."""
    async with TestSessionLocal() as db:
        session = ShoppingSession(
            id=str(uuid4()),
            brief_text="Test brief for checkout",
            status="completed",
        )
        db.add(session)
        await db.flush()

        product = ProductResult(
            id=str(uuid4()),
            session_id=session.id,
            name="Test Product",
            price=price,
            currency=currency,
        )
        db.add(product)
        await db.commit()
        await db.refresh(session)
        await db.refresh(product)
        return session.id, product.id


@pytest.mark.asyncio
async def test_create_order_validates_product_exists(async_client):
    response = await async_client.post(
        "/api/v1/checkout/create",
        json={"product_result_id": "nonexistent-id"},
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_capture_idempotent_when_already_captured(async_client):
    session_id, product_id = await create_session_and_product()

    # Create order
    create_resp = await async_client.post(
        "/api/v1/checkout/create",
        json={"product_result_id": product_id},
    )
    assert create_resp.status_code == 200
    create_data = create_resp.json()
    order_id = create_data["order_id"]
    purchase_id = create_data["purchase_id"]

    capture_payload = {"order_id": order_id, "purchase_id": purchase_id}

    # First capture
    resp1 = await async_client.post("/api/v1/checkout/capture", json=capture_payload)
    assert resp1.status_code == 200
    txn_id_1 = resp1.json()["transaction_id"]

    # Second capture (idempotent)
    resp2 = await async_client.post("/api/v1/checkout/capture", json=capture_payload)
    assert resp2.status_code == 200
    txn_id_2 = resp2.json()["transaction_id"]

    assert txn_id_1 == txn_id_2


@pytest.mark.asyncio
async def test_capture_updates_purchase_status(async_client):
    session_id, product_id = await create_session_and_product()

    # Create order
    create_resp = await async_client.post(
        "/api/v1/checkout/create",
        json={"product_result_id": product_id},
    )
    assert create_resp.status_code == 200
    create_data = create_resp.json()
    order_id = create_data["order_id"]
    purchase_id = create_data["purchase_id"]

    # Capture
    capture_resp = await async_client.post(
        "/api/v1/checkout/capture",
        json={"order_id": order_id, "purchase_id": purchase_id},
    )
    assert capture_resp.status_code == 200
    assert capture_resp.json()["verified"] is True

    # Verify purchase status in DB
    async with TestSessionLocal() as db:
        from sqlalchemy import select
        result = await db.execute(
            select(PurchaseRecord).where(PurchaseRecord.id == purchase_id)
        )
        purchase = result.scalars().first()
        assert purchase is not None
        assert purchase.status == "captured"
