# Messaging Practice

tags: #architecture #ops

Canonical rules live in hub `harness/constitutions/messaging.md`.

Summary for agents:

- RabbitMQ + `aio-pika`
- Versioned envelopes and routing keys
- Outbox (publish) / inbox (consume idempotency)
- DLQ + bounded retries
- Consumers own queues; producers own event contracts
