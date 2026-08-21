# Task 6.03 — Repository unit tests batch 2

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Unit tests for `ShootsRepository`, `FileManagerRepository`, `AvailabilityRepository`. Each covers happy + 401 + 5xx + cancel.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.2

## Files in scope (3)
- `test/features/shoots/data/repositories/shoots_repository_impl_test.dart`
- `test/features/file_manager/data/repositories/file_manager_repository_impl_test.dart`
- `test/features/availability/data/repositories/availability_repository_impl_test.dart`

## Steps
- [x] Mirrored the 6.02 pattern (`MockDioClient.dio = MockDio`, AAA, captured-arg assertions).
- [x] AAA + ≥ 3 cases per method on the two Dio-backed repos.
- [x] No multipart paths in scope here — `ShootsRepositoryImpl` and `AvailabilityRepositoryImpl` are JSON-only; `FileManagerStubRepository` has no network surface.

## Acceptance
- [x] All 3 test files pass (`35 / 35`: shoots `16`, file_manager `8`, availability `11`).
- [x] Every method has happy + error envelope (where applicable) + at least one transport-error path. Cancel covered for representative methods per repo.
- [x] No real network — mocktail `verify(...).captured` confirms request shape; `FileManagerStubRepository` is constructed directly so there is nothing to mock.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (379 events).

## Notes
- **`FileManagerStubRepository`**: backend endpoints are not live yet (Phase 4 left this on a stub). Tests pin the canonical shape the stub returns — 20 folders, 6 alternating pdf/doc files, folderId-namespaced ids — so notifier/widget tests can rely on it and so the swap to a Dio-backed impl forces a deliberate test update. No 401 / 5xx / cancel branches exist because the repo never touches the network.
- **`AvailabilityRepositoryImpl.fetchMonth` is swallow-on-envelope-error**: returns `{}` on non-Map payload, missing `data.availability`, or `error: true`. Tests assert that explicitly (a future cleanup that surfaces these as errors would need test updates).
- **`AvailabilityRepositoryImpl.createAvailability` is fire-and-forget**: the live impl never reads `response.data`. One test pins this behavior so a future "inspect envelope" change is visible.
- **`ShootsRepositoryImpl.respondToProject`** uses Dart 3 collection-if-elements (`'reason': ?reason,`) to drop null fields from the body. Tests cover both branches (omitted vs included).
- **`ShootsRepositoryImpl.respondToProject` vs `HomeRepositoryImpl.acceptDeclineProject`**: both POST `acceptdeclineproject` but with different body shapes (status enum vs `crew_accept` int). 6.02 covered the home shape; 6.03 covers the shoots shape. No de-dup attempted — bridging these is its own task and would change behavior.
