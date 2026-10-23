from datetime import datetime
from typing import Optional, Dict, List

from pydantic import BaseModel, ConfigDict, model_validator


class ProductImage(BaseModel):
    url: str
    cleaned_url: Optional[str] = None
    is_main_image: bool = False
    shot_type: Optional[str] = None
    alt_text: Optional[str] = None


class ProductOffer(BaseModel):
    url: str
    domain: str
    price: float
    compare_at_price: Optional[float] = None
    currency: str
    availability: str
    condition: Optional[str] = None


class ProductRatings(BaseModel):
    value: float
    count: int
    source_count: int


class ProductResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    session_id: str
    name: str
    price: Optional[float] = None      # nullable — Channel3 may not return a price
    currency: Optional[str] = None     # nullable — Channel3 may not return a currency
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

    # Rich product data fields
    all_images: List[ProductImage] = []
    all_offers: List[ProductOffer] = []
    ratings: Optional[ProductRatings] = None
    materials: Optional[List[str]] = None
    key_features: Optional[List[str]] = None
    variants_options: Optional[List[dict]] = None
    structured_attributes: Optional[dict] = None
    category_title: Optional[str] = None
    gender: Optional[str] = None
    description: Optional[str] = None

    @model_validator(mode="after")
    def compute_data_complete(self) -> "NormalizedProduct":
        self.data_complete = (
            self.price is not None
            and self.currency is not None
            and bool(self.name)
        )
        return self


class RankedProduct(BaseModel):
    id: Optional[str] = None
    product: dict  # raw product dict from channel3
    constraint_results: Dict[str, str]  # attribute -> ConstraintResult value
    ranking_score: float
    ranking_confidence: float
    explanation: Optional[str] = None
