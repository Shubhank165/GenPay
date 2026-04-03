# GenPay

GenPay is a full-stack fintech super app prototype inspired by modern digital payment platforms. It combines a rich Flutter client experience with a modular FastAPI backend and an experimental agentic layer for natural-language financial workflows.

This project demonstrates how a traditional payment app architecture can evolve toward AI-assisted task execution while still keeping APIs structured, secure, and production-oriented.

## Project Overview

GenPay is built as an end-to-end product prototype with two major components:

- `genpay/`: Flutter application for user-facing flows (auth, wallet, transactions, services)
- `backend/`: FastAPI service for auth, ledger operations, travel/services discovery, and agent endpoints

The backend includes a LangGraph-based orchestration path for intent-driven actions like payments and recharges, with risk-aware confirmation support.

## Key Features

- JWT-based authentication and protected APIs
- Wallet and transaction flows
- Service modules for recharge, bills, offers, and discovery categories
- Travel and booking-oriented APIs (flights, buses, hotels, movies)
- Agent query endpoint for natural-language requests
- Rule-based risk scoring with optional human-in-the-loop confirmation

## Repository Structure

```text
GenPay/
  backend/   # FastAPI backend + PostgreSQL + agentic orchestration
  genpay/    # Flutter app (Android, iOS, Web, Desktop)
```

## Tech Stack

- Frontend: Flutter, Provider
- Backend: FastAPI, SQLAlchemy, Pydantic, LangGraph
- Database: PostgreSQL
- Infra: Docker Compose

## Prerequisites

Install these tools locally:

- Flutter SDK (Dart >= 3.4.3)
- Python 3.11+
- Docker + Docker Compose (recommended)
- Git

## Getting Started

### 1) Clone Repository

```bash
git clone https://github.com/Shubhank165/GenPay.git
cd GenPay
```

### 2) Start Backend

#### Option A: Docker (recommended)

```bash
cd backend
docker compose up --build
```

Available services:

- API: `http://localhost:8000`
- API Docs: `http://localhost:8000/docs`
- PostgreSQL: `localhost:5432`

#### Option B: Manual Python setup

```bash
cd backend
python -m venv .venv
```

Activate the environment:

```bash
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# macOS/Linux
source .venv/bin/activate
```

Install and run:

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Note: The backend reads environment values from `backend/.env` (if present). Otherwise, local defaults from `backend/app/core/config.py` are used.

### 3) Start Flutter App

```bash
cd genpay
flutter pub get
flutter run
```

Run on a specific target:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

## API Quick Reference

- `GET /` - API metadata
- `GET /health` - health status
- `GET /docs` - Swagger documentation
- `POST /api/agent/query` - agentic natural-language query endpoint

## Database and Data Model

- Schema planning document: `backend/DB_SCHEMA.md`
- Database tables are initialized during backend startup
- Reference data is seeded when database connectivity is available

## Additional Documentation

- Backend-specific details: `backend/README.md`
- Flutter app details: `genpay/README.md`

## Troubleshooting

- If the backend cannot connect to PostgreSQL, verify `DATABASE_URL` and container status.
- If Flutter targets are missing, run `flutter doctor` and complete pending setup.
- If the app cannot reach backend from an emulator/device, verify host mapping and port access.

## Contributing

Contributions are welcome. Open an issue for feature requests or bug reports, and use focused pull requests with clear descriptions.

## License

No license file is currently included. Add a `LICENSE` file to define usage and distribution terms.
