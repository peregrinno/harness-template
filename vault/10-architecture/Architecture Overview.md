# Architecture Overview

tags: #architecture

## Style

Microservices polyrepo orchestrated by a harness hub.

## Workspace

```text
<workspace>/harness-hub/   ← this vault + SDD + harness
<workspace>/repos/         ← service-* and ui-* working copies
<workspace>/.cursor/       ← Cursor rules/agents/skills (moved here on INSTALL)
```

See [[Workspace Layout]].

## Shared platform

- PostgreSQL 17
- Redis
- RabbitMQ
- MongoDB optional (`project.yaml`)

## Backend defaults

Python 3.13 · uv · FastAPI · SQLAlchemy 2 async · Alembic · Hexagonal · loguru

## Frontend defaults

TypeScript · yarn · React · Next.js · Ant Design · Atomic Design

## Related

- [[Harness Operating Model]]
- [[Branching and Repositories]]
- [[Messaging Practice]]
- Constitution sources live in hub `harness/constitutions/`.
