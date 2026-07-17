# 2026-07-14 — Token economy template policy

## Summary

Harness template policy to cut agent/context cost without dropping SDD gates: bounded orchestration waves, `review_class`, local-first commits, lean prompts, and `.cursorignore`.

## Repos

- Hub template only (workflows, rules, agents, skills, `project.yaml`)

## User-visible changes

- Spec/Design work prefers Ask / focused Composer; implementation only after pack OK, in small waves
- Scaffold/docs/meta tasks no longer auto-spawn QA + security + code-review by default
- Push is optional / wave-end; commits stay local by default

## Technical changes

- Added `harness/workflows/token-economy.md`
- Updated `sdd.md`, `delivery-loop.md`, `parallel-orchestration.md`
- `project.yaml → agents`: `review_by_class`, `orchestration`, `model_hints`
- New always-applied rule `60-token-economy.mdc`
- `.cursorignore` for deps, locks, coverage, bulky qa/security artifacts
- Vault note [[Token Economy]]

## Security notes

- `security_sensitive` and `product_code` still require full QA → security → review triad

## Follow-ups

- After INSTALL, ensure `.cursorignore` exists at workspace root (copy from hub if needed)
- Tune `max_tasks_per_wave` / `push_default` per project if desired
