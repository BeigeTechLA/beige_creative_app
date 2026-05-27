# Task 4.16 — Group D · Unit 11.b · Migrate `HomeScreen`

**Phase:** 4 · **Group:** D · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupD-home` |

## Goal
Migrate the post-split home dashboard to Riverpod. Replace 7 `initState` fetchers with a coordinated `AsyncNotifier` that fans-out via `Future.wait` and emits one combined state.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group D Unit 11
- [`../audit/AUDIT_PERF.md`](../audit/AUDIT_PERF.md) D-3

## Files in scope (max 8)
- `lib/features/home/data/datasources/home_remote_datasource.dart`
- `lib/features/home/data/repositories/home_repository_impl.dart`
- `lib/features/home/domain/repositories/home_repository.dart`
- `lib/features/home/presentation/providers/home_notifier.dart` + `_state.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- All widgets from 4.15 (consume notifier)

## Steps
- [ ] Combined state: dashboard summary + upcoming + creatives + stats + notifications
- [ ] `Future.wait([fetchA(), fetchB(), ...])` inside `AsyncNotifier.build`
- [ ] Each section can show partial loading if needed (granular sub-states)
- [ ] Remove the 7 raw `initState` fetchers
- [ ] Pull-to-refresh hooks into `ref.invalidate(homeNotifierProvider)`
- [ ] Widget tests for happy + partial-failure path

## Acceptance
- [ ] `setState` removed from home screen
- [ ] 7 fetchers consolidated into one orchestrated call
- [ ] Cold-start TTI improves or holds (measure with Flutter Performance overlay)
- [ ] `flutter analyze` clean
- [ ] All `TextEditingController`s disposed

## Notes
Pre-Phase-4 the home screen leaked controllers and fired fetchers on every rebuild. Post-migration the budget is one fetch per `ref.invalidate` call.
