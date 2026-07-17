# Harness Operating Model

tags: #architecture #sdd

## Layers

1. Short map: `AGENTS.md`
2. System of record: this vault + `sdd/`
3. Feedforward: constitutions, Cursor rules, skills, scaffolds (molds under hub)
4. Sensors: lint, tests, coverage, semver, CI
5. Inferential agents: QA, security-analyst, code-reviewer
6. Feedback into vault/changelogs

Product code execution happens in `<workspace>/repos/`, not in hub molds after bootstrap.

## Delivery

Plan → Execute → Verify. Prefer deterministic sensors. Parallelize independent tasks **inside bounded waves** (one sprint or ≤3 tasks). See [[Token Economy]].

## Human gates

1. Approve Spec (PT) — Ask / focused Composer (no implementers)
2. Approve Designs/ADRs/Sprints/Tasks (EN)
3. Implement in waves; escalate only after QA/security/review retries exhausted (when `review_class` requires them)
