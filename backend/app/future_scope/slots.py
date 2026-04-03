from __future__ import annotations

import re
from typing import Any


AMOUNT_PATTERN = re.compile(r"(?:rs\.?|inr\.?|₹)?\s*(\d{2,7})(?:\.\d{1,2})?", re.IGNORECASE)
PHONE_PATTERN = re.compile(r"\b(?:\+91[-\s]?)?[6-9]\d{9}\b")
UPI_PATTERN = re.compile(r"\b[a-zA-Z0-9._-]{2,}@[a-zA-Z]{2,}\b")


def extract_slots(text: str) -> dict[str, Any]:
    lowered = text.lower()
    entities: dict[str, Any] = {}

    amount_match = AMOUNT_PATTERN.search(text)
    if amount_match:
        entities["amount"] = float(amount_match.group(1))

    phone_match = PHONE_PATTERN.search(text)
    if phone_match:
        entities["phone"] = phone_match.group(0)

    upi_match = UPI_PATTERN.search(text)
    if upi_match:
        entities["upi_id"] = upi_match.group(0)

    if "offer" in lowered or "discount" in lowered or "cashback" in lowered:
        entities["category"] = "offers"
    if "electricity" in lowered:
        entities["biller_id"] = "electricity"
    if "water" in lowered:
        entities["biller_id"] = "water"
    if "gas" in lowered:
        entities["biller_id"] = "gas"
    if "rent" in lowered:
        entities["recipient"] = "landlord"

    return entities
