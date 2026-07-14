# Data Constitution (Harness Active)

> Microservices-first data standards for PostgreSQL 17 (primary) and optional MongoDB.
> Pair with `backend.md` (SQLAlchemy 2 async + Alembic) and `project.yaml` inventory.

## Skills Reference

Check `.cursor/skills/` when scaffolding migrations or new persistence adapters.

# Project Constitution — Data & Persistence

## 0. Microservices data ownership (MANDATORY)

| Principle | Rule |
| --- | --- |
| Database per service (default) | Each `service-<intent>` owns **its** schema/database. No shared mutable tables across services. |
| One service → one or more stores | A service **may** use multiple stores (e.g. PostgreSQL for transactions + Redis for cache + MongoDB for documents) when justified by access patterns — never to share ownership with another service. |
| No cross-service FK | **Never** create foreign keys that point at another service’s database. |
| Integration by contract | Cross-service consistency via APIs, async events (RabbitMQ), or explicit saga/outbox — not joins across DBs. |
| Shared DB anti-pattern | Sharing one Postgres *database* among multiple services is forbidden unless an ADR documents a temporary exception with an exit plan. |
| Read models | If a service needs another’s data, replicate via events into its own store (CQRS/read model) rather than querying foreign tables. |

### Multi-store inside one service (allowed)

Valid reasons: different consistency/latency needs (OLTP vs documents vs cache vs search).

Rules when using multiple stores in the same service:

1. Declare every store in `project.yaml` for that service.
2. Own migrations/indexes per store.
3. Keep a single **write authority** per business entity (no dual-write without outbox/inbox).
4. Lifespan must ping **all** required stores (see `backend.md`).

## 1. PostgreSQL naming

| Object | Convention | Example |
| --- | --- | --- |
| Database | `svc_<intent>` or service name slug | `svc_billing` |
| Schema | Prefer `public` unless domains split cleanly | `public` |
| Tables | **plural** `snake_case` nouns | `orders`, `order_items` |
| Columns | `snake_case` | `created_at`, `customer_id` |
| Primary key | `id` (UUID preferred for distributed systems; BIGSERIAL ok for purely internal) | `id UUID` |
| Foreign keys (same DB) | `<singular_table>_id` | `order_id` |
| Unique constraints | `uq_<table>_<cols>` | `uq_users_email` |
| Check constraints | `ck_<table>_<intent>` | `ck_orders_total_nonneg` |
| Indexes | `ix_<table>_<cols>` | `ix_orders_customer_id_created_at` |
| Enum-like | DB enum sparingly; prefer lookup table or app check | — |

### Timestamp & soft delete

- `created_at`, `updated_at` — `TIMESTAMPTZ`, UTC.
- Soft delete: `deleted_at TIMESTAMPTZ NULL` (partial index on active rows when queried often).

### Prefix ban list

Do not prefix tables with the service name (`billing_orders`) inside a dedicated DB — redundant. Do prefix only in the rare temporary shared-DB exception.

## 2. Foreign keys (same database only)

**Use FK when:**

- Both tables belong to the **same service database**.
- Referential integrity must be enforced at rest (money, inventory, membership).
- Cascades are intentional and documented (`ON DELETE RESTRICT` default for money-related; `CASCADE` only for true ownership trees like `orders` → `order_items`).

**Do not use FK when:**

- The referenced id belongs to another microservice (store opaque id + validate via API/events).
- High-churn, loosely coupled references better handled as eventual consistency.
- Cross-database references (impossible / forbidden across services).

### Cascade policy

| Relationship | Default |
| --- | --- |
| Parent-child owned rows | `ON DELETE CASCADE` ok if child has no independent lifecycle |
| References to “catalog”/master data inside same DB | `ON DELETE RESTRICT` |
| Soft-deleted parents | Prefer soft delete + app rules over hard `CASCADE` |

## 3. Indexes — market practice

1. Index columns used in `WHERE` / `JOIN` / `ORDER BY` that appear in hot paths.
2. Prefer **composite** indexes matching left-most prefix of query filters.
3. Partial indexes for soft-delete / status filters (`WHERE deleted_at IS NULL`).
4. Unique indexes for natural business keys (`email`, `(tenant_id, external_id)`).
5. Avoid over-indexing write-heavy tables; measure with `EXPLAIN (ANALYZE)`.
6. Never create duplicate indexes that are prefixes of existing composites.
7. For UUID PKs, accept index width; avoid random UUID churn on massive insert-heavy tables without need — still preferred for merge/federation across services.

## 4. Migrations (Alembic)

- Every schema change is a revision; no manual prod DDL.
- Expand/contract for breaking changes (add nullable → backfill → constrain → drop old).
- Migrations must be backward-compatible with the currently running service version during rolling deploys (Railway/Portainer).
- Never rename columns in place without expand/contract.

## 5. MongoDB (when enabled)

| Topic | Rule |
| --- | --- |
| Ownership | Same as SQL — documents owned by one service only |
| Collection names | plural `snake_case` | `invoice_documents` |
| `_id` | ObjectId or UUID string — be consistent per service |
| Embedding vs referencing | Embed when data is read together and bounded; reference when large/unbounded or independently updated |
| Unbounded arrays | Forbidden as unbounded grow-only lists — risk of 16MB doc and hot documents |
| Indexes | Declare in code/migration bootstrap; compound indexes for common filters |
| Transactions | Use multi-doc transactions only when required; prefer single-document atomicity |

## 6. Redis & RabbitMQ (data-adjacent)

- Redis: keys namespaced `svc:<intent>:<purpose>:<id>`; always TTL for cache entries.
- Do not treat Redis as system of record unless ADR says so (sessions/ephemeral ok).
- RabbitMQ: routing keys `svc.<intent>.<event>`; payloads versioned; consumers idempotent.

## 7. Multi-tenancy (if applicable)

- Prefer `tenant_id` on every tenant-owned row + composite unique/indexes starting with `tenant_id`.
- Enforce tenant filter in repositories (adapter), never only in controllers.

## 8. Checklist (new persistence)

1. Confirm store ownership (no shared tables).  
2. Name tables/collections per this constitution.  
3. Add PK + timestamps.  
4. FK only inside same DB; cascades documented.  
5. Indexes for hot queries + uniqueness for business keys.  
6. Alembic (or Mongo index bootstrap) committed.  
7. Lifespan pings the new store.  
8. Update vault service note + `project.yaml` databases list.  
