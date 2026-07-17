# Delivery Loop — Plan → Execute → Verify (PEV)

Also read `harness/workflows/token-economy.md`.

## Order of work for every implementation task

```text
Plan (task file + linked Design/ADR paths + needed constitutions — not the whole Spec tree)
  → Execute (code in target polyrepo under `../repos/<name>`, or hub docs)
  → Computational sensors (lint, typecheck, unit/acceptance/component) when code changed
  → Follow-ups by review_class (project.yaml → agents.review_by_class):
        product_code / security_sensitive:
          QA → security-analyst → code-reviewer → Fix loop
        scaffold: sensors only
        docs / meta: skip agent triad
  → Commit locally (subagent-owned)
  → Push only if wave/human requests (orchestration.push_default: false)
  → Update task status (+ vault changelog when the feature/wave closes)
```

## Branch / commit / push

Before coding starts on an approved SDD pack:

1. Identify impacted repos from Spec.
2. From `develop`, create `feature/SPEC(<n>)/<slug>` on each impacted repo (and hub if SDD/reports change).
3. Each subagent commits with `NNN-brief-kebab-title` **locally**.
4. Push is a **separate step** (human ask or single wave-end push) — avoid parallel remote fan-out.
5. Orchestrator ends each wave with residual local commit(s) for leftovers; push with the wave when requested.

## Parallelism

Read `parallel-orchestration.md`. Independent tasks → parallel subagents **within the wave cap**. Shared files in the same repo → serialize or partition by directory ownership.

## Retry / escalate

From `project.yaml`:

- `max_qa_security_review_retries` (default 3) — applies when QA/security/review run
- After exhaustion: stop, write failure summary in Portuguese for the human, attach paths under `qa/`, `security/`, `reviews/`.

## Report locations

| Agent | Path pattern |
| --- | --- |
| QA | `qa/<spec-id>/<run-ts>/REPORT.md` (+ scripts used) |
| Security | `security/<spec-id>/<run-ts>/FINDINGS.md` |
| Code review | `reviews/<spec-id>/<run-ts>/REVIEW.md` |
| Feature rollup | `sdd/<NNN>-<slug>/STATUS.md` + vault changelog |

## Critical security

Findings rated critical / system-compromising are fixed immediately by a remediation subagent **without waiting for human report approval**, then QA + security re-run.
