---
name: scaffold-service
description: Scaffold a new polyrepo FastAPI service (service-<intent>) from the harness template with SQLAlchemy 2 async hexagonal layout. Use when creating a new backend microservice.
---

# Skill: scaffold-service

## Steps

1. Read `project.yaml` and ask for `intent` slug if missing.
2. Name must be `service-<intent>`.
3. Copy `scaffolds/service-example/` to the destination (new folder or new GitHub repo via `gh repo create`).
4. Replace placeholders: package name, ports, DB name.
5. Ensure Python 3.13, uv, FastAPI, SQLAlchemy async, Alembic, **loguru** (`app/src/core/logging.py`), lifespan dependency pings, pre-commit, Makefile.
6. Copy CI from `harness/templates/github-ci/service-ci.yml` into `.github/workflows/ci.yml`.
7. Copy deploy manifests from `harness/templates/deploy/<project.yaml deploy.target>/`.
8. Obey `harness/constitutions/data.md` for schema design.
9. Obey `harness/constitutions/messaging.md` for RabbitMQ publishers/consumers.
10. Register the service in `project.yaml` and add `vault/30-services/<name>.md` (English).
11. Update this skill if defaults change — keep skills non-legacy.

## Do not

- Use Gino.
- Add cross-service integration tests inside the service.
- Configure logging outside `app/src/core/logging.py`.
- Skip lifespan pings for required dependencies in non-test environments.
