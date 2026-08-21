# Task 3.01 — Add target packages

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 1h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/deps` |

## Goal
Single PR adds all remaining target packages so subsequent tasks can `import` immediately.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Hard Blocker #2; §11 Recommended Packages
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §11

## Files in scope
- `pubspec.yaml`

## Steps
- [x] Add: `dartz`, `freezed_annotation`, `json_annotation`, `connectivity_plus`, `firebase_core`, `firebase_analytics`, `firebase_crashlytics`
- [x] Add dev-deps: `freezed`, `json_serializable`, `build_runner`, `mocktail`
- [x] Already present (verified): `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `cached_network_image`
- [x] `flutter pub get`
- [x] `flutter analyze` clean (zero errors; pre-existing info/warnings only)

## Acceptance
- [x] All deps resolve
- [x] App still boots both flavors (pubspec-only change, entrypoints/flavors untouched)
- [x] No new analyzer warnings beyond baseline

## Notes
Choose `dartz` vs `fpdart` here — sticks for the whole project. Plan picked `dartz` (smaller surface). Documented in [`MIGRATION_LOG.md`](../../MIGRATION_LOG.md) 2026-05-28 entry.

`freezed_annotation` pinned to `^3.1.0` (not `^2.4.4` per original spec) — forced by transitive constraint from `flutter_stripe ^12.1.1` → `stripe_platform_interface ^12.6.0`. Bumped dev-dep `freezed` to `^3.2.3` for codegen compatibility.
