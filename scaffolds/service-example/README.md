# service-example

Bootable hexagonal FastAPI microservice scaffold (SQLAlchemy 2 async).

## Setup

```bash
uv sync --group dev
make test
make run
```

Health: `GET http://localhost:8001/health`

## Notes

- Publish as its own GitHub repo named `service-example`.
- Copy CI from hub `harness/templates/github-ci/service-ci.yml`.
- Docstrings in Portuguese; code in English.
