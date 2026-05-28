# Task 3.13 — `SessionStore` interface + impls

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 4h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/session-store` |

## Goal
Replace static `SharedService` with a dependency-injectable `SessionStore`. Secrets (token, refresh) live in `flutter_secure_storage` (`SecureSessionStore`); non-secrets (`isLoggedIn`, locale, theme) in `SharedPreferences` (`PrefsSessionStore`).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 19; §4 Risk #6; §5 Architectural Decision #3
- [`../audit/AUDIT_SEC.md`](../audit/AUDIT_SEC.md)

## Files in scope (max 3)
- `lib/core/session/session_store.dart` — abstract interface
- `lib/core/session/secure_session_store.dart` — `flutter_secure_storage` backend
- `lib/core/session/prefs_session_store.dart` — `SharedPreferences` backend for non-secrets

## Steps
- [x] Interface `SessionStore` (composite) at `lib/core/session/session_store.dart` — `readToken/writeToken/clearToken`, `readRefreshToken/writeRefreshToken/clearRefreshToken`, `readUser/writeUser/clearUser`, `readLastLoginAt/writeLastLoginAt`, `isLoggedIn`, `clearSession`. Plus value type `UserSnapshot` (id, name, email, role, userType, profileImageUrl with `fromJson`/`toJson`).
- [x] `SecureSessionStore` (`lib/core/session/secure_session_store.dart`) implements `SecureSessionBackend` — token + refresh via `flutter_secure_storage` (Keychain / EncryptedSharedPreferences).
- [x] `PrefsSessionStore` (`lib/core/session/prefs_session_store.dart`) implements `PrefsSessionBackend` — user snapshot + lastLoginAt via `SharedPreferences`.
- [x] `CompositeSessionStore implements SessionStore` (in `session_store.dart`) wires both backends. Accepts public structural contracts `SecureSessionBackend` + `PrefsSessionBackend` so test fakes plug in without touching real Keychain.
- [x] Round-trip unit test at `test/core/session/session_store_test.dart` — 6 cases: token CRUD, refresh CRUD, user JSON round-trip, lastLoginAt round-trip, `isLoggedIn` reflects token (incl. empty=false), `clearSession` wipes everything. **All passing.**
- [x] Provider already wired in `core_providers.dart` (Task 3.11) — `sessionStoreProvider` returns `SessionStore`; will be overridden with `CompositeSessionStore(...)` in `startApp` (Task 3.15) and in `pumpProviderApp` (Task 3.16).

## Acceptance
- [x] `flutter analyze lib/core/session/ lib/core/providers/` → No issues found.
- [x] `flutter analyze` (full) → 299 issues (within baseline).
- [x] Round-trip test: 6/6 passing. Full suite: 13/13 passing.
- [x] No production call sites touched. Legacy `SharedService` + `PrefsService` + `SecureStorageService` remain in place — Task 3.14 migrates them.

## Notes
Migration of token from prefs → keychain runs in [Task 3.14](task_14_session_migration_shim.md). This task only lands the abstraction.
