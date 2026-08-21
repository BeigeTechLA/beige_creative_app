# Task 6.09 — Widget tests: file_manager + availability

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Widget tests for remaining feature roots.

## Files in scope (3)
- `test/features/file_manager/presentation/screens/file_manager_screen_test.dart` — **pre-existing** (Phase 4). 3 tests: render of folders from stub repo, search filter, view-mode toggle. Untouched.
- `test/features/availability/presentation/screens/manage_availability_screen_test.dart` — **new** — 4 tests. Header + info banner + Add CTA render; count cards render under seeded events; chevron-left invokes `shiftMonth(-1)`; chevron-right invokes `shiftMonth(1)`.
- `test/features/availability/presentation/screens/add_availability_screen_test.dart` — **new** — 4 tests. Title + subtitle + Save/Cancel CTAs render; `Select Type*` dropdown placeholder visible; tap Save routes through `notifier.submit`; Save shows `CircularProgressIndicator` when `isSubmitting=true`.

## Steps
- [x] Smoke render + one interaction per screen.
- [x] CommonCalendar plays nicely with notifier-driven state — manage-availability test seeds `events` map and asserts "This Month" section renders. Calendar internals covered in `availability_notifier_test.dart`.

## Acceptance
- [x] All test files pass (`11 / 11`: file_manager `3` pre-existing, manage `4`, add `4`).
- [x] Widget coverage on these screens — every screen has render + interaction smoke.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (438 events).

## Notes
- **`AddAvailabilityScreen` uses a `CircularProgressIndicator`** for the in-flight Save button (not `AppLoader`). The screen's bottom CTA renders a 22×22 native spinner inline. Asserted explicitly so a future swap to `AppLoader` must be deliberate.
- **`ManageAvailabilityScreen` doesn't expose an `AppLoader` overlay.** The loading state is reflected in the calendar via `isLoading`; the screen otherwise renders normally. No loader test on this screen.
- **Pre-existing `file_manager_screen_test.dart` predates this task** and uses a different harness pattern: real `FileManagerNotifier` + repo override (the stub repo is cheap, no Dio). Kept as-is — the alternative (subclass + fake notifier) would be churn without coverage gain.
- **Phase 6 widget breadth complete after this task.** Every entry-point screen with a Notifier has at least one widget test. Goldens + integration tests follow in 6.10–6.12.
