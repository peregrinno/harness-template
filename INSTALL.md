# INSTALL.md — Bootstrap do hub Harness

Este arquivo é a **porta de entrada**. Qualquer agente acionado neste hub deve lê-lo primeiro e executar o setup antes de SDD ou código.

Respostas ao humano: **português**. Artefatos do vault: **inglês**. Specs SDD: **português**. Designs/tasks: **inglês**.

---

## Layout canônico do workspace (obrigatório)

Ao copiar o template, organize assim:

```text
<workspace-root>/              ← abra ESTA pasta no Cursor (não só o hub)
  .cursor/                     ← OBRIGATÓRIO na raiz (rules, agents, skills)
  harness-hub/                 ← este template (pode renomear via project.yaml)
    … hub files …
  repos/                       ← código de produto (polyrepos)
    service-<intent>/
    ui-<context>/
```

| Pasta | Função |
| --- | --- |
| `.cursor/` **na raiz** | Onde o Cursor carrega rules (`.mdc`), agents e skills do projeto. Sem isso na raiz do workspace, o IDE não aplica o harness de forma confiável. |
| `harness-hub/` | Orquestração: SDD, vault Obsidian, constitutions, QA/security/reviews, scaffolds (moldes) |
| `repos/` | Git repos reais de microserviços e UIs |

### `.cursor` na raiz — regra crítica

O template distribui `.cursor/` **dentro** do hub. No setup de um projeto real, essa pasta **deve ser movida** (ou copiada e depois removida do hub, se preferir uma única fonte) para `<workspace-root>/.cursor/`.

Motivo: o Cursor resolve project rules / agents / skills a partir da **raiz do workspace aberto**. Se `.cursor` ficar só em `harness-hub/.cursor` e a pasta aberta for `<workspace-root>` (hub + repos), as regras **não** entram no contexto como deveriam.

- Path esperado após install: `<workspace-root>/.cursor/rules/*.mdc`, `agents/`, `skills/`
- Paths em `project.yaml → repositories.*.path` continuam relativos ao **hub**, ex.: `../repos/service-example`.
- `scaffold` aponta para o molde no hub, ex.: `scaffolds/service-example`.
- Detalhes: `vault/50-operations/Workspace Layout.md`.

Se o layout ainda não existir, o agente **cria** `../repos/` no setup, **move `.cursor` para a raiz do workspace** e materializa os serviços/UIs listados em `project.yaml`.

---

## Pré-requisitos humanos

