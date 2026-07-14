"""Lifespan FastAPI com ping das dependências externas."""

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from loguru import logger
from redis.asyncio import Redis
from sqlalchemy import text

from app.src.adapters.outbound.db import engine
from app.src.core.logging import configure_logging
from app.src.settings import settings


async def _ping_postgres() -> None:
    """Valida conectividade com o PostgreSQL."""
    async with engine.connect() as connection:
        await connection.execute(text("SELECT 1"))
    logger.info("postgres_ping_ok")


async def _ping_redis() -> None:
    """Valida conectividade com o Redis."""
    client = Redis.from_url(settings.redis_url)
    try:
        pong = await client.ping()
        if not pong:
            raise RuntimeError("Redis PING returned falsy")
        logger.info("redis_ping_ok")
    finally:
        await client.aclose()


async def _ping_rabbitmq() -> None:
    """Valida conectividade com o RabbitMQ."""
    import aio_pika

    connection = await aio_pika.connect_robust(settings.rabbitmq_url)
    await connection.close()
    logger.info("rabbitmq_ping_ok")


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    """Configura logs e verifica dependências antes de aceitar tráfego."""
    configure_logging(level=settings.log_level)
    logger.info("service_starting name={}", settings.service_name)

    if settings.skip_dependency_pings:
        logger.warning("dependency_pings_skipped")
    else:
        await _ping_postgres()
        await _ping_redis()
        await _ping_rabbitmq()

    logger.info("service_ready")
    yield
    logger.info("service_stopping")
    await engine.dispose()
