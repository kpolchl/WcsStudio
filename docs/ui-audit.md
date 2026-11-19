# UI consistency audit — deviations from the `/patterns` baseline

Baseline contract: [`design-system.md`](design-system.md). Every hit from the
audit greps is accounted for below. `en/` = entries from the plan's known
offenders; the rest are new findings from the full scan of `lib/wcs_studio_web/`.

## 1. Known offenders (from the improvement plan)

| # | File | Location | Problem | Baseline |
|---|---|---|---|---|
| 1 | `core_components.ex` | `confirm_modal/1` (~L180) | Uses **light theme**: `text-slate-900`, `text-slate-600`, `bg-slate-200` — clashes with dark baseline | `text-white`, `text-slate-300`, `bg-slate-700/50 border border-slate-600/50` |
| 2 | `core_components.ex` | `confirm_modal/1` | Button padding `py-2.5 px-6` | `py-2 px-4` |
| 3 | `core_components.ex` | `form_modal/1` submit button | `py-2.5 px-5 text-sm` | `py-2 px-4` |
| 4 | `home_html/index.html.heex` | Feature cards | Uses raw `<a href="/...">` instead of `<.link href={~p"/..."}>` | `<.link>` + verified routes |
| 5 | `home_html/index.html.heex` | Feature cards | Hover lift `hover:-translate-y-2` | `hover:-translate-y-0.5` |
| 6 | `home_html/index.html.heex` | Feature cards | `hover:shadow-2xl` without coloured glow | `hover:shadow-lg hover:shadow-pink-500/25` |
| 7 | `home_html/index.html.heex` | Stats section icons | `w-20 h-20` icon containers | `w-10 h-10` for inline, `w-12 h-12` for header badges |
| 8 | `home_html/index.html.heex` | CTA buttons | `px-8 py-4` | `py-2 px-4` (or define an explicit "large CTA" variant) |
| 9 | `home_html/index.html.heex` | Card titles | `text-xl font-bold text-white` — OK but no gradient treatment | Match patterns page heading treatment where appropriate |
| 10 | `layouts/app.html.heex` | Nav "Register" button | `px-4 py-2` — **matches baseline** | keep |
| 11 | `layouts/app.html.heex` | User menu avatar | `size-8` and `size-12` | Consolidate to a token (`size-8` header, `size-12` in dropdown) |
| 12 | `layouts/app.html.heex` | User menu role badge | `bg-gradient-to-r from-pink-500/20 to-purple-500/20 text-pink-300 border border-pink-500/30` | Matches baseline pill — keep |
| 13 | `layouts/root.html.heex` | Inline `<style>` overrides `body` bg | Global `html { background: #f0f0f0 }` shows through on overscroll | Remove and rely on `body` gradient |
| 14 | `layouts/app.html.heex` | `<main class="flex-1 py-16">` adds `py-16` | Home page hero uses `mt-[-128px]` to pull up under nav | Standardize: remove `py-16` from main; each page defines its own top padding |
| 15 | `user_session_controller.ex` | Flash messages `"Welcome back!"` etc. | Hard-coded English, not `gettext` | Wrap in `gettext(...)` |
| 16 | `error_html.ex` / `error_json.ex` | Default plain-text error pages | No styled 404/500 templates | Build error templates using baseline card styling |

## 2. Audit grep results

### 2.1 Non-baseline button/input padding (`py-2.5|py-3|py-4|px-5|px-6|px-8`) — 75 hits

