# ProofBuy AI — Project Checklist

Last updated: 2026-10-14

## Phase 1 — Research and Feasibility ✅
- [x] Hackathon rules and deadlines verified → docs/hackathon-requirements.md
- [x] Channel3 API documented → docs/technical-feasibility.md
- [x] PayPal Orders v2 API documented → docs/technical-feasibility.md
- [x] OpenAI structured output documented → docs/technical-feasibility.md
- [x] Architecture proposal → docs/architecture.md
- [x] API contracts → docs/api-contracts.md
- [x] Technical feasibility report → docs/technical-feasibility.md

## Phase 2 — Backend Foundation ✅
- [x] FastAPI application running
- [x] Configuration management (pydantic-settings)
- [x] Database models (ShoppingSession, ProductResult, PurchaseRecord, Transaction)
- [x] Database migrations (Alembic)
- [x] API schemas (Pydantic v2)
- [x] Error handling (global exception handlers)
- [x] Structured logging
- [x] Health check endpoint
- [x] Test framework (pytest-asyncio, aiosqlite in-memory)
- [x] 15 initial tests passing

## Phase 3 — Real Product Retrieval ✅
- [x] Channel3 service class (httpx-based)
- [x] Product normalization (NormalizedProduct schema)
- [x] Mock mode (clearly labeled, no real HTTP calls)
- [x] Custom exceptions (Channel3AuthError, RateLimitError, ServiceError)
- [x] UNKNOWN-not-PASS invariant (missing attrs stay None)
- [x] Products router updated to call real service
- [x] 7 Channel3 tests passing (1 skipped — needs real API key)

## Phase 4 — AI Shopping Engine ✅
- [x] ShoppingRequirements Pydantic schema
- [x] AIService (GPT-4o structured output, mock mode)
- [x] Budget guard (model cannot exceed stated budget)
- [x] Refusal and invalid output handling
- [x] ConstraintEngine (PASS/FAIL/UNKNOWN, 100% deterministic)
- [x] Product ranking (zero FAILs first, confidence score)
- [x] Evidence-backed explanations (top 3)
- [x] Evaluation dataset — 20 test cases → docs/ai-evaluation.md
- [x] 35 AI + constraint engine tests passing

## Phase 5 — PayPal Integration ✅
- [x] OAuth2 token caching with expiry
- [x] Create order (POST /v2/checkout/orders)
- [x] Approval URL extraction from HATEOAS links
- [x] Capture order (POST /v2/checkout/orders/{id}/capture)
- [x] Server-side status verification
- [x] Mock mode (no HTTP calls when no credentials)
- [x] Idempotency (no duplicate captures)
- [x] Amount sourced from DB (never from client request)
- [x] get_approval_url() uses correct sandbox vs live hostname
- [x] Audit trail in raw_capture_json (capture_id, status, amount, currency)
- [x] 11 PayPal tests passing

## Phase 6 — Flutter Mobile Application ✅
- [x] Flutter project created (com.proofbuy.proofbuy_ai)
- [x] Riverpod state management
- [x] GoRouter navigation
- [x] Dio HTTP client with error interceptor
- [x] AppConfig (BACKEND_URL via --dart-define, no hardcoded localhost)
- [x] 11 screens implemented:
  - [x] OnboardingScreen
  - [x] ShoppingBriefScreen
  - [x] ProductSearchScreen (loading + requirements review)
  - [x] ProductComparisonScreen (ranked cards + constraint badges)
  - [x] ProductDetailsScreen (evidence section)
  - [x] PurchaseReviewScreen (UNKNOWN warning banner)
  - [x] CheckoutScreen (url_launcher + manual confirmation)
  - [x] CheckoutReturnScreen
  - [x] TransactionResultScreen
  - [x] TransactionHistoryScreen
  - [x] SettingsScreen
