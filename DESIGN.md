# WCS Studio — Design System Contract

**Status:** Locked (Phase 0). All later phases are measured against this document.

Scope: CSS, markup, tokens, spacing, colors, shapes, and on-screen text presentation.
Out of scope: behavior bugs, copy/voice rewrites, i18n extraction, accessibility audits.

The goal is one coherent visual language: a pink→purple brand family, a dark utility
surface system, and four semantic accents derived from that family.

---

## Decisions recorded during Phase 0

These resolve conflicts between the remediation plan and the state of the codebase.

1. **Radius scale (user decision): keep four steps.**
   The plan proposes exactly three radii (`md`, `lg`, `full`) and forbids `sm`/`xl`.
   We keep `sm = 4px`, `md = 6px`, `lg = 8px`, `xl = 12px` from the earlier refactor,
   plus `full`. `sm` and `xl` are therefore **documented exceptions**, not violations.
   Still forbidden: `rounded-none`, `rounded-2xl`, `rounded-3xl`.
2. **Small-button padding (user decision): `py-2`, not `py-1.5`.**
   Phase 2.3 of the plan specifies `px-3 py-1.5` for `:sm`, but `1.5` (6px) is off the
   4px spacing scale. Use `px-3 py-2` (12px / 8px).
3. **Visual snapshots (user decision): skip.**
   No browser automation is available in this environment. Phase 8.2's manual
   checklist is the verification mechanism; `docs/visuals/` is not produced.
4. **`text-body` is intentionally both a font-size and a color token.**
   Tailwind emits both `.text-body { font-size… }` and `.text-body { color… }`; both
   rules apply. Using `text-body` therefore sets 1rem/1.6 type **and** slate-300
   color. Combine with an explicit size token (e.g. `text-caption`) to override size.
5. **Carousel is already wired.** `phx-hook="Carousel"` drives prev/next, dots and a
   7s auto-advance. Phase 7 work is limited to deleting the dead commented-out
   `<script>` and making auto-advance respect reduced motion — not reimplementing it.
6. **Reduced-motion CSS already exists** in `assets/css/app.css` and is retained.
7. **`#user-avatar` is retained.** It wraps the avatar *and* the green status dot;
   only the pointless `phx-update="ignore"` attribute is removed in Phase 7.

---

## 0.1 Palette

### Brand family (`theme.extend.colors.brand`)

| Token | Value | Purpose |
|---|---|---|
| `brand-from` | `#ec4899` | canonical gradient start (pink-500) |
| `brand-to` | `#a855f7` | canonical gradient end (purple-500) |
| `brand-hoverFrom` | `#db2777` | gradient hover start |
| `brand-hoverTo` | `#9333ea` | gradient hover end |
| `brand-lightFrom` | `#f472b6` | text-on-dark highlight start |
| `brand-lightTo` | `#c084fc` | text-on-dark highlight end |
| `brand-deepTo` | `#7e22ce` | deepest gradient hover end |

### Semantic accents (`theme.extend.colors.accent`)

Each accent is a **two-hue pair**. The original gradients were restored after
the value-only color rollback: blue→cyan, green→emerald, yellow→orange and
red→pink. Templates never contain raw palette names — every hue lives here.

| Token | Value | Purpose |
|---|---|---|
| `accent-info` | `#3b82f6` | blue-500 — gradient start, links, info chips |
| `accent-infoTo` | `#06b6d4` | cyan-500 — gradient end |
| `accent-infoHoverFrom` | `#2563eb` | blue-600 — hover start |
| `accent-infoHoverTo` | `#0e7490` | cyan-700 — hover end |
| `accent-infoLight` | `#22d3ee` | cyan-400 — progress bar start |
| `accent-infoLightTo` | `#60a5fa` | blue-400 — progress bar end |
| `accent-success` | `#22c55e` | green-500 — gradient start, "learned" |
| `accent-successTo` | `#059669` | emerald-600 — gradient end |
| `accent-successHoverFrom` | `#16a34a` | green-600 |
| `accent-successHoverTo` | `#047857` | emerald-700 |
| `accent-successLight` | `#34d399` | emerald-400 — progress bar start |
| `accent-successLightTo` | `#4ade80` | green-400 — progress bar end |
| `accent-warning` | `#facc15` | yellow-400 — gradient start, "in progress" |
| `accent-warningTo` | `#f97316` | orange-500 — gradient end |
| `accent-warningHoverFrom` | `#eab308` | yellow-500 |
| `accent-warningHoverTo` | `#ea580c` | orange-600 |
| `accent-warningLight` | `#fbbf24` | amber-400 — progress bar start |
| `accent-warningLightTo` | `#fb923c` | orange-400 — progress bar end |
| `accent-danger` | `#ef4444` | red-500 — gradient start, delete/error |
| `accent-dangerTo` | `#ec4899` | pink-500 — gradient end |
| `accent-dangerHoverFrom` | `#dc2626` | red-600 |
| `accent-dangerHoverTo` | `#be185d` | pink-700 |
| `accent-dangerLight` | `#fb7185` | rose-400 — progress bar start |
| `accent-dangerLightTo` | `#f472b6` | pink-400 — progress bar end |

