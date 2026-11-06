from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.user import User

_pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ── Password helpers ─────────────────────────────────────────────────────────

def hash_password(plain: str) -> str:
    return _pwd_context.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    return _pwd_context.verify(plain, hashed)


# ── JWT helpers ───────────────────────────────────────────────────────────────

def create_access_token(user_id: str, email: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.jwt_expire_minutes
    )
    payload = {
        "sub": user_id,
        "email": email,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> Optional[dict]:
    """Return payload dict or None if token is invalid/expired."""
    try:
        return jwt.decode(
            token, settings.jwt_secret, algorithms=[settings.jwt_algorithm]
        )
    except JWTError:
        return None


# ── User helpers ──────────────────────────────────────────────────────────────

async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
    result = await db.execute(
        select(User).where(User.email == email.lower().strip())
    )
    return result.scalars().first()


async def get_user_by_id(db: AsyncSession, user_id: str) -> Optional[User]:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalars().first()


async def create_user(
    db: AsyncSession,
    full_name: str,
    email: str,
    password: str,
    country: Optional[str] = None,
) -> User:
    user = User(
        full_name=full_name.strip(),
        email=email.lower().strip(),
        hashed_password=hash_password(password),
        country=country,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def authenticate_user(
    db: AsyncSession, email: str, password: str
) -> Optional[User]:
    user = await get_user_by_email(db, email)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


# ── Password reset helpers ────────────────────────────────────────────────────

import random
import string
from datetime import timedelta

from sqlalchemy import select

from app.models.password_reset_token import PasswordResetToken


def _generate_otp(length: int = 6) -> str:
    """Generate a random numeric OTP."""
    return "".join(random.choices(string.digits, k=length))


def _hash_otp(otp: str) -> str:
    """Hash the OTP using bcrypt so it is safe to store."""
    return _pwd_context.hash(otp)


def _verify_otp(plain: str, hashed: str) -> bool:
    return _pwd_context.verify(plain, hashed)


def create_reset_token(user_id: str) -> str:
    """Create a short-lived JWT (15 minutes) for use in /reset-password."""
    expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    payload = {
        "sub": user_id,
        "type": "password_reset",
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_reset_token(token: str) -> Optional[str]:
    """Decode the reset token and return user_id, or None if invalid/expired."""
    try:
        payload = jwt.decode(
            token, settings.jwt_secret, algorithms=[settings.jwt_algorithm]
        )
        if payload.get("type") != "password_reset":
            return None
        return payload.get("sub")
    except JWTError:
        return None


async def create_otp_for_user(
    db: AsyncSession, user_id: str
) -> str:
    """
    Generate a 6-digit OTP, persist it (hashed, expires in 10 minutes),
    and return the plain OTP to show to the user / send via email.
    """
    # Invalidate any existing unused tokens for this user
    existing = await db.execute(
        select(PasswordResetToken).where(
            PasswordResetToken.user_id == user_id,
            PasswordResetToken.is_used == False,  # noqa: E712
        )
    )
    for old_token in existing.scalars().all():
        old_token.is_used = True

    otp = _generate_otp()
    token = PasswordResetToken(
        user_id=user_id,
        otp_hash=_hash_otp(otp),
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=10),
    )
    db.add(token)
    await db.commit()
    return otp


async def verify_otp_and_get_reset_token(
    db: AsyncSession, email: str, otp: str
) -> Optional[str]:
    """
    Verify the OTP for the user with this email.
    Returns a reset JWT if valid, None otherwise.
    Marks the token as used on success.
    """
    user = await get_user_by_email(db, email)
    if not user:
        return None

    result = await db.execute(
        select(PasswordResetToken).where(
            PasswordResetToken.user_id == user.id,
            PasswordResetToken.is_used == False,  # noqa: E712
        )
    )
    token_row = result.scalars().first()
    if not token_row:
        return None
    if token_row.is_expired:
        return None
    if not _verify_otp(otp, token_row.otp_hash):
        return None

    # Mark token as used
    token_row.is_used = True

    # Generate and store a reset JWT
    reset_jwt = create_reset_token(user.id)
    token_row.reset_token = reset_jwt
    await db.commit()
    return reset_jwt


async def reset_password_with_token(
    db: AsyncSession, reset_token: str, new_password: str
) -> bool:
    """
    Use the reset JWT to set a new password.
    Returns True on success, False on invalid/expired token.
    """
    user_id = decode_reset_token(reset_token)
    if not user_id:
        return False

    user = await get_user_by_id(db, user_id)
    if not user:
        return False

    user.hashed_password = hash_password(new_password)
    user.updated_at = datetime.now(timezone.utc)
    await db.commit()
    return True
