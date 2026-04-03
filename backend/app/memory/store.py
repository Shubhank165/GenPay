from __future__ import annotations

from collections import defaultdict
from threading import Lock
from typing import Any


class InMemoryStore:
    def __init__(self) -> None:
        self._lock = Lock()
        self._contacts: dict[str, list[str]] = defaultdict(list)
        self._trusted_recipients: dict[str, set[str]] = defaultdict(set)
        self._last_transactions: dict[str, list[dict[str, Any]]] = defaultdict(list)
        self._default_phone: dict[str, str] = {}

    def get_context(self, user_id: str) -> dict[str, Any]:
        return {
            "contacts": self._contacts.get(user_id, []),
            "trusted_recipients": list(self._trusted_recipients.get(user_id, set())),
            "last_transactions": self._last_transactions.get(user_id, []),
            "default_phone": self._default_phone.get(user_id),
        }

    def seed_user(self, user_id: str) -> None:
        with self._lock:
            if user_id in self._contacts:
                return
            self._contacts[user_id] = ["Rahul Sharma", "Rahul Verma", "Priya Nair"]
            self._trusted_recipients[user_id] = {"Rahul Sharma", "Priya Nair"}
            self._default_phone[user_id] = "9876543210"

    def resolve_contact(self, user_id: str, recipient_hint: str) -> dict[str, Any]:
        hint = recipient_hint.lower().strip()
        candidates = [c for c in self._contacts.get(user_id, []) if hint in c.lower()]

        if len(candidates) == 1:
            resolved = candidates[0]
            return {
                "resolved": resolved,
                "ambiguous": False,
                "not_found": False,
                "options": [],
                "is_new": resolved not in self._trusted_recipients.get(user_id, set()),
            }

        if len(candidates) > 1:
            return {
                "resolved": None,
                "ambiguous": True,
                "not_found": False,
                "options": candidates,
                "is_new": True,
            }

        return {
            "resolved": None,
            "ambiguous": False,
            "not_found": True,
            "options": [],
            "is_new": False,
        }

    def get_default_phone(self, user_id: str) -> str | None:
        return self._default_phone.get(user_id)

    def record_transaction(self, user_id: str, tx: dict[str, Any]) -> None:
        with self._lock:
            self._last_transactions[user_id].insert(0, tx)
            self._last_transactions[user_id] = self._last_transactions[user_id][:10]

            recipient = tx.get("recipient")
            if recipient:
                self._trusted_recipients[user_id].add(recipient)
                if recipient not in self._contacts[user_id]:
                    self._contacts[user_id].append(recipient)


memory_store = InMemoryStore()
