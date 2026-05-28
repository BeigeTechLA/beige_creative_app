# Task 3.06 — Move `ApiEndpoints` to `lib/core/network/`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 2h

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
- [x] Moved class definition to `lib/core/network/api_endpoints.dart` (canonical location).
- [x] Fixed `add_availability` — stripped leading `/`. Now `"creator/add-availability"` matching all other endpoints.
- [x] Replaced `lib/service/api_endpoints.dart` with single-line `export` shim.
- [x] `flutter analyze` clean — 301 total issues = baseline preserved, zero new lints (snake_case info-level lints carried over verbatim from original file).

## Acceptance
- [x] `add_availability` no longer has leading `/` — `Env.apiUrl` already ends with `api/`, so URL is now `…/api/creator/add-availability` (was `…/api//creator/add-availability`).
- [x] All 25 importing files still resolve via shim — no caller edits needed.
- [ ] Manual smoke on add-availability flow — **not verified** (no live API in this env). Endpoint-string-only change; logic untouched.

## Notes
4 hardcoded URL string literals still exist in feature code — they're fixed in their Phase 4 feature rows (Profile 4.11/4.12, Auth 4.21/4.22, Home/Shoots 4.13).
