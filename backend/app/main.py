from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
from .auth.middleware import get_current_user
from .core.config import get_settings
from .core.database import init_db
from .core.seed import seed_reference_data
from .routers import auth_router, transactions_router, travel_router, services_router, bank_router
from .routes import agent_router

settings = get_settings()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables
    try:
        await init_db()
        await seed_reference_data()
    except Exception as exc:
        # Keep agent endpoints available for prototype/demo mode without DB.
        logger.warning("Database init failed; continuing in degraded mode: %s", exc)
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
app.include_router(transactions_router, prefix="/api", dependencies=[Depends(get_current_user)])
app.include_router(travel_router, prefix="/api", dependencies=[Depends(get_current_user)])
app.include_router(services_router, prefix="/api", dependencies=[Depends(get_current_user)])
app.include_router(bank_router, prefix="/api", dependencies=[Depends(get_current_user)])
app.include_router(agent_router, prefix="/api", dependencies=[Depends(get_current_user)])


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
