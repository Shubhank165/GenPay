from __future__ import annotations

from ..core.state import AgentState
from ..memory import memory_store


def _match_directory_recipients(recipient_hint: str, directory: list[dict]) -> list[str]:
    def _normalize(value: str) -> str:
        cleaned = "".join(ch.lower() if ch.isalnum() or ch.isspace() else " " for ch in value)
        return " ".join(cleaned.split())

    hint = _normalize(recipient_hint)
    if not hint:
        return []

    matches: list[str] = []
    for entry in directory:
        name = str(entry.get("name") or "").strip()
        phone = str(entry.get("phone") or "").strip()
        upi_id = str(entry.get("upi_id") or "").strip().lower()
        display = name or upi_id or phone
        if not display:
            continue

        if name and hint in _normalize(name):
            matches.append(display)
            continue
        if phone and hint == _normalize(phone):
            matches.append(display)
            continue
        if upi_id and hint in _normalize(upi_id):
            matches.append(display)

    # Preserve order while deduplicating.
    return list(dict.fromkeys(matches))


async def context_node(state: AgentState) -> AgentState:
    state["current_step"] = 2
    user_id = state["user_id"]
    memory_store.seed_user(user_id)

    base_context = state.get("context", {})
    context = {**memory_store.get_context(user_id), **base_context}
    intent = state.get("intent", {})
    missing = set(state.get("missing_fields", []))

    if intent.get("intent") == "send_money":
        recipient = intent.get("recipient")
        if recipient:
            resolution = memory_store.resolve_contact(user_id, recipient)
            if resolution["ambiguous"]:
                state["status"] = "failed"
                state["message"] = (
                    "Multiple matching recipients found: "
                    + ", ".join(resolution["options"])
                )
                state["error"] = "Multiple contacts match recipient. Please specify the full name."
                missing.add("recipient")
            elif resolution.get("not_found"):
                directory = context.get("recipient_directory", [])
                directory_matches = _match_directory_recipients(str(recipient), directory)

                if len(directory_matches) == 1:
                    intent["recipient"] = directory_matches[0]
                    context["is_new_recipient"] = True
                    context["recipient_source"] = "registered_user"
                elif len(directory_matches) > 1:
                    state["status"] = "failed"
                    state["message"] = (
                        "Multiple registered users match recipient: "
                        + ", ".join(directory_matches)
                    )
                    state["error"] = "Multiple registered recipients match. Please be more specific."
                    missing.add("recipient")
                else:
                    state["status"] = "failed"
                    state["message"] = "Recipient not found in contacts or registered users."
                    state["error"] = "Recipient not found in contacts or registered users."
                    missing.add("recipient")
            else:
                intent["recipient"] = resolution["resolved"]
                context["is_new_recipient"] = resolution["is_new"]
        else:
            missing.add("recipient")

        if not intent.get("amount"):
            missing.add("amount")

    if intent.get("intent") == "recharge":
        if not intent.get("phone"):
            default_phone = memory_store.get_default_phone(user_id)
            if default_phone:
                intent["phone"] = default_phone
            else:
                missing.add("phone")

        if not intent.get("plan") and intent.get("amount"):
            intent["plan"] = f"₹{int(intent['amount'])} plan"

        if not intent.get("plan"):
            missing.add("plan")

    state["intent"] = intent
    state["context"] = context
    state["missing_fields"] = sorted(missing)
    return state
