from pydantic_settings import BaseSettings
from functools import lru_cache


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

    # Agent Layer Config (future NLP integration)
    AGENT_API_KEY: str = "agent-api-key-placeholder"
    AGENT_ENABLED: bool = False
    AGENT_MAX_QUERY_BUDGET: float = 100000.0

    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()
