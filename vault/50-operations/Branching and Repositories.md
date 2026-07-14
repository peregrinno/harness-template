# Branching and Repositories

tags: #ops

## Branch model

`master <- stage <- develop`  
Features: `feature/fix(<n>)/<slug>`  
Commits: `001-brief-kebab-title`

## Naming

- `service-<intent>`
- `ui-<context>`

## Polyrepo

Product code lives in separate GitHub repositories. This hub holds vault, SDD, reports, and orchestration intelligence.

See `project.yaml` for inventory.
