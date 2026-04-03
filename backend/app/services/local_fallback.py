from __future__ import annotations

from datetime import datetime, timedelta, timezone
import uuid
from typing import Any

_USERS_BY_PHONE: dict[str, dict[str, Any]] = {}
_USERS_BY_ID: dict[str, dict[str, Any]] = {}
_TRANSACTIONS: dict[str, list[dict[str, Any]]] = {}
_BILLS: dict[str, list[dict[str, Any]]] = {}
_BANK_ACCOUNTS: dict[str, list[dict[str, Any]]] = {}


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _ensure_user(phone: str) -> dict[str, Any]:
    existing = _USERS_BY_PHONE.get(phone)
    if existing:
        return existing

    user_id = str(uuid.uuid4())
    user = {
        "id": user_id,
        "name": f"User {phone[-4:]}",
        "phone": phone,
        "email": None,
        "upi_id": f"{phone}@genpay",
        "kyc_status": "verified",
        "wallet_balance": 19748.45,
        "created_at": _now(),
    }
    _USERS_BY_PHONE[phone] = user
    _USERS_BY_ID[user_id] = user

    _BILLS[user_id] = [
        {
            "id": f"bill-{user_id[:6]}-1",
            "category": "electricity",
            "provider_name": "State Power",
            "consumer_number": "CON123456",
            "amount": 1240.5,
            "due_date": _now() + timedelta(days=6),
            "is_paid": False,
        },
        {
            "id": f"bill-{user_id[:6]}-2",
            "category": "mobile",
            "provider_name": "Jio",
            "consumer_number": phone,
            "amount": 299.0,
            "due_date": _now() + timedelta(days=2),
            "is_paid": False,
        },
    ]

    _BANK_ACCOUNTS[user_id] = [
        {
            "id": f"bank-{user_id[:8]}-1",
            "bank_name": "State Bank of India",
            "account_number": "30925678431",
            "ifsc_code": "SBIN0001234",
            "upi_id": f"{phone}@sbi",
            "balance": 45230.50,
            "is_default": True,
        },
        {
            "id": f"bank-{user_id[:8]}-2",
            "bank_name": "HDFC Bank",
            "account_number": "50100234567",
            "ifsc_code": "HDFC0001234",
            "upi_id": f"{phone}@hdfcbank",
            "balance": 128750.00,
            "is_default": False,
        },
    ]

    return user


def get_or_create_user(phone: str) -> dict[str, Any]:
    return _ensure_user(phone)


def get_user_by_id(user_id: str) -> dict[str, Any] | None:
    return _USERS_BY_ID.get(user_id)


def list_transactions(
    user_id: str,
    tx_type: str | None = None,
    tx_status: str | None = None,
    min_amount: float | None = None,
    max_amount: float | None = None,
    search: str | None = None,
) -> list[dict[str, Any]]:
    items = list(_TRANSACTIONS.get(user_id, []))

    def _match(tx: dict[str, Any]) -> bool:
        if tx_type and tx["type"] != tx_type:
            return False
        if tx_status and tx["status"] != tx_status:
            return False
        if min_amount is not None and tx["amount"] < min_amount:
            return False
        if max_amount is not None and tx["amount"] > max_amount:
            return False
        if search:
            blob = f"{tx.get('recipient_name', '')} {tx.get('description', '')}".lower()
            if search.lower() not in blob:
                return False
        return True

    return [tx for tx in items if _match(tx)]


def create_transaction(
    user_id: str,
    tx_type: str,
    amount: float,
    recipient_name: str | None,
    recipient_identifier: str | None,
    description: str | None,
) -> dict[str, Any]:
    tx = {
        "id": str(uuid.uuid4()),
        "type": tx_type,
        "status": "success",
        "amount": amount,
        "currency": "INR",
        "recipient_name": recipient_name,
        "recipient_identifier": recipient_identifier,
        "description": description,
        "reference_id": f"REF{uuid.uuid4().hex[:12].upper()}",
        "created_at": _now(),
    }
    _TRANSACTIONS.setdefault(user_id, []).insert(0, tx)
    return tx


def search_flights(origin: str, destination: str, max_price: float | None, max_stops: int | None) -> list[dict[str, Any]]:
    sample = [
        {
            "id": "FL-DEL-BOM-001",
            "airline": "IndiGo",
            "flight_code": "6E201",
            "origin_city": "Delhi",
            "origin_code": "DEL",
            "destination_city": "Mumbai",
            "destination_code": "BOM",
            "departure_time": _now() + timedelta(days=1, hours=2),
            "arrival_time": _now() + timedelta(days=1, hours=4, minutes=20),
            "duration_minutes": 140,
            "stops": 0,
            "cabin_class": "economy",
            "price": 4850.0,
            "available_seats": 8,
        },
        {
            "id": "FL-DEL-BOM-002",
            "airline": "Air India",
            "flight_code": "AI887",
            "origin_city": "Delhi",
            "origin_code": "DEL",
            "destination_city": "Mumbai",
            "destination_code": "BOM",
            "departure_time": _now() + timedelta(days=1, hours=4),
            "arrival_time": _now() + timedelta(days=1, hours=7),
            "duration_minutes": 180,
            "stops": 1,
            "cabin_class": "economy",
            "price": 4300.0,
            "available_seats": 14,
        },
    ]

    items = [
        f
        for f in sample
        if origin.lower() in f["origin_city"].lower()
        and destination.lower() in f["destination_city"].lower()
        and (max_price is None or f["price"] <= max_price)
        and (max_stops is None or f["stops"] <= max_stops)
    ]
    return sorted(items, key=lambda x: x["price"])


