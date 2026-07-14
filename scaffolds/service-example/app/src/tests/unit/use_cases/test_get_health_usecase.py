"""Testes unitários do caso de uso de saúde."""

from app.src.use_cases.get_health_usecase import GetHealthUseCase


def test_get_health_execute_returns_ok_status() -> None:
    use_case = GetHealthUseCase()
    result = use_case.execute()
    assert result.status == "ok"
    assert result.service == "service-example"
    assert result.version == "0.1.0"
