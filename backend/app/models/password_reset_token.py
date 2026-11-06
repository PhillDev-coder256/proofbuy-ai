from datetime import datetime, timezone
from uuid import uuid4

from sqlalchemy import String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id"), nullable=False, index=True
    )
    # 6-digit OTP the user enters (hashed for security)
    otp_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    # Short-lived JWT returned after OTP verification — used to set new password
    reset_token: Mapped[str] = mapped_column(String(512), nullable=True)
    is_used: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    def __init__(self, **kw):
        if "id" not in kw or kw["id"] is None:
            kw["id"] = str(uuid4())
        if "created_at" not in kw:
            kw["created_at"] = datetime.now(timezone.utc)
        if "is_used" not in kw:
            kw["is_used"] = False
        super().__init__(**kw)

    @property
    def is_expired(self) -> bool:
        return datetime.now(timezone.utc) > self.expires_at.replace(tzinfo=timezone.utc)
