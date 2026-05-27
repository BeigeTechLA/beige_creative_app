# Task 4.01 — Group A · Unit 1 · `SplashScreen` migration

**Phase:** 4 · **Group:** A (Pilot) · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupA-splash` |

## Goal
Migrate the 72-LOC splash to `ConsumerWidget`. Move the `isLoggedIn` read out of the screen — the router `redirect:` (Task 3.17) now owns auth boot. Splash becomes presentation-only.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group A; §6 Recommended Pilot
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14 Per-Feature Checklist

## Files in scope (max 5)
- `lib/features/splash/presentation/screens/splash_screen.dart` — new (moved)
- `lib/features/splash/presentation/providers/splash_notifier.dart` — animation/timer driver
- `lib/features/splash/presentation/providers/splash_state.dart`
- `lib/app/router.dart` — update import
- `test/features/splash/presentation/screens/splash_screen_test.dart` — smoke widget test

## Steps
- [ ] Move file to new feature folder
- [ ] Replace `Navigator.pushReplacement` with `context.goNamed(RouteNames.onboarding | home)` driven by auth redirect
- [ ] Verify Lottie animation still plays
- [ ] Add 1 widget test using `pumpProviderApp`
- [ ] Delete old `lib/splash/`

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Cold start logged-out → onboarding
- [ ] Cold start logged-in → home
- [ ] Widget test green
- [ ] No `setState` in splash screen

## Notes
This is the pilot. Time spent here calibrates every subsequent task — measure actual hours and update remaining tasks if drift >25%.
