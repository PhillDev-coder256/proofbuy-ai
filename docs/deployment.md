# Deployment — ProofBuy AI

## Prerequisites

- Python 3.11+
- Flutter 3.x SDK + Android SDK
- PostgreSQL (for production; SQLite for development)
- A Render account (https://render.com) for backend hosting
- API keys for: Channel3, OpenAI, PayPal (all optional — mock mode works without them)

---

## Environment Variables

All secrets are set via environment variables. Never commit `.env` files.

| Variable | Required for live | Description |
|---|---|---|
| `DATABASE_URL` | Yes | `postgresql+asyncpg://user:pass@host:5432/db` |
| `CHANNEL3_API_KEY` | For real products | Get from https://docs.trychannel3.com |
| `AI_PROVIDER_API_KEY` | For real AI extraction | Groq API key from console.groq.com |
| `AI_MODEL` | No | Default: `openai/gpt-oss-120b` |
| `PAYPAL_CLIENT_ID` | For real payments | From PayPal Developer Dashboard |
| `PAYPAL_CLIENT_SECRET` | For real payments | From PayPal Developer Dashboard |
| `PAYPAL_ENVIRONMENT` | No | `sandbox` (default) or `live` |
| `CORS_ALLOWED_ORIGINS` | Yes in production | Your frontend origins, comma-separated |
| `APP_ENV` | No | `development` or `production` |

---

## Database Setup

### Local development (SQLite — no setup needed)
```bash
cd backend
cp .env.example .env
# DATABASE_URL defaults to sqlite+aiosqlite:///./proofbuy_dev.db
uvicorn app.main:app --reload
# Tables are created automatically on first startup
```

### Production (PostgreSQL on Render)
1. Create a PostgreSQL database in Render dashboard
2. Copy the internal connection string to `DATABASE_URL`
3. Run migrations:
```bash
cd backend
alembic upgrade head
```

### Migration commands
```bash
# Apply all pending migrations
alembic upgrade head

# Create a new migration after model changes
alembic revision --autogenerate -m "description"

# Rollback one migration
alembic downgrade -1
```

---

## Backend Startup (Local)

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your values

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

API docs available at: `http://localhost:8000/docs`
Health check: `http://localhost:8000/health`

---

## Backend Deployment on Render

1. Push repository to GitHub
2. In Render dashboard: New → Web Service
3. Connect your GitHub repository
4. Configure:
   - **Runtime:** Python 3
   - **Build command:** `pip install -r requirements.txt`
   - **Start command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Root directory:** `backend`
5. Add all environment variables in Render's Environment tab
6. Run migrations after first deploy:
   ```bash
   # In Render Shell or via one-off job
   alembic upgrade head
   ```

### Render keep-alive (demo day)
The free tier spins down after 15 minutes. For demo day, use Render Starter ($7/month) or add a keep-alive ping:
```bash
# Simple cron to ping health endpoint every 10 minutes
*/10 * * * * curl https://your-app.onrender.com/health
```

---

## Flutter Configuration

### Development (Android emulator)
```bash
cd mobile
flutter run
# Uses http://10.0.2.2:8000 by default (emulator → host machine)
```

### Physical Android device (local backend)
Find your machine's local IP:
```bash
ipconfig getifaddr en0   # macOS
```
Then:
```bash
flutter run --dart-define=BACKEND_URL=http://192.168.x.x:8000
```

### Production build (deployed backend)
```bash
flutter build apk --release \
  --dart-define=BACKEND_URL=https://your-backend.onrender.com
```

### Debug APK (no signing required)
```bash
flutter build apk --debug \
  --dart-define=BACKEND_URL=https://your-backend.onrender.com
```

Output: `mobile/build/app/outputs/flutter-apk/app-debug.apk`

---

## Android Build

### Prerequisites
- Android SDK installed
- `ANDROID_HOME` or `ANDROID_SDK_ROOT` environment variable set
- Android emulator or physical device with USB debugging

```bash
cd mobile
flutter pub get
flutter analyze       # must show no issues
flutter test          # must pass
flutter build apk --debug
```

### Install on device/emulator
```bash
adb install mobile/build/app/outputs/flutter-apk/app-debug.apk
```

### Test deep link return
```bash
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "proofbuy://checkout/return?token=TEST-ORDER-123" \
  com.proofbuy.proofbuy_ai
```

---

## Sandbox Testing

### PayPal sandbox setup
1. Go to https://developer.paypal.com/dashboard/
2. Create an app → get `PAYPAL_CLIENT_ID` and `PAYPAL_CLIENT_SECRET`
3. Create a sandbox buyer account
4. Set `PAYPAL_ENVIRONMENT=sandbox` in backend `.env`

### Test a complete sandbox transaction
1. Start backend with real PayPal sandbox credentials
2. Submit a shopping brief in the app
3. Select a product → Purchase Review → Confirm
4. Complete payment with sandbox buyer account
5. Verify: `GET /api/v1/transactions/{purchase_id}` returns `status: captured`

### Verify transaction integrity
A successful transaction must satisfy ALL of:
- `Transaction.status == "captured"`
- `Transaction.verified_at` is not null
- `PurchaseRecord.status == "captured"`
- `Transaction.paypal_capture_id` is not null
- `Transaction.raw_capture_json` contains capture metadata

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `uvicorn: command not found` | Not in PATH | `python3 -m uvicorn app.main:app --reload` |
| `ModuleNotFoundError` | Dependencies not installed | `pip install -r requirements.txt` |
| `Cannot connect to database` | Wrong DATABASE_URL | Check `.env`, verify PostgreSQL is running |
| `alembic: target database is not up to date` | Pending migrations | `alembic upgrade head` |
| `PayPal: 401 Unauthorized` | Wrong credentials | Verify PAYPAL_CLIENT_ID and SECRET match sandbox app |
| `Channel3: 401` | Wrong API key | Verify CHANNEL3_API_KEY |
| Flutter: `BACKEND_URL not configured` | --dart-define not set | Add `--dart-define=BACKEND_URL=...` to flutter run |
| Flutter: network error on emulator | Using localhost | Use `http://10.0.2.2:8000` for emulator |
| Render: first request times out | Free tier spin-down | Wait 30s or upgrade to Starter |
| `alembic.exc.OperationalError` on SQLite | SQLite doesn't support all Alembic ops | Use PostgreSQL for production |

---

## Known Limitations

See [known-limitations.md](known-limitations.md) for a complete list. Critical for deployment:

- No user authentication — all sessions are public by UUID
- No rate limiting — add before public deployment  
- Render free tier spins down — use Starter for demo day
- iOS build not verified — Android only
