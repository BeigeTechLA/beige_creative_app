# Task 6.07 — Widget tests: auth

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Widget tests for login, signup3 sub-screens, forgot password trio. Render check + golden submit interaction with mocked Notifier.

## Files in scope (actual: 3)
- `test/features/auth/presentation/screens/login_screen_test.dart` — **new** — 4 tests: render of email + password + Login + Forgot + Sign Up; button disabled on empty form; valid submit invokes `notifier.login(email, password)`; saved credentials hydrate from `LoginState`.
- `test/features/auth/presentation/screens/forgot_password_screens_test.dart` — **new** — 8 tests covering all three forgot-password screens. `ForgotPasswordScreen`: render + disabled CTA + tap-invokes-requestOtp-with-trimmed-email. `ForgotPasswordOtpScreen`: render of 6 OTP cells + Submit invokes `verifyOtp` with full 6-char code. `ResetPasswordScreen`: render + disabled CTA + tap-invokes-resetPassword.
- `test/features/auth/presentation/screens/signup3_screen_test.dart` — **new** — 2 smoke tests: render checks (`Social Engagement`, `3/3`, `Add Social Links`, `Add Portfolio Link (Optional)`, `Create Profile`); tap `Create Profile` invokes `submitStep3`.

**`signup3_resume_screen_test.dart`, `signup3_portfolio_screen_test.dart`, `signup3_certifications_screen_test.dart`, `signup3_recent_work_media_screen_test.dart` — NOT created.** SignUp3 is a single screen, not four sub-screens — see Notes.

## Steps
- [x] `pumpRouterApp` + override the relevant Notifier provider with a fake.
- [x] Asserted key widgets render + tap interactions invoke expected Notifier methods (via captured-call counters on the fakes).
- [x] Smoke-tested validation gating per screen — disabled-CTA tests on login + forgot + reset assert `ElevatedButton.onPressed == null` when form is empty.

## Acceptance
- [x] All test files pass (`14 / 14`: login `4`, forgot trio `8`, signup3 `2`).
- [x] Widget coverage on auth: every entry-point screen (login, forgot-password, otp, reset-password, signup3) has at least render + happy-tap; login + forgot trio also covers form-gating.
- [x] No real API calls — every test overrides the notifier provider with a fake that records calls in counters; no `Dio` ever constructed.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (418 events).

## Notes
- **SignUp3 is one screen, not four.** The spec assumed legacy sub-screens (resume / portfolio / certifications / recent-work-media) that were never carved out of `SignUp3Screen`. The four "sub-screens" are sections inside the one composite screen — file pickers, bottom sheets, and inline forms. Full interaction coverage already lives in `signup_notifier_test.dart`; the widget test here is a render-smoke + Create-Profile-tap canary so a top-level layout regression fails fast.
- **`pumpRouterApp` + `runAsync`** is the canonical pattern for these screens. Each screen uses `Image.asset(AppAssets.rectangle)` + `SvgPicture.asset(...)` which fail to decode under the test bundle; wrapping in `runAsync` + suppressing `FlutterError.onError` keeps the test focused on Notifier wiring rather than asset rendering.
- **Notifier override choice differs per screen.** Login + Forgot use `overrideWith(() => fake)` where the fake implements the public Notifier surface (records calls, returns canned booleans). SignUp3 instead `extends SignupNotifier` and only overrides `build` + `submitStep3` — the SignupNotifier surface is too large (35+ methods, many with positional/named param overloads) to mock by `implements`. Extending the real class skips the repo-touching paths the test never triggers and keeps SignupNotifier-surface drift from breaking the test.
- **The fakes deliberately do NOT call `super.build()`**. The real `LoginNotifier.build` calls `loadSavedCredentials` which reads `PrefsService` — uninitialised in widget tests. Fake `build` just returns the seeded `LoginState`. Same shape for `ForgotPasswordNotifier`.
- **Hydration test** (login) drives the screen by providing a `LoginState(savedCredentialsLoaded: true, savedEmail: 'saved@x.io', savedPassword: 'saved-pw')` and asserting both text fields show the saved values — covers the `_hydrateSavedCredentials` private method in `_LoginScreenState` without needing to touch SharedPreferences.
