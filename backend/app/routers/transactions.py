from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.transaction import Transaction
from app.models.purchase_record import PurchaseRecord
from app.models.product_result import ProductResult
from app.models.shopping_session import ShoppingSession
from app.schemas.transaction import (
    TransactionResponse,
    PurchaseRecordResponse,
    PurchaseHistoryItem,
)
from app.schemas.product import ProductResultResponse
from app.schemas.shopping import ShoppingSessionResponse
from app.core.exceptions import NotFoundError

router = APIRouter(prefix="/api/v1/transactions", tags=["transactions"])


@router.get("/{purchase_id}", response_model=TransactionResponse)
async def get_transaction(
    purchase_id: str,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Transaction).where(Transaction.purchase_record_id == purchase_id)
    )
    transaction = result.scalars().first()
    if not transaction:
        raise NotFoundError(f"Transaction for purchase '{purchase_id}' not found")
    return transaction


history_router = APIRouter(tags=["history"])


@history_router.get("/api/v1/history", response_model=List[PurchaseHistoryItem])
async def get_purchase_history(
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(PurchaseRecord))
    purchase_records = result.scalars().all()

    history = []
    for purchase in purchase_records:
        product = None
        session = None

        if purchase.product_result_id:
            pr_result = await db.execute(
                select(ProductResult).where(ProductResult.id == purchase.product_result_id)
            )
            product_row = pr_result.scalars().first()
            if product_row:
                product = ProductResultResponse.model_validate(product_row)

        if purchase.session_id:
            sess_result = await db.execute(
                select(ShoppingSession).where(ShoppingSession.id == purchase.session_id)
            )
            session_row = sess_result.scalars().first()
            if session_row:
                session = ShoppingSessionResponse.model_validate(session_row)

        history.append(
            PurchaseHistoryItem(
                purchase_record=PurchaseRecordResponse.model_validate(purchase),
                product=product,
                session=session,
            )
        )

    return history
