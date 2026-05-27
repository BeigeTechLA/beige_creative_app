# Task 3.06 — Move `ApiEndpoints` to `lib/core/network/`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 2h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/api-endpoints` |

## Goal
Move endpoint registry from `lib/service/` to `lib/core/network/`, fix the leading-slash bug on `add_availability`, and leave a re-export shim at the old path.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #11; §7 Phase 3.B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §5.2 (all endpoints in `ApiEndpoints`)

## Files in scope (max 5)
- `lib/core/network/api_endpoints.dart` — new (moved file, leading slash trimmed)
- `lib/service/api_endpoints.dart` — `export 'package:beige_creative_app/core/network/api_endpoints.dart';`

## Steps
- [ ] `git mv lib/service/api_endpoints.dart lib/core/network/api_endpoints.dart`
- [ ] Fix `add_availability` (strip leading `/`); verify base URL still ends with `api/`
- [ ] Add a single-line re-export at the old path
- [ ] `flutter analyze` clean

## Acceptance
- [ ] `add_availability` request URL no longer contains `//` joined segment
- [ ] All 30 endpoint references still resolve
- [ ] Manual smoke: add-availability flow returns 2xx

## Notes
4 hardcoded URL string literals still exist in feature code — they're fixed in their Phase 4 feature rows (Profile 4.11/4.12, Auth 4.21/4.22, Home/Shoots 4.13).
