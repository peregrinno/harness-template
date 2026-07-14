# INSTALL.md — Bootstrap do hub Harness

Este arquivo é a **porta de entrada**. Qualquer agente acionado num workspace que contém este template deve lê-lo primeiro e executar o setup antes de SDD ou código.

Respostas ao humano: **português**. Artefatos do vault: **inglês**. Specs SDD: **português**. Designs/tasks: **inglês**.

---

## Pré-requisitos humanos

- Cursor IDE
- Obsidian (abrir a pasta `vault/` como vault)
- Git + `gh` autenticado
- Docker Desktop **somente** se `runtime.local_mode: bundled_infra`
- Python 3.13 + [uv](https://docs.astral.sh/uv/)
- Node LTS + yarn
- PowerShell (Windows)

---

## Passo 0 — Identidade do projeto (perguntar se vazio)

1. Edite `project.yaml` (nome, org GitHub, serviços, UIs, portas, infra).
2. **Runtime local** — escolha obrigatória:
   - `runtime.local_mode: bundled_infra` → `start-all` sobe Postgres/Redis/Rabbit(+Mongo) via Docker e, se `start_apps: true`, as apps.
   - `runtime.local_mode: external_infra` → deps já rodam na máquina; `start-all` só valida portas e sobe apps.
3. **Deploy** — escolha obrigatória:
   - `deploy.target: railway` **ou** `portainer`
   - Agent deve copiar templates de `harness/templates/deploy/<target>/` para os polyrepos no momento da publicação.
4. Preencha `harness/supply/visual-identity.md` e coloque logos em `harness/supply/assets/`.
5. Confirme `gates.max_qa_security_review_retries` (padrão: 3).
6. Se MongoDB for necessário, `infra.mongodb.enabled: true`.

Se `runtime.local_mode` ou `deploy.target` estiverem indefinidos/ inválidos, **pare e pergunte** ao usuário.

---

## Passo 1 — O que o agente deve criar no setup inicial

Quando o usuário disser “instalar harness” / “fazer setup” / “bootstrap”:

### 1.1 Regras Cursor (`.cursor/rules/*.mdc`)

| Arquivo | `alwaysApply` | Função |
| --- | --- | --- |
| `00-harness-core.mdc` | true | Idioma, mapa, runtime, deploy, gates |
| `10-sdd-flow.mdc` | true | Spec→Designs→ADRs→Sprints→Tasks |
| `20-backend-hexagonal.mdc` | false | backend + loguru + lifespan |
| `25-data.mdc` | false | data constitution |
| `30-frontend-atomic.mdc` | false | frontend + supply visual |
| `40-git-branching.mdc` | true | branches / commits |
| `50-vault-obsidian.mdc` | true | vault + changelog |

### 1.2 Pastas operacionais

```text
sdd/ qa/ security/ reviews/
vault/00-index/ … vault/90-references/
harness/supply/assets/
```

### 1.3 Índice Obsidian + supply

Atualizar `vault/00-index/HOME.md`. Lembrar o humano de preencher `harness/supply/visual-identity.md`.

### 1.4 Polyrepos

Materializar/clonar conforme `project.yaml`. Naming: `service-<intent>`, `ui-<context>`.

### 1.5 Branches base

`master`, `stage`, `develop` em cada repo de código.

### 1.6 Manifests de deploy

Com base em `deploy.target`:

- `railway` → copiar `Dockerfile` + `railway.toml` dos templates para cada scaffold/repo.
- `portainer` → preparar stack a partir de `harness/templates/deploy/portainer/stack.example.yml` e documentar em `vault/50-operations/`.

### 1.7 Runtime local

Instruir:

```bat
harness\scripts\windows\start-all.bat
```

Comportamento depende de `runtime.local_mode` (ver `vault/50-operations/Local Runtime Modes.md`).

Agentes **não** sobem segunda cópia de Postgres/Redis/Rabbit nas mesmas portas.

### 1.8 Unlock

Criar `harness/.setup-complete` com timestamp ISO, `local_mode`, `deploy.target` e versões detectadas.

---

## Passo 2 — Comando mínimo para o usuário

```text
Leia INSTALL.md e project.yaml. Execute o setup inicial do harness neste workspace.
Confirme comigo: runtime.local_mode (bundled_infra|external_infra) e deploy.target (railway|portainer).
Crie/atualize rules .mdc, pastas, vault, supply e manifests de deploy.
Responda em português. Não inicie SDD até eu confirmar o project.yaml.
```

---

## Passo 3 — Depois do setup

1. Abrir `vault/` no Obsidian; completar identidade visual em `harness/supply/`.
2. Rodar `start-all.bat`.
3. Pedir a primeira Spec.
4. Gates SDD + orquestração (QA → security → code-review) como em `harness/workflows/`.

---

## Checklist de aceite do setup

- [ ] `project.yaml` preenchido
- [ ] `runtime.local_mode` escolhido
- [ ] `deploy.target` = `railway` ou `portainer`
- [ ] `.cursor/rules/*.mdc` ok (inclui `25-data`)
- [ ] `harness/supply/visual-identity.md` iniciado + `assets/`
- [ ] Pastas `sdd/ qa/ security/ reviews/ vault/**` ok
- [ ] Templates de deploy copiados/documentados
- [ ] `harness/.setup-complete` existe
- [ ] Stack: SQLAlchemy 2 async, loguru, lifespan pings, testes unit+acceptance

---

## Notas polyrepo

Este diretório é o **hub**. Código de produto vive em repositórios GitHub separados.
