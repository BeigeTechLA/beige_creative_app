# Task 6.06 — Notifier tests: file_manager + availability + messages

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Unit tests for remaining Notifiers in Groups B + the messaging stream/polling notifier.

## Files in scope (actual: 2)
- `test/features/file_manager/presentation/file_manager_notifier_test.dart` — **new** — 13 tests covering all 4 Notifiers (`FileManagerNotifier` root + `PreProductionNotifier`, `PostProductionNotifier`, `ViewDetailsNotifier` family Notifiers).
- `test/features/availability/presentation/availability_notifier_test.dart` — **new** — 9 tests filling gaps not covered by the existing `screens/availability_test.dart` (`ManageAvailabilityNotifier` refresh failure + `setFocusedDay` + `setFilter`; `AddAvailabilityNotifier` date / time validation, `setRecurrence` reset semantics, `toggleWeekDay` round-trip, `clearMessages`, daily recurrence path).
- **`messages_notifier_test.dart` — NOT created.** No Notifier exists for messages (`lib/features/messages` contains only `presentation/screens/messages_screen.dart`). Spec line is aspirational — the feature is still pending a Notifier-layer migration.

## Steps
- [x] Mirrored prior Notifier-test patterns (`ProviderContainer` + repo override + `_drain` microtask loop).
- [x] Messages: skipped — no Notifier in lib/. Documented in Notes below.
- [x] AAA + ≥ 3 cases per method on the 6 real Notifiers; the 2 trivial sync mutators (`setFilter`, `clearMessages`) get a single test each because there is no error / validation branch to drive.

## Acceptance
- [x] All test files pass (`22 / 22`: file_manager `13`, availability gap-fill `9`).
- [x] Notifier coverage on file_manager + availability — every public method on every Notifier has at least one happy / mutation test; family Notifiers tested with two distinct `folderId` args to confirm state isolation.
- [x] No real API calls — every test uses `_FakeRepo` inline + a stub `TelemetryClient`.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (404 events).

## Notes
- **Messages feature is not migrated yet.** `lib/features/messages/presentation/screens/messages_screen.dart` is the only file; there is no domain repository, no data repository, and no Notifier. The spec's `messages_notifier_test.dart` line predates the migration plan freeze that left messages in its legacy state. When messages is decomposed (Phase 7 candidate), this task's plan applies but isn't blocking the rest of Phase 6.
- **Existing tests preserved** — `screens/availability_test.dart` (3 ManageAvailability/AddAvailability tests with telemetry assertions) and `screens/file_manager_screen_test.dart` (widget-level search + toggleView) remain untouched. The new files **add** coverage; they don't replace anything.
- **Family Notifier state-isolation test** — `PreProductionNotifier` and `ViewDetailsNotifier` family tests prove different `folderId` args yield independent `state.query` / `state.folder`. Catches a future refactor that accidentally collapses the family into a singleton.
- **`AddAvailabilityNotifier.setRecurrence`** rewrites state via a fresh `AddAvailabilityState(...)` constructor call (not `copyWith`), preserving `type` and `isAllDay` but wiping `selectedWeekDays` and `includeWeekends`. The new "setRecurrence wipes weekday + weekend selections" test pins exactly this so a future `copyWith`-based rewrite would break the test deliberately.
- **Phase 6 Notifier coverage status after this task**: every Notifier in `lib/` that has a Notifier class has tests. The only feature without Notifier tests is messages — because messages has no Notifier yet.
