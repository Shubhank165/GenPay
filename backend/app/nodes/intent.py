from __future__ import annotations

import re

from ..core.llm import LocalIntentEngine
from ..core.state import AgentState

_intent_engine = LocalIntentEngine()


def _extract_candidate_recipient(user_input: str) -> str | None:
    match = re.search(r"\bto\s+([a-zA-Z][a-zA-Z\s]{1,40})", user_input)
    if not match:
        return None
    recipient = match.group(1).strip()
    return recipient if recipient else None


def _coerce_send_money_intent(user_input: str, detected: dict) -> dict:
    intent_name = str(detected.get("intent") or "").lower()
    lowered = user_input.lower()

    has_transfer_verb = any(token in lowered for token in ["pay", "send", "transfer"])
    has_recharge_keyword = "recharge" in lowered
    has_phone_number = re.search(r"(?:\+91)?[6-9]\d{9}", lowered) is not None
    candidate_recipient = _extract_candidate_recipient(user_input)

    # Classifier may occasionally map person-to-person "pay X to Y" as recharge.
    if intent_name == "recharge" and has_transfer_verb and candidate_recipient and not has_recharge_keyword and not has_phone_number:
        coerced = dict(detected)
        coerced["intent"] = "send_money"
        coerced["recipient"] = coerced.get("recipient") or candidate_recipient
        coerced["phone"] = None
        coerced["operator"] = None
        coerced["plan"] = None

        missing = set(coerced.get("missing_fields") or [])
        missing.discard("phone")
        missing.discard("plan")
        if not coerced.get("amount"):
            missing.add("amount")
        if not coerced.get("recipient"):
            missing.add("recipient")
        coerced["missing_fields"] = sorted(missing)
        return coerced

    return detected


def _sanitize_missing_fields(detected: dict) -> dict:
    intent_name = str(detected.get("intent") or "").lower()
    raw_missing = [str(item).strip().lower() for item in (detected.get("missing_fields") or []) if str(item).strip()]

    allowed_by_intent: dict[str, set[str]] = {
        "send_money": {"amount", "recipient"},
        "recharge": {"phone", "plan"},
        "unknown": {"intent"},
    }

    allowed = allowed_by_intent.get(intent_name)
    if allowed is not None:
        missing = [field for field in raw_missing if field in allowed]
    else:
        missing = raw_missing

    # Ensure required fields are present even if model omitted them.
    if intent_name == "send_money":
        if not detected.get("amount"):
            missing.append("amount")
        if not detected.get("recipient"):
            missing.append("recipient")
    elif intent_name == "recharge":
        if not detected.get("phone"):
            missing.append("phone")

    sanitized = dict(detected)
    sanitized["missing_fields"] = sorted(set(missing))
    return sanitized


async def intent_node(state: AgentState) -> AgentState:
    state["current_step"] = 1
    state["status"] = "in_progress"
    detected = await _intent_engine.detect_intent(state["user_input"])
    detected = _coerce_send_money_intent(state["user_input"], detected)
    detected = _sanitize_missing_fields(detected)
    state["intent"] = detected
    state["missing_fields"] = list(detected.get("missing_fields", []))
    return state
