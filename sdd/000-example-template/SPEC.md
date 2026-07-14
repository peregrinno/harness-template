# SPEC-000: Exemplo (template)

> Este arquivo é um **esqueleto de referência**. Não é uma Spec ativa. Remova ou ignore ao criar a `001`.

## Contexto

Hub harness polyrepo com scaffolds `service-example` e `ui-example`.

## Problema

Equipes e agentes precisam de um modelo canônico de Spec em português.

## Objetivos

- Validar o fluxo de gates humanos
- Servir de checklist para novas Specs

## Fora de escopo

Implementação real deste exemplo.

## Personas / atores

- Product owner
- Agente orquestrador Cursor

## Requisitos funcionais

1. O agente gera a Spec e para para aprovação humana.
2. Após OK, gera Designs/ADRs/Sprints/Tasks sem perguntar se deve continuar.

## Requisitos não funcionais

Idiomas e stack conforme `project.yaml` e constitutions.

## Restrições (vault / constitutions / stack)

Consultar `vault/00-index/HOME.md` e `harness/constitutions/*`.

## Critérios de aceite

- [ ] Pasta `sdd/<NNN>-<slug>/` criada
- [ ] Gate 1 e gate 2 respeitados
- [ ] Tasks incluem QA/security/review implícitos

## Repos impactados (service-* / ui-*)

- `service-example`
- `ui-example`

## Riscos

Drift de documentação se o vault não for alimentado.

## Referências do vault

- [[Architecture Overview]]
- [[Harness Operating Model]]

## Status: draft
