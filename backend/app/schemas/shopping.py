from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, ConfigDict, field_validator


class ShoppingBriefRequest(BaseModel):
    brief: str

    @field_validator("brief")
    @classmethod
    def brief_min_length(cls, v: str) -> str:
        if len(v) < 10:
            raise ValueError("brief must be at least 10 characters long")
        return v


class ShoppingRequirements(BaseModel):
    budget_max: Optional[float] = None
    budget_currency: Optional[str] = None
    category: Optional[str] = None
    constraints: List[str] = []
    raw: Optional[str] = None


class ShoppingSessionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    brief_text: str
    requirements_json: Optional[dict] = None
    status: str
    created_at: datetime
    updated_at: datetime


class ShoppingBriefResponse(BaseModel):
    session_id: str
    status: str
    message: str
    requirements: Optional[dict] = None
