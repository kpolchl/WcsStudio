# Changelog

All notable changes to RimTelligence will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
