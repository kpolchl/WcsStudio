# Changelog

All notable changes to WcsStudio will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2026-11-20

### Added
- For West Coast Swing dance style subpage with graph view of steps 

## [1.3.1] - 2026-11-19

### Added

- Styled 404/500 error pages and a `mix wcs.lint_ui` CI check.
- `assets/js/hooks/nav_active.js` — marks the current navigation link with
  `aria-current="page"` for elements carrying `data-nav-path`.
- `assets/js/hooks/modal_focus.js` — traps Tab focus inside a dialog and restores
  focus to the trigger on close.
- `WcsStudio.Accounts.role_label/1` — localised display labels `Admin` / `Member`.
- `WcsStudio.Pattern.hands_label/1` — display labels for hand-position atoms,
  now used by `<.pattern>` instead of showing raw atoms like `left_left`.

### Changed

- Unified buttons, cards, badges and icon containers on shared components matching the `/patterns` baseline; home now uses a dedicated full-bleed layout.
- Typography switched to Josefin Sans display headings and Lato body text
- `assets/js/hooks/carousel.js` — the 7-second auto-advance no longer starts when
  the user prefers reduced motion. Manual controls remain available. This is the
  only retained behaviour change with active master markup.

### Fixed

- Removed inline body styling and the light overscroll background; the home CTA glow now lives in `<.btn>`.

### Removed

- `heroicons` dependency and its `mix.lock` entry. It was unused; icons come from
  Font Awesome.

## [1.3.0] - 2026-11-18

### Added
- Admin-only "Add New Dance Type" form and modal in the dance types catalogue
- Dance type cards now carry the selected dance type into `/patterns`, so the pattern filter stays in sync with the clicked card

### Changed
- Improved the looks of the pattern boxes

### Fixed
- Navbar avatars now render on nested routes such as `/admin/lessons` by normalizing relative URLs to the site root
- Dance type images now render from persisted `pic_url` values

## [1.2.2] - 2026-10-25

### Fixed
- youtube embedded player was not working due to to strict CSP

## [1.2.1] - 2026-10-24

### Fixed
- Hero page carousel now does not owerflow and properly loops 
- Moved inline `script` to separate java script hook

### Security
- bumped deps

## [1.2.0] - 2026-10-11

### Added
- Unit tests for all contexts, schemas, web components, LiveViews, controllers and mailer (351 tests)
- In-process integration flows: authentication, content, locale (`test/integration`)
- Fixtures for all contexts
- `Makefile` to streamline development

### Fixed
- `DanceType.pic_url` made virtual (no DB column)
- `confirm_modal`/`form_modal` attrs shadowing `assign_new` defaults
- `input` `:value` attr default; `user_fixture` supports `:role`
- Missing form ids (form recovery)

## [1.1.1] - 2026-10-11

## Changed
- Upgrade `phoenix` from `~> 1.7.12` to `~> 1.8.15`
- Upgrade `phoenix_live_dashboard` from `~> 0.8.3` to `~> 0.9.1`
- Upgrade `gettext` from `~> 0.20` to `~> 1.0.2`
- Upgrade `dns_cluster` from `~> 0.1.1` to `~> 0.3.1`
- Bump `heroicons` from `v2.1.1` to `v2.2.0`
- Bump GitHub Actions: `actions/checkout` to `v7`, `actions/cache` to `v6`, `docker/setup-buildx-action` to `v4`, `docker/login-action` to `v4`, `docker/build-push-action` to `v7`

## [1.1.0] - 2026-10-11

## Added
 - `build.yml` workflow for creating docker image
 - `ci.yml` with sobolev static security scannig and credo for good code convention enforcement 

## Fixed
- Correct `has_many :user_lessons` association in `Lesson` schema (`foreign_key: :lesson_id`)
- Fix `submit_hands` → `submit_class` typo in pattern submission so the action actually runs

## Changed
- - Refactor `Lesson.update/9` → `update/2` (attrs map + `normalize_ids/1`)


## [1.0.0] - 2026-06-29

## Added 
- App version from this date I consider as 1.0.0 any changes or versions are not recorded as I didn't saw the purpose for writng changelogs then 
