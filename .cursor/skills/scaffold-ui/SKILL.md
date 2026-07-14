---
name: scaffold-ui
description: Scaffold a new polyrepo Next.js UI (ui-<context>) with Ant Design atomic design, yarn, Playwright. Use when creating a new frontend.
---

# Skill: scaffold-ui

1. Read `project.yaml`; require `context` slug → `ui-<context>`.
2. Copy `scaffolds/ui-example/`.
3. Prefer **latest stable antd**, then align React/Next.
4. Wire LLM reference https://ant.design/docs/react/introduce.md in README.
5. Copy `harness/templates/github-ci/ui-ci.yml` to `.github/workflows/ci.yml`.
6. Register in `project.yaml` + `vault/40-frontends/<name>.md`.
7. Refresh this skill when defaults change (versions, folder conventions).
