# Task 3.19 — `FirebaseService.initialize` stub

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 2h

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
- [ ] Try `Firebase.initializeApp(options: ...)` inside try/catch — swallow + log if config absent
- [ ] Wire `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.instance.onError` → `CrashlyticsService.recordError`
- [ ] Set Crashlytics custom key `flavor = <env.name>`
- [ ] Smoke: app boots on a machine without `google-services.json` (no crash, log warning)

## Acceptance
- [ ] App boots whether or not Firebase config files are present
- [ ] When present, errors appear in Crashlytics dashboard (verify out-of-band)
- [ ] `flutter analyze` clean

## Notes
Native config (`google-services.json` / `GoogleService-Info.plist`) is generated **outside this PR** via `flutterfire configure` once Firebase projects exist for dev + prod. Track in a separate ticket.
