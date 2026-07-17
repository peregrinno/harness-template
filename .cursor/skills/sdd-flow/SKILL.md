---
name: sdd-flow
description: Run the full SDD lifecycle with correct languages and human gates. Use when the user requests a new specification or feature.
---

# Skill: sdd-flow

Follow `harness/workflows/sdd.md`, `token-economy.md`, and `.cursor/rules/10-sdd-flow.mdc`.

- Spec + pack: Ask / focused Composer (Portuguese Spec; English Designs/ADRs/Sprints/Tasks).
- Stop for Spec approval; on approval generate pack automatically; stop again before implementation.
- On pack OK: invoke parallel-orchestrator for **one sprint or ≤3 tasks** — not the whole Spec at once.
- Honor `review_class` for QA/security/review; do not auto-spawn the triad on scaffold/docs/meta.
