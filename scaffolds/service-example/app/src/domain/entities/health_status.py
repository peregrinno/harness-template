"""Entidade de saúde do serviço."""

from dataclasses import dataclass


@dataclass(frozen=True)
class HealthStatus:
    """Representa o estado de saúde exponível pela API."""

    status: str
    service: str
    version: str
