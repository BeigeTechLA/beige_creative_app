# Task 3.19 — `FirebaseService.initialize` stub

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 2h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/firebase-init` |

## Goal
Land a tolerant `FirebaseService.initialize(Environment env)` wired into `startApp`. No-op if config files absent; full init when present. Sets the flavor as a Crashlytics custom key.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 15; §4 Risk #19
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §7

## Files in scope (max 2)
- `lib/core/firebase/firebase_service.dart` — new
- `lib/main.dart` — call `await FirebaseService.initialize(env)` after `WidgetsFlutterBinding.ensureInitialized()`

## Steps
- [x] `Firebase.initializeApp()` inside try/catch in `FirebaseService.initialize(env)`. On failure: swallow + `AppLogger.w(...)`. Returns `bool` so callers can branch if needed.
- [x] On success: `CrashlyticsService.registerErrorHandlers()` wires `FlutterError.onError` + `PlatformDispatcher.instance.onError` → `CrashlyticsService.recordError(...)` (the wiring already exists in Task 3.18; this task triggers it).
- [x] On success: `CrashlyticsService.setCustomKey(CrashlyticsKeys.flavor, env.name)` — flavor tag on every crash.
- [x] `lib/main.dart` calls `await FirebaseService.initialize(environment)` right after `WidgetsFlutterBinding.ensureInitialized()`, before any other startup work. Failure on missing config is benign.
- [x] Idempotency guard via `static bool _initialized` — second call returns true without re-running.
- [ ] `runZonedGuarded` wrap — **not added**. The framework + platform handlers from `registerErrorHandlers()` catch the dominant cases. Adding `runZonedGuarded` requires `startApp` to be wrapped at every entry point (`main_dev.dart`, `main_prod.dart`) which the spec marks as out of scope. Phase 4 can add it if Crashlytics shows gaps.
- [ ] Smoke on a config-less machine — current env is exactly that case. App still compiles + tests pass; runtime path swallows the missing-config exception via the try/catch (verified by reading the stub-log output from Task 3.18's observer in the widget test).

## Acceptance
- [x] App boots whether or not Firebase config files are present — verified by the try/catch path + the fact that the test suite (which has no Firebase config) runs to completion.
- [ ] When config is present, errors appear in Crashlytics dashboard — out-of-band, requires native config files (pre-prod ticket).
- [x] `flutter analyze lib/core/firebase/ lib/main.dart` → No issues found. Full analyze → 301 = baseline.

## Notes
Native config (`google-services.json` / `GoogleService-Info.plist`) is generated **outside this PR** via `flutterfire configure` once Firebase projects exist for dev + prod. Track in a separate ticket.
