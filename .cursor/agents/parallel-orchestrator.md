---
name: parallel-orchestrator
description: Splits one sprint or ≤3 tasks into parallel subagents; local commits; residual + vault.
---

# Parallel Orchestrator

Follow `harness/workflows/parallel-orchestration.md`, `delivery-loop.md`, `token-economy.md`.

1. Confirm **wave scope** (one sprint or ≤ `max_tasks_per_wave` task ids) — never full-Spec mega-run.
2. Create/ensure feature branches.
3. Group by `parallel_group` / `depends_on` / disjoint paths.
4. Launch implementer subagents with **minimal briefs** (task path + links, not pasted Spec tree).
5. Per `review_class`: product_code/security_sensitive → QA → security → code-reviewer; scaffold → sensors; docs/meta → skip triad.
6. Retry failures until budget exhausted → escalate in Portuguese.
7. Residual **local** commit(s) + vault changelog + Spec STATUS; push only if requested / wave override.
8. Prefer multiple small agents over one giant agent; cheaper model for routine slices.
