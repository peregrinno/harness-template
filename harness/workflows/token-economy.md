# Token Economy — high quality, low waste

Canonical policy for reducing agent/context cost without skipping SDD quality gates.
Defaults live in `project.yaml → agents`.

## Session shape

| Phase | Mode | Why |
| --- | --- | --- |
| Spec + Designs + ADRs + Sprints + Tasks | Ask / focused Composer (no implementers) | Avoid re-exploring vault/constitutions every turn |
| Decisions / refinements (“aprovado, só D5”) | Short chat | Cheap vs re-implementing |
| Product code | Agent (bounded wave) | Needs tools + subagents |
| One chat session | One bounded context (one sprint or ≤3 tasks) | Long transcripts are expensive |

Do **not** mix “draft the whole Spec pack” and “implement all tasks” in the same long-running Agent session.

## Orchestration bounds

1. After pack approval, implement **one sprint** or **1–3 tasks** per wave (`agents.orchestration.max_tasks_per_wave`).
2. Never relaunch a “full Spec” orchestrator that spins N implementers + QA + security + review in one go.
3. Prefer delta prompts (“só Dockerfile + package_meta”) over “alinha tudo ao Spec”.
4. Residual / next wave starts a fresh bounded brief — do not re-attach the entire Spec tree.

## Context hygiene

- Open **only** the files needed for the current slice.
- Subagent briefs: task file + linked Design/ADR ids (paths) + `owns_paths` + constitution **links** — not full SPEC + every ADR + whole repo pasted into the prompt.
- When the path is already known, use Grep/Read — do **not** launch broad `explore` / `very thorough`.
- Default explore thoroughness: `quick` (`project.yaml → agents.orchestration.explore_thoroughness_default`). Escalate to `medium` only when paths are unknown; never default to `very thorough`.
- Prefer wikilinks / paths over copying large vault notes into the prompt.

## Review class (task field)

Each task declares `review_class`. Mapping is in `project.yaml → agents.review_by_class`.

| Class | Typical work | Follow-ups |
| --- | --- | --- |
| `product_code` | App/domain/API/UI behavior | QA → security → code-reviewer |
| `security_sensitive` | Auth, crypto, secrets, tenancy | Same as product_code (mandatory) |
| `scaffold` | New service/UI mold, boilerplate wiring | Sensors only (lint/tests) |
| `docs` | Vault notes, README, Spec typo fixes | None |
| `meta` | STATUS.md, task checkboxes, changelog links | None |

If `review_class` is omitted on a task that touches `repos/**` application code, treat as `product_code`.

## Git: commit vs push

1. Subagents **commit locally** on the feature branch as they finish.
2. **Push** only when the human asks, or once at wave end if `agents.orchestration.push_default` is temporarily overridden for that wave.
3. Do not fan out parallel `git push` / remote tooling by default.

## Model hints

- Routine / mechanical / scaffold / docs → cheaper model (`model_hints.routine_implementation`).
- Design, ADR, crypto/auth architecture → strong model (`model_hints.design_adr_crypto`).
- Do not run the whole parallel wave on the strongest model “just in case”.

## Rules & index noise

- Keep always-applied Cursor rules short; deep policy lives in `harness/workflows/` and `vault/`.
- Respect `.cursorignore` (venv, node_modules, locks, coverage, stale qa/security/reviews dumps).

## What this does **not** relax

- Spec → Designs → ADRs → Sprints → Tasks order.
- Human gates (`approve_spec`, `approve_before_implementation`).
- Product-code quality: sensors + QA/security/review still mandatory for `product_code` / `security_sensitive`.
