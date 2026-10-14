from datetime import datetime, timezone

import pytest
from pydantic import ValidationError as PydanticValidationError

from app.schemas.shopping import ShoppingBriefRequest
from app.schemas.product import ProductResultResponse
from app.schemas.checkout import CheckoutCreateRequest


def test_shopping_brief_request_valid():
    req = ShoppingBriefRequest(brief="I need a laptop under $1000")
    assert req.brief == "I need a laptop under $1000"


def test_shopping_brief_request_too_short():
    with pytest.raises(PydanticValidationError):
        ShoppingBriefRequest(brief="short")


def test_shopping_brief_request_exactly_10_chars():
    req = ShoppingBriefRequest(brief="1234567890")
    assert len(req.brief) == 10


def test_product_result_response_from_dict():
    now = datetime.now(timezone.utc)
    data = {
        "id": "abc123",
        "session_id": "sess456",
        "name": "Test Laptop",
        "price": 799.99,
        "currency": "USD",
        "created_at": now,
    }
    response = ProductResultResponse(**data)
    assert response.id == "abc123"
    assert response.name == "Test Laptop"
    assert response.price == 799.99
    assert response.merchant is None
    assert response.specs_json is None


def test_checkout_create_request_requires_product_result_id():
    with pytest.raises(PydanticValidationError):
        CheckoutCreateRequest()


def test_checkout_create_request_valid():
    req = CheckoutCreateRequest(product_result_id="prod-123")
    assert req.product_result_id == "prod-123"
    assert req.purchase_id is None
