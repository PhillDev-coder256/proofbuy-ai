# ProofBuy AI — PayPal AI Hackathon 2026

> **Evidence-Backed AI Shopping with Verified PayPal Checkout**

[![Live Backend](https://img.shields.io/badge/Backend-Live%20on%20Render-brightgreen)](https://proofbuy-ai-backend.onrender.com/health)
[![GitHub](https://img.shields.io/badge/GitHub-Public-blue)](https://github.com/PhillDev-coder256/proofbuy-ai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🎯 What It Does

ProofBuy AI lets shoppers describe what they need in plain language and instantly get **evidence-backed product recommendations** they can purchase securely with **PayPal**.

**The problem:** Online shoppers waste hours comparing specs across websites, can't verify if products meet their requirements, and have no connection between their research and their purchase.

**The solution:** One flow — describe → AI extracts requirements → real products fetched → deterministic constraint validation (PASS/FAIL/UNKNOWN) → verified PayPal checkout.

---

## 🏆 Hackathon Prizes Targeted

- **Best Use of PayPal + AI** — PayPal Orders v2 fully integrated with server-side verification
- **Best Use of Channel3** — 100M+ product catalog with real-time search
- **Best Use of Render** — Backend deployed and live
- **Best Use of Agentic Commerce** — AI agent finds, verifies, and enables purchase

---

## 🔧 Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Mobile | Flutter 3.x (Android) | Cross-platform UI |
| State | Riverpod 3.x | Reactive state management |
| Backend | FastAPI (Python 3.9) | REST API |
| AI | Groq (openai/gpt-oss-120b) | Requirement extraction |
| Products | Channel3 REST API | 100M+ product catalog |
| Payments | PayPal Orders v2 | Secure checkout |
| Deployment | Render (free tier) | Backend hosting |
| Database | SQLite (dev) / PostgreSQL (prod) | Persistence |
| Auth | Custom JWT + bcrypt | User accounts |

---

## 🚀 Live Demo

**Backend:** https://proofbuy-ai-backend.onrender.com
- Health: https://proofbuy-ai-backend.onrender.com/health
- API Docs: https://proofbuy-ai-backend.onrender.com/docs

**⚠️ Note:** Render free tier spins down after 15 min inactivity. First request may take ~30 seconds. Open the health URL first to wake it up.

---

## 📱 How the App Works

```
1. User describes need: "M3 MacBook Pro under $1500 with 16GB RAM"
        ↓
2. Groq AI extracts: brand=Apple, model=MacBook Pro, processor=M3,
   ram_gb≥16, price≤1500 (dynamic — no hardcoded fields)
        ↓
3. User reviews AI-extracted requirements (fully editable)
        ↓
4. Channel3 searches 100M+ products → returns real products with images
        ↓
5. Deterministic ConstraintEngine: PASS / FAIL / UNKNOWN per attribute
   (AI never touches this — 100% code)
        ↓
6. Ranked results with evidence-backed explanations
        ↓
7. User selects → Purchase Review → PayPal sandbox approval
        ↓
8. Backend captures payment → server-side verification
        ↓
9. Transaction confirmed only when PayPal returns COMPLETED
```

---

## ⚡ Quick Setup

### Prerequisites
- Python 3.9+
- Flutter 3.x + Android SDK
- Git

### Backend (local)
```bash
git clone https://github.com/PhillDev-coder256/proofbuy-ai
cd proofbuy-ai/backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # add your keys
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Flutter (Android)
```bash
cd mobile
flutter pub get

# Run on emulator (uses local backend)
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8000

# Run on physical device (uses Render — no local backend needed)
flutter run
```

---

## 🔑 Environment Variables

| Variable | Required | Description |
|---|---|---|
| `CHANNEL3_API_KEY` | Yes | From https://trychannel3.com |
| `AI_PROVIDER_API_KEY` | Yes | Groq API key |
| `PAYPAL_CLIENT_ID` | Yes | PayPal Developer sandbox |
| `PAYPAL_CLIENT_SECRET` | Yes | PayPal Developer sandbox |
| `JWT_SECRET` | Yes | Random 32+ char string |

**All services have mock modes** — the app runs without any API keys for local testing.

---

## 🧪 Testing

```bash
# Backend (77 tests)
cd backend && .venv/bin/python -m pytest tests/ -v

# Flutter (19 tests)
cd mobile && flutter test

# Live end-to-end on Render
curl https://proofbuy-ai-backend.onrender.com/health
```

---

## 🏗️ Architecture

```
Flutter App (Android)
    │  Dio HTTP → Render
    ▼
FastAPI Backend (Render)
    ├── /api/v1/auth/*          JWT auth (register/login/reset)
    ├── /api/v1/shopping/brief  Groq AI requirement extraction
    ├── /api/v1/products/*      Channel3 product search + ranking
    ├── /api/v1/checkout/*      PayPal Orders v2 (create/capture/verify)
    └── /api/v1/transactions/*  Transaction history
         │
         ├── Groq (openai/gpt-oss-120b)   AI extraction
         ├── Channel3 (/v1/search)         Product data
         └── PayPal (api-m.sandbox.paypal.com)  Payments
```

---

## 🔐 PayPal Integration Details

- **API:** PayPal Orders v2 REST (`api-m.sandbox.paypal.com`)
- **Flow:** Create order → buyer approval → server-side capture → verification
- **Security:** Client secret never in mobile app. Amount sourced from DB, not client. Payment only confirmed after `status == COMPLETED` verified server-side.
- **Deep links:** `proofbuy://checkout/return` → auto-triggers capture
- **Idempotency:** Duplicate capture requests handled safely

---

## 🤖 AI Integration Details

- **Model:** Groq `openai/gpt-oss-120b` with `response_format: json_object`
- **Extraction:** Dynamic — extracts ALL relevant constraints from any product type (laptops: RAM/processor/GPU; shoes: brand/size/color; TVs: resolution/panel type/size)
- **Validation:** Pydantic schema validation on all AI output — invalid responses raise errors
- **Constraint engine:** 100% deterministic Python code — AI never evaluates constraints
- **Budget guard:** AI cannot return `budget_max` higher than what user stated

---

## 📊 Key Metrics

- **Backend:** 77 tests passing (unit + integration + e2e)
- **Flutter:** 19 tests passing
- **Products returned:** Real Channel3 data (10 per search, 100M+ catalog)
- **PayPal:** Real sandbox orders with verified capture
- **Constraint violations:** 0 (UNKNOWN is explicit, never treated as PASS)

---

## 📁 Repository Structure

```
proofbuy-ai/
├── backend/          FastAPI backend
│   ├── app/
│   │   ├── models/   SQLAlchemy models (User, ShoppingSession, etc.)
│   │   ├── schemas/  Pydantic v2 schemas
│   │   ├── routers/  API endpoints
│   │   └── services/ Channel3, AI (Groq), PayPal services
│   └── tests/        77 tests
├── mobile/           Flutter app
│   ├── lib/
│   │   ├── features/ 11 screens
│   │   └── core/     Config, networking, errors
│   └── test/         19 tests
└── docs/             Architecture, security, known limitations
```

---

## ⚠️ Known Limitations

- Google Sign-In button present in UI but requires Firebase setup (post-submission)
- Render free tier: ~30s cold start after inactivity
- No production PostgreSQL (SQLite on Render — data resets on redeploy)
- iOS build not verified (Android is the demo platform)

See [docs/known-limitations.md](docs/known-limitations.md) for full list.

---

## 📄 License

MIT License — see [LICENSE](LICENSE)

---

*Built for the PayPal AI Hackathon 2026 — Nov 1–12, 2026*
