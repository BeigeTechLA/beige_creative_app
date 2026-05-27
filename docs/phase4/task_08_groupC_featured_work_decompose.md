# Task 4.08 — Group C · Unit 7.a · Decompose `FeaturedWorkList`

**Phase:** 4 · **Group:** C · **Status:** 🔴 Not Started · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-featured-work-split` |

## Goal
Break the 1,685-LOC `featured_work_list.dart` into widgets ≤600 LOC apiece. Functions unchanged; state still in the parent. Migration to Notifier follows in 4.09.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #1; §3 Group C Sub-task discipline
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §1.1

## Files in scope (max 8)
- `lib/features/profile/presentation/widgets/featured_work_grid.dart`
- `lib/features/profile/presentation/widgets/featured_work_filter_bar.dart`
- `lib/features/profile/presentation/widgets/featured_work_upload_sheet.dart`
- `lib/features/profile/presentation/widgets/featured_work_card.dart`
- `lib/features/profile/presentation/screens/featured_work_list_screen.dart` (orchestrator)

## Steps
- [ ] Write a **characterization test** (golden + API-call snapshot) of the current screen before splitting
- [ ] Cut widgets along visual seams (filter bar, grid, card, upload sheet)
- [ ] Parent still holds `setState` — no Notifier yet
- [ ] Run characterization test → must pass byte-identical
- [ ] Commit split

## Acceptance
- [ ] No file >600 LOC in featured_work area
- [ ] Characterization test green
- [ ] App behaves identically to pre-split
- [ ] `flutter analyze` clean

## Notes
Decompose-before-migrate keeps the diff readable in 4.09. Two PRs > one mega-PR.
