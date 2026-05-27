# Task 4.17 — Group E · Unit 14 · Login + auth ViewDetails

**Phase:** 4 · **Group:** E (Auth, highest risk) · **Status:** 🔴 Not Started · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupE-login` |

## Goal
Migrate `Login` (382 LOC) + auth landing `ViewDetailsScreen` (276 LOC, rename file with literal space already done in 2.01). First Group E task — `SessionStore` (Phase 3.13) must be stable.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group E Unit 14

## Files in scope (max 5)
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/presentation/providers/login_notifier.dart` + `_state.dart`
- `lib/features/auth/presentation/screens/login_screen.dart` + `view_details_screen.dart`

## Steps
- [ ] Notifier exposes `login(email, password)` + `googleSignIn()` (if relevant)
- [ ] Success → `SessionStore.writeToken` → router redirect to `/home`
- [ ] Error → `state.errorMessage` shown via `ref.listen` snackbar
- [ ] Migrate the reset-email-check sub-call
- [ ] Widget tests for happy + validation paths

## Acceptance
- [ ] Login end-to-end works
- [ ] Token persisted in keychain (not prefs)
- [ ] No plaintext password persisted anywhere (verify Task 2.03 still in effect)
- [ ] `flutter analyze` clean

## Notes
After this task: auth state changes will start to flow through `authStateProvider` for real (not stubbed). Verify the router `redirect:` reacts correctly.
