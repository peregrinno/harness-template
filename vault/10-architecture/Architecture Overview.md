# Architecture Overview

tags: #architecture

## Style

Microservices polyrepo orchestrated by a harness hub.

## Shared platform

- PostgreSQL 17
- Redis
- RabbitMQ
- MongoDB optional (`project.yaml`)

## Backend defaults

Python 3.13 · uv · FastAPI · SQLAlchemy 2 async · Alembic · Hexagonal

## Frontend defaults

TypeScript · yarn · React · Next.js · Ant Design · Atomic Design

## Related

- [[Harness Operating Model]]
- [[Branching and Repositories]]
- Constitution sources live in hub `harness/constitutions/`.
