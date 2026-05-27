# Task 4.19 — Group E · Unit 16.a · Decompose `SignUp1`

**Phase:** 4 · **Group:** E · **Status:** 🔴 Not Started · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupE-signup1-split` |

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
- [ ] Characterization test before split
- [ ] Cut into form / map / image / orchestrator
- [ ] State remains in parent — no Notifier
- [ ] Characterization test green post-split

## Acceptance
- [ ] No file >500 LOC in signup1 area
- [ ] App behaves identically
- [ ] `flutter analyze` clean

## Notes
Smaller than signup3 but same principle. After split, both signup1 + signup2 migrate together in 4.20.
