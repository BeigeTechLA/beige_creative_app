# Task 4.05 — Group B · Unit 5 · Manage Availability

**Phase:** 4 · **Group:** B · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupB-availability` |

## Goal
Migrate the two availability screens (1,742 LOC combined). Verify `add_availability` endpoint leading-slash fix from Task 3.06 took effect.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 8)
- `lib/features/availability/data/`
- `lib/features/availability/domain/`
- `lib/features/availability/presentation/providers/availability_notifier.dart` + `_state.dart`
- `lib/features/availability/presentation/screens/manage_availability_screen.dart`
- `lib/features/availability/presentation/screens/add_availability_screen.dart`
- Delete old `lib/manage_availability/` (former `lib/manageavailability/`)

## Steps
- [ ] Repo + datasource (~2 endpoints)
- [ ] State: selected days, ranges, recurrence
- [ ] Calendar widget reusable from `lib/widgets/common_calendar.dart` → move to `lib/shared/widgets/` in Group F
- [ ] Widget tests for save flow

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Save availability returns 2xx
- [ ] Calendar selection state survives orientation change
- [ ] No `ApiService()` direct instantiation

## Notes
At Group B end: rerun pubspec + analyze for hygiene. After Group B, ~10 features cleared on the new stack.
