# WCS Studio — Design System Contract

**Status:** Locked (Phase 0). All later phases are measured against this document.

Scope: CSS, markup, tokens, spacing, colors, shapes, and on-screen text presentation.
Out of scope: behavior bugs, copy/voice rewrites, i18n extraction, accessibility audits.

The goal is one coherent visual language: a vivid pink→violet brand family, a
saturated indigo/violet surface system, and four bright semantic accents.

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
   rules apply. Using `text-body` therefore sets 1rem/1.6 type **and** the body
   text color. Combine with an explicit size token (e.g. `text-caption`) to override size.
5. **Carousel is already wired.** `phx-hook="Carousel"` drives prev/next, dots and a
   7s auto-advance. Phase 7 work is limited to deleting the dead commented-out
   `<script>` and making auto-advance respect reduced motion — not reimplementing it.
6. **Reduced-motion CSS already exists** in `assets/css/app.css` and is retained.
7. **`#user-avatar` is retained.** It wraps the avatar *and* the green status dot;
   only the pointless `phx-update="ignore"` attribute is removed in Phase 7.
8. **Master shadow hierarchy is the baseline (post-Phase 8 user decision).**
   The older master pattern card's depth is now the default for all cards and
   nested panels, expressed with brand-tinted shadow tokens. Radii are unchanged
   by this decision.

---

## 0.1 Palette

**Vibrancy pass (after Phase 8):** every token was re-saturated and the dark
surfaces were tinted indigo/violet instead of neutral slate. The pattern card's
master color choices were retained and expressed as tokens.

### Brand family (`theme.extend.colors.brand`)

| Token | Value | Purpose |
|---|---|---|
| `brand-from` | `#ff2d95` | vivid pink — canonical gradient start |
| `brand-to` | `#9d4dff` | vivid violet — canonical gradient end |
| `brand-hoverFrom` | `#e00078` | gradient hover start |
| `brand-hoverTo` | `#7d1fd4` | gradient hover end |
| `brand-lightFrom` | `#ff74c2` | text-on-dark highlight start |
| `brand-lightTo` | `#c98cff` | text-on-dark highlight end |
| `brand-soft` | `#ffa8de` | pink-300 — variations / chip text (master hue) |
| `brand-deepTo` | `#5b0fa8` | deepest gradient hover end |

### Semantic accents (`theme.extend.colors.accent`)

Each accent is a **two-hue pair**. The original master gradients were restored
first (blue→cyan, green→emerald, yellow→orange, red→pink), then saturated.
Templates never contain raw palette names — every hue lives here.

| Token | Value | Purpose |
|---|---|---|
| `accent-info` | `#2f6bff` | vivid blue — gradient start, links, info chips |
| `accent-infoTo` | `#00d5ff` | vivid cyan — gradient end |
| `accent-infoHoverFrom` | `#1f54e0` | hover start |
| `accent-infoHoverTo` | `#0098c9` | hover end |
| `accent-infoLight` | `#5ee7ff` | progress bar start |
| `accent-infoLightTo` | `#82b6ff` | progress bar end |
| `accent-success` | `#00e05a` | vivid green — gradient start, "learned" |
| `accent-successTo` | `#00b878` | vivid emerald — gradient end |
| `accent-successHoverFrom` | `#00c44d` | hover start |
| `accent-successHoverTo` | `#009a68` | hover end |
| `accent-successLight` | `#5affc4` | progress bar start |
| `accent-successLightTo` | `#6bff91` | progress bar end |
| `accent-warning` | `#ffd400` | vivid yellow — gradient start, "in progress" |
| `accent-warningTo` | `#ff7a00` | vivid orange — gradient end, master video hue |
| `accent-warningHoverFrom` | `#f5b800` | master yellow-500, description icon end |
| `accent-warningHoverTo` | `#e85d00` | hover end |
| `accent-warningLight` | `#ffcf3d` | progress bar start |
| `accent-warningLightTo` | `#ff9a4d` | progress bar end |
| `accent-amber` | `#ff9e00` | master amber-500, description icon start |
| `accent-danger` | `#ff3b4e` | vivid red — gradient start, delete/error |
| `accent-dangerTo` | `#ff4fa3` | vivid pink — gradient end |
| `accent-dangerHoverFrom` | `#e01f35` | hover start |
| `accent-dangerHoverTo` | `#d10a63` | hover end |
| `accent-dangerLight` | `#ff7791` | progress bar start |
| `accent-dangerLightTo` | `#ff79bd` | progress bar end |

Gradient rules:

- Accent gradients pair `from-accent-X` with `to-accent-XTo`; hover states use
  `hover:from-accent-XHoverFrom hover:to-accent-XHoverTo`; flash progress bars
  use `from-accent-XLight to-accent-XLightTo`.
