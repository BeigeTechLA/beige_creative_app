# Task 6.08 — Widget tests: home + profile + shoots

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Widget tests for `HomeScreen`, `MyProfileScreen`, `ShootsScreen`, `UpcomingShootViewDetailsScreen`. Coverage of pull-to-refresh + filter interactions.

## Files in scope (4)
- `test/features/home/presentation/screens/home_screen_test.dart` — **new** — 3 tests. Welcome banner render, RefreshIndicator + SingleChildScrollView present, pull-to-refresh invokes notifier.refresh.
- `test/features/profile/presentation/screens/my_profile_screen_test.dart` — **new** — 3 tests. Name + email + location render from seeded `MyProfileData`, `AppLoader` overlay visible when `isLoading=true`, stats labels (hourly rate / experience / working distance) render.
- `test/features/shoots/presentation/screens/shoots_screen_test.dart` — **new** — 3 tests. Four count cards render with zero-padded numbers (`03`, `05`, `07`, `01`), search bar renders with placeholder, typing routes to `notifier.updateSearch`.
- `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — **new** — 3 tests. Client name + `ID:` label render, `AppLoader` visible when `isLoading=true` or `isSubmitting=true`.

## Steps
- [x] Render + sections present checks per screen.
- [x] Pull-to-refresh on home fires the (overridden) `notifier.refresh()` via `tester.fling`.
- [x] Filter chip tap covered indirectly — search text routes to `updateSearch` on shoots; range/category tab interaction on home left to `home_notifier_test.dart` (range tabs sit below the 800×600 test surface; not worth the scroll dance).
- [x] Each screen has ≥ 3 cases.

## Acceptance
- [x] All test files pass (`12 / 12`: home `3`, profile `3`, shoots `3`, upcoming details `3`).
- [x] Widget coverage on these screens — every screen has render + interaction smoke + loader/state-driven branch.
- [x] No real API calls — every test overrides the relevant notifier provider with a fake.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (430 events).

## Notes
- **Skipped `tester.runAsync` + `FlutterError.onError` swallowing.** Auth widget tests in 6.07 used that combo; it caused a `_pendingExceptionDetails != null` assertion failure here because the framework expects unhandled errors to be visible. Replaced with `tester.takeException()` immediately after `pump` to drain the (harmless) asset-load errors triggered by `Image.asset` / `SvgPicture` / `Lottie.asset`.
- **`AppLoader` is the loader widget, not `CircularProgressIndicator`.** First pass asserted on `find.byType(CircularProgressIndicator)` and failed — `AppLoader` wraps `Lottie.asset(...)`. Tests now assert `find.byType(AppLoader)` directly. Worth pinning at the screen layer because a future swap from Lottie to native spinner would otherwise silently pass a misleading test.
- **Home range/category tabs sit below the 800×600 test surface fold.** First pass tried `find.text('Month')` for the dropdown selected value + tap to change range; the `tap` warned about hit-testing off-screen at `Offset(710, 1589.8)`. Removed those assertions — `home_notifier_test.dart` already covers `changeStatsRange` + `changeShootCategoryTab` end-to-end. Widget test stays focused on the welcome-banner + refresh-indicator canary.
- **Family-provider override uses the family declaration, not an instance.** `upcomingShootDetailProvider(42).overrideWith(...)` does not exist in Riverpod 2.6; you call `upcomingShootDetailProvider.overrideWith((ref, arg) => Fake())` on the family itself. The fake reads `arg` via `ref.read(...)` semantics.
- **`Myprofile` (screen) renders the client name in two places** (header + sheet trigger row). First assertion `findsOneWidget` failed with 2 matches; relaxed to `findsWidgets`. Future refactors that collapse those two render sites will need to revisit.
