# ProofBuy AI — Devpost Project Story

## About the project

### Inspiration

Online shoppers waste hours comparing specs across websites, can't verify if products actually meet their requirements, and have no bridge between their research and their purchase. I built ProofBuy AI to close that gap — one flow where you describe what you need in plain language, get evidence-backed product recommendations with constraint validation, and check out securely with PayPal.

### What it does

ProofBuy AI lets shoppers describe what they need in plain language and instantly get evidence-backed product recommendations they can purchase securely with PayPal.

The flow:
1. **Describe your need** — "M3 MacBook Pro under $1500 with 16GB RAM"
2. **AI extracts requirements** — Groq parses brand, model, processor, RAM, price, etc. (fully editable)
3. **Real product search** — Channel3 searches 100M+ products with images
4. **Constraint validation** — Deterministic PASS/FAIL/UNKNOWN per attribute (100% code, AI never evaluates constraints)
5. **Ranked results** with evidence-backed explanations
6. **PayPal checkout** — Server-side Orders v2 capture with verification

### How we built it

**Mobile:** Flutter 3.x + Riverpod 3.x (Android), Firebase Auth for Google Sign-In
**Backend:** FastAPI (Python), deployed on Render
**AI:** Groq (openai/gpt-oss-120b) for requirement extraction
**Products:** Channel3 REST API (100M+ catalog)
**Payments:** PayPal Orders v2 — create order → buyer approval → server-side capture → verification
**Database:** SQLite (dev) / PostgreSQL (prod)

Security: PayPal client secret never touches the mobile app. Amount is sourced from the database, not the client. Payment is only confirmed after PayPal returns `COMPLETED` and is verified server-side.

### Challenges we faced

- **PayPal sandbox integration:** Required server-side OAuth token management, order creation, approval URL handling, and capture verification with idempotency for duplicate captures.
- **Constraint validation:** Ensuring AI never evaluates constraints — built a 100% deterministic Python engine where UNKNOWN is explicit and never treated as PASS.
- **Firebase Google Sign-In:** Configured FlutterFire across web, Android, iOS, macOS, and Windows; set up `google-services.json` for Android and `firebase_options.dart` for all platforms.
- **Render free tier cold start:** ~30-second spin-down after inactivity; documented wake-up flow for judges.

### What we learned

- Server-side payment verification is non-negotiable — never trust the client for amounts or order status.
- Deterministic constraint validation builds trust — users know exactly why a product passed or failed.
- Firebase multi-platform setup requires careful platform-specific configuration files.

### Built with

- Flutter
- Riverpod
- FastAPI
- Groq AI
- Channel3 API
- PayPal Orders v2
- Firebase Auth
- Render

### Try it out

- **GitHub repo:** https://github.com/PhillDev-coder256/proofbuy-ai
- **Live backend:** https://proofbuy-ai-backend.onrender.com/health
- **API docs:** https://proofbuy-ai-backend.onrender.com/docs

---

**Note:** You still need to record the demo video (under 3 minutes, YouTube, public) before you can submit on Devpost. The app is working — Google Sign-In, product search, constraint validation, and PayPal checkout all function.
