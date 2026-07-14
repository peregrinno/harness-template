# Messaging Constitution (Harness Active)

> Microservices-first async messaging standards. Default broker: **RabbitMQ** via **async** clients (`aio-pika`).
> Pair with `backend.md` (hexagonal ports/adapters + lifespan pings) and `data.md` (no cross-service FKs; integrate via events).

## Skills Reference

When adding publishers/consumers, check `.cursor/skills/` and existing outbound adapters in the target `service-*`.

# Project Constitution — Messaging

## 0. Role of messaging in this platform (MANDATORY)

| Principle | Rule |
| --- | --- |
| Prefer async for cross-service side effects | Use events/commands over sync chains of HTTP calls when eventual consistency is acceptable. |
| Own your contracts | The **producing** service owns the event name, version, and payload schema. Consumers adapt. |
| Broker is not a database | Do not use RabbitMQ as system of record. Persist then publish (outbox) for business facts. |
| No shared mutable tables | Messaging replaces cross-service joins — see `data.md`. |
| Hexagonal boundary | Use cases depend on ports (`IMessagePublisher`, `I…`). Adapters own `aio-pika` / topology. |
| Async only | All broker I/O uses async drivers. No blocking `pika` in request paths. |

## 1. Message kinds

| Kind | Purpose | Naming tone | Example |
| --- | --- | --- | --- |
| **Domain event** | Something that **happened** (past tense) | Fact | `order.placed`, `payment.captured` |
| **Command** | Someone **asks** another service to do work | Imperative | `invoice.generate`, `notify.send_email` |
| **Integration event** | Cross-bounded-context notification already committed | Fact + version | `billing.invoice_issued.v1` |

Rules:

- Do **not** disguise commands as events (`CreateOrder` as if it already succeeded).
- Events are immutable statements about the past; retries must not invent a second business fact without idempotency keys.
- Prefer events for fan-out; prefer commands for pointed “do this” with a clear owner queue.

## 2. Topology (RabbitMQ)

### Default style

- **Topic exchange** per bounded context or platform bus (document choice in an ADR if you deviate).
- Queues are **owned by the consuming service** (competing consumers OK within the same service replicas).
- Binding keys are explicit; avoid `#` catch-alls in production unless an ADR allows it.

### Naming conventions

| Object | Pattern | Example |
| --- | --- | --- |
| Exchange | `ex.<context>` or `ex.platform` | `ex.orders` |
| Routing key (event) | `<context>.<entity>.<event>[.vN]` | `orders.order.placed.v1` |
| Routing key (command) | `cmd.<target_service>.<action>[.vN]` | `cmd.billing.generate_invoice.v1` |
| Queue | `q.<consumer_service>.<purpose>` | `q.billing.order_placed` |
| DLQ | `q.<consumer_service>.<purpose>.dlq` | `q.billing.order_placed.dlq` |
| Retry queue (optional) | `q.<consumer_service>.<purpose>.retry` | `q.billing.order_placed.retry` |

### Ownership

- Producers **declare/assert** exchanges they publish to (idempotent declare).
- Consumers **declare** their queues, bindings, and DLQ.
- Never let service A delete or overwrite service B’s queue arguments in shared envs.

## 3. Payload contract

Every message body (JSON) MUST include an envelope:

```json
{
  "message_id": "uuid",
  "correlation_id": "uuid-or-null",
  "causation_id": "uuid-or-null",
  "type": "orders.order.placed.v1",
  "occurred_at": "2026-07-14T15:00:00.000Z",
  "producer": "service-orders",
  "payload": { }
}
```

Rules:

- `message_id` is unique per publish attempt of a business fact; use it for consumer idempotency.
- `correlation_id` ties a user/request journey across services.
- Version in `type` (`v1`, `v2`). **Additive** changes stay on same version when backward compatible; breaking changes bump version and dual-publish or dual-bind during migration.
- Payload uses business language, not ORM row dumps.
- Never put secrets, tokens, or full card data in messages.
- Document contracts in the vault under the producing service note (English) + Spec/ADR when introducing a new type.

## 4. Delivery semantics (market defaults)

| Topic | Standard |
| --- | --- |
| Delivery | Assume **at-least-once**. Design for duplicates. |
| Ordering | No global order guarantee across queues. Per-partition/key order only if explicitly designed (usually avoid). |
| Ack | Ack **after** successful handling (or after durable inbox write). Do not ack-then-process. |
| Nack / reject | Transient failures → retry/requeue policy; poison → DLQ with reason header. |
| Prefetch | Set explicit `prefetch_count` per consumer (start low, e.g. 10–50); never unbounded. |
| Timeouts | Consumers must bound handler time; long work → hand off to internal job with ack of “accepted”. |

