# Local runtime modes

tags: #ops

Controlled by `project.yaml → runtime.local_mode`.

## `bundled_infra` (default)

`start-all.bat` runs Docker Compose profile `infra` (Postgres, Redis, RabbitMQ; Mongo if enabled), then optionally opens app windows (`runtime.start_apps`).

If `skip_infra_if_ports_healthy: true` and ports already respond, compose is skipped.

## `external_infra`

Use when Postgres/Redis/Rabbit(/Mongo) already run on the machine (native install, another stack, company VPN DB, etc.).

`start-all.bat` **does not** start Docker deps; it verifies TCP ports from `project.yaml → infra` and then starts apps if configured.

## Agent rule

Never spawn a second Postgres/Redis/Rabbit for the same ports. Always call / assume `harness/scripts/windows/start-all.bat` contract.
