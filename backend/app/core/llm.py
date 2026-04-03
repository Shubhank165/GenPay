from __future__ import annotations

import re
import importlib
from functools import lru_cache
from typing import Any

from .config import get_settings


_INTENT_ORDER = [
    "send_money",
    "recharge",
    "book_service",
    "balance_query",
    "offers_query",
    "transaction_history",
    "recharge_plans_query",
    "unknown",
]

_INTENT_ALIASES = {
    "send_money": "send_money",
    "transfer": "send_money",
    "pay": "send_money",
    "recharge": "recharge",
    "recharge_mobile": "recharge",
    "book_service": "book_service",
    "trip_planning": "book_service",
    "travel_planning": "book_service",
    "travel": "book_service",
    "balance": "balance_query",
    "check_balance": "balance_query",
    "balance_query": "balance_query",
    "offers": "offers_query",
    "offers_query": "offers_query",
    "transaction_history": "transaction_history",
    "history": "transaction_history",
    "recharge_plans_query": "recharge_plans_query",
    "recharge_plans": "recharge_plans_query",
    "unknown": "unknown",
}

_SEMANTIC_PROTOTYPES: dict[str, list[str]] = {
    "send_money": [
        "send money to a contact",
        "pay rupees to friend",
        "transfer funds to person",
    ],
    "recharge": [
        "mobile recharge for this phone number",
        "recharge prepaid number",
        "top up mobile plan",
    ],
    "book_service": [
        "book travel from one city to another",
        "find flights buses and hotels",
        "plan a trip itinerary",
    ],
    "balance_query": [
        "check wallet balance",
        "show account balance",
        "how much money do i have",
    ],
    "offers_query": [
        "show best offers and cashback",
        "find coupons and deals",
        "what offers are available",
    ],
    "transaction_history": [
        "show recent transactions",
        "payment history statement",
        "last payments made",
    ],
    "recharge_plans_query": [
        "best recharge plans",
        "find data plans by operator",
        "suggest recharge packs",
    ],
    "unknown": ["general query"],
}

_AMOUNT_PATTERN = re.compile(r"(?:rs\.?|inr|₹)?\s*(\d+(?:\.\d+)?)", re.IGNORECASE)
_PHONE_PATTERN = re.compile(r"(?:\+91)?([6-9]\d{9})")


@lru_cache(maxsize=1)
def _load_distilbert_classifier(model_path: str):
    try:
        pipeline = importlib.import_module("transformers").pipeline

        return pipeline(
            "text-classification",
            model=model_path,
            tokenizer=model_path,
            truncation=True,
        )
    except Exception:
        return None


@lru_cache(maxsize=1)
def _load_sentence_encoder(model_path: str):
    try:
        sentence_transformers = importlib.import_module("sentence_transformers")
        SentenceTransformer = sentence_transformers.SentenceTransformer

        return SentenceTransformer(model_path)
    except Exception:
        return None


