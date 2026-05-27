# Task 4.11 — Group C · Unit 6.a · Decompose `Myprofile`

**Phase:** 4 · **Group:** C · **Status:** 🔴 Not Started · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-myprofile-split` |

## Goal
Break the 2,836-LOC `myprofile.dart` into widgets ≤600 LOC apiece. Profile screen is the entry point + drawer host — riskiest split in Group C.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #1; §3 Group C
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §1.1

## Files in scope (max 10)
- `lib/features/profile/presentation/widgets/profile_header.dart`
- `lib/features/profile/presentation/widgets/profile_stats_panel.dart`
- `lib/features/profile/presentation/widgets/profile_section_list.dart` (drawer-like menu)
- `lib/features/profile/presentation/widgets/profile_action_buttons.dart`
- `lib/features/profile/presentation/widgets/profile_drawer.dart`
- `lib/features/profile/presentation/screens/my_profile_screen.dart` (orchestrator ≤600 LOC)
- 2 hardcoded endpoints at `myprofile.dart:597-598`, `:2579-2583` — move into `ApiEndpoints`

## Steps
- [ ] Characterization test (golden + API-call snapshot) before splitting
- [ ] Cut widgets along visual + semantic seams
- [ ] Hardcoded URLs moved into `ApiEndpoints`
- [ ] Parent still holds `setState` — no Notifier yet
- [ ] Characterization test green post-split

## Acceptance
- [ ] No file >600 LOC in myprofile area
- [ ] 2 hardcoded endpoint URLs eliminated
- [ ] App behaves identically to pre-split
- [ ] `flutter analyze` clean

## Notes
Riskiest single split in the project alongside signup3. Pair-program if available. Migration follows in 4.12.
