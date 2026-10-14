"""
Tests for ConstraintEngine — deterministic constraint evaluation and product ranking.
All tests are synchronous (ConstraintEngine has no async methods).
"""
import pytest

from app.services.constraint_engine import ConstraintEngine, ConstraintResult
from app.schemas.requirements import HardConstraint, ShoppingRequirements


def make_engine() -> ConstraintEngine:
    return ConstraintEngine()


def make_requirements(constraints: list) -> ShoppingRequirements:
    return ShoppingRequirements(
        product_category="test",
        hard_constraints=constraints,
        soft_preferences=[],
        budget_max=None,
        budget_currency="USD",
        quantity=1,
        use_case=None,
        search_query="test",
        clarification_needed=[],
    )


# ---------------------------------------------------------------------------
# evaluate_product — missing specs
# ---------------------------------------------------------------------------

def test_missing_spec_is_unknown_not_pass():
    """Absent attribute in specs must return UNKNOWN, never PASS."""
    engine = make_engine()
    specs = {}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.UNKNOWN


def test_none_spec_value_is_unknown():
    """Explicit None value in specs must return UNKNOWN."""
    engine = make_engine()
    specs = {"ram_gb": None}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.UNKNOWN


# ---------------------------------------------------------------------------
# evaluate_product — gte operator
# ---------------------------------------------------------------------------

def test_gte_constraint_pass():
    """specs={"ram_gb": 32}, gte 16 -> PASS."""
    engine = make_engine()
    specs = {"ram_gb": 32}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.PASS


def test_gte_constraint_exact_value_pass():
    """specs={"ram_gb": 16}, gte 16 -> PASS (boundary is inclusive)."""
    engine = make_engine()
    specs = {"ram_gb": 16}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.PASS


def test_gte_constraint_fail():
    """specs={"ram_gb": 8}, gte 16 -> FAIL."""
    engine = make_engine()
    specs = {"ram_gb": 8}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.FAIL


def test_gte_constraint_string_value_pass():
    """Spec value "16GB" should be parsed to 16.0 and pass gte 16."""
    engine = make_engine()
    specs = {"ram_gb": "16GB"}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.PASS


def test_gte_constraint_string_value_fail():
    """Spec value "8GB" should be parsed to 8.0 and fail gte 16."""
    engine = make_engine()
    specs = {"ram_gb": "8GB"}
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.FAIL


# ---------------------------------------------------------------------------
# evaluate_product — lte operator
# ---------------------------------------------------------------------------

