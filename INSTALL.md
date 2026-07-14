# INSTALL.md — Bootstrap do hub Harness

Este arquivo é a **porta de entrada**. Qualquer agente acionado num workspace que contém este template deve lê-lo primeiro e executar o setup antes de SDD ou código.

Respostas ao humano: **português**. Artefatos do vault: **inglês**. Specs SDD: **português**. Designs/tasks: **inglês**.

---

## Pré-requisitos humanos

- Cursor IDE
- Obsidian (abrir a pasta `vault/` como vault)
- Git + `gh` autenticado
- Docker Desktop (para infra local)
- Python 3.13 + [uv](https://docs.astral.sh/uv/)
- Node LTS + yarn
- PowerShell (Windows)

---

## Passo 0 — Identidade do projeto

1. Edite `project.yaml` com nome, org GitHub, serviços, UIs, portas e secrets locais de infra.
2. Confirme `gates.max_qa_security_review_retries` (padrão: 3).
3. Se MongoDB for necessário, `infra.mongodb.enabled: true`.

Sem `project.yaml` preenchido, **pare e pergunte** ao usuário.

---

## Passo 1 — O que o agente deve criar no setup inicial

Quando o usuário disser algo como “instalar harness” / “fazer setup” / “bootstrap”:

### 1.1 Regras Cursor (`.cursor/rules/*.mdc`)

Garantir (criar se faltarem) as rules abaixo, todas apontando para o harness — **não** duplicar constituições inteiras dentro do `.mdc`:

| Arquivo | `alwaysApply` | Função |
| --- | --- | --- |
| `00-harness-core.mdc` | true | Idioma, mapa AGENTS.md, gates, ordem QA→security→review |
| `10-sdd-flow.mdc` | true | Spec→Designs→ADRs→Sprints→Tasks |
| `20-backend-hexagonal.mdc` | false | globs `**/service-*/**`, `**/scaffolds/service-*/**` |
| `30-frontend-atomic.mdc` | false | globs `**/ui-*/**`, `**/scaffolds/ui-*/**` |
| `40-git-branching.mdc` | true | branches, commits, polyrepo naming |
| `50-vault-obsidian.mdc` | true | feed do vault + changelog |

Se `.cursor/rules/` já existir, atualizar sem apagar regras custom do usuário — merge inteligente.

### 1.2 Pastas operacionais

Criar se não existirem:

```text
sdd/
qa/
security/
reviews/
vault/00-index/
vault/10-architecture/
vault/20-domains/
vault/30-services/
vault/40-frontends/
vault/50-operations/
vault/60-security/
vault/70-changelogs/
vault/90-references/
```

### 1.3 Índice Obsidian

Gerar/atualizar `vault/00-index/HOME.md` com links para arquitetura, serviços listados em `project.yaml`, e SDD ativo.

### 1.4 Clonar / materializar polyrepos

Para cada item em `project.yaml → repositories`:

- Se `remote` vazio e o scaffold local existe: manter em `scaffolds/` até o usuário pedir “publicar repos”.
- Se `remote` preenchido: `gh repo clone` (ou `git clone`) para um sibling directory fora do hub, OU `repos/<name>/` conforme convenção do workspace — **confirmar path com o usuário**.
- Naming obrigatório: `service-<intent>`, `ui-<context>`.

### 1.5 Branches base (por repo de código)

Em cada repo de serviço/UI: garantir `master`, `stage`, `develop` com proteção documentada em `vault/50-operations/branching.md`.

### 1.6 Infra local

Instruir o usuário a rodar **uma vez** e deixar aberto:

```bat
harness\scripts\windows\start-all.bat
```

Agentes **não** sobem Postgres/Redis/Rabbit/Mongo sob demanda se o script já for o contrato.

### 1.7 Unlock

Marcar setup completo criando `harness/.setup-complete` com timestamp ISO e echo das versões detectadas (python, uv, node, yarn, docker).

Só depois disso o fluxo SDD fica liberado.

---

## Passo 2 — Comando mínimo para o usuário

No chat do Cursor (Agent mode), cole:

```text
Leia INSTALL.md e project.yaml. Execute o setup inicial do harness neste workspace.
Crie/atualize as rules .mdc, pastas operacionais, índice do vault e valide pré-requisitos.
Responda em português. Não inicie SDD até eu confirmar o project.yaml.
```

---

## Passo 3 — Depois do setup

1. Abrir `vault/` no Obsidian.
2. Rodar `start-all.bat`.
3. Pedir a primeira Spec: “Quero uma nova especificação para …”
4. O agente gera Spec (PT) e **para** no gate humano.
5. Após OK: Designs → ADRs → Sprints → Tasks (sem perguntar se continua).
6. Segundo gate: confirmar o pacote.
7. Orquestração paralela até QA + security + code-review passarem (retries em `project.yaml`; depois escala ao humano).

---

## Checklist de aceite do setup

- [ ] `project.yaml` preenchido
- [ ] `.cursor/rules/*.mdc` presentes e apontando ao harness
- [ ] Pastas `sdd/ qa/ security/ reviews/ vault/**` ok
- [ ] `vault/00-index/HOME.md` existe
- [ ] `harness/.setup-complete` existe
- [ ] Usuário ciente de rodar `start-all.bat`
- [ ] Agente confirma stack: SQLAlchemy 2 async (não Gino), testes service=unit+acceptance, e2e=QA

---

## Notas polyrepo

Este diretório é o **hub** (conhecimento + orquestração). Código de produto vive em repositórios GitHub separados gerados a partir de `scaffolds/` ou já existentes. O hub versiona SDD, vault, reports e a inteligência do harness.
