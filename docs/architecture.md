# Architecture — ProofBuy AI

## PayPal AI Hackathon 2026

---

## Concept

ProofBuy AI is an agentic mobile commerce tool that:
1. Accepts a natural-language shopping brief from the user ("I need a laptop under $1000 with 16GB RAM and an SSD")
2. Extracts validated structured requirements using GPT-4o structured outputs
3. Searches Channel3 for real matching products (100M+ products)
4. Runs deterministic constraint validation — PASS / FAIL / UNKNOWN per attribute
5. Presents evidence-backed ranked recommendations
6. Enables buyer-controlled PayPal sandbox checkout with server-side transaction verification

---

## System Overview

```
┌────────────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App (iOS / Android)             │
│                                                                    │
│  ┌─────────────┐  ┌────────────────┐  ┌────────────────────────┐  │
│  │ Shopping    │  │ Product        │  │ PayPal Checkout        │  │
│  │ Brief Input │  │ Comparison     │  │ (url_launcher popup)   │  │
│  │             │  │ + Evidence     │  │                        │  │
│  └──────┬──────┘  └───────┬────────┘  └────────────┬───────────┘  │
└─────────┼─────────────────┼───────────────────────-┼──────────────┘
          │                 │                         │
          │ Dio HTTP        │                         │
          ▼                 ▼                         ▼
┌────────────────────────────────────────────────────────────────────┐
│                  FastAPI Backend (Python 3.11+)                     │
│                       Deployed on Render                           │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │  AI Service      │  │  Channel3 Service │  │  PayPal Service  │ │
│  │  (GPT-4o)        │  │  (Product Search) │  │  (Orders v2)     │ │
│  │  Req Extraction  │  │  Normalization    │  │  Create/Capture  │ │
│  │  Constraint Eng. │  │  Freshness Track  │  │  Verify Status   │ │
│  └────────┬─────────┘  └─────────┬────────┘  └────────┬─────────┘ │
│           │                      │                    │            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              PostgreSQL (Render / SQLAlchemy 2.x)          │    │
│  │  ShoppingSession · ProductResult · PurchaseRecord ·        │    │
│  │  Transaction                                               │    │
│  └────────────────────────────────────────────────────────────┘    │
└──────────┬───────────────────────┬────────────────────┬────────────┘
           │                       │                    │
           ▼                       ▼                    ▼
   ┌───────────────┐   ┌─────────────────┐   ┌────────────────┐
   │  OpenAI API   │   │  Channel3 API   │   │  PayPal API    │
   │  GPT-4o       │   │  /v1/search     │   │  Orders v2     │
   │  Structured   │   │  trychannel3.com│   │  Sandbox/Live  │
   │  Output       │   │  Free: 1K/mo    │   │                │
   └───────────────┘   └─────────────────┘   └────────────────┘
```

---

## Technology Stack

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| Mobile | Flutter | 3.x | Cross-platform iOS/Android, single codebase |
| Mobile state | Riverpod | ^2.6.1 | DI + reactive state, well-tested |
| Mobile navigation | GoRouter | ^14.0.0 | Declarative routing, deep links |
| Mobile HTTP | Dio | ^5.7.0 | Interceptors, timeout, retry |
| Mobile models | Freezed + JSON | ^2.5.7 | Immutable models, serialization |
| Backend | FastAPI | 0.115.5 | Async, Pydantic v2 native, auto OpenAPI |
| Backend ORM | SQLAlchemy 2.x async | 2.0.36 | Async-native, Alembic migrations |
| Backend DB | PostgreSQL (prod) / SQLite (dev) | — | Render-hosted PostgreSQL |
| Backend HTTP | httpx | 0.28.1 | Async HTTP for external APIs |
| AI | OpenAI GPT-4o | gpt-4o-2024-08-06 | Structured output (`strict: true`) |
| Product data | Channel3 REST API | v1 | 100M+ products, free 1K/mo |
| Payments | PayPal Orders v2 | — | Hackathon requirement |
| Deployment | Render | — | Hackathon sponsor |

---

## Flutter Application Structure

