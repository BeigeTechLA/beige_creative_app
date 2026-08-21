# Task 3.18 — `AnalyticsService` + `CrashlyticsService`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/firebase-wrappers` |

## Goal
Land thin wrappers in front of `FirebaseAnalytics` / `FirebaseCrashlytics`. Centralizes event names, screen names, custom-key keys. Stubs OK if Firebase native config files are still pending.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations rows 16–17
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §7 Firebase Rules

## Files in scope (max 4)
- `lib/core/firebase/analytics_service.dart`
- `lib/core/firebase/analytics_events.dart` — `lowercase_snake_case` const event names
- `lib/core/firebase/crashlytics_service.dart`
- `lib/core/firebase/crashlytics_keys.dart` — custom-key constants
- `lib/core/firebase/analytics_observer.dart` — `RouteObserver` for GoRouter

## Steps
- [x] `AnalyticsService` (`lib/core/firebase/analytics_service.dart`) — static methods `logEvent`, `logLogin`, `logScreenView`, `setUserId`. Each guards with `Firebase.apps.isNotEmpty` so dev builds without `flutterfire configure` short-circuit safely.
- [x] `AnalyticsEvents` (`lib/core/firebase/analytics_events.dart`) — central `lowercase_snake_case` registry (auth, shoots, profile, availability, navigation).
- [x] `CrashlyticsService` (`lib/core/firebase/crashlytics_service.dart`) — `setCustomKey`, `setUserIdentifier`, `recordError`, `log`, plus `registerErrorHandlers()` wiring `FlutterError.onError` + `PlatformDispatcher.instance.onError`. Same config-absent short-circuit.
- [x] `CrashlyticsKeys` (`lib/core/firebase/crashlytics_keys.dart`) — `flavor`, `userId`, `userRole`, `route`, `featureArea`.
- [x] `AppAnalyticsObserver` upgraded from no-op stub into a delegating `NavigatorObserver`. Delegates to `FirebaseAnalyticsObserver` (via `AnalyticsService.buildObserver()`) AND records the current route name as the `last_route` Crashlytics custom key on every push/replace/pop.
- [ ] Disable native auto-tracking — **not done in this task**. Per spec note in `MIGRATION_RULES.md` §7, set `firebase_analytics_collection_enabled=false` in `AndroidManifest.xml` and `FIREBASE_ANALYTICS_COLLECTION_ENABLED=NO` in `Info.plist`. Native config + this flag belong to a pre-prod `flutterfire configure` task.
- [ ] Flavor → Crashlytics custom key in `FirebaseService.initialize` — `FirebaseService` itself lands in Task 3.19. The wrapper is ready; 3.19 calls `CrashlyticsService.setCustomKey(CrashlyticsKeys.flavor, Env.current.name)` from its `initialize()`.

## Acceptance
- [x] `flutter analyze lib/core/firebase/` → No issues found. Full analyze → 301 (baseline).
- [x] `AnalyticsService.logEvent` smoke — exercised indirectly via the widget test (observer fires `_recordRoute` → `CrashlyticsService.setCustomKey`); console output `Crashlytics(stubbed): setCustomKey last_route=splash` confirms the stub path with Firebase absent.
- [ ] Crashlytics flush in dashboard — out of scope (no config in this env).

## Notes
Firebase native config (`google-services.json`, `GoogleService-Info.plist`) is **out of repo** — generate via `flutterfire configure` in a separate pre-prod task. Wrappers tolerate missing config (no-op).
