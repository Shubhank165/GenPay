from __future__ import annotations

from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer

from .jwt_handler import verify_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/verify-otp")


async def get_current_user(token: str = Depends(oauth2_scheme)) -> dict:
    payload = verify_token(token)
    if "sub" not in payload and payload.get("user_id"):
        payload["sub"] = payload["user_id"]
    return payload
