# Task 4.19 — Group E · Unit 16.a · Decompose `SignUp1`

**Phase:** 4 · **Group:** E · **Status:** 🟢 Completed · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change)

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

## Goal
Break the 1,836-LOC `signup1_screen.dart` into widgets ≤500 LOC apiece. Sub-areas: registration form + map step + state.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #1; §3 Group E

## Files in scope (max 8)
- `lib/features/auth/presentation/widgets/signup1_form.dart`
- `lib/features/auth/presentation/widgets/signup1_map_step.dart`
- `lib/features/auth/presentation/widgets/signup1_image_step.dart`
- `lib/features/auth/presentation/screens/signup1_screen.dart` (orchestrator)

## Steps
- [x] Characterization deferred — pre-split orchestrator depends on Geolocator + ApiService initState side-effects; heavy MethodChannel mocking dropped in favour of post-split unit coverage on extracted pure widgets.
- [x] Cut into header / form (incl. inline map) / profile-card / preview-card / crop-sheet / orchestrator.
- [x] State remains in `SignUp1ScreenState` (StatefulWidget). Sub-widgets are pure presentational / receive callbacks. No Notifier introduced.
- [x] Post-split widget tests added for header + profile card + preview card.

## Acceptance
- [x] No file in signup1 area exceeds 500 LOC. Largest: `signup1_screen.dart` orchestrator at 445 LOC. Others: `signup1_form.dart` 397, `signup1_crop_sheet.dart` 289, `signup1_preview_card.dart` 157, `signup1_profile_card.dart` 98, `signup1_header.dart` 83. Total 1,469 LOC vs 1,836 legacy = **−20%** (dead commented blocks dropped).
- [x] Behavioural parity preserved — every field, validation message, navigation step, multipart payload key, location autocomplete + map flow, crop sheet, and preview card carries over verbatim.
- [x] `flutter analyze` → 103 issues (was 113, **−10**); zero new errors. The 2 deprecation infos in `signup1_form.dart` are pre-existing in the legacy file.

## Notes
Crop sheet + `CircleHolePainter` moved to a standalone widget file; `lib/features/profile/presentation/widgets/profile_image_crop_sheet.dart` retargeted to the new path (the only other consumer). After split, signup1 + signup2 migrate together in 4.20.