def test_lte_price_constraint_pass():
    """specs={"price_usd": 799}, lte 1000 -> PASS."""
    engine = make_engine()
    specs = {"price_usd": 799}
    constraints = [HardConstraint(attribute="price_usd", operator="lte", value=1000.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["price_usd"] == ConstraintResult.PASS


def test_lte_price_constraint_exact_pass():
    """specs={"price_usd": 1000}, lte 1000 -> PASS (boundary is inclusive)."""
    engine = make_engine()
    specs = {"price_usd": 1000}
    constraints = [HardConstraint(attribute="price_usd", operator="lte", value=1000.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["price_usd"] == ConstraintResult.PASS


def test_lte_price_constraint_fail():
    """specs={"price_usd": 1200}, lte 1000 -> FAIL."""
    engine = make_engine()
    specs = {"price_usd": 1200}
    constraints = [HardConstraint(attribute="price_usd", operator="lte", value=1000.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["price_usd"] == ConstraintResult.FAIL


def test_lte_price_string_dollar_pass():
    """Spec value "$799.99" is parsed to 799.99 and passes lte 1000."""
    engine = make_engine()
    specs = {"price_usd": "$799.99"}
    constraints = [HardConstraint(attribute="price_usd", operator="lte", value=1000.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["price_usd"] == ConstraintResult.PASS


# ---------------------------------------------------------------------------
# evaluate_product — eq and neq operators
# ---------------------------------------------------------------------------

def test_eq_constraint_pass():
    engine = make_engine()
    specs = {"quantity": 1}
    constraints = [HardConstraint(attribute="quantity", operator="eq", value=1.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["quantity"] == ConstraintResult.PASS


def test_eq_constraint_fail():
    engine = make_engine()
    specs = {"quantity": 2}
    constraints = [HardConstraint(attribute="quantity", operator="eq", value=1.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["quantity"] == ConstraintResult.FAIL


def test_neq_constraint_pass():
    engine = make_engine()
    specs = {"stock": 5}
    constraints = [HardConstraint(attribute="stock", operator="neq", value=0.0)]
    results = engine.evaluate_product(specs, constraints)
    assert results["stock"] == ConstraintResult.PASS


# ---------------------------------------------------------------------------
# evaluate_product — contains operator
# ---------------------------------------------------------------------------

def test_contains_constraint_pass():
    """Case-insensitive substring match should return PASS."""
    engine = make_engine()
    specs = {"processor": "Intel Core i7-13700H"}
    constraints = [HardConstraint(attribute="processor", operator="contains", value="Intel")]
    results = engine.evaluate_product(specs, constraints)
    assert results["processor"] == ConstraintResult.PASS


def test_contains_constraint_case_insensitive():
    """Contains check is case-insensitive."""
    engine = make_engine()
    specs = {"processor": "Intel Core i7"}
    constraints = [HardConstraint(attribute="processor", operator="contains", value="intel")]
    results = engine.evaluate_product(specs, constraints)
    assert results["processor"] == ConstraintResult.PASS


def test_contains_constraint_fail():
    """Substring not present -> FAIL."""
    engine = make_engine()
    specs = {"processor": "AMD Ryzen 7"}
    constraints = [HardConstraint(attribute="processor", operator="contains", value="Intel")]
    results = engine.evaluate_product(specs, constraints)
    assert results["processor"] == ConstraintResult.FAIL


# ---------------------------------------------------------------------------
# evaluate_product — contradictory constraints
# ---------------------------------------------------------------------------

def test_contradictory_constraints_both_evaluated_correctly():
    """
    specs={"ram_gb": 16, "price_usd": 250}
    constraints: ram_gb gte 33 (FAIL), price_usd lte 300 (PASS)
    """
    engine = make_engine()
    specs = {"ram_gb": 16, "price_usd": 250}
    constraints = [
        HardConstraint(attribute="ram_gb", operator="gte", value=33.0),
        HardConstraint(attribute="price_usd", operator="lte", value=300.0),
    ]
    results = engine.evaluate_product(specs, constraints)
    assert results["ram_gb"] == ConstraintResult.FAIL
    assert results["price_usd"] == ConstraintResult.PASS


# ---------------------------------------------------------------------------
# rank_products — sorting
# ---------------------------------------------------------------------------

def test_products_ranked_zero_fails_first():
    """Product with no FAILs should rank before product with FAILs."""
    engine = make_engine()
    constraints = [
        HardConstraint(attribute="ram_gb", operator="gte", value=16.0),
        HardConstraint(attribute="price_usd", operator="lte", value=1000.0),
    ]
    requirements = make_requirements(constraints)

    # Product A: passes both
    product_a = {
        "name": "Good Laptop",
        "price": 900.0,
        "currency": "USD",
        "specs_json": {"ram_gb": 32, "price_usd": 900},
    }
    # Product B: fails RAM
    product_b = {
        "name": "Bad Laptop",
        "price": 850.0,
        "currency": "USD",
        "specs_json": {"ram_gb": 8, "price_usd": 850},
    }

    ranked = engine.rank_products([product_b, product_a], requirements)

    # Good Laptop (no FAILs) should be first
    assert ranked[0]["name"] == "Good Laptop"
    assert ranked[1]["name"] == "Bad Laptop"


def test_ranking_score_all_pass_higher_than_with_fail():
    """All-PASS product has higher ranking_score than product with a FAIL."""
    engine = make_engine()
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    requirements = make_requirements(constraints)

    all_pass = {"name": "A", "price": 900.0, "specs_json": {"ram_gb": 32}}
    has_fail = {"name": "B", "price": 900.0, "specs_json": {"ram_gb": 8}}

    ranked = engine.rank_products([has_fail, all_pass], requirements)

    all_pass_score = next(p["ranking_score"] for p in ranked if p["name"] == "A")
    has_fail_score = next(p["ranking_score"] for p in ranked if p["name"] == "B")

    assert all_pass_score > has_fail_score


def test_ranking_score_clamped_between_0_and_1():
    """ranking_score must always be in [0.0, 1.0]."""
    engine = make_engine()
    constraints = [
        HardConstraint(attribute="ram_gb", operator="gte", value=16.0),
        HardConstraint(attribute="price_usd", operator="lte", value=1000.0),
    ]
    requirements = make_requirements(constraints)

    products = [
        {"name": "A", "price": 500.0, "specs_json": {"ram_gb": 32, "price_usd": 500}},
        {"name": "B", "price": 1500.0, "specs_json": {"ram_gb": 8, "price_usd": 1500}},
    ]
    ranked = engine.rank_products(products, requirements)

    for p in ranked:
        assert 0.0 <= p["ranking_score"] <= 1.0


def test_ranking_confidence_reduced_by_unknowns():
    """Product with 3 UNKNOWN constraints has ranking_confidence < 1.0."""
    engine = make_engine()
    # Create 3 constraints for attributes that are absent from specs
    constraints = [
        HardConstraint(attribute="attr1", operator="gte", value=1.0),
        HardConstraint(attribute="attr2", operator="gte", value=1.0),
        HardConstraint(attribute="attr3", operator="gte", value=1.0),
    ]
    requirements = make_requirements(constraints)

    product = {"name": "Mystery", "price": 500.0, "specs_json": {}}  # all specs missing
    ranked = engine.rank_products([product], requirements)

    assert ranked[0]["ranking_confidence"] < 1.0


def test_unknown_reduces_confidence_formula():
    """Each UNKNOWN reduces confidence by 0.15 (clamped at 0)."""
    engine = make_engine()
    # 3 unknowns: expected confidence = max(0, 1.0 - 3*0.15) = 0.55
    constraints = [
        HardConstraint(attribute="a", operator="gte", value=1.0),
        HardConstraint(attribute="b", operator="gte", value=1.0),
        HardConstraint(attribute="c", operator="gte", value=1.0),
    ]
    requirements = make_requirements(constraints)
    product = {"name": "X", "price": 100.0, "specs_json": {}}
    ranked = engine.rank_products([product], requirements)

    expected_confidence = max(0.0, 1.0 - 3 * 0.15)
    assert abs(ranked[0]["ranking_confidence"] - expected_confidence) < 1e-9


def test_no_constraints_gives_score_half():
    """With no constraints, ranking_score should be 0.5."""
    engine = make_engine()
    requirements = make_requirements([])
    product = {"name": "X", "price": 100.0, "specs_json": {"some": "spec"}}
    ranked = engine.rank_products([product], requirements)
    assert ranked[0]["ranking_score"] == 0.5


def test_ranked_products_sorted_by_fail_then_pass_then_price():
    """Verify sort order: fail_count asc -> pass_count desc -> price asc."""
    engine = make_engine()
    constraints = [
        HardConstraint(attribute="ram_gb", operator="gte", value=16.0),
        HardConstraint(attribute="price_usd", operator="lte", value=1000.0),
    ]
    requirements = make_requirements(constraints)

    # product_c: 0 fails, 2 passes, price=800
    product_c = {"name": "C", "price": 800.0, "specs_json": {"ram_gb": 32, "price_usd": 800}}
    # product_a: 0 fails, 2 passes, price=900 (same fail/pass as C but higher price)
    product_a = {"name": "A", "price": 900.0, "specs_json": {"ram_gb": 32, "price_usd": 900}}
    # product_b: 1 fail, 1 pass
    product_b = {"name": "B", "price": 700.0, "specs_json": {"ram_gb": 8, "price_usd": 700}}

    ranked = engine.rank_products([product_a, product_b, product_c], requirements)

    names = [p["name"] for p in ranked]
    # C and A both have 0 fails/2 passes, lower price (C=800) goes first
    assert names[0] == "C"
    assert names[1] == "A"
    assert names[2] == "B"


def test_constraint_results_in_output():
    """Each ranked product must have a constraint_results dict."""
    engine = make_engine()
    constraints = [HardConstraint(attribute="ram_gb", operator="gte", value=16.0)]
    requirements = make_requirements(constraints)
    product = {"name": "X", "price": 500.0, "specs_json": {"ram_gb": 32}}
    ranked = engine.rank_products([product], requirements)
    assert "constraint_results" in ranked[0]
    assert "ram_gb" in ranked[0]["constraint_results"]
    assert ranked[0]["constraint_results"]["ram_gb"] == "PASS"


def test_ranking_confidence_in_output():
    """Each ranked product must have a ranking_confidence field."""
    engine = make_engine()
    requirements = make_requirements([])
    product = {"name": "X", "price": 500.0, "specs_json": {}}
    ranked = engine.rank_products([product], requirements)
    assert "ranking_confidence" in ranked[0]
