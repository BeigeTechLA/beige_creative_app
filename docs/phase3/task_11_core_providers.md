# Task 3.11 — `core_providers.dart`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 2h

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
- [ ] `sharedPreferencesProvider` — `FutureProvider<SharedPreferences>` overridden in `runApp` after `getInstance`
- [ ] `sessionStoreProvider` — `Provider<SessionStore>` (concrete after Task 3.13)
- [ ] `dioClientProvider` — `Provider<DioClient>` consuming `sessionStoreProvider`
- [ ] `connectivityProvider` — `StreamProvider<ConnectivityResult>` (used later by offline banner)

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Provider graph compiles with no circular dependency
- [ ] Smoke test in `pumpProviderApp` (Task 3.16) overrides each cleanly

## Notes
Don't `.autoDispose` any of these — they're singletons. Per `MIGRATION_RULES.md` §3.10.
