from __future__ import annotations

import logging

from fastapi import HTTPException, status
from twilio.base.exceptions import TwilioRestException
from twilio.rest import Client

from ..core.config import get_settings

settings = get_settings()
logger = logging.getLogger("uvicorn.error")
_DEBUG_OTP_STORE: dict[str, str] = {}
_DEBUG_OTP_CODE = "123456"


def _mask_phone(phone: str) -> str:
    if len(phone) < 4:
        return "***"
    return f"***{phone[-4:]}"


def normalize_indian_phone(phone: str) -> str:
    raw = phone.strip()
    if raw.startswith("+91") and len(raw) == 13 and raw[3:].isdigit():
        return raw
    if len(raw) == 10 and raw.isdigit():
        return f"+91{raw}"
    raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid phone format")


def _twilio_client() -> Client:
    if not settings.TWILIO_ACCOUNT_SID or not settings.TWILIO_AUTH_TOKEN or not settings.TWILIO_VERIFY_SID:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Twilio Verify is not configured",
        )
    return Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)


def request_otp_call(phone: str) -> dict[str, str]:
    normalized = normalize_indian_phone(phone)
    client = _twilio_client()
    try:
        verification = client.verify.v2.services(settings.TWILIO_VERIFY_SID).verifications.create(
            to=normalized,
            channel="call",
        )
        _DEBUG_OTP_STORE.pop(normalized, None)
        logger.info(
            "Twilio OTP call accepted phone=%s sid=%s status=%s",
            _mask_phone(normalized),
            verification.sid,
            verification.status,
        )
        return {
            "phone": normalized,
            "provider": "twilio",
            "twilio_sid": verification.sid,
            "twilio_status": verification.status,
        }
    except TwilioRestException as exc:
        msg = str(exc.msg)
        # In debug mode, always allow local fallback OTP so development is not blocked
        # by Twilio trial restrictions or transient Verify API failures.
        if settings.DEBUG:
            _DEBUG_OTP_STORE[normalized] = _DEBUG_OTP_CODE
            logger.warning(
                "Twilio OTP failed; using debug fallback phone=%s code=%s detail=%s",
                _mask_phone(normalized),
                exc.code,
                msg,
            )
            return {
                "phone": normalized,
                "provider": "debug_fallback",
                "error_code": str(exc.code or ""),
                "error_detail": msg,
            }
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=msg) from exc


def verify_otp_code(phone: str, otp: str) -> bool:
    normalized = normalize_indian_phone(phone)
    if settings.DEBUG and normalized in _DEBUG_OTP_STORE:
        if _DEBUG_OTP_STORE[normalized] == otp:
            _DEBUG_OTP_STORE.pop(normalized, None)
            return True
        return False

    # Debug fallback for cases where app verification arrives after store reset.
    if settings.DEBUG and otp == _DEBUG_OTP_CODE:
        return True

    client = _twilio_client()
    try:
        result = client.verify.v2.services(settings.TWILIO_VERIFY_SID).verification_checks.create(
            to=normalized,
            code=otp,
        )
    except TwilioRestException as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc.msg)) from exc

    return result.status == "approved"


def debug_otp_hint(phone: str) -> str | None:
    normalized = normalize_indian_phone(phone)
    if settings.DEBUG and normalized in _DEBUG_OTP_STORE:
        return _DEBUG_OTP_STORE[normalized]
    return None
