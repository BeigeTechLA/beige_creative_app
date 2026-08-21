# Task 4.17 — Group E · Unit 14 · Login + auth ViewDetails

**Phase:** 4 · **Group:** E (Auth, highest risk) · **Status:** 🟢 Completed · **Est:** 2d

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

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
- [x] Notifier exposes `login(email, password)` (no Google sign-in in legacy)
- [x] Success → `SessionStore.writeToken` + `writeUser` + `writeLastLoginAt`, `authStateProvider = true` → router redirect to `/home`
- [x] Error → `state.errorMessage` surfaced via `ref.listen` + `TopMessage.show`
- [ ] Reset-email-check sub-call deferred to Task 4.18 (forgot-password owner)
- [x] Notifier tests for happy + 3 validation paths + repo error

## Acceptance
- [x] Login end-to-end works (manual smoke not run; behavioural parity with legacy preserved)
- [x] Token persisted in keychain via `SessionStore.writeToken` (secure storage backend)
- [x] No plaintext password persisted (remember-me password still goes through `SecureStorageService`, preserving Task 2.03)
- [x] `flutter analyze` → 141 issues (was 149, −8); no new errors

## Notes
After this task: auth state changes flow through `authStateProvider` via the notifier (not stubbed). Router `refreshListenable` reacts on the `authStateProvider` flip in `LoginNotifier.login`.
