from __future__ import annotations

import uuid
from datetime import datetime, timezone


def recharge(phone: str, plan: str, amount: float | None = None) -> dict:
    if not phone or len(phone) != 10:
        return {"status": "failed", "reason": "Invalid phone number"}

    if amount is not None and amount <= 0:
        return {"status": "failed", "reason": "Invalid recharge amount"}

    tx_id = f"RCG-{uuid.uuid4().hex[:10].upper()}"
    return {
        "status": "success",
        "transaction_id": tx_id,
        "type": "recharge",
        "phone": phone,
        "plan": plan,
        "amount": amount,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
