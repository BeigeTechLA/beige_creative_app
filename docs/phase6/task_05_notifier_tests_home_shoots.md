# Task 6.05 — Notifier tests: home + shoots

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/notifier-home-shoots` |

## Goal
Unit tests for home dashboard + shoots tab Notifiers. Cover partial-fetch failure on home (one of 7 fetchers errors) + debounce on shoots search.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.3

## Files in scope (max 6)
- `test/features/home/presentation/providers/home_notifier_test.dart`
- `test/features/shoots/presentation/providers/shoots_notifier_test.dart`
- `test/features/shoots/presentation/providers/upcoming_shoot_notifier_test.dart`
- `test/features/shoots/presentation/providers/shoot_cancel_notifier_test.dart`

## Steps
- [ ] Home: assert `Future.wait` coalesces multiple fetchers; one failure produces a partial-error state, others succeed
- [ ] Shoots: drive search input with synthetic time; assert only 1 fetch fires per 250ms window
- [ ] AAA + ≥3 cases per method

## Acceptance
- [ ] All test files pass
- [ ] Coverage on these Notifiers ≥ 80%
- [ ] Debounce verified via `FakeAsync`

## Notes
`FakeAsync` from `package:fake_async` (already in transitive deps via `mocktail`) lets you advance time without `await Future.delayed`.
