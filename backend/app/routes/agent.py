from __future__ import annotations

import re

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..auth.middleware import get_current_user
from ..core.database import get_db
from ..core.graph import run_agent_graph
from ..core.state import AgentState
from ..models import (
    AgentQueryRequest,
    AgentQueryResponse,
    Transaction,
    TransactionStatus,
    TransactionType,
    Flight,
    Hotel,
    Offer,
    RechargePlan,
    User,
)
from ..services.local_fallback import create_transaction as local_create_transaction
from ..services.local_fallback import get_user_by_id
from ..services.local_fallback import list_transactions as local_list_transactions

router = APIRouter(prefix="/agent", tags=["Agentic AI"])
UPI_PIN = "165165"


def _to_float(value: object, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


async def _load_wallet_balance(user_id: str, db: AsyncSession) -> float:
    try:
        result = await db.execute(select(User.wallet_balance).where(User.id == user_id))
        balance = result.scalar_one_or_none()
        if balance is not None:
            return _to_float(balance, 0.0)
    except Exception:
        pass

    fallback_user = get_user_by_id(user_id)
    if fallback_user:
        return _to_float(fallback_user.get("wallet_balance"), 0.0)
    return 0.0


async def _load_recipient_directory(user_id: str, db: AsyncSession) -> list[dict[str, str]]:
    try:
        result = await db.execute(
            select(User.name, User.phone, User.upi_id).where(User.id != user_id, User.is_active == True)
        )
        directory: list[dict[str, str]] = []
        for name, phone, upi_id in result.all():
            directory.append(
                {
                    "name": str(name or ""),
                    "phone": str(phone or ""),
                    "upi_id": str(upi_id or ""),
                }
            )
        return directory
    except Exception:
        return []


def _extract_route(message: str, intent: dict) -> tuple[str | None, str | None]:
    origin = intent.get("origin")
    destination = intent.get("destination")
    if isinstance(origin, str) and origin.strip() and isinstance(destination, str) and destination.strip():
        return origin.strip(), destination.strip()

    lowered = message.lower().strip()
    route_match = re.search(r"from\s+([a-z ]+?)\s+to\s+([a-z ]+?)(?:\s+in|\s+under|\s+for|$)", lowered)
    if route_match:
        return route_match.group(1).strip().title(), route_match.group(2).strip().title()
    return None, None


async def _build_trip_message(user_input: str, intent: dict, db: AsyncSession) -> tuple[str, list[dict[str, object]]]:
    origin, destination = _extract_route(user_input, intent)
    budget = _to_float(intent.get("amount"), 0.0)

    try:
        flight_query = select(Flight).where(Flight.is_active == True)
        if origin:
            flight_query = flight_query.where(Flight.origin_city.ilike(f"%{origin}%"))
        if destination:
            flight_query = flight_query.where(Flight.destination_city.ilike(f"%{destination}%"))
        if budget > 0:
            flight_query = flight_query.where(Flight.price <= budget)
        flight_query = flight_query.order_by(Flight.price.asc()).limit(3)
        flights_result = await db.execute(flight_query)
        flights = flights_result.scalars().all()

        hotel_query = select(Hotel).where(Hotel.is_active == True)
        if destination:
            hotel_query = hotel_query.where(Hotel.city.ilike(f"%{destination}%"))
        if budget > 0:
            hotel_query = hotel_query.where(Hotel.price_per_night <= budget)
        hotel_query = hotel_query.order_by(Hotel.price_per_night.asc()).limit(2)
        hotels_result = await db.execute(hotel_query)
        hotels = hotels_result.scalars().all()

        if not flights and not hotels:
            route_text = f" from {origin} to {destination}" if origin and destination else ""
            budget_text = f" under Rs. {budget:.0f}" if budget > 0 else ""
            return (
                f"I couldn't find trip options{route_text}{budget_text} right now. Try increasing budget or changing dates.",
                [],
            )

        message_parts: list[str] = []
        options: list[dict[str, object]] = []
        if flights:
            top_flight = flights[0]
            message_parts.append(
                f"Best flight: {top_flight.airline} {top_flight.flight_code} at Rs. {float(top_flight.price):.0f}"
            )
            for flight in flights:
                options.append(
                    {
                        "type": "flight",
                        "title": f"{flight.airline} {flight.flight_code}",
                        "subtitle": f"{flight.origin_city} to {flight.destination_city}",
                        "price": float(flight.price),
                        "meta": f"{flight.stops} stop(s)",
                    }
                )
        else:
            message_parts.append("No matching flights found")

        if hotels:
            top_hotel = hotels[0]
            message_parts.append(
                f"Top hotel: {top_hotel.name} at Rs. {float(top_hotel.price_per_night):.0f}/night"
            )
            for hotel in hotels:
                options.append(
                    {
                        "type": "hotel",
                        "title": hotel.name,
                        "subtitle": hotel.city,
                        "price": float(hotel.price_per_night),
                        "meta": f"{float(hotel.user_rating):.1f} rating",
                    }
                )

        return "; ".join(message_parts), options
    except Exception:
        route_text = f" from {origin} to {destination}" if origin and destination else ""
        budget_text = f" under Rs. {budget:.0f}" if budget > 0 else ""
        return f"Trip planning request received{route_text}{budget_text}.", []


async def _build_offer_options(db: AsyncSession) -> list[dict[str, object]]:
    try:
        result = await db.execute(
            select(Offer)
            .where(Offer.is_active == True)
            .order_by(Offer.discount_value.desc())
            .limit(6)
        )
        offers = result.scalars().all()
        options: list[dict[str, object]] = []
        for offer in offers:
            options.append(
                {
                    "type": "offer",
                    "title": offer.title,
                    "subtitle": offer.category,
                    "price": float(offer.discount_value),
                    "meta": offer.coupon_code or "No coupon",
                }
            )
        return options
    except Exception:
        return []


async def _build_history_options(user_id: str, db: AsyncSession) -> list[dict[str, object]]:
    try:
        result = await db.execute(
            select(Transaction)
            .where(Transaction.user_id == user_id)
            .order_by(Transaction.created_at.desc())
            .limit(6)
        )
        txns = result.scalars().all()
        options: list[dict[str, object]] = []
        for txn in txns:
            txn_type = str(txn.type.value).replace("_", " ")
            options.append(
                {
                    "type": "transaction",
                    "title": (txn.recipient_name or txn_type).title(),
                    "subtitle": str(txn.status.value).title(),
                    "price": float(txn.amount),
                    "meta": txn_type,
                }
            )
        if options:
            return options

        fallback_txns = local_list_transactions(user_id)
        for txn in fallback_txns[:6]:
            txn_type = str(txn.get("type") or "transaction").replace("_", " ")
            options.append(
                {
                    "type": "transaction",
                    "title": str(txn.get("recipient_name") or txn_type).title(),
                    "subtitle": str(txn.get("status") or "success").title(),
                    "price": _to_float(txn.get("amount"), 0.0),
                    "meta": txn_type,
                }
            )
        return options
    except Exception:
        fallback_txns = local_list_transactions(user_id)
        options: list[dict[str, object]] = []
        for txn in fallback_txns[:6]:
            txn_type = str(txn.get("type") or "transaction").replace("_", " ")
            options.append(
                {
                    "type": "transaction",
                    "title": str(txn.get("recipient_name") or txn_type).title(),
                    "subtitle": str(txn.get("status") or "success").title(),
                    "price": _to_float(txn.get("amount"), 0.0),
                    "meta": txn_type,
                }
            )
        return options


async def _build_recharge_plan_options(intent: dict, db: AsyncSession) -> list[dict[str, object]]:
    try:
        operator = str(intent.get("operator") or "").strip()
        query = select(RechargePlan).where(RechargePlan.is_active == True)
        if operator:
            query = query.where(RechargePlan.operator.ilike(f"%{operator}%"))
        query = query.order_by(RechargePlan.price.asc()).limit(6)
        result = await db.execute(query)
        plans = result.scalars().all()

        options: list[dict[str, object]] = []
        for plan in plans:
            options.append(
                {
                    "type": "recharge_plan",
                    "title": f"{plan.operator} {plan.plan_type.title()}",
                    "subtitle": f"Validity {plan.validity_days} days",
                    "price": float(plan.price),
                    "meta": plan.data_per_day or "Unlimited calls",
                }
            )
        return options
    except Exception:
        return []


async def _persist_agent_action(
    user_id: str,
    intent: dict,
    execution_result: dict,
    db: AsyncSession,
) -> dict[str, object]:
    intent_name = str(intent.get("intent") or "")
    if intent_name not in {"send_money", "recharge"}:
        return {"ok": True}

    amount = _to_float(intent.get("amount"), 0.0)
    if amount <= 0:
        return {"ok": False, "reason": "Invalid amount for transaction"}

    recipient_name = str(intent.get("recipient") or "") if intent_name == "send_money" else "Mobile Recharge"
    recipient_identifier = (
        str(intent.get("recipient") or "") if intent_name == "send_money" else str(intent.get("phone") or "")
    )
    tx_type = TransactionType.UPI_TRANSFER if intent_name == "send_money" else TransactionType.RECHARGE

    try:
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if user is not None:
            current_balance = _to_float(user.wallet_balance, 0.0)
            if current_balance < amount:
                return {"ok": False, "reason": "Insufficient wallet balance"}

            user.wallet_balance = round(current_balance - amount, 2)
            txn = Transaction(
                user_id=user_id,
                type=tx_type,
                status=TransactionStatus.SUCCESS,
                amount=amount,
                currency="INR",
                recipient_name=recipient_name or None,
                recipient_identifier=recipient_identifier or None,
                description=f"Agent {intent_name.replace('_', ' ')}",
                reference_id=execution_result.get("transaction_id"),
            )
            db.add(txn)
            await db.commit()
            await db.refresh(txn)
            return {
                "ok": True,
                "transaction_id": txn.id,
                "wallet_balance": _to_float(user.wallet_balance, 0.0),
            }
    except Exception:
        pass

    fallback_user = get_user_by_id(user_id)
    if not fallback_user:
        return {"ok": False, "reason": "User not found"}

    current_balance = _to_float(fallback_user.get("wallet_balance"), 0.0)
    if current_balance < amount:
        return {"ok": False, "reason": "Insufficient wallet balance"}

    fallback_user["wallet_balance"] = round(current_balance - amount, 2)
    local_tx = local_create_transaction(
        user_id=user_id,
        tx_type="upi_transfer" if intent_name == "send_money" else "recharge",
        amount=amount,
        recipient_name=recipient_name,
        recipient_identifier=recipient_identifier,
        description=f"Agent {intent_name.replace('_', ' ')}",
    )
    return {
        "ok": True,
        "transaction_id": str(local_tx.get("id") or ""),
        "wallet_balance": _to_float(fallback_user.get("wallet_balance"), 0.0),
    }


@router.post("/query", response_model=AgentQueryResponse)
async def query_agent(
    payload: AgentQueryRequest,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> AgentQueryResponse:
    effective_user_id = str(current_user.get("user_id") or current_user.get("sub") or payload.user_id)
    wallet_balance = await _load_wallet_balance(effective_user_id, db)
    recipient_directory = await _load_recipient_directory(effective_user_id, db)

    initial_state: AgentState = {
        "user_id": effective_user_id,
        "user_input": payload.message,
        "user_confirmation": payload.user_confirmation,
        "intent": {},
        "context": {
            "wallet_balance": wallet_balance,
            "recipient_directory": recipient_directory,
        },
        "plan": [],
        "current_step": 0,
        "risk_score": 0,
        "requires_confirmation": False,
        "simulation": {},
        "execution_result": None,
        "retry_count": 0,
        "status": "in_progress",
        "message": "",
        "missing_fields": [],
        "error": None,
    }

    result = await run_agent_graph(initial_state)

    if result.get("status") == "clarification_required":
        return AgentQueryResponse(
            status="failed",
            message="Action could not be completed",
            reason=result.get("error") or result.get("message") or "Clarification required",
            risk_score=result.get("risk_score"),
            simulation=result.get("simulation"),
            options=None,
        )

    if result.get("status") == "confirmation_required":
        return AgentQueryResponse(
            status="confirmation_required",
            message=result.get("message", "Action requires confirmation"),
            risk_score=result.get("risk_score"),
            simulation=result.get("simulation"),
            options=None,
        )

    execution_result = result.get("execution_result") or {}
    intent = result.get("intent") or {}
    intent_name = str(intent.get("intent") or "")

    if intent_name in {"send_money", "recharge"} and payload.upi_pin != UPI_PIN:
        return AgentQueryResponse(
            status="failed",
            message="Action could not be completed",
            reason="Invalid or missing UPI PIN",
            risk_score=result.get("risk_score"),
            simulation=result.get("simulation"),
            options=None,
        )

    if result.get("status") == "success" and execution_result.get("status") == "success":
        if intent_name == "balance_query":
            actual_balance = await _load_wallet_balance(effective_user_id, db)
            return AgentQueryResponse(
                status="success",
                message=f"Your current wallet balance is Rs. {actual_balance:.2f}",
                transaction_id=None,
                risk_score=result.get("risk_score"),
                simulation=result.get("simulation"),
                options=None,
            )

        if intent_name in {"send_money", "recharge"}:
            persisted = await _persist_agent_action(effective_user_id, intent, execution_result, db)
            if not persisted.get("ok"):
                return AgentQueryResponse(
                    status="failed",
                    message="Action could not be completed",
                    reason=str(persisted.get("reason", "Failed to persist transaction")),
                    risk_score=result.get("risk_score"),
                    simulation=result.get("simulation"),
                    options=None,
                )

            updated_balance = persisted.get("wallet_balance")
            tx_id = str(persisted.get("transaction_id") or execution_result.get("transaction_id") or "") or None
            success_message = "Action completed successfully"
            if isinstance(updated_balance, (float, int)):
                success_message = f"{success_message}. Wallet balance is Rs. {float(updated_balance):.2f}"

            return AgentQueryResponse(
                status="success",
                message=success_message,
                transaction_id=tx_id,
                risk_score=result.get("risk_score"),
                simulation=result.get("simulation"),
                options=None,
            )

        if intent_name == "book_service":
            trip_message, trip_options = await _build_trip_message(payload.message, intent, db)
            return AgentQueryResponse(
                status="success",
                message=trip_message,
                transaction_id=None,
                risk_score=result.get("risk_score"),
                simulation=result.get("simulation"),
                options=trip_options,
            )

        if intent_name == "offers_query":
            offer_options = await _build_offer_options(db)
            return AgentQueryResponse(
                status="success",
                message="Here are the best available offers",
                transaction_id=None,
                risk_score=result.get("risk_score"),
                simulation=result.get("simulation"),
                options=offer_options,
            )

        if intent_name == "transaction_history":
            history_options = await _build_history_options(effective_user_id, db)
            return AgentQueryResponse(
                status="success",
                message="Here are your latest transactions",
                transaction_id=None,
                risk_score=result.get("risk_score"),
                simulation=result.get("simulation"),
                options=history_options,
            )

        if intent_name == "recharge_plans_query":
            plan_options = await _build_recharge_plan_options(intent, db)
            return AgentQueryResponse(
                status="success",
                message="Best recharge plans available now",
                transaction_id=None,
                risk_score=result.get("risk_score"),
                simulation=result.get("simulation"),
                options=plan_options,
            )

        return AgentQueryResponse(
            status="success",
            message=result.get("message", "Action completed"),
            transaction_id=execution_result.get("transaction_id"),
            risk_score=result.get("risk_score"),
            simulation=result.get("simulation"),
            options=None,
        )

    reason = result.get("error") or execution_result.get("reason") or "Unknown failure"
    return AgentQueryResponse(
        status="failed",
        message="Action could not be completed",
        reason=reason,
        risk_score=result.get("risk_score"),
        simulation=result.get("simulation"),
        options=None,
    )
