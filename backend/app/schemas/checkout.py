from typing import Optional

from pydantic import BaseModel


class CheckoutCreateRequest(BaseModel):
    purchase_id: Optional[str] = None
    product_result_id: str


class CheckoutCreateResponse(BaseModel):
    order_id: str
    approval_url: str
    purchase_id: str


class CheckoutCaptureRequest(BaseModel):
    order_id: str
    purchase_id: str


class CheckoutCaptureResponse(BaseModel):
    transaction_id: str
    status: str
    verified: bool
