"""Testes de aceitação da API de saúde."""

from fastapi.testclient import TestClient

from app.main import create_app


def test_health_endpoint_returns_200_ok_payload() -> None:
    client = TestClient(create_app())
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "service-example"
