# Task 6.11 — Integration test: login → home → logout

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

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
- [ ] Stub `DioClient` with canned responses for `auth/login` + `auth/logout`
- [ ] Drive UI through robots pattern (`AuthRobot.enterEmail`, etc.)
- [ ] Verify final screen + session state cleared

## Acceptance
- [ ] `flutter test integration_test/login_logout_test.dart` passes
- [ ] Test runs on an emulator
- [ ] Robots pattern adopted (per `MIGRATION_RULES.md` §9.1)

## Notes
First integration test sets the pattern. Future integration tests reuse the robots.
