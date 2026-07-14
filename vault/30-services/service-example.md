# service-example

tags: #service

## Intent

Example health/ping microservice used as the canonical backend scaffold.

## Stack

FastAPI · SQLAlchemy 2 async · Alembic · PostgreSQL · Redis · RabbitMQ-ready ports

## Paths

| Role | Location |
| --- | --- |
| Mold (hub) | `scaffolds/service-example` |
| Working copy | `../repos/service-example` (relative to hub) |
| GitHub | set `remote` in `project.yaml` after publish |

## Port

`8001` (see `project.yaml`)

## Notes

Update this page whenever the service gains domain capabilities. Do not treat the mold as the long-term product path.
