# Deploy targets — Railway | Portainer

Chosen in `project.yaml → deploy.target` during INSTALL.

## railway

- Each polyrepo ships a `railway.toml` / Dockerfile from `harness/templates/deploy/railway/`.
- Configure env vars in Railway dashboard to mirror `infra` / service settings (never commit secrets).
- Healthcheck path: `/health` for FastAPI scaffolds; Next.js default route for UIs.
- Rolling deploys must keep Alembic expand/contract compatible (see data constitution).

## portainer

- Use stack compose from `harness/templates/deploy/portainer/stack.example.yml` as a starting point per environment.
- Map secrets via Portainer env files / Swarm secrets.
- Prefer one stack per environment (develop/stage/master alignment is operational, not automatic).

## Agent rules

1. Read `deploy.target` before generating deploy manifests.
2. Do not mix Railway-only and Portainer-only files without an ADR.
3. Keep Dockerfile/runtime aligned with Python 3.13 / Node versions in constitutions.