- The single-hue `from-accent-X to-accent-X/80` form from Phase 1 is **retired**.
- The brand gradient is `from-brand-from to-brand-to`
  (vivid pink → vivid violet), with `brand-hoverFrom` / `brand-hoverTo` on hover.
- The user-profile ambient wash uses
  `from-accent-infoHoverFrom/20 via-accent-infoTo/20 to-brand-hoverTo/20`.

### Pattern card color identity (master hues)

Reverted on user request, expressed through tokens:

- Variations chip: `from-brand-from/20 to-accent-warningTo/20`,
  `text-brand-soft`, `border-brand-from/30`.
- Variations toggle: `text-brand-soft` for the active/expanded label.
- Description icon: `from-accent-amber to-accent-warningHoverFrom` (amber→yellow).
- Showcase Video icon: `from-accent-danger to-accent-warningTo` (red→orange).

### Text (`theme.extend.colors` top-level aliases)

| Token | Value | Purpose |
|---|---|---|
| `text-strong` | `#ffffff` | primary copy |
| `text-body` | `#e4e9f7` | secondary copy |
| `text-muted` | `#b4c0dc` | tertiary copy / labels |
| `text-subtle` | `#8b9bc0` | hints / meta |

### Borders (`theme.extend.borderColor`)

| Token | Value | Purpose |
|---|---|---|
| `border-subtle` | `#3a2f60` | low-emphasis separators |
| `border-strong` | `#51447f` | high-emphasis separators |

These are independent of the text tokens: `border-strong` is a violet gray,
while `text-strong` is white. Do not derive one from the other.

### Surfaces (`theme.extend.colors.surface`)

| Token | Value |
|---|---|
| `surface-base` | `#140f2e` |
| `surface-raised` | `#211a40` |
| `surface-muted` | `#352b57` |

The overscroll background in `assets/css/app.css` matches `surface-base`.

### Hero ambient (`theme.extend.colors.hero`)

| Token | Value | Purpose |
|---|---|---|
| `hero-ambient-1` | `#6a1fb5` | vivid purple wash in the hero |
| `hero-ambient-2` | `#b31769` | vivid pink wash in the hero |

These are the *only* permitted `*-900`-style palette references, and they are tokenized.

### Shadows (`theme.extend.boxShadow`)

The master pattern card defines the depth hierarchy. Its Tailwind scale shadows
are re-expressed as brand-tinted tokens; raw `shadow-lg` / `shadow-xl` /
`shadow-2xl` are not used in templates.

| Token | Basis | Use |
|---|---|---|
| `shadow-panel` | master `shadow-lg` geometry, violet + pink at low alpha | nested panels, icon badges, inset controls |
| `shadow-raised` | violet + pink at low alpha, slightly deeper than `panel` | buttons and small floating elements |
| `shadow-card` | master `shadow-xl` geometry, violet + pink at low alpha | outer cards and panels at rest |
| `shadow-lift` | master `shadow-2xl` geometry, deep violet at 60% | `hover:` lift on outer cards |
| `shadow-glow` | vivid pink at 70% | primary CTA emphasis |

Outer cards use `shadow-card` with `hover:shadow-lift`; nested panels use
`shadow-panel`. Radius stays at `rounded-lg` for cards and `rounded-md` for inner
panels. The `pulse-glow` keyframes use the same vivid pink/violet pair.

### Enforcement

No `.heex` or component file may reference raw palettes directly:
`purple-*`, `pink-*`, `blue-*`, `cyan-*`, `orange-*`, `amber-*`, `yellow-*`,
`emerald-*`, `green-*`, `red-*`, `slate-*`, `zinc-*`, `gray-*`.

Neutral white/black utilities (`bg-white/10`, `border-white/10`, `bg-black`
scrims, `ring-white`) remain permitted where a literal neutral is intentional.
The QR-code container keeps `bg-white` so the code scans correctly.

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
      search-expanded variations; variations chip is pink→orange with pink-soft
      text, description icon is amber→yellow, video icon is red→orange
- [ ] Vibrancy — vivid pink/violet brand, blue→cyan / green→emerald /
      yellow→orange / red→pink gradients, violet-tinted dark surfaces, bright
      secondary text; no gray/bland panels remain
- [ ] Depth — outer cards use `shadow-card` and lift to `shadow-lift` on hover;
      nested panels and icon badges use `shadow-panel`; radii remain unchanged
- [ ] Admin / Lessons — shared header/meta/expanded/footer structure
- [ ] All modals — aligned headers/footers, identical cancel buttons, visible
      focus rings
- [ ] Locale switcher — desktop/mobile match, no empty header, active locale clear
- [ ] Nav — role reads "Admin" / "Member"