### Idempotency (MANDATORY for consumers)

1. Persist processed `message_id` (inbox table) in the **consumer’s** database, unique constraint.
2. Or make the business operation naturally idempotent (UPSERT by natural key).
3. Retries and redeploys must not double-charge, double-email without guardrails, or create duplicate aggregates.

### Publisher reliability (MANDATORY for business facts)

Use **transactional outbox** (or equivalent) when the fact is stored in PostgreSQL:

1. Write domain state + outbox row in the **same DB transaction**.
2. Relay publishes to RabbitMQ asynchronously.
3. Mark outbox published; retry relay on failure.

Do **not** “DB commit then best-effort publish” for money, inventory, or compliance flows without an ADR accepting the risk.

## 5. Hexagonal implementation map

| Concern | Location |
| --- | --- |
| Port | `app/src/ports/i_*_publisher.py` / consumer-facing use case invoked by inbound adapter |
| Publish adapter | `app/src/adapters/outbound/*_publisher.py` (`aio-pika`) |
| Consume adapter | `app/src/adapters/inbound/*_consumer.py` |
| Envelope DTOs | domain commands/entities or dedicated message DTOs — typed, not raw `dict` sprawl |
| Topology bootstrap | outbound/inbound helpers; called from lifespan after broker ping |

Use cases must not import `aio-pika`. Controllers/consumers translate envelope → command → use case.

## 6. Retries, DLQ, and poison messages

1. Configure TTL/retry hop or delayed retry — not infinite hot requeue loops.
2. After N attempts, route to **DLQ**.
3. DLQ messages carry `x-death` / custom headers: attempt count, last error, original routing key.
4. Operational runbook: vault `50-operations` note on how to replay DLQ (QA/ops — not silent drop).
5. Alert on DLQ depth in production (Railway/Portainer metrics or broker UI).

## 7. Continuum: sync API vs messaging

| Use messaging when | Prefer sync HTTP when |
| --- | --- |
| Fan-out to many services | Caller needs immediate validated response |
| Decoupling & resilience | Simple query/read of owning service |
| Peak leveling | Low-latency user-facing confirmation that cannot be deferred |
| Saga / workflow steps | Strict synchronous authz gate |

Avoid chatty hybrid: publish event **and** wait sync on the same write path without orchestration design.

## 8. Sagas & multi-service workflows

- Prefer **choreography** with clear events when few services participate.
- Prefer **orchestration** (explicit workflow service/commands) when compensation and visibility matter.
- Compensating actions must be idempotent and documented in an ADR.
- Never lock rows across service databases.

## 9. Security & multi-tenancy

- Separate vhosts or credentials per environment (local/stage/prod).
- Least-privilege users: publishers cannot consume unrelated queues.
- Include `tenant_id` in payload when multi-tenant; consumers filter/enforce — do not trust alone for authz without service-side checks.
- Encrypt in transit (TLS) in non-local environments.

## 10. Observability

- Log with **loguru**: `message_id`, `type`, `correlation_id`, producer/consumer service — never full sensitive payload.
- Trace publish and consume spans when OpenTelemetry is introduced (future-friendly field names).
- Metrics: publish success/fail, consume latency, retry count, DLQ depth.

## 11. Lifespan & local runtime

- Backend lifespan **must** ping RabbitMQ when the service lists messaging in `project.yaml` (see `backend.md`).
- Topology declare may run at startup (idempotent) or via controlled migration job — document which.
- Local broker comes from `runtime.local_mode` (`bundled_infra` | `external_infra`); do not spawn a second broker on the same port.

## 12. Testing

| Layer | Expectation |
| --- | --- |
| Unit | Use case with mocked publisher port; consumer handler with fake envelope |
| Acceptance (service) | Optional in-process fake broker or test double — **not** other microservices |
| Cross-service e2e | Hub **QA** agent under `qa/` only |

## 13. Checklist (new message flow)

1. Choose event vs command; name per section 2.  
2. Define envelope + versioned `type`; document in vault.  
3. Publisher port + outbound adapter (`aio-pika`).  
4. Outbox if business fact in SQL.  
5. Consumer queue + binding + DLQ owned by consumer service.  
6. Inbox / idempotent handler.  
7. Prefetch + ack-after-success.  
8. Lifespan broker ping still green.  
9. Unit tests; QA e2e if multi-service.  
10. Update `project.yaml` messaging inventory if new broker dependency.  
