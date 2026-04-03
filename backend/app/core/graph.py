from __future__ import annotations

from langgraph.graph import END, StateGraph

from .config import get_settings
from .state import AgentState
from ..nodes import (
    confirm_node,
    context_node,
    execute_node,
    intent_node,
    planner_node,
    retry_node,
    risk_node,
)

settings = get_settings()


def _route_after_risk(state: AgentState) -> str:
    if state.get("status") == "failed":
        return "execute"

    if state.get("requires_confirmation") and not state.get("user_confirmation", False):
        return "confirm"

    return "execute"


def _route_after_execute(state: AgentState) -> str:
    result = state.get("execution_result") or {}
    if result.get("non_retryable"):
        return END
    if result.get("status") == "failed" and int(state.get("retry_count", 0)) < settings.AGENT_MAX_RETRIES:
        return "retry"
    return END


def build_graph():
    graph = StateGraph(AgentState)

    graph.add_node("intent_node", intent_node)
    graph.add_node("context_node", context_node)
    graph.add_node("planner_node", planner_node)
    graph.add_node("risk_node", risk_node)
    graph.add_node("confirm_node", confirm_node)
    graph.add_node("execute_node", execute_node)
    graph.add_node("retry_node", retry_node)

    graph.set_entry_point("intent_node")
    graph.add_edge("intent_node", "context_node")
    graph.add_edge("context_node", "planner_node")
    graph.add_edge("planner_node", "risk_node")

    graph.add_conditional_edges(
        "risk_node",
        _route_after_risk,
        {"confirm": "confirm_node", "execute": "execute_node"},
    )
    graph.add_edge("confirm_node", END)

    graph.add_conditional_edges("execute_node", _route_after_execute, {"retry": "retry_node", END: END})
    graph.add_edge("retry_node", END)

    return graph.compile()


agent_graph = build_graph()


async def run_agent_graph(initial_state: AgentState) -> AgentState:
    result = await agent_graph.ainvoke(initial_state)
    return result
