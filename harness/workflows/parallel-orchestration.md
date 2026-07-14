# Parallel Orchestration

## Principle

If two tasks do not mutate the same files and do not require the same exclusive resource, run them with **parallel subagents**.

## How to split

At sprint design time, mark each task with:

```yaml
parallel_group: A | B | C | serial
owns_paths:
  - "app/src/use_cases/**"
depends_on: [T001]
```

Rules:

1. Same `parallel_group` and disjoint `owns_paths` → parallel.
2. `depends_on` unmet → wait.
3. `serial` → one after another.
4. Never parallelize two writers on the same module without a merge plan.

## Subagent brief (minimum)

Each subagent receives:

- Task file path
- Repo path + feature branch name
- Constitution links
- Port contracts assumed already running via `start-all.bat`
- Obligation to run delivery-loop locally for its slice
- Commit/push duty for its own commits

## Orchestrator duties

1. Launch eligible subagents.
2. Collect reports.
3. Re-queue failed slices (respect retry budget).
4. Invoke QA / security / code-reviewer for integration-level validation after leaf tasks complete (and for each task as required).
5. Residual commit + vault changelog + human summary in Portuguese.
