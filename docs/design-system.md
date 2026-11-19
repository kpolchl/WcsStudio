# WCS Studio — Design System (baseline contract)

**Status:** locked. The `/patterns` page (`pattern/1` in `core_components.ex`, its
LiveView, and the surrounding layouts) is the reference standard. Every other
page in `WcsStudioWeb` is refactored to match it — never the other way around.

This document is the **single source of truth** for visual tokens. Every future
PR is checked against it. The full list of current deviations is in
[`ui-audit.md`](ui-audit.md).

Non-goals (explicitly out of scope): changing the patterns page itself, new
features/themes, changing the typography scale or colour palette, and
LiveView logic refactors. Corrections to the patterns page, if genuinely
needed, land in a separate PR that updates this document first.

---

## 1. Colour tokens

| Token | Value | Usage |
|---|---|---|
| `surface-card` | `bg-slate-800/50` | Main card background |
| `surface-inner` | `bg-slate-700/30` | Inner nested cards |
| `border-card` | `border border-slate-700/50` | Main card border |
| `border-inner` | `border border-slate-600/50` | Inner card border |
| `border-hover` | `hover:border-pink-500/30` | Card hover accent |
| `text-primary` | `text-white` | Headings |
| `text-body` | `text-slate-300` | Body copy |
| `text-muted` | `text-slate-400` | Secondary labels |
| `text-subtle` | `text-slate-500` | Micro text / hints |
| `accent-primary` | `from-pink-500 to-purple-500` | Primary gradient (buttons, icons) |
| `accent-info` | `from-blue-500 to-cyan-600` | Update / info actions |
| `accent-danger` | `from-red-500 to-pink-600` | Delete / destructive |
| `accent-success` | `from-green-500 to-emerald-600` | Confirmed / learned |
| `accent-warn` | `from-yellow-400 to-yellow-500` | In-progress |
| `accent-info-icon` | `from-amber-500 to-yellow-500` | Info / description icon containers |

## 2. Radius tokens

| Token | Class | Usage |
|---|---|---|
| Card radius | `rounded-2xl` | Main cards |
| Inner radius | `rounded-xl` | Inner cards, icon containers, inputs |
| Control radius | `rounded-lg` | Buttons, inputs, small chips |
| Pill radius | `rounded-full` | Badges, avatars |

## 3. Shadow tokens

| Token | Class | Usage |
|---|---|---|
| Card shadow | `shadow-xl` | Main cards |
| Inner shadow | `shadow-lg` | Inner cards, buttons on hover |
| Modal shadow | `shadow-2xl` | Modals, hover-lifted cards |
| Coloured glow | `shadow-pink-500/25` / `shadow-red-500/25` / `shadow-blue-500/25` | Match the gradient of the button on hover |

## 4. Spacing

| Token | Class | Usage |
|---|---|---|
| Card padding | `p-6` | Outer card |
| Inner padding | `p-4` | Inner nested cards |
| Card inner gap | `gap-4`, `mb-4` | Between blocks inside a card |
| Button padding | `py-2 px-4` | **Baseline for all action buttons** |
| Button icon gap | `mr-2` | Icon → label spacing |

## 5. Typography

| Role | Class |
|---|---|
| Page heading | `text-3xl font-bold text-white` + `bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent` |
| Section heading | `text-2xl font-bold text-white` |
| Card title | `text-xl font-bold text-white` |
| Body | `text-base text-slate-300 leading-relaxed` |
| Label | `text-sm text-slate-400` |
| Hint | `text-xs text-slate-500` |

## 6. Icon container gradients (by category)

| Category | Gradient |
|---|---|
| Info / description | `from-amber-500 to-yellow-500` |
| Video / media | `from-red-500 to-orange-500` |
| General / default | `from-pink-500 to-purple-500` |
| Icon container shell | `w-10 h-10 rounded-xl flex items-center justify-center shadow-lg` |

Inline icon containers use `w-10 h-10`; header badges use `w-12 h-12`.

## 7. Transitions

| Interaction | Class |
|---|---|
| Cards / buttons | `transition-all duration-300` |
| Nav links & micro-interactions | `duration-200` |
| Card hover lift | `hover:-translate-y-0.5` |
| Card hover scale (icon badge) | `group-hover:scale-110` |
| Card hover glow | `hover:shadow-lg` + matching `shadow-<color>/25` |

## 8. Badges / pills

```heex
# Primary badge
bg-gradient-to-r from-purple-500/20 to-pink-500/20 text-purple-300
border border-purple-500/30

# Variation badge
bg-gradient-to-r from-pink-500/20 to-orange-500/20 text-pink-300
border border-pink-500/30

# Shared
px-2 sm:px-3 py-1 rounded-full text-xs font-medium
```

## 9. Component API

All shared components live in `WcsStudioWeb.CoreComponents`. Templates must not
hand-write gradient buttons, card shells, badges, or icon containers — use these
instead.

| Component | Key options |
|---|---|
| `<.btn>` | `variant`: `primary`, `info`, `danger`, `success`, `warn`, `ghost`; `size`: `sm`, `md`, `lg`; `icon`: Font Awesome icon name (no `fa-` prefix). Renders a link when `href` is supplied, otherwise a `<button>`. |
| `<.card>` | `padding`: `sm`, `md`, `lg`, `none`; `hover`: boolean. |
| `<.badge>` | `variant`: `primary`, `variation`, `success`, `danger`, `muted`; `icon`: optional Font Awesome icon name. |
| `<.icon_badge>` | `gradient`: `primary`, `info`, `warn`, `danger`, `success`; `size`: `sm`, `md`, `lg`; `icon` (required). |
| `<.modal>`, `<.form_modal>`, `<.confirm_modal>` | Dark-themed dialogs built on the same tokens. |
| `<.pattern>` | Reference component — the baseline. Do not change without updating this document. |

### Variant → token mapping

- `btn` variants: `primary` → `accent-primary`, `info` → `accent-info`,
  `danger` → `accent-danger`, `success` → `accent-success`, `warn` →
  `accent-warn`, `ghost` → `surface-card` + `border-inner`.
- `btn` sizes: `sm` → `py-2 px-3 text-sm`, `md` → `py-2 px-4` (baseline),
  `lg` → `py-3 px-6` (large CTA; matches the patterns page CTA).
- `badge` variants: `primary` and `variation` are the two pill recipes in §8;
  `success`, `danger`, and `muted` reuse the same shell with green/red/slate
  tints.
- `icon_badge` gradients: `primary` → general (`from-pink-500 to-purple-500`),
  `info` → description (`from-amber-500 to-yellow-500`), `warn` →
  `from-yellow-400 to-yellow-500`, `danger` → video/media
  (`from-red-500 to-orange-500`), `success` → `from-green-500 to-emerald-600`.
- `icon_badge` sizes: `sm` → `w-8 h-8 rounded-lg`, `md` → `w-10 h-10 rounded-xl`,
  `lg` → `w-12 h-12 rounded-xl`.
