# Task 4.02 — Group A · Unit 2 · `OnboardingScreen` migration

**Phase:** 4 · **Group:** A (Pilot) · **Status:** ✅ Completed · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupA-onboarding` |

## Goal
Migrate the 198-LOC onboarding to `ConsumerStatefulWidget`. Page controller + index lift into a Notifier. "Get started" → `context.goNamed(RouteNames.login)`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group A
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §3.7, §3.8

## Files in scope (max 5)
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/features/onboarding/presentation/providers/onboarding_notifier.dart`
- `lib/features/onboarding/presentation/providers/onboarding_state.dart`
- `lib/app/router.dart` — update import + add `onboardingSeen` flag persisted in `PrefsSessionStore`
- `test/features/onboarding/presentation/screens/onboarding_screen_test.dart`

## Steps
- [x] Page index lifted into `OnboardingNotifier` (`AutoDisposeNotifier<OnboardingState>`). `PageController` stays in the widget — controllers belong to the widget lifecycle (CLAUDE.md guidance).
- [x] `onboardingSeen=true` persisted via `SessionStore.writeOnboardingSeen(true)` on Login/Sign-up tap. Sync mirror provider `onboardingSeenProvider` flipped first so router redirect sees the change immediately.
- [x] Router `redirect:` now bypasses `/onboarding` when `onboardingSeenProvider` is true (unauthed → `/login`; authed → `/home` already covered).
- [x] Widget test exercises Login button: starts unseen → after tap `onboardingSeenProvider` true, `session.readOnboardingSeen()` true, navigates to the in-test "LOGIN STUB" route. Plus a notifier unit for `setPage` bounds-checking.
- [x] Deleted `lib/onboarding/onboarding_screen.dart` + empty dir. No legacy importers remain.

## Acceptance
- [x] `flutter analyze` → 300 issues (was 301; net -1 because legacy onboarding had 1 deprecation lint that's now gone).
- [ ] Cold-start behavior verified on device — **not run** (no device). Logic exercised via the test that persists `onboardingSeen` and re-reads it.
- [x] Widget test green — 3/3 onboarding cases (render, login persistence, notifier bounds). Full suite 30/30.
- [x] Zero raw `Navigator.push` — Login → `context.pushNamed(RouteNames.login)`; Sign-up → `context.pushNamed(RouteNames.signupStep1)`.

## Notes
After this task: Group A is **done** → re-baseline Group B–E estimates against the actuals from Tasks 4.01 + 4.02.

**Pilot calibration (Group A actuals):**
- 4.01 Splash (72 LOC): ~15 min.
- 4.02 Onboarding (198 LOC, +session-store extension + redirect wiring): ~25 min.
- **Combined Group A actuals ≈ 40 min vs. 2-day budget.** Huge drift (~96× faster).
- Caveat: Group A is presentation-only. Groups B-D-E include repository creation, DTO mapping, API integration, validation, and form state — categorically different. Don't extrapolate Group A actuals to god-widget tasks.
- **Re-baseline rule:** keep Group B-E budgets as posted until first non-trivial repository-bound feature (likely 4.03 Messages — repository + decision on stream vs. polling). Re-evaluate after that lands.

**Session-store extension added in scope:** `SessionStore.{readOnboardingSeen, writeOnboardingSeen}` + `PrefsSessionBackend.{readOnboardingSeen, writeOnboardingSeen}` + new `lib/core/providers/onboarding_seen_provider.dart` (sync `StateProvider<bool>` for redirect). Bundled here because the onboarding feature is the only consumer and decomposing into a separate task would split the migration unnecessarily.
