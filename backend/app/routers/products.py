from datetime import datetime, timezone
from typing import List, Optional
from uuid import uuid4

from fastapi import APIRouter, Depends, Request
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.rate_limiter import limiter
from app.database import get_db
from app.models.product_result import ProductResult
from app.models.shopping_session import ShoppingSession
from app.schemas.product import NormalizedProduct, ProductResultResponse, RankedProduct
from app.schemas.requirements import ShoppingRequirements
from app.services.constraint_engine import constraint_engine
from app.services.ai_service import ai_service
from app.services import channel3_service
from app.services.channel3_service import get_channel3_service, MOCK_PRODUCTS
from app.core.exceptions import NotFoundError, ValidationError
import random

router = APIRouter(prefix="/api/v1/products", tags=["products"])


# ── Random / popular products (for browse) ────────────────────────────────────

@router.get("/random", response_model=List[NormalizedProduct])
@limiter.limit("30/minute")
async def get_random_products(
    request: Request,
    limit: int = 12,
):
    """Return a randomized selection of products for browsing."""
    svc = get_channel3_service()
    if svc._is_mock():
        pool = list(MOCK_PRODUCTS)
        random.shuffle(pool)
        return pool[:limit]

    # Real mode: search broadly and shuffle, fall back to mock on error
    try:
        products = await svc.search_products("", limit=limit * 3)
        random.shuffle(products)
        return products[:limit]
    except Exception:
        pool = list(MOCK_PRODUCTS)
        random.shuffle(pool)
        return pool[:limit]


# ── Categories ────────────────────────────────────────────────────────────────

@router.get("/categories", response_model=List[str])
@limiter.limit("30/minute")
async def get_categories(
    request: Request,
):
    """Return a list of product categories for browsing."""
    svc = get_channel3_service()
    if svc._is_mock():
        cats = sorted({p.category_title for p in MOCK_PRODUCTS if p.category_title})
        return list(cats)

    try:
        products = await svc.search_products("", limit=100)
        cats = sorted({p.category_title for p in products if p.category_title})
        return list(cats)
    except Exception:
        cats = sorted({p.category_title for p in MOCK_PRODUCTS if p.category_title})
        return list(cats)


@router.get("/detail/{channel3_product_id}")
@limiter.limit("30/minute")
async def get_product_detail(
    request: Request,
    channel3_product_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Return full rich product data for a single Channel3 product ID."""
    svc = get_channel3_service()
    product = await svc.get_product_detail(channel3_product_id)

    if product is None:
        # Fall back to DB lookup
        result = await db.execute(
            select(ProductResult).where(
                ProductResult.channel3_product_id == channel3_product_id
            )
        )
        p = result.scalars().first()
        if p is None:
            raise NotFoundError(f"Product '{channel3_product_id}' not found")
        # Return DB record as a basic dict
        return JSONResponse(content={
            "channel3_product_id": p.channel3_product_id,
            "name": p.name,
            "price": p.price,
            "currency": p.currency,
            "merchant": p.merchant,
            "source_url": p.source_url,
            "specs_json": p.specs_json,
            "retrieved_at": p.retrieved_at.isoformat() if p.retrieved_at else None,
            "all_images": [],
            "all_offers": [],
            "ratings": None,
        })

    # Serialize NormalizedProduct to dict, converting datetime fields to ISO strings
    data = product.model_dump()
    if isinstance(data.get("retrieved_at"), datetime):
        data["retrieved_at"] = data["retrieved_at"].isoformat()

    return JSONResponse(content=data)


@router.get("/{session_id}", response_model=List[RankedProduct])
@limiter.limit("30/minute")
async def get_products_for_session(
    request: Request,
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

        # Generate UUID explicitly before object creation — used in the response
        # and also passed as id= to ensure consistency.
        product_id = str(uuid4())

        # Pass currency as-is (None if unknown) — do NOT default to "USD"
        product_row = ProductResult(
            id=product_id,
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

        # Build the product dict with ALL fields Flutter needs
        product_dict = {
            **ranked_product,
            "id": product_id,  # DB UUID for checkout
            "image_url": ranked_product.get("image_url"),
        }

        response_items.append(
            RankedProduct(
                id=product_id,
                product=product_dict,
                constraint_results=constraint_results,
                ranking_score=ranking_score,
                ranking_confidence=ranking_confidence,
                explanation=explanation,
            )
        )

    await db.commit()

    return response_items
