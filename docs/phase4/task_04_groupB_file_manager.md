# Task 4.04 — Group B · Unit 4 · File Manager (4 screens)

**Phase:** 4 · **Group:** B · **Status:** 🔴 Not Started · **Est:** 3.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupB-file-manager` |

## Goal
Migrate the four file-manager screens (1,462 LOC combined) to Clean Architecture + Riverpod. Exercises the multi-screen feature template for the first time.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group B; §4 Risk #8 (controller leaks)
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 10)
- `lib/features/file_manager/data/` (datasource + repo impl)
- `lib/features/file_manager/domain/` (repo interface + entities)
- `lib/features/file_manager/presentation/providers/` (1 notifier per screen)
- `lib/features/file_manager/presentation/screens/`: `file_manager_screen.dart` (604), `pre_production_screen.dart` (434), `post_production_screen.dart` (173), `view_details_screen.dart` (251)
- Delete old `lib/file_manager/`

## Steps
- [ ] Repo + datasource with 3 endpoints
- [ ] One Notifier per screen (lifts list state + filters)
- [ ] Replace `ApiService()` instantiations with repo provider
- [ ] All `TextEditingController`s owned + disposed by Notifier
- [ ] Widget test on file_manager root screen

## Acceptance
- [ ] `flutter analyze` clean
- [ ] All 4 screens render and fetch data
- [ ] No `setState` after migration
- [ ] No `ApiService()` instantiation in this feature

## Notes
Establishes the per-feature pattern that every remaining feature unit follows.