| File | Lines | Notes |
|---|---|---|
| `live/user_forgot_password_live.ex` | 9, 21 | L21 gradient btn `py-3 px-6 rounded-lg` |
| `live/user_registration_live.ex` | 10, 46 | L46 gradient btn `py-3 px-6 rounded-lg` |
| `live/user_login_live.ex` | 7, 39 | L39 gradient btn `py-3 px-6 rounded-lg` |
| `live/user_reset_password_live.ex` | 9, 33 | L33 gradient btn `py-3 px-6 rounded-lg` |
| `live/blog_live.ex` | 67 | gradient CTA `py-3 px-6 rounded-lg` |
| `components/layouts/root.html.heex` | 30 | `px-4 py-4` footer |
| `live/practice_live.ex` | 158, 211 | L158 dropdown `py-3`; L211 `py-4 px-6` gradient btn |
| `live/user_profile.ex` | 70, 298 | L70 `px-2 sm:px-6 lg:px-8 -py-8` (invalid `-py-8`); L298 `py-3 px-8 rounded-xl` gradient btn |
| `live/connect_live.ex` | 122, 133, 144, 151 | L122/133/144 inputs `py-3`; L151 `px-6 py-3 rounded-xl` gradient btn |
| `live/user_settings_live.ex` | 108, 135, 182 | L135/182 `py-3 px-6 rounded-lg` gradient btns |
| `live/blog_post_live.ex` | 148, 155, 162, 170, 177, 186, 270, 277, 290 | inputs `px-4 py-3`; L177 `px-6 py-3` green→blue btn; L186 `px-6 py-3` slate btn; L277 `px-6 py-3` purple→pink btn; L290 `px-6 py-2` purple btn |
| `live/dance_types_live.ex` | 99, 117, 133, 149, 165 | L99 CTA `py-3 px-6`; L117/133/149/165 tab btns `px-6 py-3 rounded-xl` |
| `live/patterns_live.ex` | 357, 374, 433 | L357 CTA `py-3 px-6`; L374 dropdown `py-3`; L433 search input `py-3` |
| `components/locale_switcher.ex` | 51, 92 | `px-4 py-3`, `px-3 py-3` |
| `live/lessons_live.ex` | 279, 294, 314 | L279 CTA `py-3 px-6`; L294/314 tab btns `px-6 py-2 rounded-lg` |
| `controllers/home_html/index.html.heex` | 13, 31, 50, 87, 316, 358, 367, 372 | L13/31/50 `px-8 md:px-16 lg:px-24`; L87/316/358 `md:px-8`; L367 `px-8 py-4` gradient btn; L372 `px-8 py-4` slate btn |
| `components/layouts/app.html.heex` | 112, 143, 150, 165, 251, 257, 264, 271, 277, 283 | L143/150/165 `py-2.5`; L251–283 `px-3 py-3`; L112 `py-3` |
| `components/core_components.ex` | 162, 171, 301, 308, 416, 434, 527, 650, 759, 1153, 1202, 1324, 1332, 1367 | L162/171 `py-2.5 px-6`; L301/308 `px-5 py-2.5`; L759 `py-3 px-6 rounded-xl`; L1153/1202 `px-4 py-3` |

### 2.2 Hard-coded internal links (`href="/"`) — 5 hits

| File | Line | Value |
|---|---|---|
| `components/layouts/root.html.heex` | 34 | `href="/"` (root layout logo link) |
| `controllers/home_html/index.html.heex` | 100 | `href="/dance_types"` |
| `controllers/home_html/index.html.heex` | 153 | `href="/patterns"` |
| `controllers/home_html/index.html.heex` | 206 | `href="/admin/lessons"` |
| `controllers/home_html/index.html.heex` | 259 | `href="/blog"` |

### 2.3 Raw light/neutral palette (`slate-900\b|slate-600\b|bg-slate-200|text-gray-`) — 81 hits

