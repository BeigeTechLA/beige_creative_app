# Task 4.13 — Group D · Unit 13 · `UpcomingShootViewDetils`

**Phase:** 4 · **Group:** D · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupD-upcoming-details` |

## Goal
Migrate the 1,184-LOC shoot details screen. Fix 4 hardcoded endpoint string literals (`:75-84` in current file) by moving them into `ApiEndpoints`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group D Unit 13; §4 Risk #13

## Files in scope (max 6)
- `lib/features/shoots/data/datasources/shoots_remote_datasource.dart`
- `lib/features/shoots/data/repositories/shoots_repository_impl.dart`
- `lib/features/shoots/domain/repositories/shoots_repository.dart`
- `lib/features/shoots/presentation/providers/upcoming_shoot_notifier.dart` + `_state.dart`
- `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`
- `lib/core/network/api_endpoints.dart` — 4 new endpoints

## Steps
- [ ] Move 4 string-literal URLs into `ApiEndpoints` with semantic names
- [ ] AsyncNotifier loads booking detail + status
- [ ] Cancel + Accept actions emit state, UI navigates via `ref.listen`
- [ ] File viewer (from shared widgets) reused
- [ ] Widget tests for cancel happy path

## Acceptance
- [ ] `grep -rn "https://\|http://" lib/features/shoots/` returns nothing
- [ ] `flutter analyze` clean
- [ ] All 4 API calls flow through repo
- [ ] Cancel + Accept flow work

## Notes
Smallest entry into Group D — exercises pattern on a single big screen before the multi-screen units (4.14, 4.16) land.
