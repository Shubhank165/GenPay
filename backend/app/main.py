from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from .core.config import get_settings
from .core.database import init_db
from .routers import auth_router, transactions_router, travel_router, services_router, agent_router

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables
    await init_db()
    yield
    # Shutdown


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
## GenPay API — Agent-Friendly Financial Super App Backend

### Architecture
This API is designed with a future NLP agent layer in mind:
- **Structured endpoints** with queryable parameters (price, date, city, type)
- **Agent capability discovery** at `/agent/capabilities`
- **Natural language query** entry point at `/agent/query`
- **Composable responses** that agents can aggregate across services

### Modules
- 🔐 **Auth** — Phone/OTP login, JWT tokens
- 💸 **Transactions** — Payment ledger with rich filtering
- ✈️ **Travel** — Flights, buses, hotels, movies search
- 📱 **Services** — Recharge plans, bill payments, offers
- 🤖 **Agent** — NLP integration layer (future)
    """,
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth_router)
app.include_router(transactions_router)
app.include_router(travel_router)
app.include_router(services_router)
app.include_router(agent_router)


@app.get("/", tags=["Health"])
async def root():
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running",
        "docs": "/docs",
        "agent_enabled": settings.AGENT_ENABLED,
    }


@app.get("/health", tags=["Health"])
async def health():
    return {"status": "healthy"}
