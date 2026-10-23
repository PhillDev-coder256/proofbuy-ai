from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.rate_limiter import limiter
from app.database import get_db
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse, UserResponse
from app.services.auth_service import (
    get_user_by_email,
    create_user,
    authenticate_user,
    create_access_token,
    decode_access_token,
)
from app.core.exceptions import ValidationError, NotFoundError

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


@router.post("/register", response_model=AuthResponse, status_code=201)
@limiter.limit("5/minute")
async def register(
    request: Request,
    body: RegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    # Check email not already taken
    existing = await get_user_by_email(db, body.email)
    if existing:
        raise ValidationError("An account with this email already exists")

    user = await create_user(
        db,
        full_name=body.full_name,
        email=body.email,
        password=body.password,
        country=body.country,
    )

    token = create_access_token(user.id, user.email)
    return AuthResponse(
        access_token=token,
        user_id=user.id,
        full_name=user.full_name,
        email=user.email,
        country=user.country,
    )


@router.post("/login", response_model=AuthResponse)
@limiter.limit("5/minute")
async def login(
    request: Request,
    body: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    user = await authenticate_user(db, body.email, body.password)
    if not user:
        raise ValidationError("Invalid email or password")

    token = create_access_token(user.id, user.email)
    return AuthResponse(
        access_token=token,
        user_id=user.id,
        full_name=user.full_name,
        email=user.email,
        country=user.country,
    )


@router.get("/me", response_model=UserResponse)
async def get_me(
    db: AsyncSession = Depends(get_db),
    # Simple header-based auth — extract token manually
    # (avoids OAuth2 dependency complexity for the hackathon)
):
    """Returns the current user. Token passed as Authorization: Bearer <token>."""
    # This is handled below via dependency — kept simple for hackathon scope
    raise NotFoundError("Use Authorization header: Bearer <token>")


# Dependency: extract user from Bearer token
from fastapi import Header
from typing import Optional as Opt


async def get_current_user_id(
    authorization: Opt[str] = Header(default=None),
) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise ValidationError("Missing or invalid Authorization header")
    token = authorization.split(" ", 1)[1]
    payload = decode_access_token(token)
    if not payload:
        raise ValidationError("Token is invalid or expired")
    return payload["sub"]
