# Supply — visual & media kit for agents

Place brand assets and the visual identity guide here. Agents **must** consult this folder before inventing UI colors, logos, or illustrative imagery.

```text
harness/supply/
  README.md                 ← this file
  visual-identity.md        ← colors, typography, tone (edit for each project)
  assets/                   ← drop images/logos/icons used by UIs
    .gitkeep
```

## Rules for agents

1. Never invent a competing palette if `visual-identity.md` is filled.
2. Prefer files under `assets/` (reference by relative path from the hub) over generating placeholder art when a suitable asset exists.
3. When creating frontend work, sync Ant Design `ConfigProvider` tokens with the identity tokens documented in `visual-identity.md`.
4. If identity is still `TODO`, ask the human before shipping brand-critical screens.
5. Keep binary assets here (hub), not scattered across polyrepos — copy into `../repos/ui-*` only when the UI build needs them locally.
