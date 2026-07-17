# SDD Workflow — Spec Driven Development

## Languages

| Artifact | Language |
| --- | --- |
| `SPEC.md` | Portuguese (human validation) |
| `designs/*` | English |
| `adrs/*` | English |
| `sprints/*` | English |
| `tasks/*` | English |

## Folder shape

```text
sdd/
  <NNN>-<slug>/
    SPEC.md
    designs/
      001-<title>.md
    adrs/
      ADR-001-<title>.md
    sprints/
      sprint-01.md
    tasks/
      T001-<title>.md
    STATUS.md
```

`NNN` is zero-padded sequential across the hub (`001`, `002`, …).

## Mode & token economy

Follow `harness/workflows/token-economy.md` and `project.yaml → agents`.

- **Spec + Designs/ADRs/Sprints/Tasks pack**: Ask mode or focused Composer — do **not** spawn implementers.
- **Implementation**: separate Agent session(s), **one sprint or ≤ `max_tasks_per_wave` tasks** per wave.
- Prefer short decision messages (“aprovado”, “só D5”) over re-running the whole pack.
- Delta work beats “alinha tudo ao Spec”.

## Mandatory context before writing a Spec

The agent MUST read, in order (once per Spec drafting session — do not re-dump every refinement turn):

1. `project.yaml`
2. `AGENTS.md`
3. `vault/00-index/HOME.md` and **relevant** vault notes only
4. Constitutions that apply to the impact surface (not every constitution if N/A)
5. Existing related specs under `sdd/` (titles/STATUS first; open bodies only if related)
6. Target service/UI README under `../repos/<name>` (paths from `project.yaml`)

Never start from zero inventing architecture. Do not attach the entire vault or every prior Spec into the prompt.

## Human gates

```text
[1] User need
    → agent drafts SPEC.md (PT)
    → STOP (gate: approve_spec)

[2] User approves Spec
    → agent creates Designs + ADRs + Sprints + Tasks WITHOUT asking to continue
    → STOP (gate: approve_before_implementation)
    → ask: "está tudo certo para implementar?"

[3] User approves pack
    → create feature branch on each impacted polyrepo
    → bounded orchestration (one sprint or 1–3 tasks per wave)
    → each task follows review_class (product_code → QA+security+review; scaffold/docs → lighter)
    → retries up to gates.max_qa_security_review_retries (when review agents run)
    → if still failing → STOP and escalate to human
```

Between gate 1 and gate 2 the agent must **not** ask permission to generate Designs/ADRs/Sprints/Tasks — that pack is automatic after Spec approval.

## Spec template (`SPEC.md`) — Portuguese

```markdown
# SPEC-<NNN>: <Título>

## Contexto
## Problema
## Objetivos
## Fora de escopo
## Personas / atores
## Requisitos funcionais
## Requisitos não funcionais
## Restrições (vault / constitutions / stack)
## Critérios de aceite
## Repos impactados (service-* / ui-*)
## Riscos
## Referências do vault
## Status: draft | approved | implemented
```

## Design template — English

```markdown
# Design <id>: <title>
## Summary
## Options considered
## Chosen approach
## Service boundaries
## Data / events / APIs
## Security considerations
## Test strategy (unit, acceptance, QA e2e)
## Open questions
```

## ADR template — English

```markdown
# ADR-<id>: <title>
## Status
## Context
## Decision
## Consequences
```

## Sprint template — English

```markdown
# Sprint <n>
## Goal
## Task ids
## Parallelization plan
## Definition of Done
## Wave note
- Implement this sprint in its own session/wave; do not batch every sprint of the Spec together.
```

## Task template — English

```markdown
# T<id>: <title>
## Repo
## Sprint
## Goal
## review_class: product_code | security_sensitive | scaffold | docs | meta
## Constraints (links only — do not paste full Spec/ADRs)
## Implementation notes
## owns_paths
## depends_on
## parallel_group
## Implicit follow-ups (from project.yaml → agents.review_by_class)
- product_code / security_sensitive: QA + security-analyst + code-reviewer
- scaffold: local sensors only
- docs / meta: none
## Status: todo | doing | blocked | done
## Commits
## Subagent
```

## Task handling rules

- When finishing a task, update its Status and linked sprint checklist.
- `product_code` / `security_sensitive` tasks are incomplete until QA + security + review pass (or human escalates).
- `scaffold` / `docs` / `meta` skip the heavy agent triad unless the human asks otherwise.
- Prefer splitting into parallelizable tasks at sprint design time — but **execute** in bounded waves.

## STATUS.md

Track overall spec progress, gate timestamps, branch names, wave boundaries, and final merge readiness.
