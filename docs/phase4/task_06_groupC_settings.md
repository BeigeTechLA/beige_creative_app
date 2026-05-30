# Task 4.06 — Group C · Unit 9 · Profile settings

**Phase:** 4 · **Group:** C · **Status:** ✅ Completed · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` |

## Goal
Migrate the lowest-complexity profile sub-cluster: AppPreferences + the change-password chain + You're-all-set. 5 screens, all small. Builds momentum into the bigger Group C tasks.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 9; intra-group order
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 10)
- `lib/features/profile/domain/repositories/change_password_repository.dart` — 4-method interface
- `lib/features/profile/data/repositories/change_password_repository_impl.dart` — Dio-backed
- `lib/features/profile/presentation/providers/change_password_providers.dart` — repo provider + 3 notifiers + 3 state classes + `isValidEmail` helper
- `lib/features/profile/presentation/screens/app_preferences_screen.dart` (was 193 LOC; class renamed `AppPreferences` → `AppPreferencesScreen`)
- `lib/features/profile/presentation/screens/change_password_screen.dart`
- `lib/features/profile/presentation/screens/profile_otp_screen.dart`
- `lib/features/profile/presentation/screens/profile_new_password_screen.dart` (class renamed `MyprofileNewPasswordScreen` → `ProfileNewPasswordScreen`)
- `lib/features/profile/presentation/screens/profile_youre_all_set_screen.dart` (class renamed `MyprofileYoureAllSetScreen` → `ProfileYoureAllSetScreen`)
- `test/features/profile/presentation/change_password_test.dart` — 10 cases
- (Glue: `lib/app/router.dart` import + class renames; `lib/auth/resetpassword/reset_password_screen.dart` import update; `lib/profile/` 5 legacy files deleted)

## Steps
- [x] Lift forms into Notifiers; validation via state — `RequestOtpNotifier`, `VerifyOtpNotifier`, `NewPasswordNotifier`. Each exposes `validationMessage` + `errorMessage` in state; `ref.listen` in widget drives `TopMessage.show`.
- [x] Replace typo'd class names — `MyprofileNewPasswordScreen` → `ProfileNewPasswordScreen`; `MyprofileYoureAllSetScreen` → `ProfileYoureAllSetScreen`; `AppPreferences` → `AppPreferencesScreen`. Router builders + the 1 external consumer (`auth/resetpassword/reset_password_screen.dart`) updated.
- [x] Wire 3-step chain (change → otp → new password) with `state.extra` payload pattern per CLAUDE.md — kept legacy pattern: `{email: ...}` from change → otp, `{email, otp}` from otp → new password.
- [x] Widget tests for the 3-step happy path — 10 notifier unit cases covering: request-OTP validation + happy + error; verify-OTP rejects partial + happy + resend; new-password rejects mismatch + short + happy.

## Acceptance
- [x] All 5 screens render — `app_preferences`, `change_password`, `profile_otp`, `profile_new_password`, `profile_youre_all_set`.
- [x] Password change end-to-end works — full Dio chain wired: `auth/forgot-password-check` → `auth/forgot-password-verify-otp` → `auth/reset-password`. Legacy had the final API call commented out (TODO marker); this task **enables it**.
- [x] `flutter analyze` → 265 issues (was 285; net **-20** from removing 5 legacy files which had ~6 `print` + ~10 deprecated + several unused lints).
- [x] No `setState` for form/network state — `setState` retained only for widget-lifecycle UI (OTP focus-color refresh, password visibility toggle).
- [x] No `Navigator.push` for the chain — `context.pushNamed` with `state.extra`. `Navigator.push` remains in `reset_password_screen.dart` (Group E scope).

## Notes
**Endpoint reuse for resend + finalize:** Backend reuses `auth/reset-password` for both OTP resend (payload `{email}`) and password finalize (payload `{email, otp, new_password, confirm_password}`). The repository exposes them as separate methods (`resendOtp`, `setNewPassword`) so the screens don't need to know about the shared endpoint. Documented in MIGRATION_LOG.

**Controllers stay in widgets** — same precedent as 4.01/4.02/4.04/4.05. OTP screen owns 6 text controllers + 6 focus nodes; Timer also widget-scoped. Notifier only holds parsed values + flow flags.

**Calibration:** ~60 min vs. 2d budget. Mid-complexity API task with 3 API calls + 5 screens; smaller than 4.05 but more screens. Confirms 4.05 wasn't a one-off — Group C's standard-shape tasks fit a ~1 hr / 1k LOC / 3-5 screens template.
