from datetime import datetime
from typing import Optional, Dict

from pydantic import BaseModel, ConfigDict, model_validator


class ProductResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    session_id: str
    name: str
    price: float
    currency: str
    merchant: Optional[str] = None
    specs_json: Optional[dict] = None
    source_url: Optional[str] = None
    constraint_results_json: Optional[dict] = None
    ranking_score: Optional[float] = None
    retrieved_at: Optional[datetime] = None
    created_at: datetime


class NormalizedProduct(BaseModel):
    channel3_product_id: str
    name: str
    price: Optional[float] = None
    currency: Optional[str] = None
    merchant: Optional[str] = None
    source_url: Optional[str] = None
    image_url: Optional[str] = None
    specs: dict = {}
    retrieved_at: datetime
    data_complete: bool = False

    @model_validator(mode="after")
    def compute_data_complete(self) -> "NormalizedProduct":
        self.data_complete = (
            self.price is not None
            and self.currency is not None
            and bool(self.name)
        )
        return self


class RankedProduct(BaseModel):
    product: dict  # raw product dict from channel3
    constraint_results: Dict[str, str]  # attribute -> ConstraintResult value
    ranking_score: float
    ranking_confidence: float
    explanation: Optional[str] = None
