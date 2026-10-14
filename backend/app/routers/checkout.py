from datetime import datetime, timezone
from uuid import uuid4

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.product_result import ProductResult
from app.models.purchase_record import PurchaseRecord
from app.models.transaction import Transaction
from app.schemas.checkout import (
    CheckoutCreateRequest,
    CheckoutCreateResponse,
    CheckoutCaptureRequest,
    CheckoutCaptureResponse,
)
from app.services.paypal_service import PayPalService, get_paypal_service
from app.core.exceptions import (
    NotFoundError,
    ValidationError,
    PayPalInstrumentDeclinedError,
    PayPalServiceError,
    PayPalDuplicateCaptureError,
)

router = APIRouter(prefix="/api/v1/checkout", tags=["checkout"])


@router.post("/create", response_model=CheckoutCreateResponse)
async def create_checkout(
    request: CheckoutCreateRequest,
    db: AsyncSession = Depends(get_db),
    paypal_service: PayPalService = Depends(get_paypal_service),
):
    # a. Load ProductResult — 404 if not found
    result = await db.execute(
        select(ProductResult).where(ProductResult.id == request.product_result_id)
    )
    product = result.scalars().first()
    if not product:
        raise NotFoundError(f"Product '{request.product_result_id}' not found")

    # b. Validate price and currency
    if not product.price or float(product.price) <= 0:
        raise ValidationError("Product price must be greater than 0")
    if len(product.currency) != 3:
        raise ValidationError("Product currency must be a 3-letter ISO code")

    # c. Idempotency: return existing non-failed purchase if one exists
    existing_result = await db.execute(
        select(PurchaseRecord).where(
            PurchaseRecord.product_result_id == product.id,
            PurchaseRecord.session_id == product.session_id,
            PurchaseRecord.status != "failed",
        )
    )
    existing_purchase = existing_result.scalars().first()
    if existing_purchase and existing_purchase.paypal_order_id:
        return CheckoutCreateResponse(
            order_id=existing_purchase.paypal_order_id,
            approval_url=(
                f"https://www.sandbox.paypal.com/checkoutnow?token={existing_purchase.paypal_order_id}"
            ),
            purchase_id=str(existing_purchase.id),
        )

    # d. Create PurchaseRecord
    purchase = PurchaseRecord(
        session_id=product.session_id,
        product_result_id=product.id,
        amount=product.price,
        currency=product.currency,
        status="pending",
        idempotency_key=str(uuid4()),
    )
    db.add(purchase)
    await db.flush()

    # e. Create PayPal order
    paypal_result = await paypal_service.create_order(
        str(purchase.id), float(product.price), product.currency
    )

    # f. Update purchase with order info
    purchase.paypal_order_id = paypal_result.order_id
    purchase.updated_at = datetime.now(timezone.utc)

    await db.commit()
    await db.refresh(purchase)

    return CheckoutCreateResponse(
        order_id=paypal_result.order_id,
        approval_url=paypal_result.approval_url,
        purchase_id=str(purchase.id),
    )


@router.post("/capture", response_model=CheckoutCaptureResponse)
async def capture_checkout(
    request: CheckoutCaptureRequest,
    db: AsyncSession = Depends(get_db),
    paypal_service: PayPalService = Depends(get_paypal_service),
):
    # a. Load PurchaseRecord — 404 if not found
    result = await db.execute(
        select(PurchaseRecord).where(PurchaseRecord.id == request.purchase_id)
    )
    purchase = result.scalars().first()
    if not purchase:
        raise NotFoundError(f"Purchase record '{request.purchase_id}' not found")

    # b. Verify order_id matches
    if purchase.paypal_order_id != request.order_id:
        raise ValidationError("order_id does not match purchase record")

    # c. Idempotency: already captured
    if purchase.status == "captured":
        txn_result = await db.execute(
            select(Transaction).where(
                Transaction.purchase_record_id == str(purchase.id)
            )
        )
        transaction = txn_result.scalars().first()
        if transaction:
            return CheckoutCaptureResponse(
                transaction_id=str(transaction.id),
                status="captured",
                verified=True,
            )

    # d. Capture via PayPal
    try:
        capture_result = await paypal_service.capture_order(request.order_id)
    except (PayPalInstrumentDeclinedError, PayPalServiceError):
        purchase.status = "failed"
        purchase.updated_at = datetime.now(timezone.utc)
        await db.commit()
        raise
    except PayPalDuplicateCaptureError:
        purchase.status = "captured"
        purchase.updated_at = datetime.now(timezone.utc)
        await db.commit()
        txn_result = await db.execute(
            select(Transaction).where(
                Transaction.purchase_record_id == str(purchase.id)
            )
        )
        transaction = txn_result.scalars().first()
        if transaction:
            return CheckoutCaptureResponse(
                transaction_id=str(transaction.id),
                status="captured",
                verified=True,
            )
        raise

    # e/f. Create Transaction and update purchase status
    if capture_result.verified:
        transaction = Transaction(
            purchase_record_id=str(purchase.id),
            paypal_capture_id=capture_result.capture_id,
            status="captured",
            verified_at=datetime.now(timezone.utc),
            raw_capture_json=None,
        )
        db.add(transaction)
        purchase.status = "captured"
    else:
        purchase.status = "failed"
        transaction = Transaction(
            purchase_record_id=str(purchase.id),
            paypal_capture_id=capture_result.capture_id,
            status="failed",
            verified_at=None,
            raw_capture_json=None,
        )
        db.add(transaction)

    purchase.updated_at = datetime.now(timezone.utc)
    await db.flush()
    await db.commit()
    await db.refresh(transaction)

    return CheckoutCaptureResponse(
        transaction_id=str(transaction.id),
        status=capture_result.status,
        verified=capture_result.verified,
    )
