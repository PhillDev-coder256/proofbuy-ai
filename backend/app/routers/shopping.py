from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.shopping_session import ShoppingSession
from app.schemas.shopping import (
    ShoppingBriefRequest,
    ShoppingBriefResponse,
    ShoppingSessionResponse,
)
from app.services.ai_service import ai_service
from app.core.exceptions import NotFoundError

router = APIRouter(prefix="/api/v1/shopping", tags=["shopping"])


@router.post("/brief", response_model=ShoppingBriefResponse)
async def submit_brief(
    request: ShoppingBriefRequest,
    db: AsyncSession = Depends(get_db),
):
    session = ShoppingSession(
        brief_text=request.brief,
        status="processing",
    )
    db.add(session)
    await db.flush()

    requirements = await ai_service.extract_requirements(request.brief)
    session.requirements_json = requirements.model_dump()
    session.status = "complete"
    session.updated_at = datetime.now(timezone.utc)

    await db.commit()
    await db.refresh(session)

    return ShoppingBriefResponse(
        session_id=str(session.id),
        status=session.status,
        message="Brief received and processed",
        requirements=session.requirements_json,
    )


@router.get("/{session_id}", response_model=ShoppingSessionResponse)
async def get_session(
    session_id: str,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ShoppingSession).where(ShoppingSession.id == session_id)
    )
    session = result.scalars().first()
    if not session:
        raise NotFoundError(f"Shopping session '{session_id}' not found")
    return session
