"""Configurações assíncronas do serviço."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Carrega variáveis de ambiente do microserviço."""

    database_url: str = (
        "postgresql+asyncpg://platform:platform@localhost:5432/platform"
    )
    redis_url: str = "redis://localhost:6379/0"
    rabbitmq_url: str = "amqp://guest:guest@localhost:5672/"
    service_name: str = "service-example"
    service_version: str = "0.1.0"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
