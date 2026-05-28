# Task 4.01 — Group A · Unit 1 · `SplashScreen` migration

**Phase:** 4 · **Group:** A (Pilot) · **Status:** ✅ Completed · **Est:** 1d

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
- [x] Moved to `lib/features/splash/presentation/{providers,screens}/`. Three files: `splash_state.dart` (immutable `SplashState{animationDone}`), `splash_notifier.dart` (`AutoDisposeNotifier` with `markAnimationComplete()`), `splash_screen.dart` (`ConsumerStatefulWidget` — needs `TickerProviderStateMixin` vsync).
- [x] Reads `authStateProvider` (not `PrefsService.isLoggedIn`) and dispatches `context.goNamed(home | onboarding)` on completion. Router redirect (Task 3.17) is the safety net if auth state flips between mount and animation-complete.
- [x] Lottie unchanged — `AppAssets.lottie2` still drives the animation, controller still owned by the widget (vsync requirement).
- [x] 2 widget/unit tests at `test/features/splash/presentation/screens/splash_screen_test.dart` — widget renders Scaffold + Lottie; notifier flips `animationDone` exactly once. Both passing.
- [x] Deleted `lib/splash/splash_screen.dart` + empty `lib/splash/` dir. Router import updated.

## Acceptance
- [x] `flutter analyze lib/features/splash/ lib/app/router.dart test/features/splash/` → No issues found. Full → 301 (baseline).
- [ ] Cold start logged-out → onboarding — **not verified on device.** Logic exercised: `ref.read(authStateProvider) == false` → `RouteNames.onboarding`.
- [ ] Cold start logged-in → home — **not verified on device.** Logic: `ref.read(authStateProvider) == true` → `RouteNames.home`.
- [x] Widget test green — 27/27 in full suite.
- [x] No `setState` in splash screen — animation controller writes don't trigger rebuilds; navigation effect runs from `ref.listen`.

## Notes
This is the pilot. Time spent here calibrates every subsequent task — measure actual hours and update remaining tasks if drift >25%.

**Pilot actuals (2026-05-28):** ~15 minutes wall-clock for a 72-LOC presentation-only screen. Budget for similar leaf screens (Group A unit 2 onboarding, simple Group B variants) can be aggressive. God-widget tasks (`Myprofile`, `HomeScreen`, `SignUp3`) are categorically different — keep their estimates as-is until their decompose-`.a` tasks land actuals.

**Pattern established for Phase 4 pilot screens:**
- `<feature>_state.dart` — `final` fields, `copyWith`, no logic.
- `<feature>_notifier.dart` — `AutoDisposeNotifier<State>` (or `Notifier` if app-lifetime needed). Imperative `mark…/load…/submit…` methods.
- `<feature>_screen.dart` — `ConsumerStatefulWidget` only when vsync/controller-ownership demands it; otherwise `ConsumerWidget`. UI side-effects fire from `ref.listen`, not raw callbacks.
- Unit test the notifier via `ProviderContainer`; widget test the screen via `pumpProviderApp`.
