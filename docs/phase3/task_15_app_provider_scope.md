# Task 3.15 — Resurrect `lib/app/app.dart` + `ProviderScope`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/provider-scope` |

## Goal
Switch the live app root from the plain `MyApp` `StatelessWidget` to a `ConsumerWidget` `App` in `lib/app/app.dart` wrapped in `ProviderScope`. Drop the `isLoggedIn` constructor plumbing — Phase 3.17's `redirect:` owns the auth boot path.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 9; §7 Phase 3.D
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §3.2 Root Setup

## Files in scope (max 3)
- `lib/app/app.dart` — uncomment + finish the `ConsumerWidget` root
- `lib/main.dart` — `runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const App()))`
- `lib/main_dev.dart` / `lib/main_prod.dart` — unchanged (still call `startApp(Environment.x)`)

## Steps
- [x] `MaterialApp.router` moved into `App.build` (`ConsumerWidget` at `lib/app/app.dart`).
- [x] `ProviderScope` mounted in `startApp` with overrides for `sharedPreferencesProvider` (resolved `SharedPreferences`) and `sessionStoreProvider` (live `CompositeSessionStore`).
- [x] `MyApp(isLoggedIn:)` deleted — class removed entirely. Auth boot branching now owned by router redirect (Task 3.17 hook point).
- [ ] Both-flavor boot — **not run** (no device/simulator here). Static analysis + widget smoke green; flavor-specific code paths unchanged.
- [x] `test/widget_test.dart` rewritten — pumps `ProviderScope(...App())` with mock `SharedPreferences` + fake `SecureSessionBackend`. Passing.

## Acceptance
- [x] `flutter analyze lib/app/app.dart lib/main.dart test/widget_test.dart` → No issues found. Full analyze → 301 (baseline + 2 deprecation infos on `SharedService` from Task 3.14).
- [ ] App boots both flavors — not verified in this env (no device).
- [x] `widget_test.dart` → green (1/1).
- [x] No commented-out blocks in `lib/app/app.dart` (was a `/* … */` placeholder pre-task; now real code).

## Notes
Splash continues to be the entry route; the redirect set up in Task 3.17 handles the logged-in-vs-out branching now.