| File | Lines | Notes |
|---|---|---|
| `live/user_profile.ex` | 42, 55, 290 | L42 `text-gray-400`; L55 `bg-gray-500/20 text-gray-300 border-gray-500/30`; L290 `text-slate-600` icon |
| `live/practice_live.ex` | 158, 221, 264 | `border-slate-600/50` |
| `live/patterns_live.ex` | 374, 435, 538, 600 | baseline `border-slate-600/50`; L538/600 `border-slate-600/40` |
| `live/lessons_live.ex` | 382, 390, 401, 409, 445, 453, 464, 472 | `border-slate-600` (full opacity vs baseline `/50`) + `bg-slate-800/50` |
| `live/dance_types_live.ex` | 186, 206, 231 | `border-slate-600/50`; L206 `from-slate-900/70` |
| `live/connect_live.ex` | 122, 133, 144 | `bg-slate-900/50 border-slate-600` (full) |
| `live/blog_post_live.ex` | 148, 155, 162, 170, 186, 270, 286, 301, 308 | `bg-slate-900/50 border-slate-600`; L186 `bg-slate-600 hover:bg-slate-700`; L301 `text-slate-600` icon |
| `components/layouts/root.html.heex` | 26, 29 | L26 `from-slate-900 via-purple-900 to-slate-900`; L29 `bg-slate-900/80` |
| `components/core_components.ex` | 60, 98, 148, 153, 162, 243, 268, 301, 308, 416, 434, 456, 531, 672, 681, 690, 699, 717, 796, 1128, 1131, 1152, 1153, 1154, 1177, 1178, 1179, 1201, 1202, 1203 | L148 `text-slate-900`, L153 `text-slate-600`, L162 `bg-slate-200` (light modal); L1128–1203 form borders `border-slate-600`/`bg-slate-800/50` |
| `components/layouts/app.html.heex` | 1, 100, 240 | L1 `bg-slate-900/80`; L100 `border-slate-900`; L240 `bg-slate-900/95` |
| `controllers/home_html/index.html.heex` | 9, 27, 46, 101, 117, 143, 154, 170, 196, 207, 223, 249, 260, 276, 302 | hero gradients `from-slate-900`/`to-slate-900`; card borders `border-slate-600/50`; L117/170/223/276 `from-slate-900/70` |

### 2.4 Missing gettext in controllers — 12 hits

| File | Line | Value | Disposition |
|---|---|---|---|
| `controllers/error_json.ex` | 12, 17 | comments | false positive |
| `controllers/error_html.ex` | 20 | comment | false positive |
| `controllers/home_html/index.html.heex` | 3 | `phx-hook="Carousel"` | false positive |
| `controllers/home_html/index.html.heex` | 16, 53 | `"Elevated"` / `"Journey"` | false positive (multi-line `gettext(`) |
| `controllers/home_html/index.html.heex` | 123 | `alt="Dance styles illustration"` | untranslated attribute |
| `controllers/user_session_controller.ex` | 8 | `"Account created successfully!"` | **fix (3.8)** |
| `controllers/user_session_controller.ex` | 14 | `"Password updated successfully!"` | **fix (3.8)** |
| `controllers/user_session_controller.ex` | 18 | `"Welcome back!"` | **fix (3.8)** |
| `controllers/user_session_controller.ex` | 31 | `"Invalid email or password"` | **fix (3.8)** |
| `controllers/user_session_controller.ex` | 39 | `"Logged out successfully."` | **fix (3.8)** |

### 2.5 Radius mismatch (`rounded-md|rounded-sm|rounded-none`) — 1 hit

| File | Line | Value |
|---|---|---|
| `components/layouts/app.html.heex` | 198 | `p-2 rounded-md ...` (mobile menu button) |

Separately, bare `rounded` appears on checkboxes in `lessons_live.ex`
(L390/409/453/472) and `core_components.ex` (L1128).

## 3. Supplementary findings (hand-written components)

### 3.1 Gradient buttons / CTAs outside the baseline

Baseline CTA: `py-3 px-6 rounded-lg`, `from-pink-500 to-purple-500`.

| File | Lines | Deviation |
|---|---|---|
| `live/user_settings_live.ex` | 135, 182 | `to-purple-600` |
| `live/user_forgot_password_live.ex`, `user_registration_live.ex`, `user_login_live.ex`, `user_reset_password_live.ex` | 21 / 46 / 39 / 33 | `to-purple-600` |
| `live/practice_live.ex` | 211 | `py-4 px-6`, `hover:scale-[1.02]` |
| `live/connect_live.ex` | 151 | reversed `from-purple-500 to-pink-500`, `rounded-xl` |
| `live/blog_post_live.ex` | 177, 186, 277, 290 | `from-green-500 to-blue-500`, `bg-slate-600`, reversed purple→pink, purple |
| `live/lessons_live.ex` | 279, 297, 317, 438 | baseline pink→purple and `from-blue-500 to-cyan-*` |
| `live/dance_types_live.ex` | 99, 119, 135, 151, 167 | baseline CTA + tab variants |
| `live/blog_live.ex` | 67 | baseline CTA |
| `controllers/home_html/index.html.heex` | 367, 372 | `px-8 py-4 rounded-xl animate-pulse-glow`; slate outline btn |
| `components/layouts/app.html.heex` | 182, 343 | nav / sign-in buttons |
| `components/core_components.ex` | 162, 171, 308–310, 498, 506, 759, 767 | light cancel btn + several gradient btns |