- Cursor IDE (ideal: workspace = pasta que contém `harness-hub/` + `repos/`)
- Obsidian (abrir `harness-hub/vault/` como vault)
- Git + `gh` autenticado
- Docker Desktop **somente** se `runtime.local_mode: bundled_infra`
- Python 3.13 + [uv](https://docs.astral.sh/uv/)
- Node LTS + yarn
- PowerShell (Windows)

---

## Passo 0 — Identidade do projeto (perguntar se vazio)

1. Edite `project.yaml` (nome, org GitHub, serviços, UIs, portas, infra).
2. Confirme `workspace.hub_dirname` / `workspace.repos_dirname` (padrão: `harness-hub`, `repos`).
3. **Runtime local** — escolha obrigatória:
   - `runtime.local_mode: bundled_infra` → `start-all` sobe Postgres/Redis/Rabbit(+Mongo) via Docker e, se `start_apps: true`, as apps em `repos/`.
   - `runtime.local_mode: external_infra` → deps já rodam na máquina; `start-all` só valida portas e sobe apps.
4. **Deploy** — escolha obrigatória:
   - `deploy.target: railway` **ou** `portainer`
   - Agent copia templates de `harness/templates/deploy/<target>/` para cada repo em `repos/` na publicação.
5. Preencha `harness/supply/visual-identity.md` e coloque logos em `harness/supply/assets/`.
6. Confirme `gates.max_qa_security_review_retries` (padrão: 3).
7. Se MongoDB for necessário, `infra.mongodb.enabled: true`.

Se `runtime.local_mode` ou `deploy.target` estiverem inválidos, **pare e pergunte**.

---

## Passo 1 — O que o agente deve criar no setup inicial

Quando o usuário disser “instalar harness” / “fazer setup” / “bootstrap”:

### 1.0 Promover `.cursor` para a raiz do workspace (OBRIGATÓRIO — fazer primeiro)

1. Resolver `workspace-root` = diretório pai do hub (ex.: pasta que contém `harness-hub/` e `repos/`).
2. Se existir `harness-hub/.cursor/` e **não** existir `<workspace-root>/.cursor/`:
   - **Mover** `harness-hub/.cursor` → `<workspace-root>/.cursor`  
     (equivalente: `Move-Item` / `mv`; objetivo é uma única pasta `.cursor` na raiz).
3. Se ambas existirem, fazer merge inteligente (não apagar rules custom do usuário na raiz) e depois remover a cópia obsoleta do hub se estiver duplicada.
4. Confirmar que existem:
   - `<workspace-root>/.cursor/rules/*.mdc`
   - `<workspace-root>/.cursor/agents/`
   - `<workspace-root>/.cursor/skills/`
5. Se o hub tiver `.cursorignore` e a raiz do workspace ainda não: **copiar** `harness-hub/.cursorignore` → `<workspace-root>/.cursorignore` (reduz indexação de venv/node_modules/locks/coverage).
6. Lembrar o usuário: o Cursor precisa ter aberto o **workspace-root**, não apenas `harness-hub/`.

Sem este passo, rules/agents/skills do harness ficam “invisíveis” ou parciais para o agente.

### 1.1 Regras Cursor (conteúdo de `.cursor/rules/*.mdc` na raiz)

Garantir (criar/atualizar **em** `<workspace-root>/.cursor/rules/`) as rules abaixo — **não** deixar a fonte de verdade só dentro do hub:

| Arquivo | `alwaysApply` | Função |
| --- | --- | --- |
| `00-harness-core.mdc` | true | Idioma, mapa, layout, runtime, deploy, gates |
| `10-sdd-flow.mdc` | true | Spec→Designs→ADRs→Sprints→Tasks |
| `20-backend-hexagonal.mdc` | false | backend + loguru + lifespan |
| `25-data.mdc` | false | data constitution |
| `26-messaging.mdc` | false | messaging / RabbitMQ constitution |
| `30-frontend-atomic.mdc` | false | frontend + supply visual |
| `40-git-branching.mdc` | true | branches / commits / `repos/` |
| `50-vault-obsidian.mdc` | true | vault + changelog |
| `60-token-economy.mdc` | true | bounded waves, review_class, lean context |

### 1.2 Pastas operacionais (dentro do hub)

```text
sdd/ qa/ security/ reviews/
vault/00-index/ … vault/90-references/
harness/supply/assets/
```

### 1.3 Pasta `repos/` (irmã do hub)

1. Resolver workspace root = pai do hub.
2. Criar `<workspace-root>/<repos_dirname>/` se não existir.
3. Para cada item em `project.yaml → repositories`:
   - Se `path` (`../repos/<name>`) não existe:
     - Se `remote` preenchido → `git clone` / `gh repo clone` nesse path.
     - Senão → copiar de `scaffold` para `../repos/<name>`, ajustar nome/porta, init git se necessário.
   - Naming obrigatório: `service-<intent>`, `ui-<context>`.
4. Atualizar `path` / `remote` no `project.yaml` se mudarem.
5. **Não** desenvolver features só em `scaffolds/` após o bootstrap.

### 1.4 Índice Obsidian + supply

Atualizar `vault/00-index/HOME.md`. Lembrar de preencher `harness/supply/visual-identity.md`.

### 1.5 Branches base (em cada repo sob `repos/`)

`master`, `stage`, `develop` em cada `service-*` / `ui-*`.

### 1.6 Manifests de deploy

Com base em `deploy.target`, copiar para **cada** repo em `repos/` (não só scaffolds):

- `railway` → Dockerfile + `railway.toml`
- `portainer` → documentar stack a partir de `harness/templates/deploy/portainer/stack.example.yml` em `vault/50-operations/`

### 1.7 Runtime local

```bat
harness\scripts\windows\start-all.bat
```

Apps sobem a partir de `../repos/<name>` (fallback: scaffolds só se repos ainda não existirem). Ver `vault/50-operations/Local Runtime Modes.md`.

### 1.8 Unlock

Criar `harness/.setup-complete` com timestamp ISO, layout confirmado, `local_mode`, `deploy.target` e versões detectadas.

---

## Passo 2 — Comando mínimo para o usuário

```text
Leia INSTALL.md e project.yaml. Execute o setup inicial do harness.
Garanta o layout <workspace>/harness-hub + <workspace>/repos.
Mova a pasta .cursor do hub para a raiz do workspace (<workspace>/.cursor) para o Cursor carregar rules/agents/skills.
Confirme comigo: runtime.local_mode (bundled_infra|external_infra) e deploy.target (railway|portainer).
Crie/atualize rules .mdc na raiz, pastas, vault, supply, repos/ e manifests de deploy.
Responda em português. Não inicie SDD até eu confirmar o project.yaml.
```

---

## Passo 3 — Depois do setup

1. Abrir `vault/` no Obsidian; completar `harness/supply/`.
2. Rodar `start-all.bat`.
3. Pedir a primeira Spec (Ask / Composer focado).
4. Gates SDD; implementação em ondas (1 sprint ou ≤3 tasks); QA → security → code-review só quando `review_class` exigir.

Implementação de código: sempre nos paths em `repos/`, nunca no molde `scaffolds/` (exceto melhorias do próprio template).

---

## Checklist de aceite do setup

- [ ] Layout `harness-hub/` + `repos/` no workspace root
- [ ] **`.cursor/` está na raiz do workspace** (não só dentro do hub)
- [ ] Cursor aberto no workspace-root (pai de hub + repos)
- [ ] `project.yaml` preenchido (paths `../repos/...`)
- [ ] `runtime.local_mode` escolhido
- [ ] `deploy.target` = `railway` ou `portainer`
- [ ] `.cursor/rules/*.mdc` ok na raiz (inclui data + messaging + token-economy)
- [ ] `.cursorignore` na raiz do workspace (deps, locks, coverage)
- [ ] `harness/supply/visual-identity.md` iniciado + `assets/`
- [ ] Cada service/UI materializado em `repos/`
- [ ] Pastas `sdd/ qa/ security/ reviews/ vault/**` ok
- [ ] Templates de deploy nos repos documentados
- [ ] `harness/.setup-complete` existe
- [ ] Constitutions data + messaging conhecidas

---

## Notas

Este diretório (`harness-hub`) é só o **hub**. Código de produto = `repos/<name>` = repositórios GitHub separados.
