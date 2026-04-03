from __future__ import annotations

import uuid
from datetime import datetime, timezone


def send_money(user_id: str, recipient: str, amount: float) -> dict:
    if amount <= 0:
        return {"status": "failed", "reason": "Amount must be greater than 0"}

    if amount > 100000:
        return {"status": "failed", "reason": "Amount exceeds transfer limit"}

    if "fail" in recipient.lower():
        return {"status": "failed", "reason": "Beneficiary bank timed out"}

    tx_id = f"TXN-{uuid.uuid4().hex[:10].upper()}"
    return {
        "status": "success",
        "transaction_id": tx_id,
        "type": "send_money",
        "user_id": user_id,
        "recipient": recipient,
        "amount": amount,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
