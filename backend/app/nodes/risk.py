from __future__ import annotations

from ..core.config import get_settings
from ..core.state import AgentState

settings = get_settings()


async def risk_node(state: AgentState) -> AgentState:
    state["current_step"] = 4

    if state.get("status") == "failed":
        state["risk_score"] = 0
        state["requires_confirmation"] = False
        return state

    intent = state.get("intent", {})
    score = 10

    if intent.get("intent") == "send_money":
        amount = float(intent.get("amount") or 0)

        if state.get("context", {}).get("is_new_recipient"):
            score += 45

        if amount >= settings.AGENT_HIGH_VALUE_THRESHOLD:
            score += 35
        elif amount >= 1000:
            score += 15

    if intent.get("intent") == "recharge":
        score += 5

    state["risk_score"] = min(score, 100)
    state["requires_confirmation"] = state["risk_score"] > settings.AGENT_RISK_THRESHOLD
    return state