class LocalIntentEngine:
    def __init__(self) -> None:
        settings = get_settings()
        self.distilbert_model_path = settings.DISTILBERT_MODEL_PATH
        self.distilbert_confidence_threshold = settings.DISTILBERT_CONFIDENCE_THRESHOLD
        self.distilbert_label_order = [
            label.strip() for label in settings.DISTILBERT_LABEL_ORDER.split(",") if label.strip()
        ] or list(_INTENT_ORDER)
        self.sentence_model_path = settings.SENTENCE_TRANSFORMER_MODEL_PATH
        self.sentence_similarity_threshold = settings.SENTENCE_SIMILARITY_THRESHOLD

    async def detect_intent(self, user_input: str) -> dict[str, Any]:
        text = user_input.strip()
        if not text:
            return self._build_result("unknown", {}, confidence=0.0)

        slots = self._extract_slots(text)

        rule_intent, rule_score = self._rule_based_intent(text)
        clf_intent, clf_score = self._distilbert_intent(text)
        sem_intent, sem_score = self._semantic_intent(text)

        intent_scores: dict[str, float] = {intent: 0.0 for intent in _INTENT_ORDER}
        intent_scores[rule_intent] = max(intent_scores[rule_intent], rule_score)
        intent_scores[clf_intent] = max(intent_scores[clf_intent], clf_score)
        intent_scores[sem_intent] = max(intent_scores[sem_intent], sem_score)

        # Rules are deterministic and should dominate when explicit phrases exist.
        if rule_score >= 0.75:
            selected_intent = rule_intent
            confidence = rule_score
        else:
            selected_intent = max(intent_scores, key=intent_scores.get)
            confidence = intent_scores[selected_intent]
            if confidence < 0.45:
                selected_intent = "unknown"

        return self._build_result(selected_intent, slots, confidence)

    def _canonical_intent(self, intent: str) -> str:
        normalized = _INTENT_ALIASES.get(intent.strip().lower(), "unknown")
        return normalized if normalized in _INTENT_ORDER else "unknown"

    def _resolve_label(self, label: str) -> str:
        lowered = label.strip().lower()
        if lowered.startswith("label_"):
            try:
                idx = int(lowered.split("_", maxsplit=1)[1])
                if 0 <= idx < len(self.distilbert_label_order):
                    return self._canonical_intent(self.distilbert_label_order[idx])
            except ValueError:
                return "unknown"
        return self._canonical_intent(lowered)

    def _distilbert_intent(self, text: str) -> tuple[str, float]:
        classifier = _load_distilbert_classifier(self.distilbert_model_path)
        if classifier is None:
            return "unknown", 0.0

        try:
            output = classifier(text, top_k=3)
        except Exception:
            return "unknown", 0.0

        if isinstance(output, list) and output and isinstance(output[0], list):
            output = output[0]

        if not isinstance(output, list) or not output:
            return "unknown", 0.0

        best = output[0]
        label = self._resolve_label(str(best.get("label", "unknown")))
        score = float(best.get("score", 0.0) or 0.0)
        if score < self.distilbert_confidence_threshold:
            return label, score * 0.85
        return label, score

    def _semantic_intent(self, text: str) -> tuple[str, float]:
        encoder = _load_sentence_encoder(self.sentence_model_path)
        if encoder is None:
            return "unknown", 0.0

        best_intent = "unknown"
        best_score = 0.0
        try:
            query_embedding = encoder.encode([text], normalize_embeddings=True)[0]
            for intent, samples in _SEMANTIC_PROTOTYPES.items():
                sample_embeddings = encoder.encode(samples, normalize_embeddings=True)
                score = max(float(query_embedding @ sample_embedding) for sample_embedding in sample_embeddings)
                if score > best_score:
                    best_score = score
                    best_intent = intent
        except Exception:
            return "unknown", 0.0

        if best_score < self.sentence_similarity_threshold:
            return best_intent, best_score * 0.85
        return best_intent, best_score

    def _rule_based_intent(self, text: str) -> tuple[str, float]:
        lowered = text.lower()
        has_transfer = any(token in lowered for token in ["pay", "send", "transfer"])
        has_recharge = "recharge" in lowered or "top up" in lowered
        has_phone = _PHONE_PATTERN.search(lowered) is not None

        if has_recharge or has_phone:
            return "recharge", 0.9 if has_recharge else 0.72

        if has_transfer:
            return "send_money", 0.85

        if any(token in lowered for token in ["balance", "wallet", "account balance"]):
            return "balance_query", 0.95

        if any(token in lowered for token in ["offer", "offers", "coupon", "cashback", "deal"]):
            return "offers_query", 0.92

        if any(token in lowered for token in ["history", "transactions", "statement", "recent payments"]):
            return "transaction_history", 0.92

        if any(token in lowered for token in ["best recharge", "recharge plan", "data plan", "plans for"]):
            return "recharge_plans_query", 0.9

        if any(token in lowered for token in ["book", "trip", "travel", "flight", "bus", "hotel", "ticket"]):
            return "book_service", 0.82

        return "unknown", 0.25

    def _extract_recipient(self, original_text: str) -> str | None:
        lowered = original_text.lower()
        match = re.search(r"\bto\s+([a-z][a-z\s.'-]{1,60})", lowered)
        if not match:
            return None

        candidate = match.group(1)
        candidate = re.split(r"\b(for|using|via|from|on|with)\b", candidate, maxsplit=1)[0]
        candidate = " ".join(candidate.strip(" .,!?;:").split())
        if not candidate:
            return None

        return " ".join(part.capitalize() for part in candidate.split())

    def _extract_slots(self, text: str) -> dict[str, Any]:
        lowered = text.lower().strip()
        amount_match = _AMOUNT_PATTERN.search(lowered)
        amount = float(amount_match.group(1)) if amount_match else None

        phone_match = _PHONE_PATTERN.search(lowered)
        phone = phone_match.group(1) if phone_match else None

        recipient = self._extract_recipient(text)

        operator = None
        for candidate in ["jio", "airtel", "vi", "vodafone", "bsnl"]:
            if candidate in lowered:
                operator = candidate
                break

        route_match = re.search(
            r"from\s+([a-z ]+?)\s+to\s+([a-z ]+?)(?:\s+in|\s+under|\s+for|$)",
            lowered,
        )
        origin = route_match.group(1).strip().title() if route_match else None
        destination = route_match.group(2).strip().title() if route_match else None

        return {
            "amount": amount,
            "recipient": recipient,
            "phone": phone,
            "operator": operator,
            "plan": f"₹{int(amount)} plan" if amount else None,
            "service": "travel" if any(tok in lowered for tok in ["book", "travel", "trip", "flight", "hotel", "bus"]) else None,
            "origin": origin,
            "destination": destination,
        }

    def _build_result(self, intent: str, slots: dict[str, Any], confidence: float) -> dict[str, Any]:
        missing: list[str] = []
        if intent == "send_money":
            if slots.get("amount") is None:
                missing.append("amount")
            if not slots.get("recipient"):
                missing.append("recipient")
        elif intent == "recharge":
            if not slots.get("phone"):
                missing.append("phone")
            if not slots.get("plan"):
                missing.append("plan")
        elif intent == "unknown":
            missing.append("intent")

        return {
            "intent": intent,
            "amount": slots.get("amount"),
            "recipient": slots.get("recipient"),
            "phone": slots.get("phone"),
            "operator": slots.get("operator"),
            "plan": slots.get("plan"),
            "service": slots.get("service"),
            "origin": slots.get("origin"),
            "destination": slots.get("destination"),
            "missing_fields": missing,
            "confidence": round(confidence, 4),
            "classifier": "distilbert_local+sentence_rules",
        }

    def _fallback_intent(self, user_input: str) -> dict[str, Any]:
        # Kept for backward compatibility in case older imports call this method.
        return self._build_result("unknown", self._extract_slots(user_input), confidence=0.0)
