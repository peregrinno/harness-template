---
agent: speckit.constitution
---

## Skills Reference

Before starting the planning workflow, check if relevant Cursor skills apply to the feature being planned.

# Project Constitution - Frontend Coding Principles and Standards

## 0. Official Stack (MANDATORY)

| Concern | Standard |
| --- | --- |
| Language | **TypeScript** (strict) |
| Package manager | **yarn** |
| UI library | **React** |
| Framework | **Next.js** (App Router by default) |
| Design system | **Ant Design (`antd`)** |

### Ant Design as Source of Truth
- **LLM / docs reference (MUST follow)**: https://ant.design/docs/react/introduce.md
- Prefer official Ant Design docs and patterns over ad-hoc UI implementations
- Use Ant Design components and theming before inventing custom primitives that duplicate `antd`
- `antd` ships built-in TypeScript types — **DO NOT** install `@types/antd`
- Prefer modular imports (ESM / tree-shaking). Do not load full UMD bundles in app code

### Version Alignment Policy (CRITICAL)
- **Always prioritize the latest stable `antd` version** when starting or upgrading a project
- After upgrading `antd`, **adjust the rest of the stack** (`react`, `react-dom`, `next`, and other libs) to versions compatible with that `antd` release
- Never pin an older `antd` just to avoid upgrading React/Next — upgrade peers instead
- When peer dependency conflicts appear, resolve by aligning versions toward the newest `antd`-compatible set
- Document any temporary compatibility exception in the PR/commit message; treat it as short-lived

## 1. Architecture Principles - Atomic Design + Reusability

### Core Concepts
- **Atomic Design**: UI is composed in layers — Atoms → Molecules → Organisms → Templates → Pages
- **Reusability First**: Prefer composing existing atoms/molecules over creating one-off UI
- **Ant Design primitives first**: Prefer `antd` components as atoms/building blocks before custom CSS-heavy elements
- **Separation of Concerns**: Presentational components stay dumb; containers/pages own data fetching and routing
- **Type Safety**: Public component APIs are typed; avoid `any`
- **Next.js boundaries**: Prefer Server Components by default; mark Client Components only when interactivity/browser APIs are required (`"use client"`)

### Composition Flow
```
[Atoms] -> [Molecules] -> [Organisms] -> [Templates] -> [Pages / Routes]
  (antd + tiny wrappers)     (feature UI)      (layouts)      (Next.js app/)
```

### Directory Structure

**Important**: Create the project structure before implementing features if it does not exist.

```
/
  /app                      # Next.js App Router (routes, layouts, pages)
    /(routes)/...
    layout.tsx
    page.tsx
    providers.tsx           # Client providers (ConfigProvider, QueryClient, etc.)

  /src
    /components
      /atoms                # Smallest UI units (Button wrappers, Icon, Text, Input wrappers)
      /molecules            # Combinations of atoms (SearchField, FormItemGroup)
      /organisms            # Complex UI sections (Header, UserTable, CheckoutForm)
      /templates            # Page-level layouts without route data
      /pages                # Optional page compositions if not colocated under /app

    /features               # Feature modules (domain UI + hooks + local types)
      /<feature-name>/
        /components
        /hooks
        /types
        /api                # Feature-scoped API clients / server actions wrappers

    /hooks                  # Shared reusable hooks
    /lib                    # Pure utilities (formatters, validators, mappers)
    /services               # Shared API/http clients
    /stores                 # Client state (only when needed)
    /types                  # Shared TypeScript types
    /theme                  # Ant Design theme tokens / ConfigProvider setup
    /styles                 # Global styles (minimal; prefer antd theme tokens)

  /tests
    /components             # Component tests (React Testing Library)
    /e2e                    # Playwright end-to-end tests
    /fixtures               # Mocks, MSW handlers, test data
```

### Atomic Design Layers

#### Layer 1: Atoms
**Location**: `/src/components/atoms`
**Purpose**: Smallest reusable UI pieces
**Rules**:
- Prefer wrapping or re-exporting `antd` primitives when project defaults are needed (size, variant, a11y)
- No feature/business logic
- No data fetching
- Highly reusable across features

#### Layer 2: Molecules
**Location**: `/src/components/molecules`
**Purpose**: Simple combinations of atoms with a clear UI responsibility
**Rules**:
- Compose atoms + light local UI state only
- Keep props explicit and typed
- Still free of feature/domain orchestration

