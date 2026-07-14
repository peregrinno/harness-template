"""Repositório SQLAlchemy async de exemplo."""

from sqlalchemy import String, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from app.src.ports.i_ping_repository import IPingRepository


class Base(DeclarativeBase):
    """Base declarativa do ORM."""


class PingRow(Base):
    """Tabela de pings."""

    __tablename__ = "pings"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    message: Mapped[str] = mapped_column(String(255), nullable=False)


class PingRepository(IPingRepository):
    """Implementação PostgreSQL via SQLAlchemy 2 async."""

    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def save_ping(self, message: str) -> str:
        """Persiste um ping e devolve o id como string."""
        row = PingRow(message=message)
        self._session.add(row)
        await self._session.flush()
        return str(row.id)

    async def list_messages(self) -> list[str]:
        """Lista mensagens (helper de diagnóstico)."""
        result = await self._session.execute(select(PingRow.message))
        return list(result.scalars().all())
