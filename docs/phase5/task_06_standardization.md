# Task 5.06 — Standardization sweeps

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/standardization` |

## Goal
Final pass on cross-cutting concerns missed in Phase 4: consolidate date/time helpers, ensure analytics events are constants only, kill any remaining asset string literals, consolidate regex.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.E

## Files in scope (≤10)
- `lib/core/utils/date_time_utils.dart` — single source for formatters
- All call sites currently formatting dates inline
- `lib/core/firebase/analytics_events.dart` — no string literals at call sites
- Any remaining `'assets/...'` literals → `AppAssets.*`
- Any remaining regex literals → centralized `lib/core/utils/validators.dart`

## Steps
- [ ] `grep -rn "DateFormat\|.toIso8601\|DateTime\.parse" lib/` — move repetition into `DateTimeUtils`
- [ ] `grep -rn "FirebaseAnalytics\|logEvent('.*'" lib/` — all event names must reference `AnalyticsEvents`
- [ ] `grep -rn "'assets/" lib/` — must come from `AppAssets`
- [ ] `grep -rn "RegExp(" lib/` — consolidate validators

## Acceptance
- [ ] No inline date formatter literal outside `DateTimeUtils`
- [ ] No raw analytics event name string outside `AnalyticsEvents`
- [ ] No `'assets/...'` literal outside `AppAssets`
- [ ] `flutter analyze` clean

## Notes
Mechanical sweep. If a helper doesn't exist for a date format, create it; don't inline.
