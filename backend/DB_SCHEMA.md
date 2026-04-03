# GenPay PostgreSQL Schema Plan

This schema supports both classic fintech APIs and agentic workflows.

## 1) Identity and Account Domain

- users
- bank_accounts

Relation:
- users 1:N bank_accounts

Purpose:
- Authenticate by phone, store profile, UPI identity, and wallet balance.

## 2) Financial Ledger Domain

- transactions

Relation:
- users 1:N transactions

Purpose:
- Unified ledger for payments, recharge, bookings, and refunds.

Core constraints:
- Positive amount check
- Indexed by user + type + created_at
- Indexed by status + created_at

## 3) Utility Services Domain

- bills
- recharge_plans
- offers

Relation:
- users 1:N bills

Purpose:
- Bill management and payments
- Recharge discovery with filters
- Offer recommendation and coupon matching

## 4) Travel and Discovery Domain

- flights
- bus_routes
- hotels
- movies
- movie_showtimes

Relations:
- movies 1:N movie_showtimes

Purpose:
- Search-oriented inventory for agent orchestration.

## 5) Market Data Domain

- gold_prices

Purpose:
- Price time series for financial products.

## Entity Design Notes

- UUID-like string IDs used across entities for API portability.
- Enum fields ensure normalized query values for agents.
- Search-heavy indexes added for route, city, category, price, and date queries.
- Metadata fields allow extensibility for agent execution traces.

## Runtime Bootstrapping

- Tables are created at startup via SQLAlchemy metadata.
- Seed data is inserted once for:
  - flights
  - bus_routes
  - hotels
  - movies
  - recharge_plans
  - offers

Files:
- app/models/models.py
- app/core/database.py
- app/core/seed.py
