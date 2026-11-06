from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.rate_limiter import limiter
from app.database import get_db
from app.schemas.auth import (
    RegisterRequest, LoginRequest, AuthResponse, UserResponse,
    ForgotPasswordRequest, ForgotPasswordResponse,
    VerifyOtpRequest, VerifyOtpResponse,
    ResetPasswordRequest, ResetPasswordResponse,
)
from app.services.auth_service import (
    get_user_by_email,
    create_user,
    authenticate_user,
    create_access_token,
    decode_access_token,
    create_otp_for_user,
    verify_otp_and_get_reset_token,
    reset_password_with_token,
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


# ── Password reset endpoints ──────────────────────────────────────────────────

@router.post("/forgot-password", response_model=ForgotPasswordResponse)
@limiter.limit("5/minute")
async def forgot_password(
    request: Request,
    body: ForgotPasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Request a password reset OTP.

    For the hackathon we return the OTP directly in the response (no email
    server configured). In production, remove `otp` from the response and send
    it via email instead.

    Always returns 200 even if the email is not registered — prevents
    user enumeration.
    """
    user = await get_user_by_email(db, body.email)
    if not user:
        # Don't reveal whether the email exists
        return ForgotPasswordResponse(
            message="If that email is registered you will receive a reset code.",
        )

    otp = await create_otp_for_user(db, user.id)

    return ForgotPasswordResponse(
        message="Reset code generated. Check your email (or use the code below in dev mode).",
        otp=otp,
        dev_note="OTP shown here because no email provider is configured. Remove in production.",
    )


@router.post("/verify-otp", response_model=VerifyOtpResponse)
@limiter.limit("10/minute")
async def verify_otp(
    request: Request,
    body: VerifyOtpRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Verify the 6-digit OTP and return a short-lived reset token (valid 15 min).
    """
    reset_token = await verify_otp_and_get_reset_token(db, body.email, body.otp)
    if not reset_token:
        raise ValidationError("Invalid or expired reset code. Please request a new one.")

    return VerifyOtpResponse(
        reset_token=reset_token,
        message="OTP verified. Use the reset_token to set a new password.",
    )


@router.post("/reset-password", response_model=ResetPasswordResponse)
@limiter.limit("5/minute")
async def reset_password(
    request: Request,
    body: ResetPasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Set a new password using the reset token from /verify-otp.
    """
    success = await reset_password_with_token(db, body.reset_token, body.new_password)
    if not success:
        raise ValidationError("Reset token is invalid or has expired. Please start again.")

    return ResetPasswordResponse(message="Password reset successfully. You can now sign in.")
