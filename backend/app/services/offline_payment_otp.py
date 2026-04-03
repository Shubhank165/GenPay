from __future__ import annotations

from datetime import datetime, timedelta, timezone
from threading import Lock
import uuid

_TOKEN_TTL_SECONDS = 300
_TOKENS: dict[str, dict[str, str | datetime]] = {}
_LOCK = Lock()


def issue_offline_payment_token(user_id: str, phone: str) -> tuple[str, int]:
    token = uuid.uuid4().hex
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=_TOKEN_TTL_SECONDS)
    with _LOCK:
        _cleanup_locked()
        _TOKENS[token] = {
            "user_id": user_id,
            "phone": phone,
            "expires_at": expires_at,
        }
    return token, _TOKEN_TTL_SECONDS


def consume_offline_payment_token(user_id: str, token: str) -> bool:
    with _LOCK:
        _cleanup_locked()
        data = _TOKENS.get(token)
        if not data:
            return False
        if data.get("user_id") != user_id:
            return False
        _TOKENS.pop(token, None)
        return True


def _cleanup_locked() -> None:
    now = datetime.now(timezone.utc)
    expired = [
        token
        for token, data in _TOKENS.items()
        if isinstance(data.get("expires_at"), datetime) and data["expires_at"] <= now
    ]
    for token in expired:
        _TOKENS.pop(token, None)