- [x] All screens handle: initial, loading, success, empty, error states
- [x] Freezed models (ShoppingSession, RankedProduct, PurchaseRecord, Transaction)
- [x] Repository layer (Shopping, Products, Checkout, Transactions)
- [x] Android deep link configuration (proofbuy://)
- [x] flutter analyze: 0 issues
- [x] flutter test: 18/18 passing
- [x] flutter build apk --debug: 192MB APK produced
- [x] verified=true gate enforced in CheckoutNotifier

## Phase 7 — Integration and Hardening ✅
- [x] End-to-end smoke test (full workflow in 1 test: brief→products→checkout→capture→verify→history)
- [x] SQLAlchemy UUID generation fixed (eager __init__ rather than deferred default=)
- [x] ProductResultResponse.currency made Optional (matches nullable DB column)
- [x] PayPal idempotent re-create uses correct approval URL hostname (get_approval_url())
- [x] Dead PayPalDuplicateCaptureError catch removed from checkout router
- [x] raw_capture_json stores audit data (not None)
- [x] Security review complete → docs/security.md
- [x] Known limitations documented → docs/known-limitations.md
- [x] Product requirements documented → docs/product-requirements.md
- [x] 77 backend tests passing (1 skipped — live Channel3)
- [x] 18 Flutter tests passing

## Phase 8 — Documentation and Repository ✅
- [x] README.md (comprehensive, covers all 15 required sections)
- [x] LICENSE (MIT)
- [x] .env.example (root level, all variables with placeholders)
- [x] .gitignore (Python, Flutter, macOS, secrets)
- [x] docs/architecture.md ✅
- [x] docs/hackathon-requirements.md ✅
- [x] docs/technical-feasibility.md ✅
- [x] docs/api-contracts.md ✅
- [x] docs/ai-evaluation.md ✅
- [x] docs/security.md ✅
- [x] docs/product-requirements.md ✅
- [x] docs/known-limitations.md ✅
- [x] docs/deployment.md ✅
- [ ] Git repository initialized and committed
- [ ] Repository pushed to GitHub (public)
- [ ] Backend deployed to Render
- [ ] Demo video recorded (max 3 minutes)
- [ ] Hackathon submission on Devpost

## Definition of Done Checklist

### Product
- [x] Accepts natural-language shopping requests
- [x] Requirements converted to validated structured data
- [x] User can review requirements
- [x] Product data from documented source (Channel3)
- [x] Deterministic constraint validation
- [x] Unknown attributes clearly identified (UNKNOWN badge)
- [x] Recommendations explain supporting evidence
- [x] User can review purchase before checkout
- [x] Payment outcome verified server-side
- [x] User can inspect transaction records

### Engineering
- [x] Backend structured and documented
- [x] Flutter application uses maintainable architecture (Riverpod + GoRouter + repository pattern)
- [x] Database migrations work (Alembic)
- [x] Secrets not committed (.env.example only)
- [x] Errors handled gracefully (all screens have error state)
- [x] Tests cover critical business rules (constraint engine, payment verification)
- [x] Tests cover transaction integrity (e2e smoke test)
- [x] Android application builds successfully (192MB debug APK)
- [ ] Deployed application reproducible (pending deployment)

### AI
- [x] AI performs genuine requirement extraction (mock + real mode)
- [x] Structured outputs validated (Pydantic schema)
- [x] Model cannot override hard constraints (ConstraintEngine is deterministic)
- [x] Product claims grounded in retrieved evidence
- [x] Prompt injection tested (20 eval cases in ai-evaluation.md)
- [x] Evaluation dataset exists (docs/ai-evaluation.md)
- [ ] Actual evaluation results documented (requires real API key)

### PayPal
- [x] Sandbox order creation works (mock verified; real requires credentials)
- [x] Buyer approval flow implemented (url_launcher)
- [x] Capture implemented with idempotency
- [x] Transaction status verified server-side
- [x] Duplicate requests handled safely
- [x] Cancellation and failure states handled
- [x] No false-success state shown
- [x] Sandbox vs live distinction clear (PAYPAL_ENVIRONMENT)

### Submission
- [x] Official requirements verified (docs/hackathon-requirements.md)
- [ ] Repository public and licensed ← needs GitHub push
- [x] Setup documentation complete (docs/deployment.md + README.md)
- [ ] Demonstration functional (needs deployment)
- [ ] Screenshots ready
- [ ] Demo video (< 3 minutes)
- [ ] Submission before November 12, 2026 12:00 PM Pacific
