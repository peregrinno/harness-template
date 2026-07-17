# Workspace Layout (canonical)

tags: #ops

## Required disk layout

Product workspaces MUST look like this (names configurable in `project.yaml → workspace`):

```text
<workspace-root>/                 ← open THIS folder in Cursor
  .cursor/                        ← REQUIRED at workspace root (rules, agents, skills)
    rules/
    agents/
    skills/
  harness-hub/                    ← copy of this template (orchestration hub)
    project.yaml
    AGENTS.md
    INSTALL.md
    harness/
    vault/
    sdd/
    qa/ security/ reviews/
    scaffolds/                    ← molds only (service-example, ui-example)
    references/
  repos/                          ← product polyrepos (real code)
    service-<intent>/
    ui-<context>/
```

## `.cursor` at workspace root (CRITICAL)

Cursor loads project rules, agents, and skills from **`<workspace-root>/.cursor/`**.

The template ships `.cursor/` inside the hub for distribution. During INSTALL the agent **must move** `harness-hub/.cursor` → `<workspace-root>/.cursor` so that:

- Rules apply across hub + all `repos/*`
- Agents/skills are discoverable when the IDE opens the workspace root

If `.cursor` remains only under `harness-hub/` while Cursor is opened on `<workspace-root>`, harness guidance will be missing or incomplete.

## Rules

1. **Hub** (`harness-hub/`): SDD, vault, harness intelligence, reports, scaffolds (templates).
2. **Repos** (`repos/`): every `service-*` and `ui-*` is its own Git repository under `repos/<name>/`.
3. **`.cursor/`** lives at workspace root after INSTALL (not only inside the hub).
4. Paths in `project.yaml → repositories.*.path` are **relative to the hub root**, e.g. `../repos/service-example`.
5. `scaffold` field points to the mold inside the hub, e.g. `scaffolds/service-example`.
6. During INSTALL, the agent creates `../repos/` if missing, moves `.cursor` to the workspace root, and materializes services/UIs.
7. Prefer opening `<workspace-root>` in Cursor so hub, repos, and `.cursor` are visible together.
8. Never implement product features only under `scaffolds/` after bootstrap — promote to `repos/` first.

## Related

- Branching: [[Branching and Repositories]]
- Local runtime: [[Local Runtime Modes]]
- Token economy: [[Token Economy]]
