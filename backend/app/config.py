from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_env: str = "development"
    database_url: str = "sqlite+aiosqlite:///./proofbuy_dev.db"
    channel3_api_key: str = ""
    ai_provider: str = "openai"
    ai_provider_api_key: str = ""
    ai_model: str = "gpt-4o"
    paypal_client_id: str = ""
    paypal_client_secret: str = ""
    paypal_environment: str = "sandbox"
    cors_allowed_origins: List[str] = ["http://localhost:3000"]

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
