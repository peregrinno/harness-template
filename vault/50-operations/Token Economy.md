# Token Economy

tags: #ops #sdd

Canonical workflow: `harness/workflows/token-economy.md`  
Defaults: `project.yaml → agents` (review_by_class, orchestration, model_hints)

## Intent

Ship the same SDD quality with less context churn: bounded sessions, lean prompts, review only when the task class needs it.

## Quick rules

- Spec + pack drafting ≠ implementation session
- Wave = one sprint or ≤ `max_tasks_per_wave` tasks
- Minimal briefs (paths/links, not pasted trees)
- Known paths → no broad explore
- Local commits first; push on request
- `.cursorignore` cuts index noise (venv, node_modules, locks, coverage, bulky artifacts)

## Links

- [[Harness Operating Model]]
- [[Workspace Layout]]
- [[Changelog Index]]
