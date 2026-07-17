# Parallel Orchestration

Also read `harness/workflows/token-economy.md` and `project.yaml → agents.orchestration`.

## Principle

If two tasks do not mutate the same files and do not require the same exclusive resource, run them with **parallel subagents** — but only inside a **bounded wave**.

## Wave bounds (mandatory)

1. One wave = **one sprint** or **≤ `max_tasks_per_wave` tasks** (default 3).
2. Never orchestrate an entire Spec’s task list in a single mega-run.
3. Prefer a fresh session per wave / bounded context.
4. Do not relaunch “full Spec” orchestration after a partial approval — ask which sprint or task ids to run.

## How to split

At sprint design time, mark each task with:

```yaml
parallel_group: A | B | C | serial
owns_paths:
  - "app/src/use_cases/**"
depends_on: [T001]
review_class: product_code | security_sensitive | scaffold | docs | meta
```

Rules:

1. Same `parallel_group` and disjoint `owns_paths` → parallel (within wave cap).
2. `depends_on` unmet → wait.
3. `serial` → one after another.
4. Never parallelize two writers on the same module without a merge plan.

## Subagent brief (minimum — keep small)

Each subagent receives **only**:

- Task file path
- Repo path + feature branch name
- `owns_paths` / `depends_on`
- Links (not bodies) to Spec/Design/ADR + applicable constitution
- Port contracts assumed already running via `start-all.bat`
- Obligation to run delivery-loop for its slice (honoring `review_class`)
- **Commit locally**; push only if the brief says so (`push_default: false`)

Do **not** paste SPEC.md + all ADRs + repo trees into the brief.
Do **not** set explore thoroughness to `very thorough` when paths are known.

## Orchestrator duties

1. Confirm wave scope with the human if unclear (sprint id or task id list).
2. Launch eligible subagents for this wave only.
3. Collect reports.
4. Re-queue failed slices (respect retry budget).
5. Invoke QA / security / code-reviewer **per `review_class`** after leaf tasks (integration QA once per wave for product_code slices — not for docs/scaffold-only waves).
6. Residual **local** commit + vault changelog when the wave/feature closes + human summary in Portuguese.
7. Push when requested (or wave-end if explicitly enabled for that run).
