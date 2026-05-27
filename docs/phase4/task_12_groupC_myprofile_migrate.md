# Task 4.12 — Group C · Unit 6.b · Migrate `Myprofile`

**Phase:** 4 · **Group:** C · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-myprofile` |

## Goal
Migrate the post-split profile entry screen to Riverpod. ~6 API calls, drawer integration, logout flow.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 6

## Files in scope (max 8)
- `lib/features/profile/presentation/providers/my_profile_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/screens/my_profile_screen.dart`
- All widgets created in 4.11 (consume notifier via `ref.watch`)
- `lib/main_screen.dart` — drawer navigation update
- Delete legacy `lib/profile/myprofile.dart`

## Steps
- [ ] `AsyncNotifier` initialization fetches profile data
- [ ] Notifier owns refresh, logout, navigation triggers
- [ ] Stats panel updates via `ref.watch` only — no `setState`
- [ ] Drawer logout calls `SessionStore.logout()` → router redirect
- [ ] Widget tests for happy path

## Acceptance
- [ ] All 6 API calls flow through repo
- [ ] No `setState` in profile screen or its widgets
- [ ] No `ApiService()` instantiations remain in Profile feature
- [ ] `flutter analyze` clean

## Notes
Group C completion = ~30% of total feature migration done. Re-baseline Groups D + E using cumulative actuals.
