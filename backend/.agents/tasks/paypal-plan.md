# Implementation Plan — PayPal Orders v2 Integration (Phase 5)

**Project**: ProofBuy AI Backend  
**Python**: 3.9.6 (use `Optional[X]`, `List[X]` from `typing` — **not** `X | Y` unions)  
**Test runner**: `python3 -m pytest tests/ -v` (asyncio_mode=auto in pytest.ini)  
**Baseline**: 15 tests all pass before any changes  

---

## Key design decisions

- **PayPalService as a class, not a module**: The stub uses bare module functions; the replacement uses a `PayPalService` class instantiated once at app startup and injected via FastAPI dependency. This gives clean token caching per instance and testability through constructor injection.
- **Service instantiated from config in `main.py`**: A single `get_paypal_service()` FastAPI dependency function returns the singleton built from `settings`. This avoids circular imports and keeps config wiring in one place.
- **Mock mode via empty `client_id`**: When `settings.paypal_client_id` is empty (dev/CI), the service returns realistic mock data and logs a WARNING. No separate flag needed — the existing config already models this state.
- **`raw_capture_json` stored in DB, never returned to client**: `Transaction.raw_capture_json` already exists in the model. The router stores it there and returns only `transaction_id`, `status`, `verified`.
- **Amount from DB only**: The router reads `product.price` and `product.currency` from the `ProductResult` row. No amount field is accepted from the client request body.
- **Idempotency check on create**: Query for existing `PurchaseRecord` with `product_result_id + session_id` and `status != 'failed'`; return existing if found. `idempotency_key` column already exists on the model.
- **pytest-httpx for service tests**: `pytest-httpx==0.35.0` is already installed. Use `httpx_mock` fixture (the pytest-httpx approach for that version) to mock `httpx.AsyncClient` calls.

---

- [ ] 1. Add PayPal exception classes to `app/core/exceptions.py`.
      Append five new classes after `ServiceUnavailableError`: `PayPalAuthError` (502), `PayPalOrderNotApprovedError` (422), `PayPalInstrumentDeclinedError` (402), `PayPalDuplicateCaptureError` (409), `PayPalServiceError` (502). All inherit from `ProofBuyException` and delegate to `super().__init__(message, status_code=...)`.
      Files: `app/core/exceptions.py`
      Verify: `python3 -m pytest tests/ -v` — all 15 existing tests still pass (no new tests yet, just a structural change).

- [ ] 2. Create Pydantic result models for PayPal responses in a new file `app/services/paypal_models.py`.
      Define three models using `pydantic.BaseModel`, Python 3.9-compatible typing:
      - `PayPalOrderResult(order_id: str, approval_url: str, status: str)`
      - `PayPalCaptureResult(capture_id: str, order_id: str, status: str, verified: bool, amount: str, currency: str)`
      - `PayPalOrderStatus(order_id: str, status: str, intent: Optional[str] = None, payer: Optional[dict] = None)`
      These are pure data containers; no HTTP logic here.
      Files: `app/services/paypal_models.py`
      Verify: `python3 -c "from app.services.paypal_models import PayPalOrderResult, PayPalCaptureResult, PayPalOrderStatus; print('ok')"` — prints `ok`.

