from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(slots=True)
class IntentPrediction:
    intent: str
    confidence: float
    # Optional top-k output for analysis and debugging.
    alternatives: list[tuple[str, float]] = field(default_factory=list)


@dataclass(slots=True)
class SlotExtraction:
    entities: dict[str, Any] = field(default_factory=dict)
    missing_required: list[str] = field(default_factory=list)


@dataclass(slots=True)
class NLUResult:
    prediction: IntentPrediction
    slots: SlotExtraction
    normalized_intent: str
    requires_clarification: bool
