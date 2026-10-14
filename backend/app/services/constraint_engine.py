import re
from enum import Enum
from typing import List, Dict, Any

from app.schemas.requirements import HardConstraint, ShoppingRequirements


class ConstraintResult(str, Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    UNKNOWN = "UNKNOWN"


def _parse_numeric(value: Any) -> float:
    """
    Strip non-numeric characters and return a float.
    E.g. "16GB" -> 16.0, "$999.99" -> 999.99, 16 -> 16.0
    Returns float('nan') if conversion fails.
    """
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        cleaned = re.sub(r"[^\d.]", "", value)
        try:
            return float(cleaned)
        except ValueError:
            pass
    return float("nan")


class ConstraintEngine:
    """Deterministic constraint evaluator — no AI calls."""

    def evaluate_product(
        self,
        product_specs: dict,
        hard_constraints: List[HardConstraint],
    ) -> Dict[str, ConstraintResult]:
        """
        Evaluate each hard constraint against product_specs.

        Rules:
        - Absent or None attribute -> UNKNOWN (never PASS)
        - Numeric comparison after stripping non-numeric chars
        - contains: case-insensitive substring check
        """
        results: Dict[str, ConstraintResult] = {}

        for constraint in hard_constraints:
            attr = constraint.attribute
            raw_spec = product_specs.get(attr)

            if raw_spec is None:
                results[attr] = ConstraintResult.UNKNOWN
                continue

            operator = constraint.operator
            constraint_value = constraint.value

            if operator == "contains":
                # String / substring check
                spec_str = str(raw_spec).lower()
                cmp_str = str(constraint_value).lower()
                results[attr] = ConstraintResult.PASS if cmp_str in spec_str else ConstraintResult.FAIL
                continue

            # Numeric operators: gte, lte, eq, neq
            spec_num = _parse_numeric(raw_spec)
            cmp_num = _parse_numeric(constraint_value)

            if spec_num != spec_num or cmp_num != cmp_num:
                # NaN comparison — can't determine
                results[attr] = ConstraintResult.UNKNOWN
                continue

            if operator == "gte":
                results[attr] = ConstraintResult.PASS if spec_num >= cmp_num else ConstraintResult.FAIL
            elif operator == "lte":
                results[attr] = ConstraintResult.PASS if spec_num <= cmp_num else ConstraintResult.FAIL
            elif operator == "eq":
                results[attr] = ConstraintResult.PASS if spec_num == cmp_num else ConstraintResult.FAIL
            elif operator == "neq":
                results[attr] = ConstraintResult.PASS if spec_num != cmp_num else ConstraintResult.FAIL
            else:
                results[attr] = ConstraintResult.UNKNOWN

        return results

    def rank_products(
        self,
        products: List[dict],
        requirements: ShoppingRequirements,
    ) -> List[dict]:
        """
        Evaluate and rank a list of product dicts.

        Each product must have a "specs_json" key (dict or None).
        Returns a new list of dicts, each augmented with:
          - constraint_results: Dict[str, str]
          - ranking_score: float (0.0 – 1.0)
          - ranking_confidence: float (0.0 – 1.0)

        Sort order: fewer FAILs first, then more PASSes, then lower price.
        """
        hard_constraints = requirements.hard_constraints
        total = len(hard_constraints)

        ranked = []
        for product in products:
            specs = product.get("specs_json") or {}
            constraint_results = self.evaluate_product(specs, hard_constraints)

            pass_count = sum(1 for v in constraint_results.values() if v == ConstraintResult.PASS)
            fail_count = sum(1 for v in constraint_results.values() if v == ConstraintResult.FAIL)
            unknown_count = sum(1 for v in constraint_results.values() if v == ConstraintResult.UNKNOWN)

            if total > 0:
                ranking_score = (pass_count / total) * (1 - fail_count / total)
            else:
                ranking_score = 0.5

            ranking_confidence = max(0.0, 1.0 - unknown_count * 0.15)

            augmented = dict(product)
            augmented["constraint_results"] = {k: v.value for k, v in constraint_results.items()}
            augmented["ranking_score"] = ranking_score
            augmented["ranking_confidence"] = ranking_confidence
            augmented["_fail_count"] = fail_count
            augmented["_pass_count"] = pass_count
            ranked.append(augmented)

        # Sort: fewer FAILs first, more PASSes, lower price
        ranked.sort(
            key=lambda p: (
                p["_fail_count"],
                -p["_pass_count"],
                float(p.get("price", 0)),
            )
        )

        # Remove internal sort keys
        for p in ranked:
            p.pop("_fail_count", None)
            p.pop("_pass_count", None)

        return ranked


# Module-level singleton
constraint_engine = ConstraintEngine()