```
mobile/lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart          (GoRouter with deep links for PayPal return)
│   └── theme.dart
├── core/
│   ├── config/
│   │   └── app_config.dart  (env-based backend URL — no hardcoded localhost)
│   ├── networking/
│   │   ├── api_client.dart  (Dio instance with auth + error interceptors)
│   │   └── api_exceptions.dart
│   ├── errors/
│   │   └── error_handler.dart
│   └── widgets/
│       ├── loading_state.dart
│       ├── error_state.dart
│       └── empty_state.dart
└── features/
    ├── shopping_brief/      (natural language input)
    ├── product_search/      (loading + progress)
    ├── product_comparison/  (ranked cards + constraint badges)
    ├── product_details/     (evidence section, source URLs)
    ├── purchase_review/     (confirm before checkout)
    ├── checkout/            (PayPal via url_launcher, return handling)
    ├── transaction_history/ (past purchases)
    └── settings/
```

---

## Backend API Contracts (Summary)

| Method | Path | Purpose |
|---|---|---|
| GET | /health | Health check |
| POST | /api/v1/shopping/brief | Submit natural-language brief → session |
| GET | /api/v1/shopping/{session_id} | Get session + extracted requirements |
| GET | /api/v1/products/{session_id} | Get ranked, constraint-validated products |
| POST | /api/v1/checkout/create | Create PayPal order → return approval URL |
| POST | /api/v1/checkout/capture | Capture PayPal order server-side |
| GET | /api/v1/transactions/{purchase_id} | Get verified transaction status |
| GET | /api/v1/history | List purchase history |

---

## Database Models

```
ShoppingSession
  id (UUID PK) | brief_text | requirements_json | status | created_at | updated_at

ProductResult
  id (UUID PK) | session_id (FK) | channel3_product_id | name | price | currency
  merchant | specs_json | source_url | constraint_results_json | ranking_score
  retrieved_at | created_at

PurchaseRecord
  id (UUID PK) | session_id (FK) | product_result_id (FK) | amount | currency
  status | paypal_order_id | idempotency_key | created_at | updated_at

Transaction
  id (UUID PK) | purchase_record_id (FK) | paypal_capture_id | status
  verified_at | raw_capture_json | created_at
```

---

## AI Requirement Extraction Schema

```json
{
  "product_category": "laptop",
  "hard_constraints": [
    { "attribute": "price", "operator": "lte", "value": 1000, "unit": "USD" },
    { "attribute": "ram_gb", "operator": "gte", "value": 16, "unit": "GB" }
  ],
  "soft_preferences": [
    { "attribute": "battery_life_hours", "direction": "maximize", "weight": 0.7 }
  ],
  "budget_max": { "amount": 1000, "currency": "USD" },
  "quantity": 1,
  "use_case": "general computing",
  "clarification_needed": []
}
```

---

## Constraint Evaluation

For each product attribute against each hard constraint:
- **PASS**: attribute value present and satisfies constraint
- **FAIL**: attribute value present and violates constraint
- **UNKNOWN**: attribute not present in product data — treated as FAIL for ranking, shown as "⚠ Not verified" in UI

This is deterministic code — the AI model never evaluates constraints.

---

## PayPal Flow (Mobile)

```
1. User taps "Buy with PayPal"
2. Flutter POST /api/v1/checkout/create → { approval_url, order_id, purchase_id }
3. url_launcher opens approval_url in browser
4. Buyer approves in PayPal
5. PayPal redirects to deep link: proofbuy://checkout/return?token=<order_id>
6. Flutter catches deep link, extracts order_id
7. Flutter POST /api/v1/checkout/capture { order_id, purchase_id }
8. Backend verifies COMPLETED server-side → persists Transaction
9. Flutter displays verified transaction result
```

A return URL alone is never treated as payment confirmation.

---

## Security Principles

- PayPal `client_secret` lives on backend only — never in Flutter source
- AI output validated against Pydantic schema before use
- Product content cannot override system instructions (prompt structured separately from data)
- All secrets in environment variables — `.env.example` contains only placeholders
- Amount and currency validated server-side before PayPal order creation
- Duplicate captures blocked by idempotency key check

---

## Deployment

- **Backend**: Render Web Service (Python), PostgreSQL add-on
- **Flutter**: Android APK for demo; configurable `BACKEND_URL` per environment
- **Environments**: `development` (SQLite + stub services), `production` (PostgreSQL + live APIs)
