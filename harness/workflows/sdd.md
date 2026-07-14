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

## Mandatory context before writing a Spec

The agent MUST read, in order:

1. `project.yaml`
2. `AGENTS.md`
3. `vault/00-index/HOME.md` and relevant vault notes
4. `harness/constitutions/*`
5. Existing related specs under `sdd/`
6. Target service/UI README if repos are already cloned

Never start from zero inventing architecture.

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
    → parallel orchestration of tasks
    → each task implicitly includes QA + security + code-review loop
    → retries up to gates.max_qa_security_review_retries
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
```

## Task template — English

```markdown
# T<id>: <title>
## Repo
## Sprint
## Goal
## Constraints (links)
## Implementation notes
## Implicit mandatory follow-ups
- [ ] QA agent (acceptance/e2e as applicable) + report under qa/
- [ ] security-analyst (+ auto-fix critical)
- [ ] code-reviewer (duplication, coherence, accidental deletions)
## Status: todo | doing | blocked | done
## Commits
## Subagent
```

## Task handling rules

- When finishing a task, update its Status and linked sprint checklist.
- Every task that changes product code is incomplete until QA + security + review pass (or human escalates).
- Prefer splitting into parallelizable tasks at sprint design time.

## STATUS.md

Track overall spec progress, gate timestamps, branch names, and final merge readiness.
