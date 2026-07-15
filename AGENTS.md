# AGENTS.md — Harness map (keep short)

This file is a **table of contents**, not an encyclopedia. Progressive disclosure only.

## Who you are

You operate inside a **Harness Engineering hub** (polyrepo orchestration + Obsidian vault + SDD).

- Reply to the human in **Portuguese**.
- Think and write code, designs, ADRs, sprints, tasks, commits, and vault notes in **English**.
- Code docstrings are the **only** Portuguese in source files.
- Never invent architecture: read the files below first.

## Bootstrap

1. Read `project.yaml` (identity, workspace layout, repos, ports, gates).
2. Canonical disk layout: `<workspace>/harness-hub` + `<workspace>/repos/<name>` + **`<workspace>/.cursor/`** (moved from the hub during INSTALL) — see `INSTALL.md` and `vault/50-operations/Workspace Layout.md`.
3. If `harness/.setup-complete` is missing or `.cursor` is still only inside the hub → follow `INSTALL.md` (promote `.cursor` to workspace root first).
4. If `.cursor/rules/` at workspace root is missing or incomplete → follow `INSTALL.md`.
5. Local runtime follows `project.yaml → runtime.local_mode`:
   - `bundled_infra` — `start-all.bat` may start Docker deps
   - `external_infra` — deps already on the machine; script only validates ports / starts apps
   Never duplicate listeners on the same ports.
6. Prefer opening the **workspace root** (parent of hub + `repos/` + `.cursor`) in Cursor.

## System of record

| Need | Go to |
| --- | --- |
| Workspace layout | `vault/50-operations/Workspace Layout.md` |
| Project config | `project.yaml` |
| Install / unlock | `INSTALL.md` |
| Backend rules | `harness/constitutions/backend.md` |
| Data / persistence | `harness/constitutions/data.md` |
| Messaging (RabbitMQ) | `harness/constitutions/messaging.md` |
| Frontend rules | `harness/constitutions/frontend.md` |
| Visual supply | `harness/supply/` |
| Deploy templates | `harness/templates/deploy/` |
| SDD workflow | `harness/workflows/sdd.md` |
| Delivery / PEV loop | `harness/workflows/delivery-loop.md` |
| Parallelism | `harness/workflows/parallel-orchestration.md` |
| Token economy | `harness/workflows/token-economy.md` |
| Architecture knowledge | `vault/10-architecture/` |
| Service maps | `vault/30-services/` |
| Frontend maps | `vault/40-frontends/` |
| Changelogs | `vault/70-changelogs/` |
| Specs (Portuguese) | `sdd/<NNN>-<slug>/SPEC.md` |
| Designs / ADRs / sprints / tasks | `sdd/<NNN>-<slug>/` |
| QA reports | `qa/` |
| Security findings | `security/` |
| Code reviews | `reviews/` |
| Cursor agents | `.cursor/agents/` |
| Skills | `.cursor/skills/` |

## Hard rules (non-negotiable)

1. **Layout**: `<workspace>/harness-hub` + `<workspace>/repos/<name>` + `<workspace>/.cursor` (rules/agents/skills at workspace root after INSTALL).
2. **Microservices polyrepo**: backends `service-<intent>`, frontends `ui-<context>` under `repos/` (not long-term under `scaffolds/`).
3. **Branches**: `master <- stage <- develop`; features `feature/SPEC(<n>)/<slug>`.
4. **Commits**: `<seq:03d>-<brief-kebab-title>` (e.g. `001-add-health-endpoint`).
5. **SDD order**: Spec → Designs → ADRs → Sprints → Tasks. Never skip.
6. **Human gates**: stop after Spec; stop after Designs/ADRs/Sprints/Tasks pack; escalate after N failed QA/security/review loops (`project.yaml` → `gates`).
7. **Token economy**: Spec/pack in Ask/focused Composer; implement in bounded waves (one sprint or ≤ `max_tasks_per_wave`); see `harness/workflows/token-economy.md`.
8. **`review_class`**: product_code/security_sensitive → QA → security → code-reviewer; scaffold → sensors only; docs/meta → skip triad (`project.yaml → agents.review_by_class`).
9. Prefer **parallel subagents** within a wave; each owns **local** commits; push separately (`agents.orchestration.push_default`).
10. End of feature/wave: update vault (EN) + changelog entry; residual hub commits by the orchestrator.
11. Prefer **deterministic sensors** (lint, typecheck, tests, coverage) over prose. See `harness/sensors/`.
12. Critical security issues: fix immediately without waiting for a report approval.

## Stack defaults

- Backend: Python 3.13, uv, FastAPI, SQLAlchemy 2 async, Alembic, **loguru**, lifespan dependency pings, hexagonal, unit + acceptance.
- Data: database-per-service — see `harness/constitutions/data.md`.
- Messaging: RabbitMQ async, outbox/inbox, versioned envelopes — see `harness/constitutions/messaging.md`.
- Frontend: TypeScript, yarn, React, Next.js, Ant Design, atomic design; brand from `harness/supply/`.
- Infra: PostgreSQL 17, Redis, RabbitMQ; MongoDB when enabled.
- Deploy: `railway` or `portainer` via `project.yaml → deploy.target`.

## Do not

- Do not put long policy text in this file — link out.
- Do not implement product features only under hub `scaffolds/` after repos exist.
- Do not start duplicate infra on ports already owned by `start-all.bat` / external services.
- Do not write integration tests inside a service repo (unit + acceptance only). Cross-service e2e belongs to the QA agent.
- Do not reply to the user in English unless they explicitly ask.
