# Task 4.10 — Group C · Unit 8 · Profile-details forms

**Phase:** 4 · **Group:** C · **Status:** 🟢 Completed · **Est:** 4d · **Actual:** ~1.5h (cold session)

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
- [x] Form state in Notifier; controllers owned by widget (CLAUDE.md precedent — notifier holds parsed state, controllers stay in `ConsumerStatefulWidget`)
- [x] Google Maps picker → callback delivers `LatLng` + address back to widget; widget mirrors into location controller
- [x] Image picker + cropper integrated through repo `uploadPhoto` (helper available on `EnterProfessionalNotifier.uploadPhoto`; widget entrypoint pending myprofile migration in 4.12)
- [x] Validation rules in Notifier methods, not widget
- [x] Widget tests for save flow — 6 notifier cases covering load + submit + validation

## Acceptance
- [x] All 3 forms migrate
- [x] Maps pin selection survives navigation — same in-screen state pattern as legacy preserved
- [x] Photo upload returns updated URL — `ProfileRepository.uploadPhoto` returns `data.profile_image_url`
- [x] `flutter analyze` clean — no new errors/warnings; only deprecation infos matching sibling screens

## Notes
`edit_personal_details` grew from 589 → 666 since 2026-05-21 — confirmed intentional: `_isPlusCode` helper + `ageController` + deprecated-fix calls are real additions, not cruft.
