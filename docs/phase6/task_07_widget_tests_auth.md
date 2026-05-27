# Task 6.07 — Widget tests: auth

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/widget-auth` |

## Goal
Widget tests for login, signup3 sub-screens, forgot password trio. Render check + golden submit interaction with mocked Notifier.

## Files in scope (max 6)
- `test/features/auth/presentation/screens/login_screen_test.dart`
- `test/features/auth/presentation/screens/signup3_resume_screen_test.dart`
- `test/features/auth/presentation/screens/signup3_portfolio_screen_test.dart`
- `test/features/auth/presentation/screens/signup3_certifications_screen_test.dart`
- `test/features/auth/presentation/screens/signup3_recent_work_media_screen_test.dart`
- `test/features/auth/presentation/screens/forgot_password_screen_test.dart`

## Steps
- [ ] `pumpProviderApp` + override the relevant Notifier with a fake state
- [ ] Assert key widgets present + interactions trigger expected Notifier methods (via mock verify)
- [ ] Smoke test happy + validation error per screen

## Acceptance
- [ ] All test files pass
- [ ] Widget coverage on auth ≥ 60%
- [ ] No real API calls

## Notes
Login + signup3 are the most-broken-after-change screens. Treat their widget tests as the canary.
