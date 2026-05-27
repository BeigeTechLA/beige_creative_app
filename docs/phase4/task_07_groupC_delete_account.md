# Task 4.07 — Group C · Unit 10 · Delete account flow

**Phase:** 4 · **Group:** C · **Status:** 🔴 Not Started · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-delete-account` |

## Goal
Migrate the linear 3-screen delete-account flow: confirm → OTP → lottie success → `/login`. Exercises destructive-action UX patterns + `SessionStore.logout()` (scoped — not `prefs.clear()`).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 10
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 6)
- `lib/features/profile/data/repositories/profile_repository_impl.dart` (add deleteAccount + verifyOtp)
- `lib/features/profile/presentation/providers/delete_account_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/screens/delete_account_screen.dart` (275 LOC)
- `lib/features/profile/presentation/screens/delete_account_otp_screen.dart` (334 LOC)
- `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart` (75 LOC — fix camelCase)
- `lib/app/router.dart` — 3 route definitions

## Steps
- [ ] Repo methods: `requestDelete`, `verifyDeleteOtp` → on success call `SessionStore.logout()` then `context.goNamed(RouteNames.login)`
- [ ] Notifier coordinates the 3-step state machine
- [ ] Widget tests for OTP entry validation
- [ ] Test: after deletion, re-launching app routes to login (not stale home)

## Acceptance
- [ ] All 3 screens migrated
- [ ] Successful deletion redirects to login + clears session
- [ ] No `setState`
- [ ] `flutter analyze` clean

## Notes
Destructive action — keep the confirmation copy verbatim from current UI (do not "improve" during migration per `MIGRATION_RULES.md` §12).
