---
name: parallel-orchestrate
description: Orchestrate implementer subagents for one sprint or ≤3 approved tasks. Use after SDD pack approval.
---

# Skill: parallel-orchestrate

Follow `.cursor/agents/parallel-orchestrator.md` and `harness/workflows/parallel-orchestration.md` + `token-economy.md`.

- Ask which sprint or task ids if the human did not bound the wave.
- Cap parallelism with `project.yaml → agents.orchestration.max_tasks_per_wave`.
- Minimal subagent briefs; local commits; push per `push_default`.
- Keep this skill updated when branching or retry / review policy in `project.yaml` changes.
