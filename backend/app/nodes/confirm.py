from __future__ import annotations

from ..core.state import AgentState


async def confirm_node(state: AgentState) -> AgentState:
    state["current_step"] = 5
    simulation = state.get("simulation", {})
    state["status"] = "confirmation_required"
    state["message"] = simulation.get("preview_message", "Action requires confirmation") + "?"
    return state
