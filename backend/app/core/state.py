from __future__ import annotations

from typing import Any, Literal, TypedDict


class AgentState(TypedDict, total=False):
    user_id: str
    user_input: str
    user_confirmation: bool

    intent: dict[str, Any]
    context: dict[str, Any]
    plan: list[str]
    current_step: int

    risk_score: int
    requires_confirmation: bool
    simulation: dict[str, Any]

    execution_result: dict[str, Any] | None
    retry_count: int

    status: Literal["in_progress", "confirmation_required", "success", "failed", "clarification_required"]
    message: str
    missing_fields: list[str]
    error: str | None
