# Task B5 — Bridge `AppLogger.e` to Crashlytics non-fatal

**Phase:** B · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.25d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `improvments-phase1` |

## Goal
`AppLogger.e(message, error, stack)` is the canonical "something is wrong, but not crash-worthy" sink in this codebase. Right now it logs to console only. Bridge it so every `AppLogger.e` also lands in Crashlytics as a non-fatal record — gives one funnel for app-wide non-fatals without touching every call site.

## References
- `lib/core/utils/app_logger.dart`
- `lib/core/firebase/crashlytics_service.dart:65` — `recordError`

## Files in scope (1)
- `lib/core/utils/app_logger.dart` — extend `AppLogger.e` to forward to Crashlytics.

## Steps
- [x] In `AppLogger.e(String message, [Object? error, StackTrace? stack])`:
  - Keep existing console behavior unchanged.
  - After the console write, in release builds only, call:
    ```dart
    if (!kDebugMode && error != null) {
      unawaited(CrashlyticsService.recordError(
        error,
        stack,
        reason: 'logger.e: $message',
        fatal: false,
      ));
    }
    ```
- [x] Skip forwarding when `error == null` — message-only logs are not actionable in Crashlytics.
- [x] No recursion guard needed because `CrashlyticsService.recordError` swallows its own failures via `try/catch` + `AppLogger.w`.

## Acceptance
- [x] `flutter analyze` clean.
- [x] Unit test: stub `CrashlyticsService.recordError` (via the seam from A1), assert called once when `AppLogger.e('msg', err, st)` runs in a release-mode test fixture.
- [x] No new entries in Crashlytics in debug builds. *(verified via unit test, manual smoke deferred to QA)*

## Notes
- This is additive on top of [[task_a2_error_funnel]] — that one catches typed exceptions at the network boundary; this one catches anything anyone bothered to log as an error elsewhere.
- Be conservative about adding new `AppLogger.e` calls after this lands — every one becomes a Crashlytics non-fatal.

## Outcome
Shipped on `improvments-phase1`.

- **`lib/core/utils/app_logger.dart`** — `AppLogger.e` now bridges to `CrashlyticsService.recordError` when `error != null` and not in debug mode. Console-print behavior unchanged. Forward is `unawaited(...)` so logging stays fast. Reason format: `'logger.e: $message'` — gives Crashlytics dashboards enough context to bucket by callsite.
- **Test seams (mirror A2 pattern):** added `@visibleForTesting` `crashRecorder` field + `defaultCrashRecorder` static (forwards to `CrashlyticsService.recordError`), plus a `debugModeOverride` callable that defaults to `() => kDebugMode`. The override is necessary because `kDebugMode` is `const true` under `flutter test` — without it the forwarding branch is unreachable in unit tests.
- **`test/core/utils/app_logger_test.dart`** — new, 5 cases. Asserts: (1) forwarded once with error + stack + correct reason in simulated-release path, (2) not forwarded when `error == null`, (3) not forwarded when `debugModeOverride()` returns true, (4) each `e()` call drains independently (no batching / recursion), (5) `d` / `i` / `w` never touch the recorder. `tearDown` restores both seams to defaults so cross-test bleed is impossible.

**Verification:** `flutter analyze --fatal-infos` clean. `flutter test` → 237 passing (5 new).

**Deviation:** introduced a `debugModeOverride` seam (not in the task brief) because `kDebugMode` is a compile-time const under `flutter test` — pure-`kDebugMode` gates are not unit-testable without it. Field is `@visibleForTesting`; production code path is unchanged.