Gradient rules:

- Accent gradients pair `from-accent-X` with `to-accent-XTo`; hover states use
  `hover:from-accent-XHoverFrom hover:to-accent-XHoverTo`; flash progress bars
  use `from-accent-XLight to-accent-XLightTo`.
- The single-hue `from-accent-X to-accent-X/80` form from Phase 1 is **retired**.
  It was only a placeholder for the original two-hue pairs.
- The brand gradient is unchanged: `from-brand-from to-brand-to`
  (pink-500 → purple-500), with `brand-hoverFrom` / `brand-hoverTo` on hover.
- The user-profile ambient wash restores blue→cyan→purple using
  `from-accent-infoHoverFrom/20 via-accent-infoTo/20 to-brand-hoverTo/20`.

### Text (`theme.extend.colors` top-level aliases)

| Token | Value | Purpose |
|---|---|---|
| `text-strong` | `#ffffff` | primary copy |
| `text-body` | `#cbd5e1` | secondary copy (slate-300) |
| `text-muted` | `#94a3b8` | tertiary copy / labels (slate-400) |
| `text-subtle` | `#64748b` | hints / meta (slate-500) |

### Borders (`theme.extend.borderColor`)

| Token | Value | Purpose |
|---|---|---|
| `border-subtle` | `#334155` | low-emphasis separators (slate-700) |
| `border-strong` | `#475569` | high-emphasis separators (slate-600) |

These are independent of the text tokens: `border-strong` is slate-600, while
`text-strong` is white. Do not derive one from the other.

### Surfaces (`theme.extend.colors.surface`)

| Token | Value |
|---|---|
| `surface-base` | `#0f172a` |
| `surface-raised` | `#1e293b` |
| `surface-muted` | `#334155` |

### Hero ambient (`theme.extend.colors.hero`)

| Token | Value | Purpose |
|---|---|---|
| `hero-ambient-1` | `#4c1d95` | purple-900 wash in the hero |
| `hero-ambient-2` | `#831843` | pink-900 wash in the hero |

These are the *only* permitted `*-900` palette references, and they are tokenized.

### Enforcement

No `.heex` or component file may reference these raw palettes directly:
`purple-*`, `pink-*`, `blue-*`, `cyan-*`, `orange-*`, `amber-*`, `yellow-*`,
`emerald-*`, `green-*`, `red-*`.

`slate-*` is permitted only where no token exists (e.g. opacity modifiers on
surfaces) and must be migrated when a token is added. `gray-*` and `zinc-*` are
likewise non-tokenized and should be migrated opportunistically.

---

## 0.2 Radii

| Token | Value | Use |
|---|---|---|
| `rounded-md` | 6px | icon containers, inputs, inner info boxes, close buttons |
| `rounded-lg` | 8px | cards, buttons, modals, panels |
| `rounded-sm` | 4px | **documented exception** — legacy compact controls |
| `rounded-xl` | 12px | **documented exception** — legacy large surfaces |
| `rounded-full` | browser default | pills, badges, avatars, dots |

Forbidden: `rounded-none`, `rounded-2xl`, `rounded-3xl`.
New code should prefer `md`/`lg`/`full`; migrations of `sm`/`xl` are optional, not required.

---

## 0.3 Spacing scale

