from __future__ import annotations

import json
import re
from typing import Any

import httpx

from .config import get_settings


class GeminiClient:
    def __init__(self) -> None:
        settings = get_settings()
        self.api_key = settings.GEMINI_API_KEY
        self.model = settings.GEMINI_MODEL

    async def detect_intent(self, user_input: str) -> dict[str, Any]:
        """Return strict structured intent JSON for downstream execution."""
        if not self.api_key:
            return self._fallback_intent(user_input)

        prompt = (
            "You are an intent extractor for a fintech agent. "
            "Return only a valid compact JSON object with keys: "
            "intent, amount, recipient, phone, operator, plan, service, origin, destination, missing_fields. "
            "Use null when unknown and [] for missing_fields when complete. "
            "Allowed intents: send_money, recharge, book_service, balance_query, offers_query, transaction_history, recharge_plans_query, unknown. "
            "Do not include markdown.\n"
            f"User message: {user_input}"
        )

        url = (
            f"https://generativelanguage.googleapis.com/v1beta/models/"
            f"{self.model}:generateContent?key={self.api_key}"
        )
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.1, "responseMimeType": "application/json"},
        }

        try:
            async with httpx.AsyncClient(timeout=12.0) as client:
                response = await client.post(url, json=payload)
                response.raise_for_status()
        except Exception:
            return self._fallback_intent(user_input)

        data = response.json()
        text = self._extract_text(data)
        parsed = self._safe_json_loads(text)
        if not parsed:
            return self._fallback_intent(user_input)

        return self._normalize_intent(parsed)

    def _extract_text(self, payload: dict[str, Any]) -> str:
        candidates = payload.get("candidates", [])
        if not candidates:
            return ""

        content = candidates[0].get("content", {})
        parts = content.get("parts", [])
        if not parts:
            return ""
        return str(parts[0].get("text", "")).strip()

    def _safe_json_loads(self, raw_text: str) -> dict[str, Any] | None:
        raw_text = raw_text.strip()
        if not raw_text:
            return None

        try:
            loaded = json.loads(raw_text)
            if isinstance(loaded, dict):
                return loaded
        except json.JSONDecodeError:
            pass

        match = re.search(r"\{[\s\S]*\}", raw_text)
        if not match:
            return None

        try:
            loaded = json.loads(match.group(0))
            return loaded if isinstance(loaded, dict) else None
        except json.JSONDecodeError:
            return None

    def _normalize_intent(self, parsed: dict[str, Any]) -> dict[str, Any]:
        raw_intent = str(parsed.get("intent", "unknown") or "unknown").strip().lower()
        intent_aliases = {
            "send_money": "send_money",
            "transfer": "send_money",
            "pay": "send_money",
            "recharge": "recharge",
            "book_service": "book_service",
            "trip_planning": "book_service",
            "travel_planning": "book_service",
            "trip": "book_service",
            "travel": "book_service",
            "trip_plan": "book_service",
            "travel_plan": "book_service",
            "travel_booking": "book_service",
            "book_trip": "book_service",
            "book": "book_service",
            "balance_query": "balance_query",
            "check_balance": "balance_query",
            "balance": "balance_query",
            "offers_query": "offers_query",
            "offers": "offers_query",
            "coupons": "offers_query",
            "transaction_history": "transaction_history",
            "history": "transaction_history",
            "statement": "transaction_history",
            "recharge_plans_query": "recharge_plans_query",
            "recharge_plans": "recharge_plans_query",
            "plan_suggestion": "recharge_plans_query",
            "unknown": "unknown",
        }

        return {
            "intent": intent_aliases.get(raw_intent, "unknown"),
            "amount": parsed.get("amount"),
            "recipient": parsed.get("recipient"),
            "phone": parsed.get("phone"),
            "operator": parsed.get("operator"),
            "plan": parsed.get("plan"),
            "service": parsed.get("service"),
            "origin": parsed.get("origin"),
            "destination": parsed.get("destination"),
            "missing_fields": parsed.get("missing_fields", []),
        }

    def _fallback_intent(self, user_input: str) -> dict[str, Any]:
        text = user_input.lower().strip()
        amount_match = re.search(r"(?:rs\.?|inr|₹)?\s*(\d+(?:\.\d+)?)", text)
        amount = float(amount_match.group(1)) if amount_match else None

        if any(token in text for token in ["pay", "send", "transfer"]):
            recipient = None
            words = user_input.split()
            if "to" in text:
                idx = [w.lower() for w in words].index("to")
                if idx + 1 < len(words):
                    recipient = words[idx + 1]
            elif len(words) >= 2:
                recipient = words[1]

            missing = []
            if amount is None:
                missing.append("amount")
            if not recipient:
                missing.append("recipient")

            return {
                "intent": "send_money",
                "amount": amount,
                "recipient": recipient,
                "phone": None,
                "operator": None,
                "plan": None,
                "service": None,
                "missing_fields": missing,
            }

        if "recharge" in text:
            phone_match = re.search(r"(?:\+91)?([6-9]\d{9})", text)
            phone = phone_match.group(1) if phone_match else None
            operator = "jio" if "jio" in text else "airtel" if "airtel" in text else None

            missing = []
            if phone is None:
                missing.append("phone")
            if amount is None:
                missing.append("plan")

            return {
                "intent": "recharge",
                "amount": amount,
                "recipient": None,
                "phone": phone,
                "operator": operator,
                "plan": f"₹{int(amount)} plan" if amount else None,
                "service": None,
                "missing_fields": missing,
            }

        if any(
            token in text
            for token in [
                "book",
                "ticket",
                "train",
                "flight",
                "bus",
                "hotel",
                "trip",
                "travel",
                "itinerary",
                "vacation",
            ]
        ):
            route_match = re.search(r"from\s+([a-z ]+?)\s+to\s+([a-z ]+?)(?:\s+in|\s+under|\s+for|$)", text)
            origin = route_match.group(1).strip().title() if route_match else None
            destination = route_match.group(2).strip().title() if route_match else None
            return {
                "intent": "book_service",
                "amount": amount,
                "recipient": None,
                "phone": None,
                "operator": None,
                "plan": None,
                "service": "travel",
                "origin": origin,
                "destination": destination,
                "missing_fields": [],
            }

        if any(token in text for token in ["balance", "wallet", "account balance"]):
            return {
                "intent": "balance_query",
                "amount": None,
                "recipient": None,
                "phone": None,
                "operator": None,
                "plan": None,
                "service": "wallet",
                "origin": None,
                "destination": None,
                "missing_fields": [],
            }

        if any(token in text for token in ["offer", "offers", "coupon", "deals", "cashback"]):
            return {
                "intent": "offers_query",
                "amount": amount,
                "recipient": None,
                "phone": None,
                "operator": None,
                "plan": None,
                "service": None,
                "origin": None,
                "destination": None,
                "missing_fields": [],
            }

        if any(token in text for token in ["history", "transactions", "statement", "recent payments"]):
            return {
                "intent": "transaction_history",
                "amount": amount,
                "recipient": None,
                "phone": None,
                "operator": None,
                "plan": None,
                "service": None,
                "origin": None,
                "destination": None,
                "missing_fields": [],
            }

        if any(token in text for token in ["best recharge", "recharge plan", "plans for", "data plan"]):
            return {
                "intent": "recharge_plans_query",
                "amount": amount,
                "recipient": None,
                "phone": None,
                "operator": "jio" if "jio" in text else "airtel" if "airtel" in text else None,
                "plan": None,
                "service": "recharge",
                "origin": None,
                "destination": None,
                "missing_fields": [],
            }

        return {
            "intent": "unknown",
            "amount": amount,
            "recipient": None,
            "phone": None,
            "operator": None,
            "plan": None,
            "service": None,
            "origin": None,
            "destination": None,
            "missing_fields": ["intent"],
        }
