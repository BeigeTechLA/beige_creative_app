# Task 4.16 — Group D · Unit 11.b · Migrate `HomeScreen`

**Phase:** 4 · **Group:** D · **Status:** 🟢 Completed · **Est:** 3d

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
- `lib/features/home/data/repositories/home_repository_impl.dart`
- `lib/features/home/domain/repositories/home_repository.dart`
- `lib/features/home/presentation/providers/home_notifier.dart`
- `lib/features/home/presentation/providers/home_state.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/core/network/api_endpoints.dart` (added `shootCategories`)
- All widgets from 4.15 (consume notifier via unchanged constructor APIs)

## Steps
- [x] Combined state: dashboard summary + upcoming + creatives + stats + notifications
- [x] `Future.wait([fetchA(), fetchB(), ...])` inside `AutoDisposeNotifier.build`
- [x] Each section can show partial loading if needed (granular sub-states via `_safe*` wrappers)
- [x] Remove the 7 raw `initState` fetchers
- [x] Pull-to-refresh hooks into `ref.read(homeNotifierProvider.notifier).refresh()`
- [x] Widget tests for happy + partial-failure path (7 test cases)

## Acceptance
- [x] `setState` removed from home screen (only `_currentIndex` carousel animation remains as local widget state)
- [x] 7 fetchers consolidated into one orchestrated `Future.wait` call
- [x] Cold-start TTI improves or holds (coordinated `Future.wait` vs. 7 independent fire-and-forget fetches)
- [x] `flutter analyze` clean (149 issues, down from 150 baseline)
- [x] No `TextEditingController`s in home screen (none existed post-decompose)

## Notes
Pre-Phase-4 the home screen leaked controllers and fired fetchers on every rebuild. Post-migration the budget is one fetch per `ref.invalidate` call.

2026-06-05 UI polish: `HomeWelcomeHeader` was tightened against the CP Dashboard toolbar reference without changing Home's Riverpod/data flow.