4px base. Allowed Tailwind scale indices:

`0, 1, 2, 3, 4, 6, 8, 12, 16, 20, 24`

Named section rhythm (both multiples of 4px):

| Token | Value |
|---|---|
| `section` | `5rem` (80px) |
| `section-sm` | `4rem` (64px) |

Forbidden: `py-2.5`, `px-5`, `py-3.5`, `px-3.5`, `py-1.5`, `gap-5`, `gap-7`,
`mt-1.5`, `mb-1.5`, `w-3.5`, `h-3.5`, and any other fractional scale step.
Note the Phase 2 small-button exception was resolved to `px-3 py-2`.

---

## 0.4 Typography scale

Allowed text tokens (`theme.extend.fontSize`):

| Token | Size | Use |
|---|---|---|
| `text-display` | 3.5rem | home hero headline |
| `text-display-sm` | 3rem | page headers |
| `text-heading` | 1.875rem | section titles |
| `text-heading-sm` | 1.25rem | card titles, empty-state titles |
| `text-lead` | 1.25rem | intro paragraphs |
| `text-body` | 1rem | body copy (also sets the body text color) |
| `text-caption` | 0.875rem | hints, meta |
| `text-button` | 0.875rem | control labels (new) |
| `text-pill` | 0.75rem | badges and chips (new) |

Direct `text-sm`, `text-xs`, `text-2xl`, `text-3xl`, etc. are forbidden in templates;
control sizing goes through `text-button` / `text-pill`.

---

## 0.5 Motion

- Keep `animate-[slideUp_…]` and `animate-[fadeIn_…]` in the hero.
- `assets/css/app.css` already contains a `@media (prefers-reduced-motion: reduce)`
  block that collapses animation/transition durations and forces animated-in content
  to `opacity: 1`. Retain it; do not duplicate it per element.
- The carousel's 7s auto-advance must skip or pause when the user prefers reduced
  motion (Phase 7). Manual prev/next/dot interaction remains available.

---

## Phase gates

Each phase is committed independently and must pass its own acceptance criteria
before the next begins:

- [x] **Phase 0** — this document + tokens committed; no template edits
- [x] Phase 1 — palette sweep, zero forbidden palette hits
- [x] Phase 2 — all actions use `<.button>` variants
- [x] Phase 3 — confirm/form modals share chrome
- [x] Phase 4 — pattern card corners and panel radii
- [x] Phase 5 — text tokens, label/value pairs, `hands_label`, `role_label`
- [x] Phase 6 — spacing-scale hygiene
- [x] Phase 7 — micro-details
- [x] Phase 8 — grep guardrails (`mix wcs_studio.design_guard`, CI job)
      and manual checklist below

### Phase 8 notes

- **Visual snapshots skipped** by user decision; no browser automation was
  available. The manual checklist is the verification mechanism.
- **Intentional sub-scale utilities:** `p-0.5` (avatar/thumbnail ring) and
  `h-0.5` (progress bar height) are decorative dimensions, not layout spacing.
- **Deferred debt:** raw `text-sm`/`text-xs`/`text-2xl`… font-size utilities
  remain in templates. The semantic size tokens (`text-display`, `text-heading`,
  `text-lead`, `text-body`, `text-caption`, `text-button`, `text-pill`) are
  defined and used for primary text nodes; a full size migration is not part of
  the remediation phases and is tracked separately.
- **Home hero flush check:** `<main class="py-section-sm">` adds 4rem of top
  padding and the hero uses `-mt-16` (-4rem), so they cancel exactly and the
  carousel sits flush under the nav at all widths. No layout variant needed.

### Manual checklist (run before merging)

Desktop 1440 / tablet 768 / phone 390:

- [ ] Home — hero text, brand-gradient stat icons, CTA button variants
- [ ] Dance types — cards/chips/CTAs match home card style
- [ ] Patterns — variations panel corners, `Left / Left` labels, status colors,
      search-expanded variations
- [ ] Admin / Lessons — shared header/meta/expanded/footer structure
- [ ] All modals — aligned headers/footers, identical cancel buttons, visible
      focus rings
- [ ] Locale switcher — desktop/mobile match, no empty header, active locale clear
- [ ] Nav — role reads "Admin" / "Member"
