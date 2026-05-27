# Task 4.15 — Group D · Unit 11.a · Decompose `HomeScreen`

**Phase:** 4 · **Group:** D · **Status:** 🔴 Not Started · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupD-home-split` |

## Goal
Break the 2,860-LOC `home_screen.dart` into widgets ≤500 LOC apiece. Largest god widget on the dashboard side; fires **7 parallel fetchers** in `initState` (`AUDIT_PERF.md` D-3).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #1; §3 Group D
- [`../audit/AUDIT_PERF.md`](../audit/AUDIT_PERF.md)

## Files in scope (max 10)
- `lib/features/home/presentation/widgets/home_dashboard_summary.dart`
- `lib/features/home/presentation/widgets/home_upcoming_section.dart`
- `lib/features/home/presentation/widgets/home_creative_carousel.dart`
- `lib/features/home/presentation/widgets/home_quick_actions.dart`
- `lib/features/home/presentation/widgets/home_notifications_banner.dart`
- `lib/features/home/presentation/widgets/home_stats_cards.dart`
- `lib/features/home/presentation/screens/home_screen.dart` (orchestrator ≤500 LOC)

## Steps
- [ ] Characterization test (golden + API-call snapshot) before splitting
- [ ] Cut along visible UI section boundaries
- [ ] Keep `setState` in parent for now
- [ ] Note positions of the 7 fetcher calls — they migrate to a coordinated `Future.wait` in 4.16
- [ ] Characterization test green post-split

## Acceptance
- [ ] No file >500 LOC in home area
- [ ] Visual diff against pre-split — zero drift
- [ ] `flutter analyze` clean
- [ ] App behaves identically

## Notes
Riskiest single screen-split in the project alongside signup3. Allocate buffer.