#### Layer 3: Organisms
**Location**: `/src/components/organisms` or `/src/features/<feature>/components`
**Purpose**: Larger UI sections that may encode feature interactions
**Rules**:
- May use feature hooks
- Should still avoid route-level concerns (no `useRouter` leaking into deep presentational trees when avoidable)
- Prefer composing molecules/atoms instead of giant monolithic JSX

#### Layer 4: Templates
**Location**: `/src/components/templates`
**Purpose**: Layout skeletons (slots/regions) without fetching page data
**Rules**:
- Define structure (header/sidebar/content/footer)
- Receive content via children/slots/props

#### Layer 5: Pages / Routes
**Location**: `/app`
**Purpose**: Route entry points, data loading, composition of templates/organisms
**Rules**:
- Own Next.js routing, metadata, and data fetching boundaries
- Keep pages thin: wire data → organisms/templates
- Do not dump large UI trees directly into `page.tsx` — extract organisms/templates

### Reusability Principle
- Before creating a new component, search for an existing atom/molecule/organism/antd component
- Extract repeated UI into a lower atomic layer as soon as the same pattern appears twice with the same intent
- Shared UI belongs in `/src/components/*`; feature-specific UI stays under `/src/features/<feature>`
- Shared hooks/utilities belong in `/src/hooks` and `/src/lib`
- Props over duplication: expose configuration via typed props instead of copy-pasting variants
- Prefer composition (`children`, slots, render props when justified) over inheritance

### Dependency Direction
```
app (routes) -> features/organisms -> molecules -> atoms/antd
     \-> services/hooks/lib/types
```
- Lower layers must not import from higher layers (atoms must not import organisms/pages)
- Features may compose shared components; shared components must not import feature modules

## 2. Naming Conventions

### Files and Folders
- **Components**: `PascalCase` folders and files matching the component name
  - Examples: `UserTable/UserTable.tsx`, `SearchField.tsx`
- **Hooks**: `camelCase` starting with `use`
  - Examples: `useDebouncedValue.ts`, `useUserList.ts`
- **Utilities**: `camelCase`
  - Examples: `formatCurrency.ts`, `parseQuery.ts`
- **Types**: `PascalCase` for types/interfaces; prefer `type` aliases for unions, `interface` for object shapes when extending
- **Tests**:
  - Component: `ComponentName.test.tsx`
  - E2E: `feature-name.spec.ts` under `/tests/e2e`

### Components
- **Format**: PascalCase
- **Examples**: `PrimaryButton`, `OrderSummaryCard`, `BillingAddressForm`
- **Rules**:
  - Name by purpose, not by visual accident (`SubmitButton` > `BlueButton`)
  - Suffix wrappers clearly when useful (`AntdButton`, `AppModal`) — avoid noisy prefixes if unnecessary

### Props and Events
- Props: descriptive, boolean props prefixed with `is` / `has` / `should` when it improves clarity (`isLoading`, `hasError`)
- Event handlers: `onEventName` (`onSubmit`, `onChange`, `onOpenChange`)
- Avoid abbreviated prop names unless widely conventional (`id`, `key`)

### CSS / Styling
- Prefer Ant Design theme tokens and component APIs over one-off CSS
- If custom styles are required, colocate module CSS/styled solution with the component and keep scope local

## 3. Testing Strategy

### Component Tests - MANDATORY (for reusable UI and feature-critical UI)
- **Tooling**: React Testing Library (+ Jest or Vitest, whichever the project standardizes)
- **Scope**: Atoms/molecules with non-trivial behavior; organisms with interaction logic; shared hooks
- **Isolation**: Mock network/IO at the boundary; do not hit real backends
- **User-centric assertions**: Query by role/label/text; avoid testing implementation details
- **Naming Convention**: `describe('<ComponentName />')` + `it('should ...')`
- **Structure**: Arrange → Act → Assert
- **Examples**:
  - `it('should disable submit while loading')`
  - `it('should call onSubmit with form values')`
  - `it('should render validation message when email is invalid')`

