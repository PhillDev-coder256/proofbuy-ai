# PayPal Orders v2 Integration for ProofBuy AI

The change wires a PayPal Orders v2 flow into the ProofBuy checkout path: a `/create` endpoint that fetches price from the DB and opens a PayPal order, and a `/capture` endpoint that verifies approval before capturing and writes a `Transaction` record. Amount always comes from `ProductResult.price`, never from the client request body. The service runs in mock mode when `PAYPAL_CLIENT_ID` is empty, making no HTTP calls. Token caching and expiry are implemented on `_get_access_token`.

Watch for: **(confirmed)** The router's `except PayPalDuplicateCaptureError` branch is dead code — the service never raises it. **(confirmed)** The idempotent re-create path in the router hard-codes the sandbox approval URL regardless of the configured environment. **(confirmed)** `raw_capture_json` is stored as `None` on every transaction, discarding audit data the plan called for. **(possible)** The router's `PayPalDuplicateCaptureError` dead branch means a `PayPalDuplicateCaptureError` raised by a future version of the service would not be caught and would propagate as an unhandled exception.

**Verdict**: NEEDS_CHANGES

---

## High-level view

The core security invariants hold: price comes from `ProductResult.price`, the service GETs order status before POSTing capture, and `raw_capture_json` is never returned to the client. Token caching uses a proper expiry window with a 60-second buffer against clock skew. Mock mode is gated on an empty `client_id` and skips all HTTP calls. These are the structurally critical properties and they are all correctly implemented.

The duplicate-capture path has a mismatch between the service and router. The service handles `ORDER_ALREADY_CAPTURED` internally by calling `verify_order` and returning a successful `PayPalCaptureResult` — it never raises `PayPalDuplicateCaptureError`. The router has a handler for that exception that is unreachable. The net effect is that duplicate captures work correctly today (handled in the service), but the router's dead branch is misleading and could cause confusion when extending this code.

The idempotent re-create path reconstructs the approval URL by hard-coding the sandbox hostname, so production deployments would redirect buyers to a sandbox URL. This is a behavioral bug that affects real transactions in production mode.

`raw_capture_json` is `None` on every transaction record. The plan specified storing a minimal dict of capture metadata for audit purposes; the actual code stores nothing. This is not a security concern, but it is a deviation from the spec that removes the audit trail.

---

<details>
<summary>Issues (4)</summary>

1. **Dead `PayPalDuplicateCaptureError` catch in router** — `paypal_service.capture_order` never raises `PayPalDuplicateCaptureError`; it handles duplicates internally and returns a `PayPalCaptureResult`. The `except PayPalDuplicateCaptureError` block in `checkout.py` is unreachable. Either move the duplicate-raise logic into the service (raise the exception instead of silently recovering) or remove the dead handler from the router. The current split means the router's stated contract is a lie.

2. **Hard-coded sandbox approval URL in idempotent re-create path** — When an existing `PurchaseRecord` is found with a non-null `paypal_order_id`, the router returns `https://www.sandbox.paypal.com/checkoutnow?token=...` unconditionally. In a production environment (`paypal_environment = "live"`), this sends the buyer to the sandbox. Store the approval URL on `PurchaseRecord` and return it directly, or reconstruct it using the configured base URL.

3. **`raw_capture_json` always `None`** — The spec required storing a minimal capture audit record (`capture_id`, `status`, `amount`, `currency`) in `raw_capture_json`. Both transaction creation branches (`verified` and `!verified`) set `raw_capture_json=None`, discarding all audit data. Populate it from `capture_result`.

4. **No test for the production URL path or the idempotent create response** — The router tests exercise the happy path with mock mode, which always returns sandbox-like values. There is no test asserting that the idempotent re-create branch returns the stored `paypal_order_id` without calling PayPal again. This means the hard-coded sandbox URL bug (issue 2) is invisible to the test suite.

</details>

---

<details>
<summary>Details</summary>

### Dead `PayPalDuplicateCaptureError` handler in the router

The service imports `PayPalDuplicateCaptureError` but never raises it. When the capture POST returns a 422 with `ORDER_ALREADY_CAPTURED` or `ORDER_ALREADY_COMPLETED`, `capture_order` calls `verify_order` internally and returns a `PayPalCaptureResult` with `verified=True`. The exception is fully suppressed at the service layer. The router's `except PayPalDuplicateCaptureError` block:

```python
except PayPalDuplicateCaptureError:
    purchase.status = "captured"
    ...
    if transaction:
        return CheckoutCaptureResponse(...)
    raise  # <-- re-raises PayPalDuplicateCaptureError if no Transaction exists
```

is never entered. More importantly, the `raise` at the end of that block would propagate a 409 to the client if a transaction record were somehow absent — but the code path to get there no longer exists. The plan's intended split was: service raises, router catches and returns existing transaction. The implementation chose: service recovers silently, router has orphaned handler. Either approach is defensible; having both simultaneously is not.

### Hard-coded sandbox URL on idempotent re-create

In the `/create` endpoint, when a non-failed `PurchaseRecord` already exists:

```python
return CheckoutCreateResponse(
    order_id=existing_purchase.paypal_order_id,
    approval_url=(
        f"https://www.sandbox.paypal.com/checkoutnow?token={existing_purchase.paypal_order_id}"
    ),
    purchase_id=str(existing_purchase.id),
)
```

The approval URL is reconstructed from the token instead of being returned from storage. For sandbox this happens to work. For live, the buyer receives a sandbox URL and the checkout fails silently from the user's perspective. `PurchaseRecord` needs an `approval_url` column, or the service's configured `_base_url` needs to be threaded through to the router, or the URL needs to be derived from `paypal_service._base_url` at response time.

### `raw_capture_json` audit gap

The `Transaction` model has a `raw_capture_json` column. Both branches in the capture handler set it to `None`:

```python
transaction = Transaction(
    ...
    raw_capture_json=None,
)
```

The plan specified storing `{"capture_id": ..., "status": ..., "amount": ..., "currency": ...}` from the `PayPalCaptureResult`. This is not a security violation (the full PayPal response body is never stored), but it means there is no audit trail in the DB linking a transaction back to the capture amount and currency PayPal actually confirmed. For dispute resolution this data is valuable.


</details>

---

<details>
<summary>File map</summary>

| File | What changed |
|---|---|
| `app/core/exceptions.py` | Added `PayPalAuthError`, `PayPalOrderNotApprovedError`, `PayPalInstrumentDeclinedError`, `PayPalDuplicateCaptureError`, `PayPalServiceError` exception classes |
| `app/services/paypal_service.py` | New `PayPalService` with `_get_access_token`, `create_order`, `capture_order`, `verify_order`; result models `PayPalOrderResult`, `PayPalCaptureResult`, `PayPalOrderStatus`; `get_paypal_service` factory |
| `app/routers/checkout.py` | New `/create` and `/capture` endpoints wired to `PayPalService`; DB-sourced amount; idempotency checks; transaction record creation |
| `tests/test_paypal_service.py` | 8 unit tests covering token fetch/refresh, order creation, capture gating, duplicate handling, mock mode, input validation |
| `tests/test_checkout_router.py` | 3 integration tests covering 404 on unknown product, capture idempotency, purchase status update |

Full diff: `git diff main -- backend/app/services/paypal_service.py backend/app/core/exceptions.py backend/app/routers/checkout.py backend/tests/`

</details>
