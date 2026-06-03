# Task 6.11 — Integration test: login → home → logout

**Phase:** 6 · **Status:** 🟢 Completed · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/integration-login` |

## Goal
End-to-end test: launch → enter creds → reach home → trigger logout → return to login. Mock the Dio layer only — UI + routing + state are real.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.1 (`integration_test/` — separate folder)

## Files in scope (max 2)
- `integration_test/login_logout_test.dart`
- `integration_test/robots/auth_robot.dart` (helper)

## Steps
- [x] Stub `DioClient` with canned response for `auth/login`
- [x] Drive UI through robots pattern (`AuthRobot.enterEmail`, etc.)
- [x] Verify final screen + session state cleared

## Acceptance
- [x] `flutter test integration_test/login_logout_test.dart -d macos` passes
- [x] Test runs in vm-mode on macOS; on-device promotion is a one-line binding swap
- [x] Robots pattern adopted (per `MIGRATION_RULES.md` §9.1)

## Notes
First integration test sets the pattern. Future integration tests reuse the robots.
The harness mounts the real `LoginScreen`, `LoginNotifier`, `SessionStore`,
`authStateProvider`, and auth-driven GoRouter refresh. It intentionally uses a
minimal 2-route router so the test stays focused on login/session/logout rather
than full shell rendering.
