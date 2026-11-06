from typing import Optional
from pydantic import BaseModel, EmailStr, field_validator


class RegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    country: Optional[str] = None

    @field_validator("full_name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Full name must not be empty")
        return v.strip()

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one number")
        if not any(c.isalpha() for c in v):
            raise ValueError("Password must contain at least one letter")
        return v


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    full_name: str
    email: str
    country: Optional[str] = None


class UserResponse(BaseModel):
    user_id: str
    full_name: str
    email: str
    country: Optional[str] = None


# ── Password reset schemas ────────────────────────────────────────────────────

class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ForgotPasswordResponse(BaseModel):
    message: str
    # OTP returned directly in dev mode (no email server configured).
    # In production this would be None and sent via email.
    otp: Optional[str] = None
    dev_note: Optional[str] = None


class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: str


class VerifyOtpResponse(BaseModel):
    reset_token: str  # short-lived JWT to use with /reset-password
    message: str


class ResetPasswordRequest(BaseModel):
    reset_token: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one number")
        if not any(c.isalpha() for c in v):
            raise ValueError("Password must contain at least one letter")
        return v


class ResetPasswordResponse(BaseModel):
    message: str
