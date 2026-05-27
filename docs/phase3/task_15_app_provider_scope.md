# Task 3.15 — Resurrect `lib/app/app.dart` + `ProviderScope`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 3h

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
- [ ] Move `MaterialApp.router` into `App.build`
- [ ] Wrap with `ProviderScope` in `startApp`
- [ ] Drop `MyApp(isLoggedIn:)` constructor parameter
- [ ] Verify both flavors boot
- [ ] Update `test/widget_test.dart` to pump `App` instead of `MyApp`

## Acceptance
- [ ] `flutter analyze` clean
- [ ] App boots on both flavors
- [ ] `widget_test.dart` still green
- [ ] `lib/app/app.dart` has no commented-out blocks (per `MIGRATION_RULES.md` §10)

## Notes
Splash continues to be the entry route; the redirect set up in Task 3.17 handles the logged-in-vs-out branching now.
