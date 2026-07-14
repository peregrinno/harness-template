"""Aplicação exemplo FastAPI com arquitetura hexagonal."""

from fastapi import FastAPI

from app.src.adapters.inbound.health_controller import HealthController
from app.src.core.lifespan import lifespan
from app.src.core.logging import configure_logging
from app.src.use_cases.get_health_usecase import GetHealthUseCase


def create_app() -> FastAPI:
    """Cria e configura a aplicação FastAPI."""
    configure_logging()
    application = FastAPI(
        title="service-example",
        version="0.1.0",
        lifespan=lifespan,
    )
    use_case = GetHealthUseCase()
    controller = HealthController(get_health_use_case=use_case)
    application.include_router(controller.router)
    return application


app = create_app()
