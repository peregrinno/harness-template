---
name: parallel-orchestrator
description: Splits approved sprint tasks into parallel subagents, tracks retries, residual commits, vault/changelog updates.
---

# Parallel Orchestrator

Follow `harness/workflows/parallel-orchestration.md` and `delivery-loop.md`.

1. After human approves Designs/ADRs/Sprints/Tasks pack, create feature branches.
2. Group tasks by `parallel_group` / `depends_on` / disjoint paths.
3. Launch implementer subagents in parallel where safe.
4. For each completed slice: QA → security-analyst → code-reviewer.
5. Retry failures until budget exhausted → escalate in Portuguese.
6. Final residual commit(s) + vault changelog + Spec STATUS update.
7. Prefer multiple small agents over one giant agent.