- [ ] 3. Replace `app/services/paypal_service.py` with the full `PayPalService` class.
      Implement the class with these members (all Python 3.9-compatible):

      **`__init__(self, client_id: str, client_secret: str, environment: str = "sandbox")`**  
      - Set `self._base_url` to `"https://api-m.sandbox.paypal.com"` if `environment == "sandbox"`, else `"https://api-m.paypal.com"`.  
      - Set `self._client_id = client_id`, `self._client_secret = client_secret`.  
      - Set `self._access_token: Optional[str] = None` and `self._token_expires_at: Optional[datetime] = None`.  
      - If `client_id` is empty, `logger.warning("PayPal client_id not set — running in mock mode")`.

      **`async _get_access_token(self) -> str`**  
      - If token is cached and `datetime.now(timezone.utc) < self._token_expires_at`, return cached token.  
      - POST `{_base_url}/v1/oauth2/token` using `httpx.AsyncClient` with `auth=(client_id, client_secret)`, form data `grant_type=client_credentials`.  
      - On non-2xx, raise `PayPalAuthError(f"OAuth2 token fetch failed: {resp.status_code}")`.  
      - Cache token and set `_token_expires_at = now + timedelta(seconds=expires_in - 60)`.  
      - **Never log `client_secret`**.

      **`async create_order(self, purchase_id: str, amount: float, currency: str) -> PayPalOrderResult`**  
      - Validate: `amount > 0` else `raise ValueError("amount must be > 0")`. `len(currency) == 3` else `raise ValueError("currency must be 3 chars")`. `purchase_id` not empty else `raise ValueError("purchase_id required")`.  
      - Mock mode (empty `_client_id`): return `PayPalOrderResult(order_id="MOCK-ORDER-{purchase_id[:8]}", approval_url="https://www.sandbox.paypal.com/checkoutnow?token=MOCK-{purchase_id[:8]}", status="CREATED")`.  
      - Real mode: call `_get_access_token()`, POST `{_base_url}/v2/checkout/orders` with JSON body (intent CAPTURE, amount value as 2-decimal string, currency_code, reference_id=purchase_id).  
      - Extract `approval_url` from response `links` array where `rel == "approve"`.  
      - On non-2xx, raise `PayPalServiceError(f"create_order failed: {resp.status_code}")`.  
      - Return `PayPalOrderResult`.

      **`async verify_order(self, order_id: str) -> PayPalOrderStatus`**  
      - Mock mode: return `PayPalOrderStatus(order_id=order_id, status="APPROVED")`.  
      - Real mode: GET `{_base_url}/v2/checkout/orders/{order_id}` with Bearer auth.  
      - On non-2xx, raise `PayPalServiceError(f"verify_order failed: {resp.status_code}")`.  
      - Return `PayPalOrderStatus`.

      **`async capture_order(self, order_id: str) -> PayPalCaptureResult`**  
      - Mock mode: return `PayPalCaptureResult(capture_id="MOCK-CAPTURE-{order_id[-8:]}", order_id=order_id, status="COMPLETED", verified=True, amount="0.00", currency="USD")`.  
      - Real mode: call `verify_order(order_id)`; if `status != "APPROVED"`, raise `PayPalOrderNotApprovedError(f"Order {order_id} status is {status}, expected APPROVED")`.  
      - POST `{_base_url}/v2/checkout/orders/{order_id}/capture` with Bearer auth, empty JSON body `{}`, header `PayPal-Request-Id: {order_id}` for idempotency.  
      - If response contains `details[].issue == "INSTRUMENT_DECLINED"`: raise `PayPalInstrumentDeclinedError("Payment instrument declined")`.  
      - If response contains `details[].issue == "ORDER_ALREADY_CAPTURED"` (or HTTP 422 with that issue): return `PayPalCaptureResult` reconstructed from existing purchase data — handle as idempotent success. To do this, call `verify_order(order_id)` again and build the result from the order's captured amounts if available; if not, raise `PayPalDuplicateCaptureError("Order already captured")` — the router handles this by returning the existing Transaction.  
      - On other non-2xx, raise `PayPalServiceError(f"capture_order failed: {resp.status_code}")`.  
      - Extract `capture_id` from `purchase_units[0].payments.captures[0].id`, `amount.value`, `amount.currency_code`.  
      - Return `PayPalCaptureResult(verified=True)`.

      Files: `app/services/paypal_service.py`  
      Verify: `python3 -c "from app.services.paypal_service import PayPalService; print('ok')"` — prints `ok`.

