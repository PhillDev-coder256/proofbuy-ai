# Known Limitations — ProofBuy AI

This document honestly records what is not implemented, not tested, or not verified. It is not an exhaustive list of all possible improvements — only limitations that affect the core product claims or demo experience.

---

## Integration Limitations

### Channel3 live API — not verified
The Channel3 service runs in mock mode when `CHANNEL3_API_KEY` is not set. Mock mode returns three realistic laptop products from a hardcoded list. The mock response shape mirrors the documented Channel3 API format, but the live API has not been called. To enable real product retrieval, set `CHANNEL3_API_KEY` in the backend environment variables.

**Impact:** Product comparison screen shows mock data, not real products from Channel3's 100M+ catalog.

### OpenAI live calls — not verified
The AI service runs in mock mode when `AI_PROVIDER_API_KEY` is not set. Mock mode returns a hardcoded `ShoppingRequirements` object. The OpenAI GPT-4o structured output call has not been made against the live API. To enable real AI extraction, set `AI_PROVIDER_API_KEY`.

**Impact:** Requirement extraction always returns the same mock result regardless of what the user types.

### PayPal live mode — sandbox only
The PayPal integration is tested against mock responses (no actual sandbox calls made in automated tests). Live sandbox testing requires real `PAYPAL_CLIENT_ID` and `PAYPAL_CLIENT_SECRET` from a PayPal Developer account. The production (`live`) environment has not been tested.

**Impact:** Real sandbox checkout flow not verified end-to-end.

---

## Mobile Limitations

### Deep link return from PayPal — unverified on device
The Android manifest includes an intent filter for `proofbuy://checkout/return` and `proofbuy://checkout/cancel`. This has not been tested on a physical device or emulator with `adb shell am start`. The fallback "I've completed payment" button in `CheckoutScreen` works regardless of deep link support.

**Impact:** Auto-return after PayPal approval may not trigger; user must tap the manual confirmation button.

### iOS build — not verified
The Flutter project was created with iOS support but the iOS build (`flutter build ipa`) has not been executed. iOS simulator testing has not been performed. The Android build (`flutter build apk --debug`) produces a valid 192MB APK.

**Impact:** iOS experience unverified. Android is the primary target.

### No persistent login / user identity
There is no authentication system. Each session is identified by a UUID. If a user clears app storage or reinstalls, their history is not recoverable. There is no concept of "logged in user."

**Impact:** History screen shows all purchases for the current device session only.

---

## Backend Limitations

### No rate limiting
The backend has no per-IP or per-user rate limiting. Any caller can make unlimited requests to all endpoints.

**Impact:** Not suitable for public deployment without adding rate limiting (e.g., slowapi).

### No PayPal webhook verification
PayPal payment status is verified by polling (`GET /v2/checkout/orders/{id}`) at capture time. PayPal webhooks are not implemented — the backend cannot receive asynchronous payment status updates.

**Impact:** If a payment completes asynchronously after a timeout, the status may not update automatically.

### SQLite in development / tests
The backend uses SQLite + aiosqlite for development and all automated tests. Production deployments use PostgreSQL via `DATABASE_URL`. Alembic migrations are written for PostgreSQL and may need review for SQLite-specific dialect differences.

**Impact:** Development experience diverges slightly from production.

### Alembic migrations not auto-run
The deployed backend requires manual migration execution (`alembic upgrade head`) after each deployment. There is no automatic migration step in the deployment configuration.

### PurchaseRecord.currency not nullable
`PurchaseRecord.currency` defaults to "USD" and is not nullable. If a product is purchased with a `null` currency (data_complete=False), the checkout router would fail validation before creating the PayPal order. This is intentional (you cannot checkout without a currency) but means some products cannot be purchased.

---

## Demo Day Risks

### Render free tier spin-down
The Render free tier spins down after 15 minutes of inactivity. The first request after spin-down takes ~30 seconds to respond. For live demo, upgrade to Render Starter ($7/month) or set up a keep-alive ping.

### Mock data is static
In mock mode, the same three products appear for every search query. The demo will be more compelling with real Channel3 and OpenAI API keys configured.

### No error recovery UI for network timeout
If the backend is slow (Render spin-up), the Flutter loading screens have a 30-second timeout after which they show an error. The retry button works correctly.

---

## Not Implemented (out of scope for hackathon)

- User authentication and account management
- Price history charts (Channel3 price tracking API)
- Push notifications for price drops
- Multiple currency support in checkout (all purchases denominated in the product's listed currency)
- AG Grid web dashboard (investigated; would require a separate web frontend)
- APIMatic Context Plugin (investigated; designed for AI-assisted coding tools, not runtime integration)
- Bryntum scheduler integration (no applicable use case identified)
- Elastic search integration (Channel3 handles search)
- Full PCI compliance (not applicable to a prototype using PayPal-hosted checkout)
