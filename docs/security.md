# Security — ProofBuy AI

## Overview

Security is treated as a core product requirement, not an afterthought. This document describes the security model, what was verified, and known limitations.

---

## Secrets Management

**What lives in environment variables (never in code):**
- `PAYPAL_CLIENT_ID` and `PAYPAL_CLIENT_SECRET` — backend only
- `AI_PROVIDER_API_KEY` — backend only
- `CHANNEL3_API_KEY` — backend only
- `DATABASE_URL` — backend only

**What is committed:**
- `.env.example` with placeholder values only
- No real credentials are stored in the repository

**Verification:** `grep -r "sk-" backend/ mobile/` and `grep -r "client_secret" mobile/` return no matches. The Flutter source contains no API keys.

---

## PayPal Security Model

### Server-side only
All PayPal API calls (`/v1/oauth2/token`, `/v2/checkout/orders`, capture, verify) execute on the backend. The Flutter app never calls PayPal directly.

### Amount sourced from database
The checkout router loads `product.price` and `product.currency` from the `ProductResult` row in the database. The client request body contains only `product_result_id` — the amount used for the PayPal order is never sourced from the client.

```python
# checkout.py — amount always from DB
amount=float(product.price)   # product loaded from DB by product_result_id
currency=product.currency
```

### Verified-before-success gate
The Flutter `CheckoutNotifier` only transitions to `CheckoutSuccess` when the backend returns `verified: true`. The backend only sets `verified: true` after:
1. Calling `GET /v2/checkout/orders/{id}` to confirm status is `APPROVED`
2. Calling `POST /v2/checkout/orders/{id}/capture`
3. Confirming the capture response has `status: COMPLETED`

A PayPal return URL alone never triggers success.

### Audit trail
Each `Transaction` record stores `raw_capture_json` containing `{capture_id, status, amount, currency}` — sufficient for dispute resolution without storing the full PayPal response body.

### Token security
- `PAYPAL_CLIENT_SECRET` is never logged (verified: no `logger.*secret*` calls exist)
- OAuth2 token cached in-memory with expiry buffer (60s before actual expiry)
- Token never returned to the Flutter client

---

## AI Security

### Output treated as untrusted
All GPT-4o responses are validated against a Pydantic `ShoppingRequirements` schema before use. Invalid or malformed model output raises `AIInvalidOutputError` (502) rather than crashing or using bad data.

### Budget guard
After extracting requirements, the service verifies that `budget_max` does not exceed the value stated in the brief text. If the model returns a higher value, it is capped.

### Prompt injection mitigations
Product names and descriptions from Channel3 are passed as user-facing data in the chat message content, not injected into the system prompt. The system prompt is static and constructed in code.

```python
# ai_service.py — product content is data, not instructions
messages = [
    {"role": "system", "content": SYSTEM_PROMPT},  # static, no product data
    {"role": "user", "content": f"Shopping brief: {brief_text}"},  # user input only
]
```

### No unrestricted DB access
The AI service has no database access. It receives a text brief and returns a structured schema. It cannot read or write purchase records, transactions, or product data.

### Request limits
- OpenAI calls have a 30-second timeout
- Channel3 calls have a 30-second timeout
- No per-user rate limiting is implemented (see Known Limitations)

---

## Flutter Security

### No secrets in client code
The Flutter app contains no API keys, PayPal credentials, or backend secrets. `AppConfig.backendUrl` is set via `--dart-define=BACKEND_URL=...` at build time.

### Checkout flow
PayPal checkout uses `url_launcher` to open the approval URL in the system browser. The app never renders PayPal content in a WebView embedded in its own process. This means PayPal credentials and session data are handled by the browser's security context, not the app.

### No hardcoded endpoints
Verified: `grep -r "localhost\|127.0.0.1" mobile/lib/` returns no matches. The default `http://10.0.2.2:8000` is only the Android emulator's alias for the host machine and is appropriate for local development.

---

## Known Security Limitations

| Limitation | Impact | Mitigation |
|---|---|---|
| No user authentication | Any user who knows a session UUID can retrieve its products | Acceptable for hackathon prototype; production would require JWT auth |
| No per-endpoint rate limiting | Backend vulnerable to brute-force / DoS | Add slowapi or similar before production deployment |
| No PayPal webhook verification | Cannot receive server-push payment updates | Polling-based verification used instead; webhooks would improve reliability |
| No CSRF protection | Stateless API is not vulnerable to CSRF in its current form | Relevant if cookie-based auth is added |
| SQLite in development | In-memory SQLite used for tests; production uses PostgreSQL | Development-only limitation |
| Deep link return unverified on device | `proofbuy://checkout/return` not adb-tested | Requires physical device or emulator testing |
| No input sanitization beyond Pydantic | Pydantic rejects type violations but does not sanitize string content | Acceptable for prototype; add explicit sanitization for production |

---

## Security Checklist (verified)

- [x] No API keys in Flutter source
- [x] No PayPal client_secret in Flutter source  
- [x] PayPal amount from DB, not client request
- [x] `verified: true` required before payment success
- [x] `raw_capture_json` not returned to client (DB only)
- [x] AI output validated via Pydantic before use
- [x] Product data not injected into system prompt
- [x] All external HTTP calls have timeouts
- [x] No secrets in `.env.example` (placeholders only)
- [x] No secrets in git history (new project, no accidental commits)
- [ ] User authentication (not implemented)
- [ ] Rate limiting (not implemented)
- [ ] PayPal webhook verification (not implemented)
