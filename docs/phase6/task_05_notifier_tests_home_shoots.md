# Task 6.05 — Notifier tests: home + shoots

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Unit tests for home dashboard + shoots tab Notifiers. Cover partial-fetch failure on home (one of 7 fetchers errors) + debounce on shoots search.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.3

## Files in scope (actual: 3)
Existing Phase 4 tests already covered all 4 home + shoots Notifiers. Tests live at `presentation/<file>` (not the spec's `presentation/providers/<file>` layout). `CancelShootNotifier` shares `shoots_notifier_test.dart` rather than living in a separate `shoot_cancel_notifier_test.dart` file because both Notifiers depend on the same `_FakeShootsRepo` fake.

- `test/features/home/presentation/home_notifier_test.dart` — `HomeNotifier`: refresh (all 7 domains hydrated), partial failure (crew stats fails, others succeed), `changeStatsRange`, `changeShootCategoryTab`, `acceptDecline` (happy + failure), `changeMonth`.
- `test/features/shoots/presentation/shoots_notifier_test.dart` — `ShootsListNotifier` + `CancelShootNotifier`: refresh (3 cases — happy, count failure, shoots failure), `updateSearch` debounce + empty query, `acceptShoot` (happy + failure), cancel `submit` (empty reason rejection + happy + failure).
- `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — `UpcomingShootDetailNotifier`: refresh (happy + failure), accept, decline (with reason + comment), respond failure.

## Steps
- [x] Audited all 4 home + shoots Notifier classes against existing tests — every public method has ≥ 3 cases (validation / happy / error or equivalent).
- [x] **Home `Future.wait` partial-failure path** verified in `home_notifier_test.dart` line 185 — crew stats throws while other 6 fetchers succeed; state has `errorMessage` populated and the rest of the dashboard hydrated.
- [x] **Shoots search debounce** verified in `shoots_notifier_test.dart` line 209 — 3 rapid-fire `updateSearch` calls land within the 250 ms window; only the last query filters; `fetchShootsCount` does not increase.

## Acceptance
- [x] All test files pass (`22 / 22` across the 3 files).
- [x] Every public Notifier method has ≥ 3 cases.
- [x] Debounce verified — but via real wall-time drain (`_drainTime(Duration(milliseconds: 350))`), not `FakeAsync`. See deviation below.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (382 events).

## Notes
- **Debounce verified with real wall-time drain, not `FakeAsync`** — `shoots_notifier_test.dart` defines `_drainTime(Duration)` that sleeps in 20 ms steps until the deadline. The file's own comment justifies the choice: *"Using real waits rather than fake_async keeps the test in line with the existing harness pattern."* Adds ~350 ms to one test in exchange for a single harness pattern across every notifier test. Acceptable trade.
- **`CancelShootNotifier`** is exposed through `cancelShootProvider` in the same `shoots_providers.dart` file as `ShootsListNotifier`, so a single `_FakeShootsRepo` covers both. Splitting tests would duplicate the fake.
- **`shoot_cancel_notifier_test.dart` (spec name) does not exist** — covered inside `shoots_notifier_test.dart` under group `CancelShootNotifier — decline flow`.
- **Path delta** — tests live at `test/features/<feature>/presentation/<file>` not `presentation/providers/<file>`. Same blame-preservation reason as 6.04.
