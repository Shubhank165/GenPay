from __future__ import annotations

from ..core.config import get_settings
from ..core.state import AgentState
from .execute import perform_execution

settings = get_settings()


async def retry_node(state: AgentState) -> AgentState:
    state["current_step"] = 7

    result = state.get("execution_result") or {}
    if result.get("status") == "success":
        return state

    retry_count = int(state.get("retry_count", 0))
    if retry_count >= settings.AGENT_MAX_RETRIES:
        state["status"] = "failed"
        state["error"] = str(result.get("reason", "Execution failed after retries"))
        return state

    state["retry_count"] = retry_count + 1
    retried = perform_execution(state)
    state["execution_result"] = retried

    if retried.get("status") == "success":
        state["status"] = "success"
        state["message"] = "Action executed successfully after retry"
        state["error"] = None
    else:
        state["status"] = "failed"
        state["error"] = str(retried.get("reason", "Execution failed after retry"))

    return state
