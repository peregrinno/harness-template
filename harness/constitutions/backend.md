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
| Messaging | RabbitMQ (async connectors) |
| Cache | Redis (async) |
| Primary DB | PostgreSQL **17** |
| Optional DB | MongoDB (only when `project.yaml` enables it) |
| Pre-commit | ruff, pytest, semver check |
| Tests inside service | **unit** + **acceptance** |
| Cross-service e2e | **QA agent only** (not inside the service repo) |

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
4. Outbound adapter(s) + migration if needed  
5. Inbound adapter  
6. Unit tests  
7. Acceptance tests  
8. `make lint && make test`  
9. Semver bump if publishable API changed  
