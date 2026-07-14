# Frontend Constitution (Harness Active)

> Derived from `references/constitution-frontend.md`. CI sensors allowed via harness templates.
> Cross-service e2e orchestration reports live in hub `qa/`; Playwright suites live in the UI repo.

## Skills Reference

Check `.cursor/skills/` before scaffolding UI work.

# Project Constitution — Frontend

## 0. Official Stack (MANDATORY)

| Concern | Standard |
| --- | --- |
| Language | TypeScript (strict) |
| Package manager | **yarn** |
| UI | React |
| Framework | Next.js (App Router) |
| Design system | Ant Design (`antd`) |
| Architecture | Atomic Design + reusability |
| Component tests | React Testing Library |
| E2E | Playwright |

### Ant Design Source of Truth
- LLM docs: https://ant.design/docs/react/introduce.md
- Prefer latest stable `antd`, then align React/Next/peers.
- Do not install `@types/antd`.

## 1. Atomic Design

```
Atoms → Molecules → Organisms → Templates → Pages/Routes
```

### Directory Structure
```
/app                    # Next.js App Router
/src
  /components/{atoms,molecules,organisms,templates}
  /features/<feature>/{components,hooks,types,api}
  /hooks
  /lib
  /services
  /stores
  /types
  /theme
  /styles
/tests/{components,e2e,fixtures}
```

### Dependency Direction
`app → features/organisms → molecules → atoms/antd`  
Lower layers never import higher layers.

## 2. Naming

- Components: PascalCase
- Hooks: `use*` camelCase
- Tests: `ComponentName.test.tsx`, e2e `feature-name.spec.ts`
- Repo name: `ui-<context>`

## 3. Testing

### Component tests — MANDATORY for interactive/reusable UI
User-centric queries; mock network at boundary.

### Playwright e2e — MANDATORY for critical journeys inside the UI repo
Deterministic; role/label locators; no brittle antd internal class selectors.

### Cross-system scenarios
When a journey spans multiple services, the **QA agent** orchestrates execution and writes the report under hub `qa/`, while reusing this repo's Playwright scripts when applicable.

## 4. Quality

- Strict TS; no `any`.
- Server Components by default; `"use client"` only when required.
- ConfigProvider at app boundary.
- Loading / empty / error states on user-facing organisms/pages.
- Docstrings/JSDoc for non-obvious public APIs may be Portuguese when matching backend docstring policy; identifiers remain English.

## 5. Package Manager

Use yarn only. Commit `yarn.lock`. Never prefer npm/pnpm/bun as primary.

## 6. Checklist (new UI feature)

1. Search reuse (antd + existing atoms)  
2. Align versions (antd-first policy)  
3. Place components in correct atomic layer  
4. Feature module under `/src/features/<feature>`  
5. Thin route in `/app`  
6. Component tests  
7. Playwright coverage for critical path  
8. Lint/typecheck/test scripts green  