def get_flight(flight_id: str) -> dict[str, Any] | None:
    for f in search_flights("delhi", "mumbai", None, None):
        if f["id"] == flight_id:
            return f
    return None


def search_buses(origin: str, destination: str, max_price: float | None, bus_type: str | None) -> list[dict[str, Any]]:
    sample = [
        {
            "id": "BUS-DEL-JAI-001",
            "operator": "RSRTC",
            "bus_type": "AC_SLEEPER",
            "origin_city": "Delhi",
            "destination_city": "Jaipur",
            "departure_time": _now() + timedelta(days=1, hours=1),
            "arrival_time": _now() + timedelta(days=1, hours=7),
            "duration_minutes": 360,
            "price": 799.0,
            "available_seats": 11,
            "rating": 4.2,
        }
    ]
    return [
        b
        for b in sample
        if origin.lower() in b["origin_city"].lower()
        and destination.lower() in b["destination_city"].lower()
        and (max_price is None or b["price"] <= max_price)
        and (bus_type is None or b["bus_type"] == bus_type)
    ]


def search_hotels(city: str, max_price: float | None, min_rating: float | None) -> list[dict[str, Any]]:
    sample = [
        {
            "id": "HOTEL-GOA-001",
            "name": "Blue Bay Resort",
            "city": "Goa",
            "star_rating": 4,
            "user_rating": 4.4,
            "price_per_night": 4200.0,
            "amenities": "pool,wifi,breakfast",
        }
    ]
    return [
        h
        for h in sample
        if city.lower() in h["city"].lower()
        and (max_price is None or h["price_per_night"] <= max_price)
        and (min_rating is None or h["user_rating"] >= min_rating)
    ]


def search_movies(title: str | None, genre: str | None, language: str | None) -> list[dict[str, Any]]:
    sample = [
        {
            "id": "MOV-001",
            "title": "Action Hero",
            "genre": "Action",
            "language": "HINDI",
            "duration_minutes": 145,
            "rating": 4.1,
            "certificate": "UA",
        }
    ]
    return [
        m
        for m in sample
        if (not title or title.lower() in m["title"].lower())
        and (not genre or genre.lower() in m["genre"].lower())
        and (not language or language == m["language"])
    ]


def get_recharge_plans(operator: str | None, plan_type: str | None, max_price: float | None) -> list[dict[str, Any]]:
    sample = [
        {
            "id": "RCH-JIO-299",
            "operator": "Jio",
            "plan_type": "DATA",
            "price": 299.0,
            "validity_days": 28,
            "data_per_day": "2GB",
            "description": "Daily data + unlimited calls",
        },
        {
            "id": "RCH-AIR-249",
            "operator": "Airtel",
            "plan_type": "DATA",
            "price": 249.0,
            "validity_days": 24,
            "data_per_day": "1GB",
            "description": "Daily data + unlimited calls",
        },
    ]

    return [
        p
        for p in sample
        if (not operator or operator.lower() in p["operator"].lower())
        and (not plan_type or p["plan_type"] == plan_type)
        and (max_price is None or p["price"] <= max_price)
    ]


def get_bills(user_id: str, category: str | None, unpaid_only: bool) -> list[dict[str, Any]]:
    bills = list(_BILLS.get(user_id, []))
    return [
        b
        for b in bills
        if (not category or b["category"] == category)
        and (not unpaid_only or not b["is_paid"])
    ]


def pay_bill(user_id: str, bill_id: str) -> dict[str, Any] | None:
    bills = _BILLS.get(user_id, [])
    for bill in bills:
        if bill["id"] == bill_id:
            bill["is_paid"] = True
            return bill
    return None


def get_offers(category: str | None) -> list[dict[str, Any]]:
    sample = [
        {
            "id": "OFF-TRAVEL-10",
            "title": "10% off on flights",
            "description": "Use code FLY10",
            "discount_type": "percentage",
            "discount_value": 10.0,
            "coupon_code": "FLY10",
            "category": "travel",
            "valid_till": _now() + timedelta(days=30),
        },
        {
            "id": "OFF-BILL-50",
            "title": "Flat 50 on bills",
            "description": "On electricity bill payments",
            "discount_type": "flat",
            "discount_value": 50.0,
            "coupon_code": "BILL50",
            "category": "bills",
            "valid_till": _now() + timedelta(days=20),
        },
    ]
    return [o for o in sample if not category or o["category"] == category]


def list_bank_accounts(user_id: str) -> list[dict[str, Any]]:
    return list(_BANK_ACCOUNTS.get(user_id, []))


def add_bank_account(
    user_id: str,
    bank_name: str,
    account_number: str,
    ifsc_code: str,
    is_default: bool,
) -> dict[str, Any]:
    accounts = _BANK_ACCOUNTS.setdefault(user_id, [])
    if is_default:
        for acc in accounts:
            acc["is_default"] = False

    account = {
        "id": f"bank-{user_id[:8]}-{len(accounts) + 1}",
        "bank_name": bank_name,
        "account_number": account_number,
        "ifsc_code": ifsc_code,
        "upi_id": None,
        "balance": 0.0,
        "is_default": is_default,
    }
    accounts.append(account)
    return account
