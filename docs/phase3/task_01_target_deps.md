# Task 3.01 — Add target packages

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 1h

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
- [ ] Add: `dartz` (or `fpdart`), `freezed_annotation`, `json_annotation`, `connectivity_plus`, `firebase_core`, `firebase_analytics`, `firebase_crashlytics`
- [ ] Add dev-deps: `freezed`, `json_serializable`, `build_runner`, `mocktail`
- [ ] Already present (verify): `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `cached_network_image`
- [ ] `flutter pub get`
- [ ] `flutter analyze` clean

## Acceptance
- [ ] All deps resolve
- [ ] App still boots both flavors
- [ ] No new analyzer warnings beyond baseline

## Notes
Choose `dartz` vs `fpdart` here — sticks for the whole project. Plan picked `dartz` (smaller surface). Document choice in [`MIGRATION_LOG.md`](../../MIGRATION_LOG.md).
