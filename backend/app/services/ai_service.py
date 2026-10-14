import json
import logging
import re
from typing import Optional, Dict, Any

import httpx

from app.config import settings
from app.core.exceptions import AIRefusalError, AIInvalidOutputError
from app.schemas.requirements import (
    HardConstraint,
    SoftPreference,
    ShoppingRequirements,
)

logger = logging.getLogger("proofbuy")

# JSON Schema for ShoppingRequirements used in OpenAI structured output
_REQUIREMENTS_JSON_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "properties": {
        "product_category": {"type": "string"},
        "hard_constraints": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "attribute": {"type": "string"},
                    "operator": {"type": "string"},
                    "value": {},
                    "unit": {"type": ["string", "null"]},
                },
                "required": ["attribute", "operator", "value"],
                "additionalProperties": False,
            },
        },
        "soft_preferences": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "attribute": {"type": "string"},
                    "direction": {"type": "string"},
                    "weight": {"type": "number"},
                },
                "required": ["attribute", "direction", "weight"],
                "additionalProperties": False,
            },
        },
        "budget_max": {"type": ["number", "null"]},
        "budget_currency": {"type": "string"},
        "quantity": {"type": "integer"},
        "use_case": {"type": ["string", "null"]},
        "search_query": {"type": "string"},
        "clarification_needed": {
            "type": "array",
            "items": {"type": "string"},
        },
    },
    "required": [
        "product_category",
        "hard_constraints",
        "soft_preferences",
        "budget_max",
        "budget_currency",
        "quantity",
        "use_case",
        "search_query",
        "clarification_needed",
    ],
    "additionalProperties": False,
}

_SYSTEM_PROMPT = (
    "You are a precise shopping assistant. Extract structured shopping requirements "
    "from the user's brief. Output valid JSON only. "
    "Never set budget_max higher than any amount explicitly stated by the user."
)


def _extract_dollar_amounts(text: str) -> list:
    """Return list of float dollar amounts found in text (e.g. $500, $1,000)."""
    pattern = r"\$\s*([\d,]+(?:\.\d+)?)"
    matches = re.findall(pattern, text)
    return [float(m.replace(",", "")) for m in matches]


