from pydantic_settings import BaseSettings
from functools import lru_cache
from pathlib import Path


BACKEND_ROOT = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    # App
    APP_NAME: str = "GenPay API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://genpay:genpay_password@localhost:5432/genpay_db"
    DATABASE_URL_SYNC: str = "postgresql://genpay:genpay_password@localhost:5432/genpay_db"

    # Auth
    SECRET_KEY: str = "genpay-super-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours

    # JWT (new auth layer)
    JWT_SECRET: str = "your-super-secret-key-here"
    JWT_ALGORITHM: str = "HS256"

    # Twilio Verify
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_VERIFY_SID: str = ""

    # Agent Layer Config (future NLP integration)
    AGENT_API_KEY: str = "agent-api-key-placeholder"
    AGENT_ENABLED: bool = False
    AGENT_MAX_QUERY_BUDGET: float = 100000.0

    # Agentic workflow thresholds
    AGENT_RISK_THRESHOLD: int = 60
    AGENT_HIGH_VALUE_THRESHOLD: float = 2000.0
    AGENT_MAX_RETRIES: int = 1

    # Local NLU settings (finetuned weights expected on local filesystem).
    DISTILBERT_ENABLED: bool = True
    DISTILBERT_MODEL_PATH: str = "./models/distilbert-intent"
    DISTILBERT_CONFIDENCE_THRESHOLD: float = 0.70
    DISTILBERT_LABEL_ORDER: str = (
        "send_money,recharge,book_service,balance_query,offers_query,"
        "transaction_history,recharge_plans_query,unknown"
    )
    SENTENCE_TRANSFORMER_MODEL_PATH: str = "./models/sentence-transformer-finance"
    SENTENCE_SIMILARITY_THRESHOLD: float = 0.48

    # Speech-to-text (voice prompt input)
    STT_MODEL_SIZE: str = "tiny.en"
    STT_MAX_AUDIO_MB: int = 8

    class Config:
        env_file = str(BACKEND_ROOT / ".env")
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()
