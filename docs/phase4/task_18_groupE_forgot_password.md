# Task 4.18 — Group E · Unit 15 · Forgot Password trio

**Phase:** 4 · **Group:** E · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupE-forgot` |

## Goal
Migrate the 3-screen linear forgot-password flow: request (362) → OTP (400) → new password (332). Mirrors profile-change-password chain pattern.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group E Unit 15

## Files in scope (max 6)
- `lib/features/auth/data/repositories/auth_repository_impl.dart` (forgotPassword + verifyOtp + resetPassword)
- `lib/features/auth/presentation/providers/forgot_password_notifier.dart` + `_state.dart`
- `lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart`
- `lib/features/auth/presentation/screens/reset_password_screen.dart`

## Steps
- [ ] Single Notifier coordinates 3-step machine (state: requested → otpEntered → resetSucceeded)
- [ ] Email + OTP carried via `state.extra` Map between routes
- [ ] On success → snack + `context.goNamed(login)`
- [ ] Widget tests for OTP entry + validation

## Acceptance
- [ ] All 3 screens migrated
- [ ] Full flow works end-to-end on dev backend
- [ ] No `setState`
- [ ] `flutter analyze` clean

## Notes
Pattern reusable in profile change-password (Task 4.06) — verify the two flows share the OTP entry widget once both land.