### End-to-End Tests - Playwright (MANDATORY for critical user journeys)
- **Tooling**: **Playwright**
- **Location**: `/tests/e2e`
- **Scope**: Critical flows (auth, main CRUD journeys, checkout, navigation guards, regression-prone pages)
- **Rules**:
  - DO: Prefer `getByRole`, `getByLabel`, `getByText` locators
  - DO: Keep tests independent and deterministic
  - DO: Use fixtures/seeds or test doubles for backend when required by the project strategy
  - DO: Assert user-visible outcomes, not internal React state
  - DON'T: Use brittle selectors tied to CSS classnames from `antd` internals when roles/labels exist
  - DON'T: Mix e2e concerns into component unit tests

### What Not to Over-Test
- Do not snapshot every antd visual node
- Do not duplicate the same assertion in component and e2e unless risk justifies it
- Pure presentational wrappers with no logic may skip tests when coverage is better at molecule/organism level

## 4. SOLID and Frontend Design Principles

### Single Responsibility Principle (SRP)
- One component, one clear UI responsibility
- Split data-fetching containers from pure presentation when complexity grows

### Open/Closed Principle (OCP)
- Extend via props/composition/theme tokens instead of editing base atoms for each feature

### Liskov Substitution Principle (LSP)
- Variant components that share an interface must remain safely substitutable

### Interface Segregation Principle (ISP)
- Prefer narrow prop contracts; avoid “god props” objects with unused fields

### Dependency Inversion Principle (DIP)
- Feature UI depends on abstractions (hooks/services interfaces) where useful, not hard-coded transport details scattered in JSX

## 5. Code Quality Standards

### TypeScript
- Enable strict TypeScript settings for the project
- Type all public component props and hook return values
- Avoid `any`; prefer `unknown` + narrowing when input is truly unknown
- Prefer explicit return types on shared utilities and hooks

### Ant Design Usage
- Follow https://ant.design/docs/react/introduce.md
- Use `ConfigProvider` for theme, locale, and prefix configuration at the app boundary
- Prefer antd form/`Form.Item` patterns for forms unless there is a strong project reason otherwise
- Customize via theme tokens before overriding with deep CSS
- Keep accessibility roles/labels intact when wrapping antd components

### Next.js Standards
- Default to Server Components
- Add `"use client"` only when required (events, browser APIs, client-only libraries)
- Keep client islands small
- Use Next.js data fetching/caching patterns approved by the project
- Do not fetch inside deeply nested presentational atoms

### Documentation
- Document non-obvious component props and constraints
- Document shared hooks with expected inputs/outputs
- Prefer clear names over lengthy comments

### Error Handling and UX States
- Always design loading, empty, and error states for user-facing organisms/pages
- Surface actionable errors; never silently swallow failures in UI handlers

### Code Formatting
- Use the project formatter/linter (e.g. ESLint + Prettier) consistently
- Keep components focused; extract when files become hard to reason about

### Imports
- Prefer absolute imports configured by the project (`@/components/...`) when available
- Avoid deep relative `../../../` chains
- Do not import from higher atomic layers into lower ones

### Parameter and Props Clarity
- Prefer explicit props over positional ambiguity
- Destructure props in the function signature when it improves readability
- Avoid spreading unnamed prop bags across many layers without typed boundaries

### State Management
- Prefer local state and server data patterns first
- Introduce global client stores only when cross-route/shared client state is truly needed
- Do not duplicate server state in global stores without a clear reason

## 6. Key Reminders - Frontend Architecture

### UI Build Flow
```
1. Identify reusable pieces (prefer antd + existing atoms)
   ↓
2. Compose molecules/organisms
   ↓
3. Place feature logic in feature modules/hooks
   ↓
4. Wire through templates/pages (Next.js app/)
   ↓
5. Add component tests for interactive UI
   ↓
6. Cover critical journeys with Playwright e2e
```

**DO**:
- DO: Use TypeScript strictly
- DO: Use yarn for all package operations
- DO: Prefer latest stable `antd`, then align React/Next/other libs
- DO: Follow Atomic Design layering and dependency direction
- DO: Maximize reuse before creating new components
- DO: Use Ant Design as the default design system
- DO: Write component tests for reusable/interactive UI
- DO: Write Playwright e2e for critical flows
- DO: Keep pages thin and components focused
- DO: Keep Client Components minimal under Next.js App Router

