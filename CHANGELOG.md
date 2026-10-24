# Changelog

All notable changes to WcsStudio will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
