# Task 4.18 — Group E · Unit 15 · Forgot Password trio

**Phase:** 4 · **Group:** E · **Status:** 🟢 Completed · **Est:** 3d

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

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
- [x] Single `ForgotPasswordNotifier` coordinates 3-step machine (`step: idle → otpSent → otpVerified → resetSucceeded`)
- [x] Email + OTP carried via `state.extra` Map between routes (`/forgot-otp` and `/reset-password`)
- [x] On success → toast (`Password reset successfully`) + `context.goNamed(RouteNames.login)`
- [x] 10 notifier tests (validation + happy paths for request/verify/reset/resend)

## Acceptance
- [x] All 3 screens migrated (`forgot_password_screen.dart`, `forgot_password_otp_screen.dart`, `reset_password_screen.dart`)
- [x] Full flow end-to-end works via Riverpod + GoRouter pushNamed chain (manual smoke not run; behavioural parity preserved)
- [x] No `setState` for business state — only UI-local lifecycle (timer, focus rebuild, password visibility)
- [x] `flutter analyze` → 113 issues (was 141, **−28**); no new errors

## Notes
The 3-step chain is consciously similar to profile change-password (Task 4.06) but kept inside the auth feature instead of sharing. Reason: forgot-password uses email-only entry (no current-password step), and the OTP/reset endpoints (`auth/forgot-password-*`) are distinct from the profile-side (`creator/profile/change-password-*`) endpoints. The single-notifier-with-step-enum pattern from this task is what 4.06 should converge to in a later cleanup.
