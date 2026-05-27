# Task 6.08 — Widget tests: home + profile + shoots

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/widget-home-profile` |

## Goal
Widget tests for `HomeScreen`, `MyProfileScreen`, `ShootsScreen`, `UpcomingShootViewDetailsScreen`. Coverage of pull-to-refresh + filter interactions.

## Files in scope (max 5)
- `test/features/home/presentation/screens/home_screen_test.dart`
- `test/features/profile/presentation/screens/my_profile_screen_test.dart`
- `test/features/shoots/presentation/screens/shoots_screen_test.dart`
- `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart`

## Steps
- [ ] Render + sections present checks
- [ ] Pull-to-refresh fires `ref.invalidate`
- [ ] Filter chip taps update visible items
- [ ] Smoke per screen ≥ 3 cases

## Acceptance
- [ ] All test files pass
- [ ] Widget coverage on these screens ≥ 60%

## Notes
Home is the busiest — keep its widget test scoped to render + refresh; deeper logic is covered by the Notifier test (6.05).
