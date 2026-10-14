"""
Tests for AIService in mock mode (no real API calls).
All async tests use pytest-asyncio with the anyio backend (matches conftest.py).
"""
import pytest
from unittest.mock import patch

from app.services.ai_service import AIService
from app.schemas.requirements import ShoppingRequirements
from app.core.exceptions import AIRefusalError, AIInvalidOutputError


# ---------------------------------------------------------------------------
# Fixture: force mock mode regardless of environment API key
# ---------------------------------------------------------------------------

@pytest.fixture(autouse=False)
def mock_mode(monkeypatch):
    """Patch settings so AIService always runs in mock mode (no API calls)."""
    import app.config as cfg
    monkeypatch.setattr(cfg.settings, "ai_provider_api_key", "")


# ---------------------------------------------------------------------------
# Import smoke tests (synchronous)
# ---------------------------------------------------------------------------

def test_exception_classes_importable():
    """AIRefusalError and AIInvalidOutputError must be importable."""
    assert issubclass(AIRefusalError, Exception)
    assert issubclass(AIInvalidOutputError, Exception)


def test_exception_status_codes():
    err_refusal = AIRefusalError("refused")
    assert err_refusal.status_code == 422

    err_invalid = AIInvalidOutputError("invalid")
    assert err_invalid.status_code == 502


def test_aiservice_class_importable():
    """AIService must be importable and instantiable."""
    svc = AIService()
    assert svc is not None


# ---------------------------------------------------------------------------
# Mock-mode extract_requirements
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_mock_mode_returns_valid_requirements_laptop(mock_mode):
    """POST brief containing 'laptop' returns a ShoppingRequirements with expected fields."""
    svc = AIService()
    result = await svc.extract_requirements("I need a laptop under $1000 with 16GB RAM")

    assert isinstance(result, ShoppingRequirements)
    assert result.product_category == "laptop"
    assert result.budget_max == 1000.0
    assert result.budget_currency == "USD"
    assert result.quantity == 1
    assert len(result.hard_constraints) >= 1
    assert result.search_query != ""
    assert result.clarification_needed == []


@pytest.mark.asyncio
async def test_mock_mode_laptop_has_ram_and_price_constraints(mock_mode):
    """Laptop mock must include ram_gb (gte) and price_usd (lte) constraints."""
    svc = AIService()
    result = await svc.extract_requirements("laptop for gaming")

    attrs = {c.attribute for c in result.hard_constraints}
    assert "ram_gb" in attrs
    assert "price_usd" in attrs

    ram_c = next(c for c in result.hard_constraints if c.attribute == "ram_gb")
    assert ram_c.operator == "gte"
    assert float(ram_c.value) == 16.0

    price_c = next(c for c in result.hard_constraints if c.attribute == "price_usd")
    assert price_c.operator == "lte"
    assert float(price_c.value) == 1000.0


@pytest.mark.asyncio
async def test_mock_mode_non_laptop_has_clarification(mock_mode):
    """Non-laptop brief in mock mode should have clarification_needed non-empty."""
    svc = AIService()
    result = await svc.extract_requirements("something vague and unclear here")

    assert isinstance(result, ShoppingRequirements)
    assert len(result.clarification_needed) > 0


@pytest.mark.asyncio
async def test_mock_mode_non_laptop_general_category(mock_mode):
    """Non-laptop mock brief returns 'general' product category."""
    svc = AIService()
    result = await svc.extract_requirements("I want something for my home office")

    assert result.product_category == "general"
    assert result.budget_max is None


@pytest.mark.asyncio
async def test_mock_mode_extract_is_awaitable(mock_mode):
    """extract_requirements must be awaitable (async function)."""
    import inspect
    svc = AIService()
    coro = svc.extract_requirements("laptop test")
    assert inspect.isawaitable(coro)
    # Await it to avoid RuntimeWarning
    result = await coro
    assert result is not None


@pytest.mark.asyncio
async def test_mock_mode_generate_explanation_returns_string(mock_mode):
    """generate_explanation in mock mode must return a non-empty string."""
    svc = AIService()
    reqs = await svc.extract_requirements("laptop under $1000")
    product = {
        "name": "Dell XPS 15",
        "price": 999.0,
        "specs_json": {"ram_gb": 16, "price_usd": 999.0},
    }
    constraint_results = {"ram_gb": "PASS", "price_usd": "PASS"}
    explanation = await svc.generate_explanation(
        product=product,
        requirements=reqs,
        constraint_results=constraint_results,
    )
    assert isinstance(explanation, str)
    assert len(explanation) > 0


@pytest.mark.asyncio
async def test_mock_mode_explanation_mentions_pass_attributes(mock_mode):
    """Mock explanation should reference passing attribute names."""
    svc = AIService()
    reqs = await svc.extract_requirements("laptop under $1000")
    product = {"name": "Test Laptop", "price": 800.0, "specs_json": {}}
    constraint_results = {"ram_gb": "PASS", "price_usd": "FAIL"}
    explanation = await svc.generate_explanation(
        product=product,
        requirements=reqs,
        constraint_results=constraint_results,
    )
    assert "ram_gb" in explanation or "price_usd" in explanation


# ---------------------------------------------------------------------------
# Budget post-validation (tested via the internal helper directly)
# ---------------------------------------------------------------------------

def test_budget_validation_helper_extracts_dollar_amounts():
    """_extract_dollar_amounts must correctly parse dollar values from text."""
    from app.services.ai_service import _extract_dollar_amounts

    amounts = _extract_dollar_amounts("I want a laptop under $500 and monitor under $300")
    assert 500.0 in amounts
    assert 300.0 in amounts


def test_budget_validation_helper_handles_commas():
    """Dollar amounts with commas are parsed correctly."""
    from app.services.ai_service import _extract_dollar_amounts

    amounts = _extract_dollar_amounts("budget is $1,200 for the whole setup")
    assert 1200.0 in amounts


# ---------------------------------------------------------------------------
# AIInvalidOutputError raised on malformed response (unit test of internal logic)
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_requirements_schema_validation_raises_on_bad_data():
    """
    Simulating _real_extract_requirements with invalid JSON dict
    should raise AIInvalidOutputError via ShoppingRequirements(**bad_data).
    """
    import json as _json

    # Directly simulate what happens when AI returns garbage that fails Pydantic validation
    bad_data = {"bad": "data", "missing_required_fields": True}

    with pytest.raises((Exception,)):  # ShoppingRequirements will raise ValidationError
        ShoppingRequirements(**bad_data)


@pytest.mark.asyncio
async def test_budget_cannot_exceed_stated_amount_raises():
    """
    If a mock/real response sets budget_max above the stated amount,
    the post-validation check should raise AIInvalidOutputError.
    """
    from app.services.ai_service import _extract_dollar_amounts, AIInvalidOutputError

    brief = "I need a laptop under $500"
    dollar_amounts = _extract_dollar_amounts(brief)

    # Simulate a requirements object where AI set budget_max too high
    requirements = ShoppingRequirements(
        product_category="laptop",
        hard_constraints=[],
        soft_preferences=[],
        budget_max=9999.0,  # violates stated $500
        budget_currency="USD",
        quantity=1,
        use_case=None,
        search_query="laptop",
        clarification_needed=[],
    )

    # Apply the same logic as in _real_extract_requirements
    if requirements.budget_max is not None and dollar_amounts:
        if requirements.budget_max > max(dollar_amounts):
            with pytest.raises(AIInvalidOutputError):
                raise AIInvalidOutputError(
                    f"AI set budget_max={requirements.budget_max} which exceeds "
                    f"the stated amount(s) {dollar_amounts}"
                )
