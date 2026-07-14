# AGENTS.md — Harness map (keep short)

This file is a **table of contents**, not an encyclopedia. Progressive disclosure only.

## Who you are

You operate inside a **Harness Engineering hub** (polyrepo orchestration + Obsidian vault + SDD).

- Reply to the human in **Portuguese**.
- Think and write code, designs, ADRs, sprints, tasks, commits, and vault notes in **English**.
- Code docstrings are the **only** Portuguese in source files.
- Never invent architecture: read the files below first.

## Bootstrap

1. Read `project.yaml` (identity, repos, ports, gates).
2. If `.cursor/rules/` is missing or incomplete → follow `INSTALL.md`.
3. Assume shared infra is already running via `harness/scripts/windows/start-all.bat`.

## System of record

| Need | Go to |
| --- | --- |
| Project config | `project.yaml` |
| Install / unlock | `INSTALL.md` |
| Backend rules | `harness/constitutions/backend.md` |
| Frontend rules | `harness/constitutions/frontend.md` |
| SDD workflow | `harness/workflows/sdd.md` |
| Delivery / PEV loop | `harness/workflows/delivery-loop.md` |
| Parallelism | `harness/workflows/parallel-orchestration.md` |
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

1. **Microservices polyrepo**: backends `service-<intent>`, frontends `ui-<context>`.
2. **Branches**: `master <- stage <- develop`; features `feature/fix(<n>)/<slug>`.
3. **Commits**: `<seq:03d>-<brief-kebab-title>` (e.g. `001-add-health-endpoint`).
4. **SDD order**: Spec → Designs → ADRs → Sprints → Tasks. Never skip.
5. **Human gates**: stop after Spec; stop after Designs/ADRs/Sprints/Tasks pack; escalate after N failed QA/security/review loops (`project.yaml` → `gates`).
6. **Every implementation task** implicitly includes QA acceptance/e2e orchestration — do not wait for the user to ask for tests.
7. **After coding**: QA → security-analyst → code-reviewer (in that order). Critical security issues: fix immediately without waiting for a report approval.
8. Prefer **parallel subagents** for independent tasks; each subagent owns its commit + push on the feature branch.
9. End of feature: update vault (EN) + changelog entry; residual hub commits by the orchestrator.
10. Prefer **deterministic sensors** (lint, typecheck, tests, coverage) over prose. See `harness/sensors/`.

## Stack defaults

- Backend: Python 3.13, uv, FastAPI, SQLAlchemy 2 async, Alembic, hexagonal, unit + acceptance.
- Frontend: TypeScript, yarn, React, Next.js, Ant Design (latest stable first), atomic design, component + Playwright.
- Infra: PostgreSQL 17, Redis, RabbitMQ; MongoDB only when `project.yaml` enables it.

## Do not

- Do not put long policy text in this file — link out.
- Do not start services that `start-all.bat` already owns.
- Do not write integration tests inside a service repo (unit + acceptance only). Cross-service e2e belongs to the QA agent.
- Do not reply to the user in English unless they explicitly ask.
