# Changelog

All notable changes to this project will be documented in this file.

- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2026-10-31

### Added

- A changelog! [PR#18](https://github.com/OpenFn/impact-tracker/pull/18)
- Docker images carry their version in the standard
  `org.opencontainers.image.version` label.
  [PR#18](https://github.com/OpenFn/impact-tracker/pull/18)

### Changed

- Strip leading "v" (or "V") from `lightning_version` reports, and a migration
  strips it from submissions already stored.
  [PR#18](https://github.com/OpenFn/impact-tracker/pull/18)
- Docker images are tagged with the bare version (`0.6.0`, not `v0.6.0`).
  Existing `v` tags are unchanged.
  [PR#18](https://github.com/OpenFn/impact-tracker/pull/18)

### Removed

- Submission version `1` is no longer accepted. These submissions previously
  passed validation and then crashed; they are now rejected as invalid,
  and the worker logs a warning for every report it drops.
  [PR#18](https://github.com/OpenFn/impact-tracker/pull/18)
