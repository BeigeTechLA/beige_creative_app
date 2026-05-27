# Task 6.01 — Expand test helpers

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/test-helpers` |

## Goal
Expand `test/helpers/` to support the full Phase 6 suite. The minimal `pumpProviderApp` (Task 3.16) is already there; this task adds `mocks.dart` and `test_data.dart`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 6
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.1

## Files in scope
- `test/helpers/pump_app.dart` — extend with `pumpRouterApp` for GoRouter tests
- `test/helpers/mocks.dart` — `MockDioClient`, `MockSessionStore`, `Mock<RepositoryName>` for each repo
- `test/helpers/test_data.dart` — JSON fixtures for `LoginResponse`, `ProfileResponse`, `ShootListResponse`, etc.

## Steps
- [ ] Generate `MockX` classes via `mocktail` (no codegen)
- [ ] Fixture JSON drawn from real API responses (sanitized)
- [ ] One smoke test per helper to prove import works

## Acceptance
- [ ] `flutter test` passes
- [ ] Helpers importable from any test file
- [ ] At least one mock + one fixture used in a smoke test

## Notes
Don't pre-create mocks for every class — add as needed. Keep `test_data.dart` focused on response shapes the tests actually assert against.
