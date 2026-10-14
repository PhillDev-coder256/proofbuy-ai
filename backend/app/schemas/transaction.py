from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

from app.schemas.product import ProductResultResponse
from app.schemas.shopping import ShoppingSessionResponse


class TransactionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    purchase_record_id: str
    paypal_capture_id: Optional[str] = None
    status: str
    verified_at: Optional[datetime] = None
    created_at: datetime


class PurchaseRecordResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    session_id: str
    product_result_id: str
    amount: float
    currency: str
    status: str
    paypal_order_id: Optional[str] = None
    idempotency_key: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class PurchaseHistoryItem(BaseModel):
    purchase_record: PurchaseRecordResponse
    product: Optional[ProductResultResponse] = None
    session: Optional[ShoppingSessionResponse] = None
