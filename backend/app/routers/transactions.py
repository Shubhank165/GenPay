from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional
from ..core.database import get_db
from ..core.security import get_current_user
from ..models import Transaction, TransactionStatus
from ..schemas import TransactionCreate, TransactionResponse, TransactionListResponse
import uuid
from datetime import datetime, timezone

router = APIRouter(prefix="/transactions", tags=["Transactions"])


@router.get("/", response_model=TransactionListResponse)
async def list_transactions(
    type: Optional[str] = None,
    status: Optional[str] = None,
    min_amount: Optional[float] = None,
    max_amount: Optional[float] = None,
    search: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List transactions with filtering — agent-friendly queryable endpoint."""
    query = select(Transaction).where(Transaction.user_id == current_user["sub"])

    if type:
        query = query.where(Transaction.type == type)
    if status:
        query = query.where(Transaction.status == status)
    if min_amount:
        query = query.where(Transaction.amount >= min_amount)
    if max_amount:
        query = query.where(Transaction.amount <= max_amount)
    if search:
        query = query.where(
            Transaction.recipient_name.ilike(f"%{search}%") |
            Transaction.description.ilike(f"%{search}%")
        )

    # Count total
    count_q = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_q)
    total = total_result.scalar()

    # Paginate
    query = query.order_by(Transaction.created_at.desc()).offset((page - 1) * page_size).limit(page_size)
    result = await db.execute(query)
    transactions = result.scalars().all()

    return TransactionListResponse(
        transactions=[TransactionResponse.model_validate(t) for t in transactions],
        total=total, page=page, page_size=page_size,
    )


@router.post("/", response_model=TransactionResponse, status_code=201)
async def create_transaction(
    data: TransactionCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new transaction — simulated processing."""
    txn = Transaction(
        id=str(uuid.uuid4()),
        user_id=current_user["sub"],
        type=data.type,
        status=TransactionStatus.SUCCESS,
        amount=data.amount,
        recipient_name=data.recipient_name,
        recipient_identifier=data.recipient_identifier,
        description=data.description,
        reference_id=f"REF{uuid.uuid4().hex[:12].upper()}",
    )
    db.add(txn)
    await db.commit()
    await db.refresh(txn)
    return txn
