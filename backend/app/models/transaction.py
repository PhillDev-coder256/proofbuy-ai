from datetime import datetime, timezone
from typing import Optional
from uuid import uuid4

from sqlalchemy import String, JSON, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Transaction(Base):
    __tablename__ = "transactions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    purchase_record_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("purchase_records.id"), nullable=False
    )
    paypal_capture_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    status: Mapped[str] = mapped_column(String(20), nullable=False)
    verified_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    raw_capture_json: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    purchase_record: Mapped["PurchaseRecord"] = relationship(
        "PurchaseRecord", back_populates="transactions"
    )
