"""Testes unitários do repositório de ping com sessão mockada."""

from unittest.mock import AsyncMock, MagicMock

import pytest

from app.src.adapters.outbound.ping_repository import PingRepository


@pytest.mark.asyncio
async def test_save_ping_flushes_and_returns_id() -> None:
    session = AsyncMock()
    session.add = MagicMock()
    session.flush = AsyncMock()

    repo = PingRepository(session=session)
    result = await repo.save_ping(message="hello")

    session.add.assert_called_once()
    session.flush.assert_awaited_once()
    assert isinstance(result, str)


@pytest.mark.asyncio
async def test_list_messages_returns_scalar_list() -> None:
    session = AsyncMock()
    result = MagicMock()
    result.scalars.return_value.all.return_value = ["a", "b"]
    session.execute = AsyncMock(return_value=result)

    repo = PingRepository(session=session)
    messages = await repo.list_messages()

    assert messages == ["a", "b"]
    session.execute.assert_awaited_once()
