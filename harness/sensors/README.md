# Sensors — Deterministic feedback controls

Prefer these over prose rules. Agents must run them before declaring a task done.

## Backend service sensors

| Sensor | Command (typical) | Gate |
| --- | --- | --- |
| Lint/format | `uv run ruff check` + `uv run ruff format --check` | must pass |
| Unit + acceptance | `uv run pytest` | must pass |
| Coverage total | pytest-cov | ≥ `project.yaml` `coverage.total_minimum` (60) |
| Coverage new/diff | CI codecov/diff-cover or equivalent | ≥ `coverage.new_code_minimum` (80) |
| Semver | pre-commit / script `harness/sensors/check_semver.py` pattern | must pass |
| Migrations | Alembic heads aligned | must pass |

## Frontend UI sensors

| Sensor | Command | Gate |
| --- | --- | --- |
| Lint | `yarn lint` | must pass |
| Typecheck | `yarn typecheck` | must pass |
| Component tests | `yarn test` | must pass |
| Playwright | `yarn test:e2e` | critical journeys |
| Coverage | project config | 60/80 policy |

## Hub sensors

- SDD folder integrity: Spec exists before designs; designs before tasks.
- Vault links: new features referenced from `vault/00-index/HOME.md`.
- Changelog entry present after feature Done.

## Agent-readable failures

When wrapping scripts, print remediation hints in the failure output (positive prompt injection), e.g.:

```text
FAIL coverage total 54% < 60%. Add unit tests for use cases under app/src/tests/unit.
```
