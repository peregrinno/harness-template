"""Configuração centralizada do loguru para o microserviço."""

import sys

from loguru import logger

_CONFIGURED = False


def configure_logging(*, level: str = "INFO") -> None:
    """Inicializa o loguru uma única vez no processo."""
    global _CONFIGURED
    if _CONFIGURED:
        return

    logger.remove()
    logger.add(
        sys.stderr,
        level=level,
        enqueue=True,
        backtrace=False,
        diagnose=False,
        format=(
            "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
            "<level>{level: <8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
            "<level>{message}</level>"
        ),
    )
    _CONFIGURED = True
