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
5. Ensure Python 3.13, uv, FastAPI, SQLAlchemy async, Alembic, pre-commit, Makefile.
6. Copy CI from `harness/templates/github-ci/service-ci.yml` into `.github/workflows/ci.yml`.
7. Register the service in `project.yaml` and add `vault/30-services/<name>.md` (English).
8. Update this skill if you discover a better default — keep skills non-legacy.

## Do not

- Use Gino.
- Add cross-service integration tests inside the service.
