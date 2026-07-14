---
name: scaffold-ui
description: Scaffold a new polyrepo Next.js UI (ui-<context>) into ../repos/ with Ant Design atomic design, yarn, Playwright. Use when creating a new frontend.
---

# Skill: scaffold-ui

1. Read `project.yaml`; require `context` slug → `ui-<context>`.
2. Destination MUST be `<workspace>/repos/<name>` (hub-relative `../repos/<name>`). Copy from `scaffolds/ui-example/`.
3. Prefer **latest stable antd**, then align React/Next.
4. Wire LLM reference https://ant.design/docs/react/introduce.md in README.
5. Copy `harness/templates/github-ci/ui-ci.yml` to `.github/workflows/ci.yml`.
6. Copy deploy manifests for `deploy.target`.
7. Register in `project.yaml` (`path: ../repos/<name>`, `scaffold: scaffolds/ui-example`) + `vault/40-frontends/<name>.md`.
8. Refresh this skill when defaults change (versions, folder conventions).
