from datetime import datetime, timezone
from typing import Optional, List
from uuid import uuid4

from sqlalchemy import String, Text, JSON, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ShoppingSession(Base):
    __tablename__ = "shopping_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    brief_text: Mapped[str] = mapped_column(Text, nullable=False)
    requirements_json: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    product_results: Mapped[List["ProductResult"]] = relationship(
        "ProductResult", back_populates="session"
    )
    purchase_records: Mapped[List["PurchaseRecord"]] = relationship(
        "PurchaseRecord", back_populates="session"
    )
