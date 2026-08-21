# Task 3.11 — `core_providers.dart`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 2h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/core-providers` |

## Goal
Wire app-wide providers: `dioClientProvider`, `sharedPreferencesProvider`, `connectivityProvider`, `sessionStoreProvider`. Lives forever — no `.autoDispose`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 28
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §3.10 (`.autoDispose` rule)

## Files in scope
- `lib/core/providers/core_providers.dart`

## Steps
- [x] `sharedPreferencesProvider` — `FutureProvider<SharedPreferences>` that throws `UnimplementedError` until overridden with the resolved `SharedPreferences.getInstance()` future in `startApp` / `pumpProviderApp`.
- [x] `sessionStoreProvider` — `Provider<SessionStore>` that throws until overridden. Concrete impl lands in Task 3.13. Abstract interface added as a stub at `lib/core/session/session_store.dart` (`readToken`, `writeToken`, `clearSession`) so this provider has a real type to expose.
- [x] `dioClientProvider` — `Provider<DioClient>` that builds `DioClient`, attaches the canonical interceptor chain `Auth → Retry → Error → Logging` (dev-only). Auth uses `session.readToken` + `session.clearSession` as callbacks.
- [x] `connectivityProvider` — `StreamProvider<List<ConnectivityResult>>` matching `connectivity_plus ^6.x` semantics (the device can have multiple active transports).

## Acceptance
- [x] `flutter analyze lib/core/providers/ lib/core/session/` → No issues found.
- [x] No circular dependency — `dioClient` → `session`, `session` self-contained; `prefs` independent; `connectivity` independent.
- [ ] Smoke test in `pumpProviderApp` — lands in Task 3.16. Each override point already defined.

## Notes
Don't `.autoDispose` any of these — they're singletons. Per `MIGRATION_RULES.md` §3.10.
