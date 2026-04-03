from __future__ import annotations

from datetime import datetime, timedelta, timezone

import jwt
from fastapi import HTTPException, status

from ..core.config import get_settings

settings = get_settings()
TOKEN_EXPIRY_MINUTES = 15


def create_token(payload: dict) -> str:
    now = datetime.now(timezone.utc)
    token_payload = payload.copy()
    token_payload.update(
        {
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(minutes=TOKEN_EXPIRY_MINUTES)).timestamp()),
        }
    )
    return jwt.encode(token_payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)


def verify_token(token: str) -> dict:
    try:
        return jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
        ) from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        ) from exc
