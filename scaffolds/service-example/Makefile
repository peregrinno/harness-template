.PHONY: install lint test run migrate migrate-create

install:
	uv sync --group dev
	uv run pre-commit install || true

lint:
	uv run ruff check .
	uv run ruff format --check .

test:
	uv run pytest --cov=app --cov-report=term-missing --cov-fail-under=60

run:
	uv run uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload

migrate:
	uv run alembic upgrade head

migrate-create:
	uv run alembic revision --autogenerate -m "$(m)"
