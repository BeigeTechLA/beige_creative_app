# Task 6.04 — Notifier tests: auth + profile

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Unit tests for auth + profile Notifiers. State transitions on each action — happy, validation error, server error.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.3 Riverpod-Specific Testing

## Files in scope (actual: 8)
Existing Phase 4 tests already covered all 14 auth + profile Notifiers. Path layout differs from spec — tests live under `test/features/<feature>/presentation/` (one file per provider group), not `test/features/<feature>/presentation/providers/`. Mapping:

- `test/features/auth/presentation/login_notifier_test.dart` — `LoginNotifier` (+ AuthState logout telemetry).
- `test/features/auth/presentation/signup_notifier_test.dart` — `SignupNotifier` (covers step1 / step2 lookups / step3 mutators / submitStep1–3 — sub-screens share one Notifier, so the spec's separate `signup3_*` files don't apply).
- `test/features/auth/presentation/forgot_password_notifier_test.dart` — `ForgotPasswordNotifier` (requestOtp / verifyOtp / resetPassword / resendOtp + B1 events).
- `test/features/profile/presentation/my_profile_notifier_test.dart` — `MyProfileNotifier`.
- `test/features/profile/presentation/profile_files_test.dart` — `ResumeNotifier`, `CertificatesNotifier`, `FeaturedWorkNotifier`, **`ProfileDetailsViewNotifier` (added in this task — see Steps)**.
- `test/features/profile/presentation/profile_details_test.dart` — `EditPersonalNotifier`, `EnterProfessionalNotifier`.
- `test/features/profile/presentation/change_password_test.dart` — `RequestOtpNotifier`, `VerifyOtpNotifier`, `NewPasswordNotifier`.
- `test/features/profile/presentation/delete_account_test.dart` — `DeleteAccountNotifier` (+ B1 events).

## Steps
- [x] Audited all 14 auth + profile Notifier classes against existing tests — 13 already covered with ≥ 3 cases per public method (validation / happy / repo-error and B1 telemetry where relevant).
- [x] Filled the only gap: `ProfileDetailsViewNotifier` (refresh + selectTab) added to `profile_files_test.dart` — happy refresh, refresh failure, selectTab no-re-fetch.
- [x] Existing tests already use `ProviderContainer` + repo-provider override + state transitions after `await notifier.method()`, matching MIGRATION_RULES.md §9.3.

## Acceptance
- [x] All test files pass.
- [x] Every public Notifier method has ≥ 3 cases (validation / happy / error or equivalent).
- [x] No real API calls — every test uses an inline `_FakeRepo` or `_FakeAuthRepo`.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (382 events).

## Notes
- **Sub-screen Notifiers** for signup3 do not exist. The legacy spec assumed one Notifier per screen; in this codebase `SignupNotifier` owns step1 / step2 / step3 state and mutators. Existing `signup_notifier_test.dart` covers all 3 steps.
- **`featured_work_notifier_test.dart` (spec name) lives inside `profile_files_test.dart`** because `ResumeNotifier` / `CertificatesNotifier` / `FeaturedWorkNotifier` share the `ProfileFilesRepository`. Splitting would duplicate the `_FakeRepo` fake. Kept together intentionally.
- **`my_profile_notifier_test.dart`** is at `test/features/profile/presentation/my_profile_notifier_test.dart`, not the deeper `providers/` path the spec mentions. Path correction not made — would break grep history.
- **Gap fill mapping**: `ProfileDetailsViewNotifier.refresh()` covered by happy (`fetchCount == 1`, profile non-null) + failure (`errorMessage == 'Failed to load profile'`). `selectTab` covered by single sync mutation test that also asserts no extra fetch fires. 3 new tests, +3 events on the suite.
