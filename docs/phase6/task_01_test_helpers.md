# Task 6.01 — Expand test helpers

**Phase:** 6 · **Status:** 🟢 Completed (2026-05-31) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Expand `test/helpers/` to support the full Phase 6 suite. The minimal `pumpProviderApp` (Task 3.16) was already there; this task adds `pumpRouterApp`, `mocks.dart`, and `test_data.dart`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 6
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.1

## Files in scope (4)
- `test/helpers/pump_app.dart` — added `pumpRouterApp` extension method (GoRouter-aware harness).
- `test/helpers/mocks.dart` — **new** — `MockDioClient`, `MockDio`, `MockSessionStore`, `FakeSecureSessionBackend`, `FakePrefsSessionBackend`, `registerHelperFallbacks()`.
- `test/helpers/test_data.dart` — **new** — `loginResponse`, `profileResponse`, `dashboardCountResponse`, `shootCountResponse`, `shootsListResponse`, `singleShootJson`, `errorResponse` builders.
- `test/helpers/helpers_smoke_test.dart` — **new** — 6 smoke tests exercising each helper.

## Steps
- [x] `pumpRouterApp(GoRouter)` extension mounts `MaterialApp.router` against a caller-supplied router — supports redirect / `state.extra` / navigation assertions.
- [x] `mocks.dart` uses `mocktail: ^1.0.4` (already in `pubspec.yaml`). `MockDioClient` + `MockSessionStore` cover the cross-cutting deps; feature-repo mocks stay inline per task notes ("Don't pre-create mocks for every class").
- [x] `FakeSecureSessionBackend` + `FakePrefsSessionBackend` round-trip in memory — paired with the real `CompositeSessionStore` for tests that want behavior, not stubs.
- [x] `test_data.dart` builders return `Map<String, dynamic>` so consumers round-trip through `fromJson` just like the wire would.
- [x] Smoke tests validate import paths + round-trips (`MyProfileModel.fromJson(profileResponse(...))` passes).

## Acceptance
- [x] `flutter test` passes (**151/151**, up from 145 — 6 helper smoke tests added).
- [x] Helpers importable from any test file (relative `import '../helpers/...'`).
- [x] At least one mock + one fixture used in a smoke test (`MockSessionStore`, `profileResponse`, `loginResponse`, `errorResponse`, fake-session-backends).
- [x] `flutter analyze --fatal-infos` clean.

## Notes
- `profileResponse` fixture defaults `user.primary_role` to `null` because `User.fromJson` decodes it as a JSON list when non-null. Tests asserting on the decoded role pass `'[\"1\"]'` (or similar) explicitly.
- `registerHelperFallbacks()` is opt-in — tests that stub `MockDio.post(..., options: ...)` call it from `setUpAll`; everything else skips it.
- No feature-repo mocks added yet — tasks 6.02 / 6.03 introduce them as needed.