### 3.2 Gradient text headings

Baseline: `bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent`
(pattern card title). Page headings use `from-pink-500 to-purple-500`.

Pages with gradient headings: `lessons_live.ex:266`, `dance_types_live.ex:82`,
`blog_live.ex:54`, `practice_live.ex:79`, `patterns_live.ex:342` (baseline),
`connect_live.ex:28` (reversed/lighter), `root.html.heex:35`,
`app.html.heex:9`, `index.html.heex:15,52` (lighter `*-400`).

### 3.3 Cards

Baseline shell: `rounded-2xl border border-slate-700/50 bg-slate-800/50 shadow-xl
transition-all duration-300 hover:border-pink-500/30`.

Hand-rolled cards: `connect_live.ex:16,53`; `blog_post_live.ex:139,230,251,286`;
`user_profile.ex:73,112,124,138,200,217,237,260`; `practice_live.ex:221,224`;
`dance_types_live.ex:186,190`; `index.html.heex:101,117,154,170,207,223,260,276`;
`core_components.ex:381,610,792,869`; `locale_switcher.ex:34,94`.

### 3.4 Badges

`dance_types_live.ex:233`; `blog_post_live.ex:240`; `user_profile.ex:95,265`;
`app.html.heex:131` (baseline-matching role badge — keep);
`core_components.ex:397,401,615,619,796`; `locale_switcher.ex:85` (empty styled div).

### 3.5 Icon containers

Baseline shell: `w-10 h-10 rounded-xl flex items-center justify-center shadow-lg`.

`connect_live.ex:18,66,81,97`; `blog_post_live.ex:218,312`;
`user_profile.ex:114,126,140,203,220,240,289`;
`patterns_live.ex:480` (baseline empty state `w-24 h-24 rounded-full`);
`practice_live.ex:283,292`; `lessons_live.ex:357`; `dance_types_live.ex:252`;
`index.html.heex:128,181,234,287` (four identical `w-12 h-12` copies);
`core_components.ex:438,458,674,692,700,719,813,885,912`;
`app.html.heex:115`.

### 3.6 Other

- Invalid utility `-py-8` at `user_profile.ex:70`.
- Empty styled `<div>` at `locale_switcher.ex:85`.
- Duplicate decorative blur blobs in `practice_live.ex:252,254` and
  `dance_types_live.ex:200,202`, plus a third variant in `index.html.heex`.
- `layouts/root.html.heex:18-25` inline `<style>` with light `html` background.
- `layouts/app.html.heex:354-357` `<main class="flex-1 py-16">` + home hero
  `mt-[-128px]` workaround.

## 4. Conflicts found while auditing (resolve against the plan)

1. The plan's spacing table sets `py-2 px-4` as the universal button baseline,
   but the patterns LiveView CTA uses `py-3 px-6 rounded-lg`. Resolution: keep the
   patterns page untouched (non-goal) and define `lg` as `py-3 px-6`; use `md`
   (`py-2 px-4`) elsewhere.
2. The plan lists `hover:shadow-lg` as the card hover target, but the patterns
   component uses `hover:shadow-2xl`. Resolution: keep the patterns component
   unchanged; `<.card>` reproduces the plan's `hover:shadow-lg` +
   `hover:shadow-pink-500/25` for other pages.
3. The plan's §3.2 says replace buttons in *all* LiveViews, including patterns.
   Because patterns is explicitly a non-goal, its markup is left as-is and serves
   as the visual reference for `<.btn size="lg">`.
