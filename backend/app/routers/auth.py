import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from ..auth.jwt_handler import create_token
from ..auth.middleware import get_current_user
from ..auth.otp_handler import debug_otp_hint, normalize_indian_phone, request_otp_call, verify_otp_code
from ..core.config import get_settings
from ..core.database import get_db
from ..core.security import hash_password
from ..models import User, BankAccount
from ..schemas import PhoneLoginRequest, OTPVerifyRequest, TokenResponse, UserResponse
from ..services.local_fallback import get_or_create_user, get_user_by_id

router = APIRouter(prefix="/auth", tags=["Authentication"])
settings = get_settings()
STARTING_WALLET_BALANCE = 19748.45


@router.post("/request-otp", response_model=dict)
async def request_otp(request: PhoneLoginRequest):
    normalized = request_otp_call(request.phone)
    response = {"message": "OTP call initiated", "phone": normalized}
    code = debug_otp_hint(normalized)
    if code:
        response["message"] = "OTP fallback enabled (debug mode)"
        response["debug_otp"] = code
    return response


@router.post("/send-otp", response_model=dict)
async def send_otp_alias(request: PhoneLoginRequest):
    """Backward compatible alias for older clients."""
    normalized = request_otp_call(request.phone)
    response = {"message": "OTP call initiated", "phone": normalized}
    code = debug_otp_hint(normalized)
    if code:
        response["message"] = "OTP fallback enabled (debug mode)"
        response["debug_otp"] = code
    return response


@router.post("/guest-login", response_model=TokenResponse)
async def guest_login(db: AsyncSession = Depends(get_db)):
    if not settings.DEBUG:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Guest login disabled")

    guest_phone = "+919000000000"
    try:
        result = await db.execute(select(User).where(User.phone == guest_phone))
        user = result.scalar_one_or_none()
        if not user:
            user = User(
                phone=guest_phone,
                name="Guest User",
                password_hash=hash_password("guest"),
                upi_id="guest@genpay",
                wallet_balance=STARTING_WALLET_BALANCE,
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
        user_id = user.id
        phone = user.phone
    except Exception:
        fallback = get_or_create_user(guest_phone)
        user_id = fallback["id"]
        phone = fallback["phone"]

    token = create_token(
        {
            "user_id": user_id,
            "phone": phone,
            "session_id": str(uuid.uuid4()),
        }
    )
    return TokenResponse(access_token=token, user_id=user_id)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(request: OTPVerifyRequest, db: AsyncSession = Depends(get_db)):
    normalized_phone = normalize_indian_phone(request.phone)
    approved = verify_otp_code(normalized_phone, request.otp)
    if not approved:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid OTP")

    try:
        result = await db.execute(select(User).where(User.phone == normalized_phone))
        user = result.scalar_one_or_none()

        if not user:
            user = User(
                phone=normalized_phone,
                name=f"User {normalized_phone[-4:]}",
                password_hash=hash_password("default"),
                upi_id=f"{normalized_phone}@genpay",
                wallet_balance=STARTING_WALLET_BALANCE,
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)

            db.add(
                BankAccount(
                    user_id=user.id,
                    bank_name="State Bank of India",
                    account_number="30925678431",
                    ifsc_code="SBIN0001234",
                    upi_id=f"{normalized_phone}@sbi",
                    balance=45230.50,
                    is_default=True,
                )
            )
            await db.commit()

        token = create_token(
            {
                "user_id": user.id,
                "phone": user.phone,
                "session_id": str(uuid.uuid4()),
            }
        )
        return TokenResponse(access_token=token, user_id=user.id)
    except Exception:
        user = get_or_create_user(normalized_phone)
        token = create_token(
            {
                "user_id": user["id"],
                "phone": user["phone"],
                "session_id": str(uuid.uuid4()),
            }
        )
        return TokenResponse(access_token=token, user_id=user["id"])


@router.get("/me", response_model=UserResponse)
async def get_profile(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get current user profile."""
    user_id = current_user.get("user_id") or current_user.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token payload")

    try:
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user
    except Exception:
        user = get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return UserResponse.model_validate(user)
