from __future__ import annotations

from ..core.state import AgentState


async def planner_node(state: AgentState) -> AgentState:
    state["current_step"] = 3
    intent = state.get("intent", {})
    missing = state.get("missing_fields", [])

    # Respect explicit validation failures from previous nodes.
    if state.get("status") in {"failed", "clarification_required"} and state.get("error"):
        state["plan"] = ["stop_due_to_validation_error"]
        return state

    if missing:
        state["status"] = "failed"
        state["error"] = f"Missing required fields: {', '.join(missing)}"
        state["plan"] = ["collect_missing_parameters"]
        return state

    if intent.get("intent") == "send_money":
        amount = intent.get("amount")
        recipient = intent.get("recipient")
        state["plan"] = [
            "validate_recipient",
            "simulate_deduction",
            "risk_assessment",
            "execute_send_money",
            "post_transaction_update",
        ]
        state["simulation"] = {
            "action": "send_money",
            "amount": amount,
            "recipient": recipient,
            "preview_message": f"Send ₹{amount} to {recipient}",
        }

    elif intent.get("intent") == "recharge":
        amount = intent.get("amount")
        phone = intent.get("phone")
        plan = intent.get("plan")
        state["plan"] = [
            "validate_phone_and_plan",
            "simulate_recharge",
            "risk_assessment",
            "execute_recharge",
        ]
        state["simulation"] = {
            "action": "recharge",
            "amount": amount,
            "phone": phone,
            "plan": plan,
            "preview_message": f"Recharge {phone} with {plan}",
        }

    elif intent.get("intent") == "book_service":
        origin = intent.get("origin")
        destination = intent.get("destination")
        budget = intent.get("amount")
        state["plan"] = [
            "extract_trip_constraints",
            "search_travel_inventory",
            "compose_itinerary",
        ]
        route = f"from {origin} to {destination}" if origin and destination else "for your requested route"
        budget_text = f" under Rs. {float(budget):.0f}" if isinstance(budget, (int, float)) else ""
        state["simulation"] = {
            "action": "book_service",
            "preview_message": f"Planning a trip {route}{budget_text}",
        }

    elif intent.get("intent") == "balance_query":
        state["plan"] = [
            "retrieve_recent_activity",
            "compute_available_balance",
            "format_balance_response",
        ]
        state["simulation"] = {
            "action": "balance_query",
            "preview_message": "Fetching your current wallet balance",
        }

    elif intent.get("intent") == "offers_query":
        state["plan"] = [
            "fetch_active_offers",
            "rank_offers",
            "compose_offer_options",
        ]
        state["simulation"] = {
            "action": "offers_query",
            "preview_message": "Fetching active offers and cashback deals",
        }

    elif intent.get("intent") == "transaction_history":
        state["plan"] = [
            "fetch_recent_transactions",
            "summarize_transactions",
        ]
        state["simulation"] = {
            "action": "transaction_history",
            "preview_message": "Fetching your recent transactions",
        }

    elif intent.get("intent") == "recharge_plans_query":
        operator = intent.get("operator")
        state["plan"] = [
            "fetch_recharge_plans",
            "rank_by_value",
        ]
        state["simulation"] = {
            "action": "recharge_plans_query",
            "operator": operator,
            "preview_message": "Finding the best recharge plans for you",
        }

    else:
        state["plan"] = ["clarify_intent"]
        state["status"] = "failed"
        state["error"] = "Unsupported or unclear intent"

    return state
