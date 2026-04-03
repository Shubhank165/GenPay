from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional
from ..auth.middleware import get_current_user
from ..core.database import get_db
from ..models import RechargePlan, Bill, BillCategory, Offer
from ..schemas import RechargePlanResponse, BillResponse, BillPayRequest, OfferResponse
from ..services.local_fallback import (
    get_recharge_plans as local_get_recharge_plans,
    get_bills as local_get_bills,
    pay_bill as local_pay_bill,
    get_offers as local_get_offers,
)

router = APIRouter(prefix="/services", tags=["Recharge, Bills & Offers"])


@router.get("/recharge/plans", response_model=list[RechargePlanResponse])
async def get_recharge_plans(
    operator: Optional[str] = None,
    plan_type: Optional[str] = None,
    max_price: Optional[float] = None,
    db: AsyncSession = Depends(get_db),
):
    """Get recharge plans — agent-queryable by operator, type, price."""
    try:
        query = select(RechargePlan).where(RechargePlan.is_active == True)
        if operator:
            query = query.where(RechargePlan.operator.ilike(f"%{operator}%"))
        if plan_type:
            query = query.where(RechargePlan.plan_type == plan_type)
        if max_price:
            query = query.where(RechargePlan.price <= max_price)
        query = query.order_by(RechargePlan.price.asc())
        result = await db.execute(query)
        return [RechargePlanResponse.model_validate(p) for p in result.scalars().all()]
    except Exception:
        plans = local_get_recharge_plans(operator, plan_type, max_price)
        return [RechargePlanResponse.model_validate(p) for p in plans]


@router.get("/bills", response_model=list[BillResponse])
async def get_bills(
    category: Optional[str] = None,
    unpaid_only: bool = False,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get user bills — agent can query pending/overdue bills."""
    try:
        query = select(Bill).where(Bill.user_id == current_user["sub"])
        if category:
            query = query.where(Bill.category == category)
        if unpaid_only:
            query = query.where(Bill.is_paid == False)
        result = await db.execute(query)
        return [BillResponse.model_validate(b) for b in result.scalars().all()]
    except Exception:
        bills = local_get_bills(current_user["sub"], category, unpaid_only)
        return [BillResponse.model_validate(b) for b in bills]


@router.post("/bills/pay", response_model=dict)
async def pay_bill(
    data: BillPayRequest,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Pay a bill — simulated."""
    from fastapi import HTTPException

    try:
        result = await db.execute(select(Bill).where(Bill.id == data.bill_id))
        bill = result.scalar_one_or_none()
        if not bill:
            raise HTTPException(status_code=404, detail="Bill not found")
        bill.is_paid = True
        await db.commit()
        return {"message": "Bill paid successfully", "bill_id": bill.id, "amount": bill.amount}
    except HTTPException:
        raise
    except Exception:
        bill = local_pay_bill(current_user["sub"], data.bill_id)
        if not bill:
            raise HTTPException(status_code=404, detail="Bill not found")
        return {"message": "Bill paid successfully", "bill_id": bill["id"], "amount": bill["amount"]}


@router.get("/offers", response_model=list[OfferResponse])
async def get_offers(
    category: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    """Get active offers — agent can recommend relevant offers."""
    try:
        query = select(Offer).where(Offer.is_active == True)
        if category:
            query = query.where(Offer.category == category)
        result = await db.execute(query)
        return [OfferResponse.model_validate(o) for o in result.scalars().all()]
    except Exception:
        offers = local_get_offers(category)
        return [OfferResponse.model_validate(o) for o in offers]
