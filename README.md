# ProofBuy AI

**Evidence-Backed AI Shopping with PayPal**

> PayPal AI Hackathon 2026 Entry

ProofBuy AI transforms natural-language shopping requests into evidence-backed product comparisons. It combines AI-powered requirement extraction, real product data from Channel3, deterministic constraint validation, and a buyer-controlled PayPal checkout to help people make more confident purchasing decisions.

---

## What It Does

1. **Describe what you need** — type a plain-language shopping brief: *"I need a laptop under $1000 with at least 16GB RAM for software development"*
2. **Review AI-extracted requirements** — see your hard constraints, soft preferences, and budget extracted into structured data you can verify
3. **Get evidence-backed comparisons** — products ranked by how well they satisfy your constraints, with each attribute marked PASS / FAIL / UNKNOWN
4. **Buy with confidence** — complete a PayPal checkout that is verified server-side before showing you success

---

## The Problem It Addresses

Online shoppers waste hours cross-referencing specs across multiple websites, trusting merchant descriptions that may be incomplete or outdated, and have no automated way to verify that a product actually meets their mandatory requirements. The research and the purchase are completely disconnected.

ProofBuy AI connects them: the same constraints used to filter products are shown alongside each result, unknown attributes are flagged (never silently passed), and the checkout is tied to the specific verified product.

---

## How It Works

```
User brief (natural language)
        ↓
FastAPI backend
        ↓
GPT-4o structured output → ShoppingRequirements schema
        ↓
Channel3 API → real products (100M+ catalog)
        ↓
Deterministic ConstraintEngine → PASS / FAIL / UNKNOWN per attribute
        ↓
Ranked product list with evidence
        ↓
Flutter mobile app shows results
        ↓
User selects product → PayPal Orders v2 (backend only)
        ↓
Server-side capture verification → verified: true
        ↓
Transaction persisted to DB
```

---

## The Role of AI

GPT-4o with `strict: true` JSON schema output extracts structured shopping requirements from natural language. It identifies hard constraints (RAM ≥ 16GB), soft preferences (maximize battery life), budget limits, use case, and flags ambiguous requests for clarification.

**What AI does NOT do:**
- Evaluate constraints (that is deterministic code in `ConstraintEngine`)
- Access the database
- Fabricate product specifications
- Override the budget stated by the user

AI output is validated against a Pydantic schema before use. Invalid model responses raise an error rather than using bad data.

---

## The Role of PayPal

PayPal Orders v2 API handles the checkout flow:

- `POST /v2/checkout/orders` — creates the order (backend only, never in the Flutter app)
- Buyer approval via the PayPal-hosted approval URL (opened in system browser)
- `POST /v2/checkout/orders/{id}/capture` — captures payment (backend only)
- `GET /v2/checkout/orders/{id}` — server-side verification before marking complete

The Flutter app never calls PayPal directly. The PayPal `client_secret` is never in the mobile source. Payment amount is always sourced from the database, never from the client request.

---

## The Role of Channel3

Channel3 provides access to 100M+ products from 25,000+ brands across US, UK, CA, AU, and EU markets. ProofBuy AI uses the Channel3 REST API (`POST /v1/search`) to retrieve real product listings including price, specs, merchant, and source URL.

Missing fields from Channel3 are stored as `null` — the constraint engine marks them `UNKNOWN` rather than assuming compliance.

---

## Architecture

```
Flutter Mobile App (iOS / Android)
    │  Dio HTTP client
    ▼
FastAPI Backend (Python 3.11+)
    ├── AI Service       → OpenAI GPT-4o (structured output)
    ├── Channel3 Service → Channel3 REST API (/v1/search)
    ├── PayPal Service   → PayPal Orders v2 (sandbox/live)
    └── PostgreSQL DB    → SQLAlchemy 2.x async + Alembic
```

See [docs/architecture.md](docs/architecture.md) for the full diagram and component breakdown.

---

## Project Structure

