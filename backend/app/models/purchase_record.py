from datetime import datetime, timezone
from typing import Optional, List
from uuid import uuid4

from sqlalchemy import String, JSON, DateTime, ForeignKey, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class PurchaseRecord(Base):
    __tablename__ = "purchase_records"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    session_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("shopping_sessions.id"), nullable=False
    )
    product_result_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("product_results.id"), nullable=False
    )
    amount: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="USD", nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)
    paypal_order_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    idempotency_key: Mapped[Optional[str]] = mapped_column(String, unique=True, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    def __init__(self, **kw):
        if "id" not in kw or kw["id"] is None:
            kw["id"] = str(uuid4())
        if "created_at" not in kw:
            kw["created_at"] = datetime.now(timezone.utc)
        if "updated_at" not in kw:
            kw["updated_at"] = datetime.now(timezone.utc)
        if "status" not in kw:
            kw["status"] = "pending"
        if "currency" not in kw:
            kw["currency"] = "USD"
        super().__init__(**kw)

    session: Mapped["ShoppingSession"] = relationship(
        "ShoppingSession", back_populates="purchase_records"
    )
    product_result: Mapped["ProductResult"] = relationship(
        "ProductResult", back_populates="purchase_records"
    )
    transactions: Mapped[List["Transaction"]] = relationship(
        "Transaction", back_populates="purchase_record"
    )