class AIService:
    """AI service for extracting shopping requirements and generating explanations."""

    async def extract_requirements(self, brief_text: str) -> ShoppingRequirements:
        """
        Extract structured ShoppingRequirements from a plain-text brief.

        In mock mode (no API key): returns a deterministic stub.
        In real mode: calls OpenAI GPT-4o with structured output.
        """
        if not settings.ai_provider_api_key:
            logger.info(
                "AI service running in MOCK MODE — set OPENAI_API_KEY for real extractions"
            )
            return self._mock_requirements(brief_text)

        return await self._real_extract_requirements(brief_text)

    def _mock_requirements(self, brief_text: str) -> ShoppingRequirements:
        """Return a deterministic mock ShoppingRequirements."""
        if "laptop" in brief_text.lower():
            return ShoppingRequirements(
                product_category="laptop",
                hard_constraints=[
                    HardConstraint(attribute="ram_gb", operator="gte", value=16.0, unit="GB"),
                    HardConstraint(attribute="price_usd", operator="lte", value=1000.0, unit="USD"),
                ],
                soft_preferences=[],
                budget_max=1000.0,
                budget_currency="USD",
                quantity=1,
                use_case=None,
                search_query="laptop 16GB RAM under $1000",
                clarification_needed=[],
            )
        return ShoppingRequirements(
            product_category="general",
            hard_constraints=[],
            soft_preferences=[],
            budget_max=None,
            budget_currency="USD",
            quantity=1,
            use_case=None,
            search_query=brief_text[:100],
            clarification_needed=["Please specify the product type and budget"],
        )

    async def _real_extract_requirements(self, brief_text: str) -> ShoppingRequirements:
        """Call OpenAI and parse the structured response."""
        payload = {
            "model": "gpt-4o-2024-08-06",
            "messages": [
                {"role": "system", "content": _SYSTEM_PROMPT},
                {"role": "user", "content": brief_text},
            ],
            "response_format": {
                "type": "json_schema",
                "json_schema": {
                    "name": "shopping_requirements",
                    "strict": True,
                    "schema": _REQUIREMENTS_JSON_SCHEMA,
                },
            },
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.ai_provider_api_key}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )
            response.raise_for_status()

        data = response.json()
        choice = data["choices"][0]

        # Check for refusal
        if choice.get("finish_reason") == "refusal" or choice["message"].get("refusal"):
            raise AIRefusalError("AI model refused to process the request")

        raw_content = choice["message"]["content"]

        try:
            parsed = json.loads(raw_content)
        except (json.JSONDecodeError, TypeError) as exc:
            raise AIInvalidOutputError(f"AI returned non-JSON content: {exc}") from exc

        try:
            requirements = ShoppingRequirements(**parsed)
        except Exception as exc:
            raise AIInvalidOutputError(f"AI output failed schema validation: {exc}") from exc

        # Post-validation: budget_max must not exceed any stated dollar amount
        dollar_amounts = _extract_dollar_amounts(brief_text)
        if requirements.budget_max is not None and dollar_amounts:
            if requirements.budget_max > max(dollar_amounts):
                raise AIInvalidOutputError(
                    f"AI set budget_max={requirements.budget_max} which exceeds "
                    f"the stated amount(s) {dollar_amounts}"
                )

        return requirements

    async def generate_explanation(
        self,
        product: dict,
        requirements: ShoppingRequirements,
        constraint_results: dict,
    ) -> str:
        """
        Generate a 2-3 sentence explanation for why a product matches requirements.

        Only cites PASS/FAIL attributes, acknowledges UNKNOWN ones.
        Mock mode returns a template string.
        """
        if not settings.ai_provider_api_key:
            return self._mock_explanation(product, constraint_results)

        return await self._real_generate_explanation(product, requirements, constraint_results)

    def _mock_explanation(self, product: dict, constraint_results: dict) -> str:
        """Return a template explanation without calling the API."""
        name = product.get("name", "This product")
        passes = [k for k, v in constraint_results.items() if v == "PASS"]
        fails = [k for k, v in constraint_results.items() if v == "FAIL"]
        unknowns = [k for k, v in constraint_results.items() if v == "UNKNOWN"]

        parts = [f"{name} was evaluated against your requirements."]
        if passes:
            parts.append(f"It meets: {', '.join(passes)}.")
        if fails:
            parts.append(f"It does not meet: {', '.join(fails)}.")
        if unknowns:
            parts.append(f"Specs unavailable for: {', '.join(unknowns)}.")
        return " ".join(parts)

    async def _real_generate_explanation(
        self,
        product: dict,
        requirements: ShoppingRequirements,
        constraint_results: dict,
    ) -> str:
        """Call OpenAI to generate an evidence-backed explanation."""
        # Only include PASS/FAIL results in context; note UNKNOWNs separately
        known_results = {k: v for k, v in constraint_results.items() if v != "UNKNOWN"}
        unknown_attrs = [k for k, v in constraint_results.items() if v == "UNKNOWN"]

        prompt = (
            f"Product: {product.get('name', 'Unknown')} at ${product.get('price', '?')}\n"
            f"Specs: {json.dumps(product.get('specs_json', {}))}\n"
            f"Constraint results: {json.dumps(known_results)}\n"
            f"Unknown specs: {unknown_attrs}\n\n"
            "Write a 2-3 sentence explanation (under 100 words) for why this product "
            "does or does not meet the requirements. Only cite attributes with known results. "
            "Acknowledge unknown attributes explicitly. Never fabricate specs."
        )

        payload = {
            "model": "gpt-4o-2024-08-06",
            "messages": [
                {"role": "system", "content": "You are a concise product reviewer."},
                {"role": "user", "content": prompt},
            ],
            "max_tokens": 150,
        }

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    "https://api.openai.com/v1/chat/completions",
                    headers={
                        "Authorization": f"Bearer {settings.ai_provider_api_key}",
                        "Content-Type": "application/json",
                    },
                    json=payload,
                )
                response.raise_for_status()
            data = response.json()
            return data["choices"][0]["message"]["content"].strip()
        except Exception as exc:
            logger.warning("generate_explanation API call failed, using fallback: %s", exc)
            return self._mock_explanation(product, constraint_results)


# Module-level singleton — preserves `from app.services import ai_service` import pattern
ai_service = AIService()
