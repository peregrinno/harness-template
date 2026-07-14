# Harness Template — Hub Full-Cycle (IA + Obsidian + Cursor)

Template **agnóstico e reutilizável** para conduzir agentes com [Harness Engineering](https://openai.com/index/harness-engineering/): controles feedforward, sensores determinísticos, agents inferenciais (QA / security / code-review) e knowledge base no Obsidian.

## O que é este repositório

Um **hub polyrepo**, não um monólito de produto:

| Parte | Função |
| --- | --- |
| `project.yaml` | Identidade do projeto |
| `AGENTS.md` | Mapa curto para qualquer agente |
| `INSTALL.md` | Bootstrap (rules, pastas, unlock) |
| `harness/` | Constitutions, workflows, sensors, CI templates, scripts Windows |
| `vault/` | Cofre Obsidian (conhecimento em inglês) |
| `sdd/` | Spec-Driven Development (Spec em PT; demais artefatos em EN) |
| `qa/` `security/` `reviews/` | Relatórios versionados |
| `scaffolds/` | Exemplos bootáveis `service-example` e `ui-example` |
| `.cursor/` | Rules, agents, skills |

## Stack fixa

- **Arquitetura**: microserviços + RabbitMQ + Redis + PostgreSQL 17 (+ MongoDB sob demanda)
- **Backend**: Python 3.13, uv, FastAPI, SQLAlchemy 2.0 async, Alembic, hexagonal, unit + acceptance
- **Frontend**: TypeScript, yarn, React, Next.js, Ant Design (versão mais recente primeiro), atomic, Playwright
- **Git**: `master ← stage ← develop` · `feature/fix(<n>)/<slug>` · commits `001-<titulo>`

## Começar

1. Copie esta pasta para o workspace do novo projeto.
2. Preencha `project.yaml`.
3. No Cursor: peça para seguir `INSTALL.md`.
4. Suba a infra: `harness\scripts\windows\start-all.bat`
5. Peça a primeira Spec.

Detalhes: [INSTALL.md](./INSTALL.md) · mapa do agente: [AGENTS.md](./AGENTS.md)

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

Veja `references/` (constituições históricas, links Harness, livros de escalabilidade). As constitutions ativas do template vivem em `harness/constitutions/` (já reconciliadas: SQLAlchemy async, testes unit+acceptance, CI permitido no harness).
