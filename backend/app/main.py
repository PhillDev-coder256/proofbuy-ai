from contextlib import asynccontextmanager

from fastapi import FastAPI
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from app.core.logging_config import setup_logging
from app.core.middleware import add_middleware
from app.core.exceptions import add_exception_handlers
from app.core.rate_limiter import limiter
from app.database import init_db
from app.routers import health, shopping, products, checkout, transactions
from app.routers import auth as auth_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging()
    await init_db()
    yield


app = FastAPI(
    title="ProofBuy AI",
    version="0.1.0",
    lifespan=lifespan,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

add_middleware(app)
add_exception_handlers(app)

app.include_router(health.router)
app.include_router(auth_router.router)
app.include_router(shopping.router)
app.include_router(products.router)
app.include_router(checkout.router)
app.include_router(transactions.router)
app.include_router(transactions.history_router)