```
proofBuy-AI/
├── backend/              FastAPI backend
│   ├── app/
│   │   ├── models/       SQLAlchemy models
│   │   ├── schemas/      Pydantic v2 schemas
│   │   ├── routers/      API endpoints
│   │   └── services/     Channel3, AI, PayPal services
│   ├── tests/            77 tests (unit + e2e)
│   └── .env.example
├── mobile/               Flutter mobile app
│   ├── lib/
│   │   ├── app/          Router, theme
│   │   ├── core/         Config, networking, errors
│   │   ├── features/     11 screens
│   │   └── shared/       Models, providers
│   └── test/             18 widget + repository tests
└── docs/
    ├── architecture.md
    ├── technical-feasibility.md
    ├── hackathon-requirements.md
    ├── api-contracts.md
    ├── ai-evaluation.md
    ├── security.md
    ├── product-requirements.md
    ├── known-limitations.md
    └── deployment.md
```

---

## Setup

### Prerequisites

- Python 3.11+
- Flutter 3.x SDK
- Android SDK (for APK build)
- PostgreSQL (optional; SQLite used by default in development)

### Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your API keys (all optional — mock mode works without them)

pip install -r requirements.txt
uvicorn app.main:app --reload
```

The backend starts at `http://localhost:8000`. Visit `http://localhost:8000/docs` for the interactive API documentation.

### Flutter

```bash
cd mobile
flutter pub get

# Run on Android emulator (uses http://10.0.2.2:8000 by default)
flutter run

# Run against a deployed backend
flutter run --dart-define=BACKEND_URL=https://your-backend.onrender.com
```

---

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | No | PostgreSQL URL (default: SQLite) |
| `CHANNEL3_API_KEY` | No | Channel3 API key (mock mode if empty) |
| `AI_PROVIDER_API_KEY` | No | Groq API key (mock mode if empty) |
| `AI_MODEL` | No | Groq model (default: openai/gpt-oss-120b) |
| `PAYPAL_CLIENT_ID` | No | PayPal client ID (mock mode if empty) |
| `PAYPAL_CLIENT_SECRET` | No | PayPal client secret |
| `PAYPAL_ENVIRONMENT` | No | `sandbox` or `live` (default: sandbox) |
| `CORS_ALLOWED_ORIGINS` | No | Comma-separated allowed origins |

All services have mock modes — the full app is demonstrable without any API keys.

---

## Running the Backend

```bash
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Running Tests

```bash
cd backend
pytest tests/ -v
# 77 passed, 1 skipped (live Channel3 — needs real API key)
```

---

## Running the Flutter Application

```bash
cd mobile

# Analyze
flutter analyze

# Test
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK (requires signing config)
flutter build apk --release
```

### Android Emulator Configuration

The default backend URL for the Android emulator is `http://10.0.2.2:8000` (the host machine alias). No configuration needed for local development.

For a deployed backend:
```bash
flutter run --dart-define=BACKEND_URL=https://your-backend.onrender.com
```

---

## Testing the PayPal Sandbox

1. Create a PayPal Developer account at https://developer.paypal.com
2. Create a sandbox app to get `PAYPAL_CLIENT_ID` and `PAYPAL_CLIENT_SECRET`
3. Set these in `backend/.env`
4. Use a PayPal sandbox buyer account to test the checkout flow
5. Verify transaction status via `GET /api/v1/transactions/{purchase_id}`

See [docs/deployment.md](docs/deployment.md) for full sandbox setup instructions.

---

## Running the Evaluation Dataset

The AI evaluation dataset is documented in [docs/ai-evaluation.md](docs/ai-evaluation.md) with 20 test cases covering:

- Straightforward requests
- Multi-constraint requests
- Contradictory constraints
- Ambiguous requests (expect clarification_needed)
- Prompt injection attempts

To run: set `AI_PROVIDER_API_KEY` and execute:
```bash
cd backend
pytest tests/ -v -m "not integration"
```

---

## Known Limitations

See [docs/known-limitations.md](docs/known-limitations.md) for a complete honest list. Key items:

- Channel3 and OpenAI run in mock mode without real API keys
- PayPal tested with mocked HTTP responses; real sandbox requires credentials
- No user authentication (session-based, UUID-identified)
- Deep link return from PayPal not verified on physical device
- iOS build not verified

---

## Screenshots

*Screenshots will be added once a deployed demo is available.*

---

## License

MIT License — see [LICENSE](LICENSE)

---

## Hackathon

**Competition:** PayPal AI Hackathon 2026  
**Deadline:** November 12, 2026, 12:00 PM Pacific Time  
**Devpost:** https://paypalaihackathon.devpost.com/
