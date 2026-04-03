from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..auth.middleware import get_current_user
from ..core.database import get_db
from ..models import BankAccount
from ..schemas import BankAccountCreate, BankAccountResponse
from ..services.local_fallback import (
    add_bank_account as local_add_bank_account,
    list_bank_accounts as local_list_bank_accounts,
)

router = APIRouter(prefix="/bank", tags=["Bank Accounts"])


@router.get("/accounts", response_model=list[BankAccountResponse])
async def list_accounts(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await db.execute(select(BankAccount).where(BankAccount.user_id == current_user["sub"]))
        accounts = result.scalars().all()
        return [BankAccountResponse.model_validate(a) for a in accounts]
    except Exception:
        accounts = local_list_bank_accounts(current_user["sub"])
        return [BankAccountResponse.model_validate(a) for a in accounts]


@router.post("/accounts", response_model=BankAccountResponse, status_code=201)
async def create_account(
    payload: BankAccountCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        if payload.is_default:
            result = await db.execute(select(BankAccount).where(BankAccount.user_id == current_user["sub"]))
            for account in result.scalars().all():
                account.is_default = False

        account = BankAccount(
            user_id=current_user["sub"],
            bank_name=payload.bank_name,
            account_number=payload.account_number,
            ifsc_code=payload.ifsc_code,
            is_default=payload.is_default,
        )
        db.add(account)
        await db.commit()
        await db.refresh(account)
        return BankAccountResponse.model_validate(account)
    except Exception:
        account = local_add_bank_account(
            user_id=current_user["sub"],
            bank_name=payload.bank_name,
            account_number=payload.account_number,
            ifsc_code=payload.ifsc_code,
            is_default=payload.is_default,
        )
        return BankAccountResponse.model_validate(account)
