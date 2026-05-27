# Task 3.18 — `AnalyticsService` + `CrashlyticsService`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 3h

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
- [ ] All static methods on `AnalyticsService` (logEvent, logLogin, logScreenView)
- [ ] Disable native auto-tracking (note in Android manifest + iOS Info.plist per `MIGRATION_RULES.md` §7)
- [ ] Set flavor as a Crashlytics custom key in `FirebaseService.initialize`
- [ ] `AppAnalyticsObserver` consumes route names and emits `screen_view`

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Smoke: a manual `AnalyticsService.logEvent` call doesn't crash with config absent
- [ ] Crashlytics flush works (verify in dashboard — out of scope for code task)

## Notes
Firebase native config (`google-services.json`, `GoogleService-Info.plist`) is **out of repo** — generate via `flutterfire configure` in a separate pre-prod task. Wrappers tolerate missing config (no-op).
