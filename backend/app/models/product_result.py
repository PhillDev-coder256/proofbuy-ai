from datetime import datetime, timezone
from typing import Optional, List
from uuid import uuid4

from sqlalchemy import String, JSON, DateTime, ForeignKey, Numeric, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ProductResult(Base):
    __tablename__ = "product_results"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    session_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("shopping_sessions.id"), nullable=False
    )
    channel3_product_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    price: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    currency: Mapped[Optional[str]] = mapped_column(String(3), nullable=True)
    merchant: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    specs_json: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)
    source_url: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    constraint_results_json: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)
    ranking_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    retrieved_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    session: Mapped["ShoppingSession"] = relationship(
        "ShoppingSession", back_populates="product_results"
    )
    purchase_records: Mapped[List["PurchaseRecord"]] = relationship(
        "PurchaseRecord", back_populates="product_result"
    )
