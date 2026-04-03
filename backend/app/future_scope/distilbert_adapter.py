from __future__ import annotations

from abc import ABC, abstractmethod

from app.future_scope.intents_taxonomy import CANONICAL_INTENTS
from app.future_scope.schemas import IntentPrediction


class IntentClassifier(ABC):
    @abstractmethod
    async def predict(self, text: str) -> IntentPrediction:
        raise NotImplementedError


class MockIntentClassifier(IntentClassifier):
    """
    Safe placeholder adapter.

    This class intentionally avoids importing heavy ML dependencies so it can
    live in production codebase without impacting the current Gemini runtime.
    """

    async def predict(self, text: str) -> IntentPrediction:
        lowered = text.lower().strip()
        if any(token in lowered for token in ["balance", "wallet", "how much"]):
            return IntentPrediction(
                intent="check_balance",
                confidence=0.88,
                alternatives=[("view_transactions", 0.08), ("offers_query", 0.04)],
            )
        if any(token in lowered for token in ["send", "pay", "transfer"]):
            return IntentPrediction(
                intent="send_money",
                confidence=0.81,
                alternatives=[("pay_merchant", 0.11), ("bank_transfer", 0.08)],
            )
        return IntentPrediction(
            intent="unknown",
            confidence=0.35,
            alternatives=[(label, 0.0) for label in CANONICAL_INTENTS[:3]],
        )
