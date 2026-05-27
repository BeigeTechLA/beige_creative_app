# Task 4.02 — Group A · Unit 2 · `OnboardingScreen` migration

**Phase:** 4 · **Group:** A (Pilot) · **Status:** 🔴 Not Started · **Est:** 1d

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
- [ ] Lift page index + PageController into Notifier
- [ ] Persist `onboardingSeen=true` after final page via `SessionStore`
- [ ] Router `redirect:` skips onboarding when seen
- [ ] Widget test for next/skip buttons
- [ ] Delete old `lib/onboarding/` (former `lib/onboding/` after Task 2.01)

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Skipping or completing onboarding never shows it again on the same device
- [ ] Widget test green
- [ ] No raw `Navigator.push`

## Notes
After this task: Group A is **done** → re-baseline Group B–E estimates against the actuals from Tasks 4.01 + 4.02.
