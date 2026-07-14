# Harness Template — Hub Full-Cycle (IA + Obsidian + Cursor)

Template **agnóstico e reutilizável** para conduzir agentes com [Harness Engineering](https://openai.com/index/harness-engineering/): controles feedforward, sensores determinísticos, agents inferenciais (QA / security / code-review) e knowledge base no Obsidian.

## Layout canônico

```text
<workspace-root>/          ← abrir no Cursor
  .cursor/                 ← rules/agents/skills (movido do hub na instalação)
  harness-hub/             ← este repositório (orquestração)
  repos/                   ← service-* e ui-* (código de produto)
```

**Importante:** na instalação, a pasta `.cursor` do hub deve ser **movida para a raiz do workspace**. O Cursor só carrega rules/agents/skills de forma confiável a partir da raiz aberta no IDE.

## O que é o hub

| Parte | Função |
| --- | --- |
| `.cursor/` (raiz do workspace) | Rules, agents, skills — **após INSTALL**, não deixar só dentro do hub |
| `project.yaml` | Identidade + paths `../repos/<name>` |
| `AGENTS.md` | Mapa curto para qualquer agente |
| `INSTALL.md` | Bootstrap (layout, rules, repos/, unlock) |
| `harness/` | Constitutions, workflows, sensors, CI/deploy, scripts, supply |
| `vault/` | Cofre Obsidian (conhecimento em inglês) |
| `sdd/` | Spec-Driven Development |
| `qa/` `security/` `reviews/` | Relatórios |
| `scaffolds/` | Moldes bootáveis (não substituem `repos/`) |

## Stack fixa

- **Arquitetura**: microserviços + RabbitMQ + Redis + PostgreSQL 17 (+ MongoDB sob demanda)
- **Backend**: Python 3.13, uv, FastAPI, SQLAlchemy 2.0 async, Alembic, loguru, hexagonal, unit + acceptance
- **Dados**: database-per-service (`harness/constitutions/data.md`)
- **Mensageria**: RabbitMQ async, outbox/inbox (`harness/constitutions/messaging.md`)
- **Frontend**: TypeScript, yarn, React, Next.js, Ant Design, atomic, Playwright (+ `harness/supply/`)
- **Runtime local**: `bundled_infra` ou `external_infra`
- **Deploy**: Railway ou Portainer
- **Git**: `master ← stage ← develop` · `feature/SPEC(<n>)/<slug>` · commits `001-<titulo>`

## Começar

1. Crie `<workspace-root>/` e copie este template como `harness-hub/`.
2. Deixe (ou deixe o setup criar) a pasta irmã `repos/`.
3. Preencha `project.yaml`.
4. No Cursor (abrindo o **workspace root**): peça para seguir `INSTALL.md` — o agente **move** `.cursor` para a raiz.
5. Suba a infra: `harness-hub\harness\scripts\windows\start-all.bat`
6. Peça a primeira Spec.

Detalhes: [INSTALL.md](./INSTALL.md) · mapa: [AGENTS.md](./AGENTS.md) · layout: `vault/50-operations/Workspace Layout.md`

## Idiomas

| Superfície | Idioma |
| --- | --- |
| Respostas ao usuário | Português |
| Vault Obsidian | Inglês |
| Spec SDD | Português |
| Designs / ADRs / Sprints / Tasks | Inglês |
| Código e raciocínio do agente | Inglês |
| Docstrings | Português |

## Referências locais

Veja `references/`. Constitutions ativas: `harness/constitutions/`.
