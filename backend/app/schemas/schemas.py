"""Pydantic schemas for API request/response validation — agent-friendly structured output."""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


# ─── AUTH ───
class PhoneLoginRequest(BaseModel):
    phone: str = Field(..., pattern=r"^\+91[6-9]\d{9}$", description="Indian E.164 mobile")

class OTPVerifyRequest(BaseModel):
    phone: str
    otp: str = Field(..., min_length=6, max_length=6)

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: Optional[str] = None

class UserResponse(BaseModel):
    id: str
    name: str
    phone: str
    email: Optional[str] = None
    upi_id: Optional[str] = None
    kyc_status: str
    wallet_balance: float
    created_at: datetime
    class Config:
        from_attributes = True


# ─── TRANSACTION ───
class TransactionCreate(BaseModel):
    type: str
    amount: float = Field(..., gt=0)
    recipient_name: Optional[str] = None
    recipient_identifier: Optional[str] = None
    description: Optional[str] = None
    upi_pin: Optional[str] = Field(None, min_length=6, max_length=6)

class TransactionResponse(BaseModel):
    id: str
    type: str
    status: str
    amount: float
    currency: str
    recipient_name: Optional[str]
    recipient_identifier: Optional[str]
    description: Optional[str]
    reference_id: Optional[str]
    created_at: datetime
    class Config:
        from_attributes = True

class TransactionListResponse(BaseModel):
    transactions: List[TransactionResponse]
    total: int
    page: int
    page_size: int


# ─── BANK ACCOUNT ───
class BankAccountCreate(BaseModel):
    bank_name: str
    account_number: str
    ifsc_code: str = Field(..., pattern=r"^[A-Z]{4}0[A-Z0-9]{6}$")
    is_default: bool = False

class BankAccountResponse(BaseModel):
    id: str
    bank_name: str
    account_number: str
    ifsc_code: str
    upi_id: Optional[str]
    balance: float
    is_default: bool
    class Config:
        from_attributes = True


# ─── FLIGHT (Agent-queryable schema) ───
class FlightSearchRequest(BaseModel):
    """Agent sends: origin, destination, date, optional constraints"""
    origin: str = Field(..., description="Origin city or airport code")
    destination: str = Field(..., description="Destination city or airport code")
    date: str = Field(..., description="Travel date YYYY-MM-DD")
    max_price: Optional[float] = Field(None, description="Budget constraint")
    max_stops: Optional[int] = Field(None, description="Max stops (0=nonstop)")
    cabin_class: Optional[str] = Field("economy", description="Cabin class")
    passengers: int = Field(1, ge=1, le=9)

class FlightResponse(BaseModel):
    id: str
    airline: str
    flight_code: str
    origin_city: str
    origin_code: str
    destination_city: str
    destination_code: str
    departure_time: datetime
    arrival_time: datetime
    duration_minutes: int
    stops: int
    cabin_class: str
    price: float
    available_seats: int
    class Config:
        from_attributes = True

class FlightSearchResponse(BaseModel):
    flights: List[FlightResponse]
    total: int
    cheapest: Optional[float]
    fastest_minutes: Optional[int]


# ─── BUS (Agent-queryable) ───
class BusSearchRequest(BaseModel):
    origin: str
    destination: str
    date: str
    max_price: Optional[float] = None
    bus_type: Optional[str] = None

class BusResponse(BaseModel):
    id: str
    operator: str
    bus_type: str
    origin_city: str
    destination_city: str
    departure_time: datetime
    arrival_time: datetime
    duration_minutes: int
    price: float
    available_seats: int
    rating: float
    class Config:
        from_attributes = True


# ─── MOVIE (Agent-queryable) ───
class MovieSearchRequest(BaseModel):
    city: str
    title: Optional[str] = None
    genre: Optional[str] = None
    language: Optional[str] = None
    date: Optional[str] = None
    max_price: Optional[float] = None

class MovieResponse(BaseModel):
    id: str
    title: str
    genre: str
    language: str
    duration_minutes: int
    rating: float
    certificate: str
    class Config:
        from_attributes = True

class ShowtimeResponse(BaseModel):
    id: str
    movie: MovieResponse
    theater_name: str
    city: str
    show_time: datetime
    price: float
    available_seats: int
    class Config:
        from_attributes = True


# ─── HOTEL ───
class HotelSearchRequest(BaseModel):
    city: str
    checkin: str
    checkout: str
    max_price: Optional[float] = None
    min_rating: Optional[float] = None
    guests: int = Field(1, ge=1)

class HotelResponse(BaseModel):
    id: str
    name: str
    city: str
    star_rating: int
    user_rating: float
    price_per_night: float
    amenities: Optional[str]
    class Config:
        from_attributes = True


# ─── RECHARGE ───
class RechargeRequest(BaseModel):
    phone: str
    operator: str
    plan_id: str

class RechargePlanResponse(BaseModel):
    id: str
    operator: str
    plan_type: str
    price: float
    validity_days: int
    data_per_day: Optional[str]
    description: Optional[str]
    class Config:
        from_attributes = True


# ─── BILL ───
class BillPayRequest(BaseModel):
    bill_id: str

class BillResponse(BaseModel):
    id: str
    category: str
    provider_name: str
    consumer_number: str
    amount: float
    due_date: Optional[datetime]
    is_paid: bool
    class Config:
        from_attributes = True


# ─── OFFER ───
class OfferResponse(BaseModel):
    id: str
    title: str
    description: Optional[str]
    discount_type: str
    discount_value: float
    coupon_code: Optional[str]
    category: str
    valid_till: datetime
    class Config:
        from_attributes = True


# ─── AGENT QUERY (Future NLP layer) ───
class AgentQueryRequest(BaseModel):
    """Natural language query from the agent layer"""
    query: str = Field(..., description="Natural language query, e.g. 'Plan a trip from Delhi to Goa in ₹10,000'")
    user_id: Optional[str] = None
    context: Optional[dict] = None

class AgentQueryResponse(BaseModel):
    """Structured response for the agent to compose"""
    intent: str
    entities: dict
    results: List[dict]
    summary: str
    total_cost: Optional[float] = None
    suggestions: Optional[List[str]] = None
