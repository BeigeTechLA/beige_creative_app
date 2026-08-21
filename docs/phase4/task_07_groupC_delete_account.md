# Task 4.07 — Group C · Unit 10 · Delete account flow

**Phase:** 4 · **Group:** C · **Status:** ✅ Completed · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` |

## Goal
Migrate the linear 3-screen delete-account flow: confirm → OTP → lottie success → `/login`. Exercises destructive-action UX patterns + `SessionStore.clearSession()` (scoped — not `prefs.clear()`).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 10
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 6)
- `lib/features/profile/domain/repositories/delete_account_repository.dart`
- `lib/features/profile/data/repositories/delete_account_repository_impl.dart`
- `lib/features/profile/presentation/providers/delete_account_providers.dart` — repo provider + notifier + state
- `lib/features/profile/presentation/screens/delete_account_screen.dart` (was 275 LOC; class renamed `DeleteAccount` → `DeleteAccountScreen`)
- `lib/features/profile/presentation/screens/delete_account_otp_screen.dart`
- `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart`
- `test/features/profile/presentation/delete_account_test.dart` — 6 cases
- (Glue: `lib/app/router.dart` 3 imports + 1 class reference; `lib/profile/deleteaccount/` deleted)

## Steps
- [x] Repo methods: `requestDelete`, `confirmDelete`, `resendOtp`. On `confirmDelete` success the notifier calls `sessionStoreProvider.clearSession()` + flips `authStateProvider` to `false`. Widget then `context.goNamed(deleteAccountSuccess)`; lottie screen auto-redirects to `/login` after 3s.
- [x] Notifier coordinates the 3-step state machine — single `DeleteAccountNotifier` covers all 3 screens (request, confirm, resend) since they share the same session state.
- [x] Widget tests for OTP entry validation — `confirmDelete` rejects 3-digit input.
- [x] Test: post-deletion auth state is `false` + session cleared — covered explicitly.

## Acceptance
- [x] All 3 screens migrated — `DeleteAccountScreen`, `DeleteAccountOtpScreen`, `DeleteAccountLottieScreen`.
- [x] Successful deletion redirects to login + clears session — `confirmDelete` happy-path test asserts `session.cleared == true` and `authStateProvider == false`; lottie screen then `Future.delayed(3s) → context.goNamed(login)`.
- [x] No `setState` for network/form state — `setState` retained only for OTP focus-color refresh (widget-lifecycle UI).
- [x] `flutter analyze` → 254 issues (was 265; net **-11** from removing 3 legacy files containing `debugPrint` + deprecated patterns + the latent `response.error` Map-access bug that would have thrown at runtime).

## Notes
**Latent bug fixed:** Legacy `delete_account.dart` / `delete_account_otp_screen.dart` called `response.error` on `Future<dynamic>` — `dynamic` field access against the underlying `Map<String, dynamic>` throws `NoSuchMethodError` at runtime. New `DeleteAccountRepositoryImpl._postOrThrow` uses `data is Map && data['error'] == true` correctly.

**Resend OTP endpoint** matches legacy: reuses `restartpassword` (`auth/reset-password`) with empty body. Likely a backend mis-wiring (the password-reset endpoint reused for the delete-account flow) — flagged for backend confirmation. Preserved verbatim to keep parity; swap endpoint once backend lead clarifies.

**Class rename:** `DeleteAccount` → `DeleteAccountScreen` (consistent with `*Screen` suffix convention across the migrated `features/` tree). Router builder updated.

**Session-clear ordering:** Session cleared *after* the backend confirms the deletion, not before. If `confirmDelete` throws, the user stays logged in — they can retry the OTP entry. Test `repo failure leaves session intact` enforces this.

**Calibration:** ~45 min vs. 2d budget. Similar shape to 4.06 (3 screens, OTP timer, multi-step flow) but fewer notifiers. Group C pattern is consolidating: ~45-60 min per standard-shape unit.
