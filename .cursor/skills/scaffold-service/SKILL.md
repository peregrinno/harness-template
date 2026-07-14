---
name: scaffold-service
description: Scaffold a new polyrepo FastAPI service (service-<intent>) into ../repos/ from the hub mold. Use when creating a new backend microservice.
---

# Skill: scaffold-service

## Steps

1. Read `project.yaml` (`workspace`, repositories) and ask for `intent` slug if missing.
2. Name must be `service-<intent>`.
3. Destination MUST be `<workspace>/repos/<name>` (hub-relative `../repos/<name>`). Copy from `scaffolds/service-example/` (or `scaffold` field).
4. Replace placeholders: package name, ports, DB name.
5. Ensure Python 3.13, uv, FastAPI, SQLAlchemy async, Alembic, **loguru** (`app/src/core/logging.py`), lifespan dependency pings, pre-commit, Makefile.
6. Copy CI from `harness/templates/github-ci/service-ci.yml` into `.github/workflows/ci.yml`.
7. Copy deploy manifests from `harness/templates/deploy/<project.yaml deploy.target>/`.
8. Obey `harness/constitutions/data.md` for schema design.
9. Obey `harness/constitutions/messaging.md` for RabbitMQ publishers/consumers.
10. Register in `project.yaml` with `path: ../repos/<name>` and `scaffold: scaffolds/...`; add `vault/30-services/<name>.md` (English).
11. Optionally `gh repo create` from the `repos/<name>` folder (not from scaffolds).
12. Update this skill if defaults change — keep skills non-legacy.

## Do not

- Use Gino.
- Leave the long-term working copy only under `scaffolds/`.
- Add cross-service integration tests inside the service.
- Configure logging outside `app/src/core/logging.py`.
- Skip lifespan pings for required dependencies in non-test environments.
