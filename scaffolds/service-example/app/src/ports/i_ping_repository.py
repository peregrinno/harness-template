"""Porta de repositório de exemplo (ping)."""

from abc import ABC, abstractmethod


class IPingRepository(ABC):
    """Contrato para persistir/recuperar pings de saúde."""

    @abstractmethod
    async def save_ping(self, message: str) -> str:
        """Persiste um ping e retorna o identificador."""
        raise NotImplementedError