**DON'T**:
- DON'T: Use npm/pnpm/bun as the primary package manager when yarn is the project standard
- DON'T: Install `@types/antd`
- DON'T: Invent parallel design systems that fight `antd`
- DON'T: Put business/data orchestration inside atoms
- DON'T: Import pages/features into atoms/molecules
- DON'T: Skip loading/empty/error states on user-facing views
- DON'T: Rely on brittle antd internal class selectors in tests
- DON'T: Generate CI/CD pipelines or IaC templates (SAM, CDK, Terraform, CloudFormation, GitHub Actions, etc.)

### Frontend Feature Checklist

When creating a new feature:
1. Check existing atoms/molecules/organisms and antd components for reuse
2. Confirm `antd` / React / Next versions are aligned (latest antd-first policy)
3. Create or extend typed components in the correct atomic layer
4. Place feature-specific logic under `/src/features/<feature>`
5. Wire the route in `/app` with a thin page/template composition
6. Add/adjust theme/locale via `ConfigProvider` only when needed
7. Write component tests for interactive behavior
8. Add/extend Playwright coverage for critical path changes
9. Verify no upward imports in the atomic hierarchy
10. Verify accessibility basics (labels, roles, keyboard where relevant)

## 7. Skills Reference

> **For Cursor Agents**: Refer to the appropriate Cursor skills for detailed implementation guides.

`.cursor/skills/` (or project/user skills) contains skills to assist coding tasks in Cursor IDE.

For Ant Design behavior and APIs, prioritize:
- https://ant.design/docs/react/introduce.md
- Official Ant Design component docs for the installed major version

## 8. CI/CD and Infrastructure-as-Code - OUT OF SCOPE

**IMPORTANT**: This constitution focuses exclusively on **application code**. Do NOT generate:

- DON'T: CI/CD pipeline configurations (GitHub Actions, GitLab CI, Jenkins, etc.)
- DON'T: Infrastructure-as-Code templates (AWS SAM, CDK, Terraform, CloudFormation, Pulumi, etc.)
- DON'T: Deployment scripts or Dockerfiles for deployment
- DON'T: Kubernetes manifests or Helm charts

**Rationale**: Infrastructure and deployment concerns are managed separately by dedicated teams and tooling. Focus on clean, testable application code only.

## 9. Development Environment Standards

### Package Manager - yarn (MANDATORY)
- **Tooling Policy**: Use **yarn** for all Node.js dependency operations in frontend projects
- **Rules**:
  - DO: Use `yarn`, `yarn add`, `yarn remove`, `yarn install`
  - DO: Commit the yarn lockfile (`yarn.lock`)
  - DO: Document setup in `README.md`
  - DON'T: Use `npm install` / `pnpm` / `bun` as the primary workflow for the project
  - DON'T: Commit `node_modules/`

### Common Commands
```bash
# Install dependencies
yarn install

# Add runtime dependency
yarn add antd

# Add dev dependency
yarn add -D @playwright/test

# Run app
yarn dev

# Run component/unit tests
yarn test

# Run Playwright e2e
yarn test:e2e
# or project-standard equivalent, e.g. yarn playwright test
```

### Dependency Management
- Declare dependencies in root `package.json`
- Keep app dependencies and test tooling clearly separated (`dependencies` vs `devDependencies`)
- **antd version policy**:
  - Upgrade/install the latest stable `antd` first
  - Then align `react`, `react-dom`, `next`, and related libs to compatible versions
  - Re-run component and Playwright suites after upgrades
- Example shape:
  ```json
  {
    "dependencies": {
      "antd": "latest-stable",
      "next": "aligned-version",
      "react": "aligned-version",
      "react-dom": "aligned-version"
    },
    "devDependencies": {
      "@playwright/test": "...",
      "@testing-library/react": "...",
      "typescript": "..."
    }
  }
  ```
- **Rules**:
  - DO: Prefer exact or lockfile-pinned installs for reproducibility
  - DO: Update lockfile when dependency changes occur
  - DO: Verify Ant Design peer compatibility after upgrades
  - DON'T: Leave the project on an old `antd` to avoid upgrading React/Next
  - DON'T: Add competing UI kits without an explicit architectural decision

### TypeScript / Next baseline
- Use TypeScript for all application source files (`.ts` / `.tsx`)
- Keep `tsconfig` strict and aligned with Next.js recommendations
- Prefer path aliases for cleaner imports

---

**Remember**: Reuse first, compose with Atomic Design, build on Ant Design, keep Next.js boundaries clean, and prove behavior with component tests plus Playwright e2e. Consistency is key!
