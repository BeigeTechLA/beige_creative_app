# Task B3 — Typed event helpers

**Phase:** B · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.25d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `improvments-phase1` |

## Goal
Replace ad-hoc `AnalyticsService.logEvent(AnalyticsEvents.X, parameters: {...})` calls with typed helpers on `AnalyticsEvents` (or a sibling `AnalyticsEmit` class). Stops param-shape drift across notifiers and makes events refactor-safe.

## References
- `lib/core/firebase/analytics_events.dart`
- `lib/core/firebase/analytics_service.dart:45-61`

## Files in scope (1)
- `lib/core/firebase/analytics_events.dart` — add static methods alongside the string constants. (Or extract `AnalyticsEmit` into a new file if file balloons.)

## Steps
- [x] For each event with parameters, add a typed helper:
  ```dart
  static Future<void> shootAccepted(String shootId) =>
      AnalyticsService.logEvent(
        shootAcceptedName,
        parameters: {'shoot_id': shootId},
      );
  ```
- [ ] Rename existing `String` constants to `*Name` (e.g. `shootAcceptedName`) to keep the registry pattern alive for the observer + future direct uses. *(deferred — see Outcome)*
- [x] Parameter-less events stay as constants OR get nullary helpers — pick one for the codebase. Recommend nullary helpers for consistency.
- [x] No `Map<String, Object>` reaches feature code after this task.

## Acceptance
- [x] B1 + B2 callsites use the typed helpers exclusively. *(B1/B2 not yet implemented — helpers are the only surface they can use; verified by removing the lone direct constant call inside `TelemetryClient.clearUserIdentity`)*
- [x] `rg "AnalyticsService.logEvent\(" lib/features` returns zero hits.
- [x] `flutter analyze` clean.

## Notes
- If the rename of constants causes churn elsewhere, defer the rename and add helpers without it. Drift is the real cost; rename is sugar.
- Helpers return `Future<void>` to match the underlying API. Callers `unawaited(...)` per `ExceptionHandler` pattern in [[task_a2_error_funnel]].

## Outcome
Shipped on `improvments-phase1`.

- **Shape:** extension methods on `TelemetryClient` (`extension TelemetryEventHelpers on TelemetryClient` in `lib/core/firebase/analytics_events.dart`). Kept the registry + helpers co-located — file is 184 lines, under the ~200-line threshold. Helpers compose from `TelemetryClient.logEvent`, so they're testable through the existing `_FakeTelemetry` seam in `test/features/auth/presentation/login_notifier_test.dart` and the new `_RecordingTelemetry` in `test/core/firebase/analytics_events_test.dart`.
- **Closed-set parameter enums:** `LoginFailureReason` (`invalid_credentials` / `network` / `server`) and `ProfilePhotoSource` (`camera` / `gallery`). Forces B1/B2 to pick from the documented set instead of free-typing reason strings.
- **TelemetryClient interface not extended.** The interface stays minimal (`setUserIdentity`, `clearUserIdentity`, `logEvent`, `recordError`); typed helpers live on the extension. This keeps test fakes from having to stub 14 methods.
- **`AnalyticsEvents.logout` direct-constant call removed.** `FirebaseTelemetryClient.clearUserIdentity` now calls `logout()` via the extension. No callsite in `lib/` references `AnalyticsEvents.<name>` directly anymore — all paths go through the helpers.
- **Rename of `String` constants to `*Name` deferred.** With helpers as the canonical emit surface (and no remaining direct const reads) the rename buys nothing right now. Will revisit when/if a direct registry read returns. Steps box reflects the deferral.
- **Tests:** new `test/core/firebase/analytics_events_test.dart` with 9 cases — 6 parametric (`shootAccepted`, `loginFailure` with enum wire name, `signupCompleted` shape, `profilePhotoUploaded` enum wire name, `featuredWorkUploaded`, `availabilityAdded`) + 3 nullary (`loginSuccess`, `logout`, batched `signupStarted` / `passwordResetRequested` / `accountDeletionRequested`). Each asserts the registry name + parameter shape routed through `TelemetryClient.logEvent`.

**Verification:** `flutter analyze --fatal-infos` clean. `flutter test` → 232 passing (9 new).

**Deviation:** Constants rename deferred per Notes. No churn would have been caused (only 1 callsite), but the rename buys nothing once direct reads are gone — re-evaluate if a registry-read use case appears.
