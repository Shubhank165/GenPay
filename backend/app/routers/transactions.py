from fastapi import APIRouter, Depends, HTTPException, Query, status as http_status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional
from ..auth.middleware import get_current_user
from ..core.database import get_db
from ..models import Transaction, TransactionStatus
from ..schemas import TransactionCreate, TransactionResponse, TransactionListResponse
from ..services.local_fallback import list_transactions as local_list_transactions, create_transaction as local_create_transaction
import uuid

router = APIRouter(prefix="/transactions", tags=["Transactions"])
UPI_PIN = "165165"


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
    try:
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

        count_q = select(func.count()).select_from(query.subquery())
        total_result = await db.execute(count_q)
        total = total_result.scalar()

        query = query.order_by(Transaction.created_at.desc()).offset((page - 1) * page_size).limit(page_size)
        result = await db.execute(query)
        transactions = result.scalars().all()

        if not transactions:
            items = local_list_transactions(
                user_id=current_user["sub"],
                tx_type=type,
                tx_status=status,
                min_amount=min_amount,
                max_amount=max_amount,
                search=search,
            )
            total_local = len(items)
            start_local = (page - 1) * page_size
            paged_local = items[start_local : start_local + page_size]
            return TransactionListResponse(
                transactions=[TransactionResponse.model_validate(t) for t in paged_local],
                total=total_local,
                page=page,
                page_size=page_size,
            )

        return TransactionListResponse(
            transactions=[TransactionResponse.model_validate(t) for t in transactions],
            total=total,
            page=page,
            page_size=page_size,
        )
    except Exception:
        items = local_list_transactions(
            user_id=current_user["sub"],
            tx_type=type,
            tx_status=status,
            min_amount=min_amount,
            max_amount=max_amount,
            search=search,
        )
        total = len(items)
        start = (page - 1) * page_size
        paged = items[start : start + page_size]
        return TransactionListResponse(
            transactions=[TransactionResponse.model_validate(t) for t in paged],
            total=total,
            page=page,
            page_size=page_size,
        )


@router.post("/", response_model=TransactionResponse, status_code=201)
async def create_transaction(
    data: TransactionCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new transaction — simulated processing."""
    if data.upi_pin != UPI_PIN:
        raise HTTPException(
            status_code=http_status.HTTP_401_UNAUTHORIZED,
            detail="Invalid UPI PIN",
        )

    try:
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
    except Exception:
        txn = local_create_transaction(
            user_id=current_user["sub"],
            tx_type=data.type,
            amount=data.amount,
            recipient_name=data.recipient_name,
            recipient_identifier=data.recipient_identifier,
            description=data.description,
        )
        return TransactionResponse.model_validate(txn)


@router.post("/payment-failed", response_model=dict)
async def payment_failed_event(current_user: dict = Depends(get_current_user)):
    return {
        "message": "Payment failure event authenticated",
        "user_id": current_user.get("sub") or current_user.get("user_id"),
    }
