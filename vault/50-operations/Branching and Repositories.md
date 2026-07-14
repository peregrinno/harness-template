# Branching and Repositories

tags: #ops

## Disk layout

See [[Workspace Layout]].

```text
<workspace>/harness-hub/     ← orchestration
<workspace>/repos/<name>/    ← product git repos
```

## Branch model

`master <- stage <- develop`  
Features: `feature/SPEC(<n>)/<slug>`  
Commits: `001-brief-kebab-title`

## Naming

- `service-<intent>`
- `ui-<context>`

## Polyrepo

Product code lives under `repos/` as separate GitHub repositories. This hub holds vault, SDD, reports, scaffolds (molds), and orchestration intelligence.

Inventory and paths: `project.yaml` (`path: ../repos/...`, `scaffold: scaffolds/...`).
