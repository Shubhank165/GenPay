"""
GenPay Database Models
Designed for agent-friendly querying — all entities have structured,
queryable fields that an NLP system can compose into SQL/API calls.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Float, Integer, Boolean, DateTime, Text,
    ForeignKey, Enum, Index, CheckConstraint
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
import enum
from ..core.database import Base


def utc_now():
    return datetime.now(timezone.utc)


def gen_uuid():
    return str(uuid.uuid4())


# ─── ENUMS (Agent-friendly: clear, queryable string values) ───

class TransactionType(str, enum.Enum):
    UPI_TRANSFER = "upi_transfer"
    WALLET_TOPUP = "wallet_topup"
    WALLET_WITHDRAW = "wallet_withdraw"
    RECHARGE = "recharge"
    BILL_PAYMENT = "bill_payment"
    FLIGHT_BOOKING = "flight_booking"
    BUS_BOOKING = "bus_booking"
    TRAIN_BOOKING = "train_booking"
    HOTEL_BOOKING = "hotel_booking"
    MOVIE_BOOKING = "movie_booking"
    GOLD_PURCHASE = "gold_purchase"
    GOLD_SELL = "gold_sell"
    INSURANCE = "insurance"
    LOAN_EMI = "loan_emi"
    REFUND = "refund"


class TransactionStatus(str, enum.Enum):
    PENDING = "pending"
    SUCCESS = "success"
    FAILED = "failed"
    REFUNDED = "refunded"


class BillCategory(str, enum.Enum):
    ELECTRICITY = "electricity"
    GAS = "gas"
    WATER = "water"
    BROADBAND = "broadband"
    DTH = "dth"
    CREDIT_CARD = "credit_card"
    INSURANCE = "insurance"
    RENT = "rent"
    EDUCATION = "education"
    MUNICIPAL_TAX = "municipal_tax"
    FASTAG = "fastag"


class KYCStatus(str, enum.Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    VERIFIED = "verified"
    REJECTED = "rejected"


class CabinClass(str, enum.Enum):
    ECONOMY = "economy"
    PREMIUM_ECONOMY = "premium_economy"
    BUSINESS = "business"
    FIRST = "first"


class BusType(str, enum.Enum):
    SEATER = "seater"
    SLEEPER = "sleeper"
    SEMI_SLEEPER = "semi_sleeper"
    AC_SEATER = "ac_seater"
    AC_SLEEPER = "ac_sleeper"
    VOLVO = "volvo"


class MovieLanguage(str, enum.Enum):
    HINDI = "hindi"
    ENGLISH = "english"
    TAMIL = "tamil"
    TELUGU = "telugu"
    KANNADA = "kannada"
    MALAYALAM = "malayalam"
    BENGALI = "bengali"
    MARATHI = "marathi"


# ─── USER ───

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=gen_uuid)
    phone = Column(String(15), unique=True, nullable=False, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    upi_id = Column(String(100), unique=True, nullable=True)
    kyc_status = Column(Enum(KYCStatus), default=KYCStatus.NOT_STARTED)
    wallet_balance = Column(Float, default=19748.45)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    # Relationships
    bank_accounts = relationship("BankAccount", back_populates="user")
    transactions = relationship("Transaction", back_populates="user")
    bills = relationship("Bill", back_populates="user")

    __table_args__ = (
        Index("ix_users_phone_active", "phone", "is_active"),
    )


# ─── BANK ACCOUNT ───

class BankAccount(Base):
    __tablename__ = "bank_accounts"

    id = Column(String, primary_key=True, default=gen_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    bank_name = Column(String(100), nullable=False)
    account_number = Column(String(20), nullable=False)
    ifsc_code = Column(String(11), nullable=False)
    upi_id = Column(String(100), nullable=True)
    balance = Column(Float, default=0.0)
    is_default = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    user = relationship("User", back_populates="bank_accounts")


# ─── TRANSACTION (central ledger — agent queries this heavily) ───

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String, primary_key=True, default=gen_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    type = Column(Enum(TransactionType), nullable=False, index=True)
    status = Column(Enum(TransactionStatus), default=TransactionStatus.PENDING, index=True)
    amount = Column(Float, nullable=False)
    currency = Column(String(3), default="INR")
    recipient_name = Column(String(200), nullable=True)
    recipient_identifier = Column(String(200), nullable=True)  # UPI ID, phone, account
    description = Column(Text, nullable=True)
    reference_id = Column(String(100), nullable=True)  # links to booking/bill IDs
    metadata_json = Column(Text, nullable=True)  # flexible JSON for agent queries
    created_at = Column(DateTime(timezone=True), default=utc_now, index=True)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    user = relationship("User", back_populates="transactions")

    __table_args__ = (
        Index("ix_txn_user_type_date", "user_id", "type", "created_at"),
        Index("ix_txn_status_date", "status", "created_at"),
        CheckConstraint("amount > 0", name="ck_txn_positive_amount"),
    )


# ─── BILL ───

class Bill(Base):
    __tablename__ = "bills"

    id = Column(String, primary_key=True, default=gen_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    category = Column(Enum(BillCategory), nullable=False, index=True)
    provider_name = Column(String(200), nullable=False)
    consumer_number = Column(String(50), nullable=False)
    amount = Column(Float, nullable=False)
    due_date = Column(DateTime(timezone=True), nullable=True)
    is_paid = Column(Boolean, default=False)
    paid_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    user = relationship("User", back_populates="bills")


# ─── FLIGHT (Agent-queryable: source, dest, price, date, airline) ───

class Flight(Base):
    __tablename__ = "flights"

    id = Column(String, primary_key=True, default=gen_uuid)
    airline = Column(String(100), nullable=False, index=True)
    flight_code = Column(String(20), nullable=False)
    origin_city = Column(String(100), nullable=False, index=True)
    origin_code = Column(String(10), nullable=False)
    destination_city = Column(String(100), nullable=False, index=True)
    destination_code = Column(String(10), nullable=False)
    departure_time = Column(DateTime(timezone=True), nullable=False, index=True)
    arrival_time = Column(DateTime(timezone=True), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    stops = Column(Integer, default=0)  # 0 = non-stop
    cabin_class = Column(Enum(CabinClass), default=CabinClass.ECONOMY)
    price = Column(Float, nullable=False, index=True)
    available_seats = Column(Integer, default=180)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    __table_args__ = (
        Index("ix_flight_route", "origin_code", "destination_code"),
        Index("ix_flight_price_date", "price", "departure_time"),
        Index("ix_flight_search", "origin_code", "destination_code", "departure_time", "price"),
        CheckConstraint("price > 0", name="ck_flight_positive_price"),
        CheckConstraint("available_seats >= 0", name="ck_flight_seats_non_negative"),
    )


# ─── BUS ROUTE (Agent-queryable: source, dest, price, type) ───

class BusRoute(Base):
    __tablename__ = "bus_routes"

    id = Column(String, primary_key=True, default=gen_uuid)
    operator = Column(String(100), nullable=False, index=True)
    bus_type = Column(Enum(BusType), nullable=False, index=True)
    origin_city = Column(String(100), nullable=False, index=True)
    destination_city = Column(String(100), nullable=False, index=True)
    departure_time = Column(DateTime(timezone=True), nullable=False, index=True)
    arrival_time = Column(DateTime(timezone=True), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    price = Column(Float, nullable=False, index=True)
    available_seats = Column(Integer, default=40)
    rating = Column(Float, default=0.0)
    amenities = Column(Text, nullable=True)  # JSON: ["wifi", "charging", "blanket"]
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    __table_args__ = (
        Index("ix_bus_route", "origin_city", "destination_city"),
        Index("ix_bus_search", "origin_city", "destination_city", "departure_time", "price"),
        CheckConstraint("price > 0", name="ck_bus_positive_price"),
    )


# ─── MOVIE (Agent-queryable: title, city, genre, language, showtime) ───

class Movie(Base):
    __tablename__ = "movies"

    id = Column(String, primary_key=True, default=gen_uuid)
    title = Column(String(200), nullable=False, index=True)
    genre = Column(String(100), nullable=False, index=True)
    language = Column(Enum(MovieLanguage), nullable=False, index=True)
    duration_minutes = Column(Integer, nullable=False)
    rating = Column(Float, default=0.0)
    certificate = Column(String(10), default="UA")  # U, UA, A
    release_date = Column(DateTime(timezone=True), nullable=True)
    poster_url = Column(String(500), nullable=True)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)


class MovieShowtime(Base):
    __tablename__ = "movie_showtimes"

    id = Column(String, primary_key=True, default=gen_uuid)
    movie_id = Column(String, ForeignKey("movies.id"), nullable=False, index=True)
    theater_name = Column(String(200), nullable=False)
    city = Column(String(100), nullable=False, index=True)
    screen = Column(String(20), nullable=True)
    show_time = Column(DateTime(timezone=True), nullable=False, index=True)
    price = Column(Float, nullable=False)
    available_seats = Column(Integer, default=200)
    is_active = Column(Boolean, default=True)

    movie = relationship("Movie")

    __table_args__ = (
        Index("ix_showtime_search", "city", "movie_id", "show_time"),
        Index("ix_showtime_city_date", "city", "show_time"),
    )


# ─── HOTEL (Agent-queryable: city, price, rating, amenities) ───

class Hotel(Base):
    __tablename__ = "hotels"

    id = Column(String, primary_key=True, default=gen_uuid)
    name = Column(String(200), nullable=False, index=True)
    city = Column(String(100), nullable=False, index=True)
    address = Column(Text, nullable=True)
    star_rating = Column(Integer, default=3)
    user_rating = Column(Float, default=0.0)
    price_per_night = Column(Float, nullable=False, index=True)
    amenities = Column(Text, nullable=True)  # JSON array
    room_types = Column(Text, nullable=True)  # JSON
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    image_url = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    __table_args__ = (
        Index("ix_hotel_city_price", "city", "price_per_night"),
        Index("ix_hotel_city_rating", "city", "user_rating"),
        CheckConstraint("price_per_night > 0", name="ck_hotel_positive_price"),
    )


# ─── RECHARGE PLAN (Agent-queryable: operator, type, price) ───

class RechargePlan(Base):
    __tablename__ = "recharge_plans"

    id = Column(String, primary_key=True, default=gen_uuid)
    operator = Column(String(50), nullable=False, index=True)
    plan_type = Column(String(30), nullable=False, index=True)  # popular, data, unlimited, talktime
    price = Column(Float, nullable=False, index=True)
    validity_days = Column(Integer, nullable=False)
    data_per_day = Column(String(20), nullable=True)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    __table_args__ = (
        Index("ix_recharge_operator_type", "operator", "plan_type"),
    )


# ─── OFFER / COUPON (Agent can recommend offers) ───

class Offer(Base):
    __tablename__ = "offers"

    id = Column(String, primary_key=True, default=gen_uuid)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    discount_type = Column(String(20), nullable=False)  # flat, percentage
    discount_value = Column(Float, nullable=False)
    min_amount = Column(Float, default=0.0)
    max_discount = Column(Float, nullable=True)
    coupon_code = Column(String(30), nullable=True, unique=True)
    category = Column(String(50), nullable=False, index=True)  # recharge, travel, bills, upi
    valid_from = Column(DateTime(timezone=True), nullable=False)
    valid_till = Column(DateTime(timezone=True), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    __table_args__ = (
        Index("ix_offer_category_active", "category", "is_active"),
    )


# ─── GOLD PRICE (Agent tracks market data) ───

class GoldPrice(Base):
    __tablename__ = "gold_prices"

    id = Column(String, primary_key=True, default=gen_uuid)
    price_per_gram = Column(Float, nullable=False)
    purity = Column(String(10), default="24K")
    recorded_at = Column(DateTime(timezone=True), default=utc_now, index=True)
