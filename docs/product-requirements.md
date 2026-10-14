# Product Requirements — ProofBuy AI

## Core User Story

> As a shopper, I want to describe what I need in plain language and receive evidence-backed product recommendations I can trust and buy securely with PayPal.

---

## Problem Statement

Online shopping requires visiting multiple websites, comparing specifications manually, and trusting merchant descriptions that may be incomplete, stale, or misleading. Budget constraints and mandatory requirements (minimum RAM, maximum weight) are not automatically enforced. Payment requires navigating to a separate checkout flow with no connection to the research that preceded it.

ProofBuy AI addresses this by:
1. Extracting structured requirements from natural language
2. Retrieving real product data from a verified source (Channel3)
3. Deterministically evaluating each product against hard constraints
4. Marking unknown attributes explicitly rather than assuming compliance
5. Presenting evidence-backed recommendations with a connected PayPal checkout

---

## Feature List

### F1: Natural Language Shopping Brief
**Status:** Implemented (mock AI mode when no OpenAI key)
- User enters a plain-language description of what they need
- Minimum 10 characters, maximum 500
- Backend AI service extracts structured requirements
- User can review extracted requirements before searching

**Acceptance criteria:**
- Brief submitted via POST /api/v1/shopping/brief returns a session_id
- Session contains `requirements_json` with `product_category`, `hard_constraints`, `soft_preferences`, `budget_max`, `search_query`
- Ambiguous briefs populate `clarification_needed`

---

### F2: Requirement Extraction
**Status:** Implemented (GPT-4o structured output; mock mode when no API key)
- Extracts: product category, hard constraints, soft preferences, budget, use case
- Validates output against Pydantic schema — rejects malformed model output
- Budget guard: model cannot return budget_max higher than what user stated
- Prompt injection test cases documented in docs/ai-evaluation.md

**Acceptance criteria:**
- `ShoppingRequirements` schema validation passes for all valid briefs
- Contradictory constraints both appear in `hard_constraints` (not silently dropped)
- Malformed model output raises `AIInvalidOutputError`

---

### F3: Real Product Retrieval (Channel3)
**Status:** Implemented (mock mode when no CHANNEL3_API_KEY)
- Searches Channel3 using `requirements.search_query`
- Normalizes response to `NormalizedProduct` schema
- Missing fields set to `None` — never defaulted to passing values
- `data_complete: false` products skipped before DB insert

**Acceptance criteria:**
- Products with no price are not persisted to DB and do not appear in results
- `currency=None` is stored as null (not "USD") when absent from Channel3 response
- 401/429/5xx from Channel3 raise typed exceptions

---

### F4: Deterministic Constraint Validation
**Status:** Implemented (100% deterministic — no AI involved)
- Each product attribute evaluated against each hard constraint
- Result: `PASS` | `FAIL` | `UNKNOWN`
- `UNKNOWN` when attribute is absent from product data — never treated as PASS
- Products ranked: zero FAILs first, then by PASS count, then by price

**Acceptance criteria (verified by test_constraint_engine.py):**
- Missing spec attribute → `UNKNOWN` (21 tests cover this)
- `None` spec value → `UNKNOWN`
- Products with FAILs rank below products with zero FAILs
- `ranking_confidence` reduced by proportion of UNKNOWN attributes

---

### F5: Evidence-Backed Product Comparison
**Status:** Implemented
- Ranked product list with constraint badges (PASS/FAIL/UNKNOWN) per attribute
- AI-generated explanation for top 3 products (mock mode: template explanation)
- Product details screen shows full spec table with source attribution
- UNKNOWN attributes displayed with ⚠ badge, not hidden

**Acceptance criteria:**
- Each product card shows at least one constraint badge
- UNKNOWN attributes are visually distinct from PASS attributes
- Explanation text is present for top 3 products

---

### F6: Purchase Review
**Status:** Implemented
- User reviews product, price, currency, and all constraint results before checkout
- UNKNOWN attributes shown in a warning banner: "The following could not be verified"
- User must explicitly confirm before checkout initiates

**Acceptance criteria:**
- Purchase review screen shows all hard constraint results
- UNKNOWN banner appears when any attribute is UNKNOWN
- "Confirm" button leads to checkout; "Cancel" returns to comparison

---

### F7: PayPal Checkout
**Status:** Implemented (mock mode; sandbox requires real credentials)
- Backend creates PayPal order via Orders v2 API
- Amount sourced from DB (never from client request)
- Approval URL opened via url_launcher (system browser)
- User taps "I've completed payment" to trigger capture
- Backend verifies COMPLETED server-side before returning verified=true
- Flutter only shows success after backend verified=true

**Acceptance criteria:**
- POST /api/v1/checkout/create returns order_id + approval_url
- POST /api/v1/checkout/capture returns verified=true only on COMPLETED
- A return URL alone never triggers success state in Flutter
- Duplicate capture attempts handled gracefully

---

### F8: Transaction History
**Status:** Implemented
- Past purchases shown with status (pending/captured/failed/cancelled)
- Tap to view transaction details

**Acceptance criteria:**
- History screen lists all PurchaseRecord entries
- Each entry shows product name, price, and status
- Empty state shown when no history exists

---

## Non-Functional Requirements

### Performance
- Backend endpoints respond within 5 seconds under mock mode
- Channel3 and OpenAI calls have 30-second timeouts
- Flutter loading screens shown immediately on async operations

### Security
- No API keys in Flutter source
- PayPal amount validated server-side
- AI output validated against schema before use
- Full details in docs/security.md

### Accessibility
- Minimum touch target: 48×48dp on all interactive elements
- Semantic labels on all images and icons
- Text contrast ratio ≥ 4.5:1 (light and dark mode)
- Screen reader support via Flutter Semantics widgets

### Reliability
- All screens handle: initial, loading, success, empty, error, network-failure states
- Retry buttons on all error states
- Mock mode ensures app is demonstrable without API keys

### Testability
- Backend: 77 tests (unit + integration + e2e), 1 skipped (live Channel3)
- Flutter: 18 tests (widget + repository)
- All critical business rules (constraint validation, payment verification) have dedicated tests
