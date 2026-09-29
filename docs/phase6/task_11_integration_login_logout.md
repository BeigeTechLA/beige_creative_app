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

## Session-expiry follow-up (2026-09-29)

- [x] Centralize HTTP 401 cleanup in `AuthStateNotifier.expireSession()` and
  connect the shared Dio callback to it. Auth state changes notify the router.
- [x] Share cleanup with explicit logout, deduplicate repeated expiry, clear
  temporary/persisted sessions, cached user snapshot, restoration and drafts.
- [x] Route Messages/Meetings unauthorized fallbacks through expiry without
  emitting a user-initiated logout event.
- [x] Add real Dio interceptor/provider tests for the supplied missing-token
  401, repeated failures, re-login, 200/403 exclusions and cleanup failure.
- [ ] Verify expired-token navigation against the backend on a device.

Scope extends this completed journey task for the requested session-expiry fix;
the original integration-test status is unchanged.

## Backend code contract correction (2026-09-29)

- [x] Supersede status-only expiry with exact `SESSION_EXPIRED` / `TOKEN_INVALID`
  matching in both success and error response handlers.
- [x] Preserve sessions for `TOKEN_MISSING`, missing/unknown codes and message-only errors.
- [x] Remove generic unauthorized logout fallbacks from Messages/Meetings.
- [x] Cover both allowed codes and excluded codes across HTTP 200/401/403,
  alongside cleanup, deduplication, re-login and explicit logout tests.
- [ ] Verify the updated contract on device against the backend.
