# Delivery Loop — Plan → Execute → Verify (PEV)

## Order of work for every implementation task

```text
Plan (read vault + task + constitutions)
  → Execute (code in target polyrepo under `../repos/<name>`)
  → Computational sensors (lint, typecheck, unit/acceptance/component)
  → QA agent (acceptance within service + cross-service e2e when needed)
  → security-analyst (auto-fix critical findings)
  → code-reviewer (duplication, coherence, accidental deletions)
  → Fix loop (same order)
  → Commit + push (subagent-owned)
  → Update task status + vault changelog (EN)
```

## Branch / commit / push

Before coding starts on an approved SDD pack:

1. Identify impacted repos from Spec.
2. From `develop`, create `feature/fix(<n>)/<slug>` on each impacted repo (and hub if SDD/reports change).
3. Each subagent commits with `NNN-brief-kebab-title` and pushes the same feature branch.
4. Orchestrator ends with a residual commit for leftovers on the hub (and code repos if needed).

## Parallelism

Read `parallel-orchestration.md`. Independent tasks → parallel subagents. Shared files in the same repo → serialize or partition by directory ownership.

## Retry / escalate

From `project.yaml`:

- `max_qa_security_review_retries` (default 3)
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
