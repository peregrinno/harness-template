# Backend Constitution (Harness Active)

> Derived from `references/constitution-backend.md`, reconciled with template policy:
> SQLAlchemy 2.0 async (not Gino), unit + acceptance tests allowed, CI sensors owned by harness.

## Skills Reference

Before planning, check `.cursor/skills/` for scaffold/update skills.

# Project Constitution — Backend

## 0. Official Stack (MANDATORY)

| Concern | Standard |
| --- | --- |
| Language | Python **3.13** |
| Package manager | **uv** |
| API | **FastAPI** |
| ORM | **SQLAlchemy 2.0 async** |
| Migrations | **Alembic** |
| Architecture | **Hexagonal (Ports & Adapters)** |
| Messaging | RabbitMQ async — see `harness/constitutions/messaging.md` |
| Cache | Redis (async) |
| Primary DB | PostgreSQL **17** |
| Optional DB | MongoDB (only when `project.yaml` enables it) |
| Logging | **loguru** (single config module under service core) |
| Pre-commit | ruff, pytest, semver check |
| Tests inside service | **unit** + **acceptance** |
| Cross-service e2e | **QA agent only** (not inside the service repo) |
| Data standards | See `harness/constitutions/data.md` |
| Messaging standards | See `harness/constitutions/messaging.md` |

### Async Connectors Policy
Every library that talks to DB, cache, broker, or external HTTP must use **async** clients/drivers.

## 1. Hexagonal Architecture

### Flow
```
[Inbound Adapters] → [Ports] → [Use Cases] → [Ports] → [Outbound Adapters]
```

### Directory Structure
```
/app
  /src
    /core
      logging.py        # loguru setup ONLY (import everywhere else)
      lifespan.py       # FastAPI lifespan: ping external deps
    /domain
      /commands
      /entities
      /exceptions
    /use_cases          # *_usecase.py ONLY
    /ports              # i_*_repository.py, i_*_service.py, i_*_publisher.py
    /adapters
      /inbound          # *_controller.py, *_consumer.py, ...
      /outbound         # *_repository.py, *_publisher.py, ...
    /tests
      /unit
      /acceptance
      /fixtures
```

### Layer Rules (summary)
- Domain: pure; no infra imports.
- Use cases: orchestrate business rules; depend only on ports; file suffix `*_usecase.py`.
- Ports: ABC/Protocol; business names (`IUserRepository`), never vendor names (`IRedisCache`).
- Inbound adapters: thin transform → command → use case → response.
- Outbound adapters: implement ports; may import SQLAlchemy/aio-pika/redis/httpx.

### Dependency Injection
Constructor injection of ports. Named arguments for multi-param calls.

### Imports
Absolute from `app` only (`from app.src...`). Empty `__init__.py` files (no code).

## 2. SQLAlchemy 2.0 Async + Alembic

- Use `AsyncEngine`, `AsyncSession`, `async_sessionmaker`.
- Map tables in outbound adapters / infrastructure mapping modules — keep domain entities free of ORM coupling when possible (translate at adapter boundary).
- Alembic migrations required for every schema change.
- Never use sync SQLAlchemy APIs in request paths.
- Naming/indexes/FKs: follow `harness/constitutions/data.md`.

## 2.1 Logging — loguru (MANDATORY)

- Use **loguru** as the only application logger. Do not configure stdlib `logging` handlers ad hoc in adapters/use cases.
- Centralize setup in `app/src/core/logging.py` (format, level, enqueue, diagnose flags).
- Call `configure_logging()` once at process start (lifespan or `create_app` before routes).
- Elsewhere: `from loguru import logger` after core config has run (or import `configure_logging` side effect from core).
- Prefer structured messages with bound context (`logger.bind(service=..., request_id=...)`).
- Never log secrets, tokens, or full PII payloads.

## 2.2 Lifespan — dependency readiness (MANDATORY)

Every FastAPI service **must** customize `lifespan` to verify external dependencies before serving traffic:

1. Ping **PostgreSQL** (e.g. `SELECT 1`) when the service uses SQL.
2. Ping **Redis** (`PING`) when cache/session deps are required.
3. Ping **RabbitMQ** (open connection / declare check) when messaging is required.
4. Ping **MongoDB** (`ping` command) when enabled for that service.
5. Ping any other required external HTTP/gRPC dependency declared in settings.

Rules:

- Fail **fast** on startup if a required dependency is unreachable (do not silently degrade unless an ADR allows degraded mode).
- Log each check result via loguru.
- Expose liveness vs readiness clearly: process up ≠ ready; readiness reflects lifespan checks.
- Keep ping helpers in outbound adapters or `core/` — use cases stay free of infra SDKs.
- Acceptance tests may monkeypatch pings; production and local run use real targets from `project.yaml` / env.

## 3. Naming

- Classes: PascalCase
- Ports: `I` + PascalCase capability (`IOrderStorage`)
- Methods/vars: snake_case
- Constants: UPPER_SNAKE_CASE
- Use cases: `*_usecase.py` / `*UseCase`
- Repo packaging name: `service-<intent>`

## 4. Testing Strategy

### Unit — MANDATORY
- AAA pattern; mock ports; no real network/DB.
- Name: `test_<method>_<scenario>_<expected>`

### Acceptance — MANDATORY for user-visible behaviours of the service
- Exercise the service API/process boundary with test doubles or ephemeral fixtures owned by the **service**.
- Do **not** call other microservices' real network endpoints here.

### Integration / cross-service e2e — PROHIBITED inside service repos
Owned by hub QA agent under `qa/`.

## 5. Quality & Tooling

- Ruff for lint/format; type hints everywhere; Pydantic for commands/DTOs.
- Prefer objects over dicts; Commands in `/domain/commands`.
- Semantic versioning; pre-commit must fail on invalid version bumps.
- Makefile targets: `make install`, `make test`, `make lint`, `make migrate`, `make run`.
- Docstrings in **Portuguese**; identifiers/comments narrative in English as needed.

## 6. SOLID + Clean Boundaries

Apply SRP/OCP/LSP/ISP/DIP. Dependencies point inward.

## 7. What service agents MUST NOT generate casually

Infrastructure ownership stays in hub templates when possible. Service PRs may include service-level GitHub Actions from `harness/templates/github-ci/`, but must not invent conflicting branch models.

## 8. Checklist (new feature inside a service)

1. Entity + Command  
2. Port(s)  
3. Use case  
4. Outbound adapter(s) + migration if needed (data constitution)  
5. Inbound adapter  
6. Lifespan pings still cover all required deps  
7. Logging via loguru (no new ad-hoc log frameworks)  
8. Unit tests  
9. Acceptance tests  
10. `make lint && make test`  
11. Semver bump if publishable API changed  
