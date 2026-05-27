# Task 6.02 — Repository unit tests batch 1

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/repo-tests-1` |

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
- [ ] Mock `DioClient` per test; assert the right method + path + headers
- [ ] Assert `Either<AppException, T>` left + right for each branch
- [ ] AAA pattern: Arrange → Act → Assert (`MIGRATION_RULES.md` §9.2)
- [ ] Min 3 cases per method (happy, error, cancel)

## Acceptance
- [ ] All 3 repo test files pass
- [ ] Coverage on those repos ≥ 80%
- [ ] No real network calls (verify with mocktail)

## Notes
Cancel-path test uses `CancelToken` cancellation mid-flight — verifies `RequestCancelledException` is returned, not thrown.