- [ ] 4. Add a FastAPI dependency function `get_paypal_service()` to `app/services/paypal_service.py`.
      After the class definition, add:
      ```python
      from app.config import settings
      
      def get_paypal_service() -> PayPalService:
          return PayPalService(
              client_id=settings.paypal_client_id,
              client_secret=settings.paypal_client_secret,
              environment=settings.paypal_environment,
          )
      ```
      This is a plain function (not `async`); FastAPI will call it per-request, but since the object is cheap to construct and token is cached on the instance, this is acceptable. (If per-request construction becomes a concern, it can be promoted to app state later — that's a single-line change.)
      Files: `app/services/paypal_service.py`  
      Verify: `python3 -c "from app.services.paypal_service import get_paypal_service; s = get_paypal_service(); print(s._base_url)"` — prints a paypal URL without error.

- [ ] 5. Rewrite `app/routers/checkout.py` with the real PayPal flow and security rules.

      **`POST /api/v1/checkout/create`**:  
      a. Inject `PayPalService` via `Depends(get_paypal_service)`.  
      b. Query `ProductResult` by `request.product_result_id`; raise `NotFoundError` if missing.  
      c. Validate `product.price > 0` and `len(product.currency) == 3`; raise `ValidationError` if not.  
      d. Idempotency: query for existing `PurchaseRecord` where `product_result_id == request.product_result_id` AND `session_id == product.session_id` AND `status != 'failed'`; if found and `paypal_order_id` is set, return existing `CheckoutCreateResponse` without creating a new order.  
      e. Create `PurchaseRecord(session_id=product.session_id, product_result_id=product.id, amount=product.price, currency=product.currency, status='pending', idempotency_key=str(uuid4()))`.  
      f. `db.add(purchase)` then `await db.flush()` to get the `purchase.id`.  
      g. Call `await paypal_service.create_order(str(purchase.id), float(product.price), product.currency)`.  
      h. Set `purchase.paypal_order_id = result.order_id`, `purchase.status = 'pending'` (NOT 'approved' — approval happens on the PayPal side; status 'pending' is correct until capture), `purchase.updated_at = datetime.now(timezone.utc)`.  
      i. `await db.commit()`, `await db.refresh(purchase)`.  
      j. Return `CheckoutCreateResponse(order_id=result.order_id, approval_url=result.approval_url, purchase_id=str(purchase.id))`.

      **`POST /api/v1/checkout/capture`**:  
      a. Inject `PayPalService` via `Depends(get_paypal_service)`.  
      b. Load `PurchaseRecord` by `request.purchase_id`; raise `NotFoundError` if missing.  
      c. Verify `purchase.paypal_order_id == request.order_id`; raise `ValidationError("order_id does not match purchase record")` if not.  
      d. Idempotency: if `purchase.status == 'captured'`, query existing `Transaction` for this purchase and return `CheckoutCaptureResponse(transaction_id=str(transaction.id), status='captured', verified=True)`.  
      e. Call `await paypal_service.capture_order(request.order_id)`.  
      f. On `PayPalInstrumentDeclinedError` or `PayPalServiceError`: set `purchase.status = 'failed'`, `await db.commit()`; re-raise the exception (the exception handler in `add_exception_handlers` will return the correct HTTP status).  
      g. On `PayPalDuplicateCaptureError`: set `purchase.status = 'captured'`, `await db.commit()`; look up and return the existing `Transaction` (or create a minimal one if none exists, to maintain idempotency).  
      h. On success: create `Transaction(purchase_record_id=str(purchase.id), paypal_capture_id=capture.capture_id, status='captured', verified_at=datetime.now(timezone.utc), raw_capture_json={"capture_id": capture.capture_id, "status": capture.status, "amount": capture.amount, "currency": capture.currency})`.  
         **Never put the full PayPal JSON response in the HTTP response — only store it in `raw_capture_json` in the DB.**  
      i. Set `purchase.status = 'captured'`, `purchase.updated_at = datetime.now(timezone.utc)`.  
      j. `await db.commit()`, `await db.refresh(transaction)`.  
      k. Return `CheckoutCaptureResponse(transaction_id=str(transaction.id), status='captured', verified=capture.verified)`.

      Files: `app/routers/checkout.py`  
      Verify: `python3 -m pytest tests/ -v` — all 15 existing tests still pass (checkout router has no existing tests; import changes must not break anything).

- [ ] 6. Create `tests/test_paypal_service.py` with 8 pytest-httpx unit tests.

      The `httpx_mock` fixture is provided automatically by `pytest-httpx==0.35.0`.  
      Import `PayPalService` directly (not via the router) for isolation.  
      Use `httpx_mock.add_response(method=..., url=..., json=..., status_code=...)` to register mock HTTP responses before calling service methods.

      **Tests to implement**:

      1. `test_token_fetch_succeeds`: Create `PayPalService("id", "secret")`. Add mock for `POST https://api-m.sandbox.paypal.com/v1/oauth2/token` returning `{"access_token": "tok123", "expires_in": 3600}`. Call `await svc._get_access_token()`. Assert returns `"tok123"` and `svc._access_token == "tok123"` and `svc._token_expires_at` is not None.

      2. `test_token_refresh_when_expired`: Create service, set `_access_token = "old"` and `_token_expires_at = datetime(2000, 1, 1, tzinfo=timezone.utc)` (already expired). Add mock token response returning `"new_tok"`. Call `_get_access_token()`. Assert returns `"new_tok"`.

      3. `test_create_order_returns_approval_url`: Mock `POST .../v1/oauth2/token` and `POST .../v2/checkout/orders` returning a PayPal-shaped response with `links` array containing `{"href": "https://paypal.com/approve", "rel": "approve"}`. Call `await svc.create_order("purchase-abc", 49.99, "USD")`. Assert `result.approval_url == "https://paypal.com/approve"` and `result.order_id` equals the mocked order id.

      4. `test_capture_checks_approved_first`: Mock GET `...orders/{id}` returning `{"id": "ORDER1", "status": "CREATED"}`. Call `await svc.capture_order("ORDER1")`. Assert `PayPalOrderNotApprovedError` is raised.

      5. `test_capture_succeeds_on_approved`: Mock GET returning `{"id": "ORDER1", "status": "APPROVED"}`. Mock POST `.../capture` returning a completed capture response with `purchase_units[0].payments.captures[0]` having `id`, `amount.value`, `amount.currency_code`. Assert `result.verified == True` and `result.capture_id` is set.

      6. `test_duplicate_capture_handled`: Mock POST `.../capture` returning 422 with `{"details": [{"issue": "ORDER_ALREADY_CAPTURED"}]}`. Also mock GET returning APPROVED status. Assert `PayPalDuplicateCaptureError` is raised (the router handles it as idempotent).

      7. `test_invalid_amount_raises`: Call `await svc.create_order("purchase-abc", 0, "USD")`. Assert `ValueError` is raised. No HTTP calls should be made (no mock needed; if httpx tries to call real network it will fail differently, but the validation runs before any HTTP).

      8. `test_mock_mode_no_http_calls`: Create `PayPalService("", "")`. Call `await svc.create_order("purchase-xyz", 10.00, "USD")`. Assert result is a `PayPalOrderResult` with `order_id` containing `"MOCK"`. Assert `httpx_mock` received zero requests (verify with `httpx_mock.get_requests()` returns empty list).

      Files: `tests/test_paypal_service.py`  
      Verify: `python3 -m pytest tests/test_paypal_service.py -v` — all 8 new tests pass.

- [ ] 7. Create `tests/test_checkout_router.py` with 3 integration tests via the FastAPI test client.

      Use the existing `async_client` fixture from `conftest.py` and the existing in-memory SQLite DB. The PayPal service is running in mock mode (empty `PAYPAL_CLIENT_ID` default in `settings`) so no HTTP mocks are needed for these router tests.

      Helper: add a `create_product_fixture` async helper (or `@pytest.fixture`) that inserts a `ShoppingSession` + `ProductResult` into the DB and returns their IDs. Follow the same DB setup pattern as `test_shopping.py` — the `setup_db` autouse fixture handles table creation/teardown.

      **Tests to implement**:

      1. `test_create_order_validates_product_exists`: POST `/api/v1/checkout/create` with `{"product_result_id": "nonexistent-uuid"}`. Assert `response.status_code == 404`.

      2. `test_capture_idempotent_when_already_captured`: Create a product fixture, call create order, call capture once (assert 200), call capture again with the same payload. Assert second response is also 200 and both responses have the same `transaction_id`.

      3. `test_capture_updates_purchase_status`: Create product fixture, call create order, call capture. Then query the DB directly via `TestSessionLocal` to load the `PurchaseRecord` and assert `purchase.status == 'captured'`.

      Files: `tests/test_checkout_router.py`  
      Verify: `python3 -m pytest tests/test_checkout_router.py -v` — all 3 new tests pass.

- [ ] 8. Final full-suite verification.
      Run the complete test suite and confirm the baseline tests still pass alongside the new ones.  
      Files: none  
      Verify: `python3 -m pytest tests/ -v` — all tests pass (15 original + 8 service + 3 router = 26 total).

---

## Security checklist (implementer must verify each)

- [ ] `_client_secret` is never passed to `logger.*` calls anywhere in `paypal_service.py`
- [ ] `raw_capture_json` is stored in `Transaction.raw_capture_json` only; never included in any response schema or returned from any endpoint
- [ ] All PayPal amounts sent to PayPal come from `product.price` read from DB, not from any client-supplied field
- [ ] `verify_order` (GET the order) is always called before treating a return URL as proof of payment — this is enforced by `capture_order` calling `verify_order` first

## Known gaps / assumptions

- **`PayPalDuplicateCaptureError` in router (step 5g)**: The spec says "handle as idempotent — no exception raised". The service raises `PayPalDuplicateCaptureError`; the router catches it and returns the existing Transaction. This is the cleanest separation of concerns: service reports what happened, router decides what to do with it.
- **`session_id` for idempotency check (step 5d)**: The `PurchaseRecord` stores `session_id` which comes from `product.session_id`. The idempotency query uses both `product_result_id` and `session_id` to scope it correctly to the same buyer session.
- **`raw_capture_json` content**: Stored as a dict with `capture_id`, `status`, `amount`, `currency` — not the full PayPal response object. This satisfies the "never return to client" rule while still preserving audit data. The full PayPal response is only in memory during the request and is not persisted verbatim.
