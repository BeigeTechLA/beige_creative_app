# Task 3.14 — Token migration + `SharedService` shim + scoped `logout()`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 3h

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
- [ ] `SessionMigration.runOnce()` — if token exists in prefs, move to secure store, then delete prefs key
- [ ] `SharedService.setLoginDetails`/`logout` → `@Deprecated`, body delegates to `SessionStore`
- [ ] `logout()` removes only auth keys, not `prefs.clear()`
- [ ] Manual test: logout → re-login → confirm non-auth prefs (if any) survive

## Acceptance
- [ ] First boot on a device with an existing token migrates cleanly
- [ ] `prefs.clear()` no longer called from `SharedService`
- [ ] All 50+ call sites of `SharedService.*` still work (forwarding to `SessionStore`)
- [ ] `flutter analyze` clean (deprecations warned, not errored)

## Notes
The shim survives until Phase 4 migrates the last consumer. Phase 5.01 deletes both `shared_service.dart` and `api_service.dart`.
