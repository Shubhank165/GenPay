from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field


class AgentQueryRequest(BaseModel):
    user_id: str = Field(..., description="Unique user id")
    message: str = Field(..., min_length=1, description="Natural language user command")
    user_confirmation: bool = Field(
        default=False,
        description="Pass true to approve high-risk actions after preview",
    )
    upi_pin: str | None = Field(
        default=None,
        min_length=6,
        max_length=6,
        description="UPI PIN required for transactional intents",
    )


class AgentQueryResponse(BaseModel):
    status: Literal["confirmation_required", "success", "failed"]
    message: str
    transaction_id: str | None = None
    reason: str | None = None
    risk_score: int | None = None
    simulation: dict[str, Any] | None = None
    options: list[dict[str, Any]] | None = None
