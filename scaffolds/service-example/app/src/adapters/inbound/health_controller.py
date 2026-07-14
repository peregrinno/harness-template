"""Controlador HTTP de saúde."""

from fastapi import APIRouter

from app.src.use_cases.get_health_usecase import GetHealthUseCase


class HealthController:
    """Expõe endpoints de saúde."""

    def __init__(self, get_health_use_case: GetHealthUseCase) -> None:
        self._get_health_use_case = get_health_use_case
        self.router = APIRouter(tags=["health"])
        self.router.add_api_route(
            path="/health",
            endpoint=self.get_health,
            methods=["GET"],
        )

    async def get_health(self) -> dict[str, str]:
        """Retorna payload JSON de saúde."""
        result = self._get_health_use_case.execute()
        return {
            "status": result.status,
            "service": result.service,
            "version": result.version,
        }
