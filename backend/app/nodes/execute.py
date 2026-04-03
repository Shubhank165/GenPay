from __future__ import annotations

import asyncio
import random

from ..core.state import AgentState
from ..memory import memory_store
from ..tools import recharge, send_money


DEFAULT_WALLET_BALANCE = 19748.45


def perform_execution(state: AgentState) -> dict:
    intent = state.get("intent", {})
    intent_name = intent.get("intent")

    if intent_name == "send_money":
        result = send_money(
            user_id=state["user_id"],
            recipient=str(intent.get("recipient")),
            amount=float(intent.get("amount") or 0),
        )
    elif intent_name == "recharge":
        result = recharge(
            phone=str(intent.get("phone") or ""),
            plan=str(intent.get("plan") or ""),
            amount=float(intent.get("amount")) if intent.get("amount") is not None else None,
        )
    elif intent_name == "balance_query":
        context = state.get("context", {})
        wallet_balance = context.get("wallet_balance")
        if isinstance(wallet_balance, (int, float)):
            current_balance = float(wallet_balance)
        else:
            memory_context = memory_store.get_context(state["user_id"])
            tx_history = memory_context.get("last_transactions", [])
            spent = 0.0
            for tx in tx_history:
                if tx.get("type") in {"send_money", "recharge"}:
                    spent += float(tx.get("amount") or 0)
            current_balance = max(DEFAULT_WALLET_BALANCE - spent, 0.0)

        result = {
            "status": "success",
            "message": f"Your current wallet balance is Rs. {current_balance:.2f}",
            "balance": round(current_balance, 2),
        }
    elif intent_name == "book_service":
        origin = intent.get("origin")
        destination = intent.get("destination")
        budget = intent.get("amount")
        route = f"from {origin} to {destination}" if origin and destination else "for your route"
        budget_text = f" under Rs. {float(budget):.0f}" if isinstance(budget, (int, float)) else ""
        result = {
            "status": "success",
            "message": f"Planning options {route}{budget_text}",
        }
    elif intent_name == "offers_query":
        result = {
            "status": "success",
            "message": "Here are the latest offers available for you",
        }
    elif intent_name == "transaction_history":
        result = {
            "status": "success",
            "message": "Here are your recent transactions",
        }
    elif intent_name == "recharge_plans_query":
        result = {
            "status": "success",
            "message": "Here are the best recharge plans right now",
        }
    else:
        result = {"status": "failed", "reason": "Unsupported intent for execution"}

    if result.get("status") == "success" and intent_name in {"send_money", "recharge"}:
        context = state.setdefault("context", {})
        wallet_balance = context.get("wallet_balance")
        amount = float(intent.get("amount") or 0)
        if isinstance(wallet_balance, (int, float)) and amount > 0:
            updated_balance = max(float(wallet_balance) - amount, 0.0)
            context["wallet_balance"] = round(updated_balance, 2)
            result["wallet_balance"] = round(updated_balance, 2)

        memory_store.record_transaction(
            state["user_id"],
            {
                "transaction_id": result.get("transaction_id"),
                "recipient": intent.get("recipient"),
                "amount": intent.get("amount"),
                "type": intent_name,
            },
        )

    return result


async def execute_node(state: AgentState) -> AgentState:
    state["current_step"] = 6

    if state.get("status") == "failed":
        state["execution_result"] = {
            "status": "failed",
            "reason": state.get("error", "Cannot execute"),
            "non_retryable": True,
        }
        return state

    await asyncio.sleep(random.uniform(6.0, 7.0))

    result = perform_execution(state)
    state["execution_result"] = result

    if result.get("status") == "success":
        state["status"] = "success"
        state["message"] = str(result.get("message", "Action executed successfully"))
    else:
        state["status"] = "failed"
        state["error"] = str(result.get("reason", "Execution failed"))

    return state
