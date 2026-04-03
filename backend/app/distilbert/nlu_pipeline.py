from __future__ import annotations

from .distilbert_adapter import IntentClassifier
from .intents_taxonomy import INTENT_ALIASES, REQUIRED_FIELDS_BY_INTENT
from .schemas import NLUResult, SlotExtraction
from .slots import extract_slots


def _normalize_intent(intent: str) -> str:
    return INTENT_ALIASES.get(intent, intent)


async def run_nlu(
    text: str,
    classifier: IntentClassifier,
    confidence_threshold: float = 0.70,
) -> NLUResult:
    prediction = await classifier.predict(text)
    normalized = _normalize_intent(prediction.intent)

    entities = extract_slots(text)
    required = REQUIRED_FIELDS_BY_INTENT.get(normalized, ["intent"])
    missing = [field for field in required if field not in entities]

    needs_clarification = prediction.confidence < confidence_threshold or bool(missing)

    return NLUResult(
        prediction=prediction,
        normalized_intent=normalized,
        slots=SlotExtraction(entities=entities, missing_required=missing),
        requires_clarification=needs_clarification,
    )
