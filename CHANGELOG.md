# Changelog

All notable changes to RimTelligence will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
