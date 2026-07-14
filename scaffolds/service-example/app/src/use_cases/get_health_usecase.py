"""Caso de uso para consulta de saúde."""

from app.src.domain.entities.health_status import HealthStatus


class GetHealthUseCase:
    """Retorna o estado de saúde do microserviço."""

    def execute(self) -> HealthStatus:
        """Executa a consulta de saúde."""
        return HealthStatus(
            status="ok",
            service="service-example",
            version="0.1.0",
        )
