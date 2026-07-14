# Decisão do template: Gino → SQLAlchemy 2.0 async

## Status

Accepted

## Context

The original product preference listed Gino as the ORM. Gino is effectively stalled versus SQLAlchemy 2.0's first-class async API, which agents and the ecosystem document better.

## Decision

All backend services use **SQLAlchemy 2.0 async** + Alembic. Gino is not used in this harness template.

## Consequences

- Scaffolds, constitutions, and skills assume SQLAlchemy async patterns.
- Existing Gino codebases must migrate before adopting this template's generators.
