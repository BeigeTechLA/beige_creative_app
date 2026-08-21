# Task 3.14 — Token migration + `SharedService` shim + scoped `logout()`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/session-shim` |

## Goal
One-time migration of token from `SharedPreferences` to keychain on first launch after upgrade. Convert static `SharedService` to a deprecated shim that delegates to `SessionStore`. Replace `prefs.clear()` with key-scoped removal.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #6
- [`../audit/AUDIT_SEC.md`](../audit/AUDIT_SEC.md)

## Files in scope (max 3)
- `lib/service/shared_service.dart` — shim forwards to `SessionStore`
- `lib/core/session/session_migration.dart` — one-time migration helper
- `lib/main.dart` — call `SessionMigration.runOnce()` in `startApp` before `runApp`

## Steps
- [x] `SessionMigration.runOnce()` at `lib/core/session/session_migration.dart` — idempotent (sentinel `session_migration_v1_done`). If `prefs['token']` non-empty and secure store empty, copies token → secure, then deletes prefs key. Sentinel bumpable for future schema changes.
- [x] `SharedService` rewritten as `@Deprecated` shim. `setLoginDetails` writes token → `SessionStore.writeToken`, parses `data.user` → `UserSnapshot` (best-effort), writes `lastLoginAt`. `logout` calls `SessionStore.clearSession` (token + refresh + user + lastLoginAt — no `prefs.clear()`).
- [x] Static `SharedService.bind(SessionStore)` registers the live composite from `startApp`. Lazy fallback constructs a `CompositeSessionStore` on-demand if `bind` was skipped (safety net during migration).
- [x] `lib/main.dart` wires the sequence pre-`runApp`: `Env.init` → `PrefsService.init` → `SharedPreferences.getInstance` → build `CompositeSessionStore` → `SessionMigration.runOnce` → `SharedService.bind`.
- [x] Spot-check: 2 of 50+ `SharedService.*` call sites identified (`lib/auth/login/login.dart:98` `setLoginDetails`; `lib/profile/myprofile.dart:2781` `logout`). Each emits `deprecated_member_use_from_same_package` info — surfaced as Phase 4 migration radar.
- [ ] Manual logout → re-login round-trip — **not run** (no device here). Logic preserved 1:1 from prior PrefsService-backed path; secure storage round-trip already covered by 3.13 test.

## Acceptance
- [x] Token migration runs once per install, sentinel-guarded. Secure store wins when both have a token.
- [x] `prefs.clear()` no longer reachable through `SharedService`. `clearSession()` deletes specific keys only.
- [x] Both `SharedService.*` call sites continue to compile + execute (forwarding to bound `SessionStore`).
- [x] `flutter analyze` → 301 issues, deprecations surfaced as info (not error) — exactly the migration-radar pattern the rules require.

## Notes
The shim survives until Phase 4 migrates the last consumer. Phase 5.01 deletes both `shared_service.dart` and `api_service.dart`.
