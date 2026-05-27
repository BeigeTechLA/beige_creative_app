# Task 4.10 — Group C · Unit 8 · Profile-details forms

**Phase:** 4 · **Group:** C · **Status:** 🔴 Not Started · **Est:** 4d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-profile-details` |

## Goal
Migrate the 3-screen profile-details cluster: enter (936 LOC, Google Maps), profile_details_1 (595), edit personal details (666). The enter form is the second-largest non-god form in the project.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 8

## Files in scope (max 8)
- `lib/features/profile/data/repositories/profile_repository_impl.dart` (add updateProfile, uploadPhoto)
- `lib/features/profile/presentation/providers/enter_profile_details_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/providers/edit_personal_details_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/screens/enter_profile_details_screen.dart`
- `lib/features/profile/presentation/screens/profile_details_1_screen.dart`
- `lib/features/profile/presentation/screens/edit_personal_details_screen.dart`

## Steps
- [ ] Form state in Notifier; controllers owned by Notifier
- [ ] Google Maps picker → lift selection into state via callback
- [ ] Image picker + cropper integrated through repo `uploadPhoto`
- [ ] Validation rules in Notifier methods, not widget
- [ ] Widget tests for save flow

## Acceptance
- [ ] All 3 forms migrate
- [ ] Maps pin selection survives navigation
- [ ] Photo upload returns updated URL
- [ ] `flutter analyze` clean

## Notes
`edit_personal_details` grew from 589 → 666 since 2026-05-21 — confirm new logic is intentional, not regression-cruft, before migrating.
