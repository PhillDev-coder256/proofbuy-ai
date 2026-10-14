# ProofBuy AI — Backend

FastAPI backend for the ProofBuy AI shopping assistant.

## Setup

```bash
pip install -r requirements.txt
cp .env.example .env
# Edit .env to fill in your API keys
```

## Run

```bash
uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000.  
Interactive docs: http://localhost:8000/docs

## Test

```bash
pytest tests/ -v
```

## Architecture

- **FastAPI** — async web framework
- **SQLAlchemy 2.x async** — ORM with async session support
- **aiosqlite** — async SQLite driver for development
- **asyncpg** — async PostgreSQL driver for production
- **Alembic** — database migrations
- **Pydantic v2** — data validation and serialisation
- **pydantic-settings** — configuration from environment variables

## Key Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /health | Health check |
| POST | /api/v1/shopping/brief | Submit a shopping brief |
| GET | /api/v1/shopping/{session_id} | Get session details |
| GET | /api/v1/products/{session_id} | Get products for a session |
| POST | /api/v1/checkout/create | Create a PayPal checkout order |
| POST | /api/v1/checkout/capture | Capture a PayPal order |
| GET | /api/v1/transactions/{purchase_id} | Get transaction details |
| GET | /api/v1/history | Get full purchase history |

## Phase Roadmap

- **Phase 3**: Replace Channel3 stub with real API integration
- **Phase 4**: Replace AI stub with real OpenAI structured output
- **Phase 5**: Replace PayPal stub with real PayPal Orders v2 API
