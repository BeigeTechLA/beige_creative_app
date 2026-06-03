# Task 6.02 — Repository unit tests batch 1

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Unit tests for `AuthRepository`, `ProfileRepository`, `HomeRepository`. Each covers happy + 401 + 5xx + cancel paths.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 6
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.2, §9.4

## Files in scope (3)
- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/profile/data/repositories/profile_repository_impl_test.dart`
- `test/features/home/data/repositories/home_repository_impl_test.dart`

## Steps
- [x] Mock `DioClient` per test (`MockDioClient` + `MockDio` from `test/helpers/mocks.dart`); assert the right method + path + body via `verify(...).captured`.
- [x] Repos throw on errors (do not return `Either`); tests assert `throwsA(...)` for both server envelopes and transport failures. **Deviation logged** below — Phase 4 docs note the same.
- [x] AAA pattern (Arrange → Act → Assert) with one section comment per group.
- [x] Min 3 cases per method (happy + error envelope + cancel/transport).

## Acceptance
- [x] All 3 repo test files pass (`83 / 83`: auth `32`, profile `26`, home `25`).
- [x] Every method in each repo has at least one happy + one error envelope test; representative methods also cover 401, 5xx, and cancel.
- [x] No real network calls — `MockDio` is wired through `MockDioClient.dio`, mocktail `verify(...)` checks the captured path/body.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (344 events).

## Notes
- **Deviation from spec — `Either` left/right**: Live repos in `lib/features/{auth,profile,home}/data/repositories/*_impl.dart` throw `Exception` / let `DioException` propagate rather than returning `Either<AppException, T>`. Tests follow the live contract. Aligning everything to `Either` is its own pass (see `docs/AI_HANDOFF.md` "Known deviation" — would touch every repo + every Notifier catch block).
- **Cancel path**: Live repos `await dio.<verb>` directly, so a `DioException(type: DioExceptionType.cancel)` propagates untouched. Tests stub the call to throw that exception and assert `e.type == DioExceptionType.cancel`. No `CancelToken` is exercised at the repo layer because none of the live methods accepts one yet; wiring CancelTokens through is a follow-up the Notifier-cancel work in 6.04–6.06 will inherit.
- **`registerStep1` / `uploadPhoto` multipart**: real `MultipartFile.fromFile` reads from disk, so those tests write a 4-byte temp file in `Directory.systemTemp` and clean it up in `tearDown` — keeps the test hermetic without faking the `FormData` API.
- **`MyProfileModel.fromJson` brittleness**: triggered when `data.user.primary_role` is a non-null non-list (decoded via `jsonDecode`). The `profileResponse` fixture already defaults that field to `null`; tests asserting on role pass `'["1"]'` etc. as documented in `test/helpers/test_data.dart`.
