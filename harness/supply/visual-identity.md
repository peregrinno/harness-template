# Identidade visual do projeto

> Preencha este arquivo no setup. O agente usa estas definições em UIs (`ui-*`), e-mails e materiais gerados.
> Deixe imagens em `harness/supply/assets/`.

## Marca

| Campo | Valor |
| --- | --- |
| Nome do produto | TODO |
| Nome curto / slug | TODO |
| Tagline | TODO |
| Tom de voz | TODO (ex.: técnico, direto, acolhedor) |

## Cores

Use hex. Mapeie para tokens Ant Design quando possível (`colorPrimary`, etc.).

| Token | Hex | Uso |
| --- | --- | --- |
| primary | `#1677ff` | CTA, links, foco |
| primary-hover | TODO | Hover do primary |
| secondary | TODO | Ações secundárias |
| background | `#ffffff` | Fundo de página |
| surface | `#f5f5f5` | Cards / painéis |
| text | `#141414` | Texto principal |
| text-muted | `#8c8c8c` | Texto auxiliar |
| success | `#52c41a` | Estados ok |
| warning | `#faad14` | Alertas |
| danger | `#ff4d4f` | Erros / destrutivo |
| border | `#d9d9d9` | Bordas |

### Gradientes / atmosfera (opcional)

- TODO (ex.: hero background)

## Tipografia

| Papel | Família | Fallback | Pesos | Notas |
| --- | --- | --- | --- | --- |
| Display / títulos | TODO | system-ui | 600–700 | Evitar Inter/Roboto/Arial como default se a marca definir outra |
| Corpo | TODO | system-ui | 400–500 | |
| Mono / código | TODO | ui-monospace | 400 | |

### Escala (rem ou px)

| Nível | Tamanho | Line-height |
| --- | --- | --- |
| H1 | TODO | TODO |
| H2 | TODO | TODO |
| Body | TODO | TODO |
| Caption | TODO | TODO |

## Espaçamento e forma

| Token | Valor |
| --- | --- |
| border-radius | TODO (ex.: 6px) |
| grid / gutter | TODO |
| max content width | TODO |

## Logo e assets

Liste arquivos em `assets/` e quando usá-los:

| Arquivo | Uso | Fundo preferido |
| --- | --- | --- |
| `assets/logo.svg` | TODO | claro/escuro |
| `assets/logo-mark.svg` | favicon / avatar | |
| `assets/...` | | |

## UI (Ant Design)

- Preferir componentes `antd` com tema via `ConfigProvider` alinhado à tabela de cores.
- Não inventar design system paralelo.
- Referência LLM: https://ant.design/docs/react/introduce.md

## Acessibilidade

- Contraste mínimo texto/fundo: WCAG AA (4.5:1 corpo).
- Não depender só de cor para status.

## Status

- [ ] Preenchido no setup
- [ ] Revisado pelo humano
- [ ] Tokens aplicados no(s) `ui-*`
