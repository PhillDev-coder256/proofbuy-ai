from typing import Optional, List, Union

from pydantic import BaseModel


class HardConstraint(BaseModel):
    attribute: str
    operator: str  # "gte", "lte", "eq", "neq", "contains"
    value: Union[float, str]
    unit: Optional[str] = None


class SoftPreference(BaseModel):
    attribute: str
    direction: str  # "maximize" or "minimize"
    weight: float


class ShoppingRequirements(BaseModel):
    product_category: str
    hard_constraints: List[HardConstraint] = []
    soft_preferences: List[SoftPreference] = []
    budget_max: Optional[float] = None
    budget_currency: str = "USD"
    quantity: int = 1
    use_case: Optional[str] = None
    search_query: str
    clarification_needed: List[str] = []
