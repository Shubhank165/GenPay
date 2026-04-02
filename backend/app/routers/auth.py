from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ..core.database import get_db
from ..core.security import hash_password, verify_password, create_access_token, get_current_user
from ..models import User
from ..schemas import PhoneLoginRequest, OTPVerifyRequest, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/send-otp", response_model=dict)
async def send_otp(request: PhoneLoginRequest, db: AsyncSession = Depends(get_db)):
    """Send OTP to phone number (simulated — always succeeds)."""
    return {"message": "OTP sent successfully", "phone": request.phone}


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(request: OTPVerifyRequest, db: AsyncSession = Depends(get_db)):
    """Verify OTP and return JWT token. Simulated: any 6-digit OTP works."""
    result = await db.execute(select(User).where(User.phone == request.phone))
    user = result.scalar_one_or_none()

    if not user:
        # Auto-register new user
        user = User(
            phone=request.phone,
            name=f"User {request.phone[-4:]}",
            password_hash=hash_password("default"),
            upi_id=f"{request.phone}@genpay",
            wallet_balance=2450.75,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

    token = create_access_token({"sub": user.id, "phone": user.phone})
    return TokenResponse(access_token=token, user_id=user.id)


@router.get("/me", response_model=UserResponse)
async def get_profile(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get current user profile."""
    result = await db.execute(select(User).where(User.id == current_user["sub"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
