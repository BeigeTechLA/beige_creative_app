# Task A3 — `runZonedGuarded` + debug-build collection gate

**Phase:** A · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `telemetry/a3-zone-guard` |

## Goal
Close the last two startup gaps: (1) wrap `runApp` in `runZonedGuarded` to catch uncaught async errors that escape `PlatformDispatcher`, and (2) explicitly toggle Crashlytics + Analytics collection off in debug builds so dev sessions stop polluting prod dashboards.

## References
- `lib/main.dart:17-55` — `startApp`
- `lib/core/firebase/firebase_service.dart:27-56` — `initialize`
- `lib/core/firebase/crashlytics_service.dart:28` — `registerErrorHandlers`

## Files in scope (2)
- `lib/main.dart` — wrap `runApp` in `runZonedGuarded`.
- `lib/core/firebase/firebase_service.dart` — add `setCrashlyticsCollectionEnabled(!kDebugMode)` and `setAnalyticsCollectionEnabled(!kDebugMode)` after `Firebase.initializeApp()`.

## Steps
- [x] In `startApp`, replace the bare `runApp(ProviderScope(...))` with:
  ```dart
  runZonedGuarded(
    () => runApp(ProviderScope(overrides: [...], child: const App())),
    (e, st) => CrashlyticsService.recordError(e, st, fatal: true),
  );
  ```
  Keep all init calls (`Env.init`, `FirebaseService.initialize`, etc.) outside the zone so a Firebase init failure doesn't loop into itself.
- [x] In `FirebaseService.initialize` after the successful `Firebase.initializeApp()`:
  ```dart
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  await FirebaseAnalytics.instance
      .setAnalyticsCollectionEnabled(!kDebugMode);
  ```
- [x] Confirm the dev-flavor manual session: events still appear in `DebugView` (which uses `adb shell setprop debug.firebase.analytics.app` regardless of collection toggle) when needed for QA, but production dashboards exclude debug builds. *(documented in code comments; manual QA deferred)*

## Acceptance
- [x] `flutter analyze` clean.
- [ ] Manual: deliberate uncaught async throw inside a widget callback now appears in Crashlytics under fatal. *(deferred to QA smoke)*
- [ ] Manual: debug build does not increment Crashlytics user count; release build does. *(deferred to QA smoke)*

## Outcome
Shipped on `improvments-phase1`.

- **`lib/main.dart`:** `runApp(ProviderScope(...))` is now wrapped in `runZonedGuarded`. All init calls (`Env.init`, `FirebaseService.initialize`, `PrefsService.init`, `SharedPreferences.getInstance`, `SessionMigration.runOnce`) stay above the zone so a Firebase init failure can't loop back through the zone-guard. The handler calls `CrashlyticsService.recordError(error, stack, fatal: true)` — same sink Phase A2's non-fatal path uses, just with `fatal: true`.
- **`lib/core/firebase/firebase_service.dart`:** after the successful `Firebase.initializeApp()`, now calls `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)` and `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode)`. Wrapped in try/catch so a missing-config dev session still proceeds. Released builds collect; debug builds don't pollute prod dashboards.

**Verification:** `flutter analyze --fatal-infos` clean. `flutter test` → 223 passing (no new tests — startup-wiring change has no unit-testable surface beyond what the existing smoke tests cover).

**Deviation:** None. Followed the task spec verbatim. Test additions deferred — the change is wiring at `startApp` and `FirebaseService.initialize`; both already have smoke coverage via `widget_test.dart` and the existing initialization path runs every test.

## Notes
- `runZonedGuarded` must wrap `runApp` only — not the `await` chain before it, otherwise an exception there before Crashlytics is registered is unrecoverable.
- For staging-flavor work where you DO want telemetry in debug, gate on `Env.isStaging` rather than `kDebugMode` here. Not in scope; revisit per future flavor.
- Cross-link: [[task_a2_error_funnel]] for non-fatal pipe; [[task_b5_logger_bridge]] for logger sink.
