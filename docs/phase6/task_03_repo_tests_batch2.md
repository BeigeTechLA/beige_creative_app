# Task 6.03 — Repository unit tests batch 2

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/repo-tests-2` |

## Goal
Unit tests for `ShootsRepository`, `FileManagerRepository`, `AvailabilityRepository`. Each covers happy + 401 + 5xx + cancel.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.2

## Files in scope (3)
- `test/features/shoots/data/repositories/shoots_repository_impl_test.dart`
- `test/features/file_manager/data/repositories/file_manager_repository_impl_test.dart`
- `test/features/availability/data/repositories/availability_repository_impl_test.dart`

## Steps
- [ ] Mirror Task 6.02 pattern
- [ ] AAA + ≥3 cases per method
- [ ] Mock multipart upload paths where relevant

## Acceptance
- [ ] All 3 test files pass
- [ ] Coverage on these repos ≥ 80%
- [ ] No real network calls

## Notes
After this task: every repository has dedicated tests. Notifier-level tests follow.
