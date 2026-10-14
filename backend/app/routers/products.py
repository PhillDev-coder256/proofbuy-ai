from datetime import datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.product_result import ProductResult
from app.models.shopping_session import ShoppingSession
from app.schemas.product import ProductResultResponse, RankedProduct
from app.schemas.requirements import ShoppingRequirements
from app.services.constraint_engine import constraint_engine
from app.services.ai_service import ai_service
from app.services import channel3_service
from app.core.exceptions import NotFoundError, ValidationError

router = APIRouter(prefix="/api/v1/products", tags=["products"])


@router.get("/{session_id}", response_model=List[RankedProduct])
async def get_products_for_session(
    session_id: str,
    db: AsyncSession = Depends(get_db),
):
    # 1. Load ShoppingSession
    session_result = await db.execute(
        select(ShoppingSession).where(ShoppingSession.id == session_id)
    )
    session = session_result.scalars().first()
    if not session:
        raise NotFoundError(f"Shopping session '{session_id}' not found")

    # 2. Check requirements are present
    if session.requirements_json is None:
        raise ValidationError("Session has no requirements — submit brief first")

    # 3. Reconstruct ShoppingRequirements
    requirements = ShoppingRequirements(**session.requirements_json)

    # 4. Search products via channel3
    products_data = await channel3_service.search_products(
        requirements.search_query, session_id
    )

    # 5. Rank products using ConstraintEngine
    ranked = constraint_engine.rank_products(products_data, requirements)

    # 6. Persist products to DB and generate explanations for top 3
    response_items: List[RankedProduct] = []
    for i, ranked_product in enumerate(ranked):
        constraint_results = ranked_product.get("constraint_results", {})
        ranking_score = ranked_product.get("ranking_score", 0.5)
        ranking_confidence = ranked_product.get("ranking_confidence", 1.0)

        # Skip products with no price — cannot persist (price column is NOT NULL)
        # and cannot create a valid checkout. Log and continue.
        if ranked_product.get("price") is None:
            import logging
            logging.getLogger("proofbuy").warning(
                "Skipping product '%s' — price is None (data_complete=False)",
                ranked_product.get("channel3_product_id"),
            )
            continue

        # Generate explanation for top 3
        explanation: Optional[str] = None
        if i < 3:
            explanation = await ai_service.generate_explanation(
                product=ranked_product,
                requirements=requirements,
                constraint_results=constraint_results,
            )

        # Persist product result to DB
        retrieved_at_raw = ranked_product.get("retrieved_at")
        if isinstance(retrieved_at_raw, str):
            retrieved_at = datetime.fromisoformat(retrieved_at_raw)
        else:
            retrieved_at = retrieved_at_raw

        # Pass currency as-is (None if unknown) — do NOT default to "USD"
        product_row = ProductResult(
            session_id=session_id,
            channel3_product_id=ranked_product.get("channel3_product_id"),
            name=ranked_product["name"],
            price=ranked_product["price"],
            currency=ranked_product.get("currency"),
            merchant=ranked_product.get("merchant"),
            specs_json=ranked_product.get("specs_json"),
            source_url=ranked_product.get("source_url"),
            constraint_results_json=constraint_results,
            ranking_score=ranking_score,
            retrieved_at=retrieved_at,
        )
        db.add(product_row)

        response_items.append(
            RankedProduct(
                product=ranked_product,
                constraint_results=constraint_results,
                ranking_score=ranking_score,
                ranking_confidence=ranking_confidence,
                explanation=explanation,
            )
        )

    await db.commit()

    return response_items
