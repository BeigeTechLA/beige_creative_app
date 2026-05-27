# Task 3.13 — `SessionStore` interface + impls

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 4h

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
- [ ] Interface: `Future<String?> readToken()`, `Future<void> writeToken(String)`, `Future<void> clearToken()`, `Future<UserSnapshot?> readUser()`, ...
- [ ] `SecureSessionStore`: implements token + refresh storage
- [ ] `PrefsSessionStore`: implements `isLoggedIn`, `lastLoginAt`, non-secret user snapshot fields
- [ ] Unit tests on storage round-trip (basic)
- [ ] Provider for each registered in `core_providers.dart` (Task 3.11)

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Round-trip test passes
- [ ] No call sites touched yet — this lands the primitive only

## Notes
Migration of token from prefs → keychain runs in [Task 3.14](task_14_session_migration_shim.md). This task only lands the abstraction.
