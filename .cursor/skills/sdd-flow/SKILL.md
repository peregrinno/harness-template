---
name: sdd-flow
description: Run the full SDD lifecycle with correct languages and human gates. Use when the user requests a new specification or feature.
---

# Skill: sdd-flow

Follow `harness/workflows/sdd.md` and `.cursor/rules/10-sdd-flow.mdc`.

- Spec in Portuguese; stop for approval.
- On approval: Designs, ADRs, Sprints, Tasks in English automatically.
- Stop again before implementation.
- On approval: invoke parallel-orchestrator behaviour.
- Always attach implicit QA/security/review tasks — do not wait for the user to ask.
