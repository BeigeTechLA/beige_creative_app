# Task 4.06 — Group C · Unit 9 · Profile settings

**Phase:** 4 · **Group:** C · **Status:** 🔴 Not Started · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-settings` |

## Goal
Migrate the lowest-complexity profile sub-cluster: AppPreferences + the change-password chain + You're-all-set. 5 screens, all small. Builds momentum into the bigger Group C tasks.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 9; intra-group order
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 10)
- `lib/features/profile/data/repositories/profile_repository_impl.dart` (extended for password endpoints)
- `lib/features/profile/presentation/providers/change_password_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/screens/app_preferences_screen.dart` (193 LOC)
- `lib/features/profile/presentation/screens/change_password_screen.dart` (274 LOC — new since 2026-05-21)
- `lib/features/profile/presentation/screens/profile_otp_screen.dart` (343 LOC — new since 2026-05-21)
- `lib/features/profile/presentation/screens/profile_new_password_screen.dart` (319 LOC — fix typo)
- `lib/features/profile/presentation/screens/profile_youre_all_set_screen.dart` (65 LOC)

## Steps
- [ ] Lift forms into Notifiers; validation via state
- [ ] Replace typo'd class name (Task 2.02 should have already renamed file; verify class follows)
- [ ] Wire 3-step chain (change → otp → new password) with `state.extra` payload pattern per `CLAUDE.md`
- [ ] Widget tests for the 3-step happy path

## Acceptance
- [ ] All 5 screens render
- [ ] Password change end-to-end works
- [ ] `flutter analyze` clean
- [ ] No `setState`, no `Navigator.push`

## Notes
The chain demonstrates `state.extra` Map payload across 3 routes — same pattern used by signup chain in Group E.
