# Task 6.15 — Location service + Google Maps consolidation

**Phase:** 6 · **Status:** 🟡 In Progress · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/location-map-consolidation` |

## Goal
Fix iOS Maps key crash, rotate leaked Google API key, collapse 3 dark map-style copies to one source, and unify location-permission flow behind a single `LocationService` that throws typed `LocationException` instead of returning nullable `LatLng` + showing snackbars from the service layer.

## References
- [`../../CLAUDE.md`](../../CLAUDE.md) — Architecture Rules (design tokens, ref.listen for UI side effects, no UI in services)
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9 testing minimums
- `google_maps_flutter` iOS setup: requires `GMSApiKey` in `Info.plist` + `GMSServices.provideAPIKey(...)` in `AppDelegate.swift`

## Problems found

### Critical
1. **iOS map broken** — `ios/Runner/Info.plist` uses `<key>GoogleMapsAPIKey</key>`; `google_maps_flutter` reads `GMSApiKey`. Wrong key name → no map renders on iOS.
2. **API key leaked in source** — `lib/config/env.dart:8` hardcodes `AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc` as `defaultValue` for `--dart-define`. Same key duplicated in iOS `Info.plist`. Committed in repo history — must rotate + restrict by SHA-1 / bundle ID.

### Drift
3. **3 dark-map-style copies, central one unused** —
   - `lib/service/google_config.dart:8` short variant (6 rules) — never imported.
   - `lib/features/auth/presentation/widgets/signup1_form.dart:22` long variant (9 rules).
   - `lib/features/profile/presentation/screens/edit_personal_details_screen.dart:33` long variant (9 rules) — duplicate of signup.
4. **Inconsistent permission flow** —
   - `LocationService.getCurrentLocation()` exists in `lib/utility/location_service.dart` but only `edit_personal_details_screen.dart:136` uses it.
   - `signup1_screen.dart:114` reimplements the full Geolocator flow inline, bypassing the service.

### Design smells
5. **`LocationService` mixes UI + business logic** — takes `BuildContext`, shows `SnackBar` inside service; violates CLAUDE.md "UI side effects in widgets via `ref.listen`, not inside repositories".
6. **`getAddressFromLatLng` null bug** — returns literal `"null, null, null, null"` when placemark fields are null (string interpolation without guards).
7. **Opaque error mode** — every failure path returns `null`; caller cannot distinguish `serviceDisabled` vs `denied` vs `permanentlyDenied`.
8. **Dead code** — `LocationService.searchLocation` defined, never called. `updateLocation` is a trivial wrapper.

### Native config
9. **iOS over-asks** — `NSLocationAlwaysAndWhenInUseUsageDescription` present but app uses foreground only. App Store flags unnecessary always-permission.
10. **Android Gradle plumbing unverified** — `AndroidManifest.xml` uses `${GOOGLE_MAPS_KEY}` placeholder; need to confirm `android/app/build.gradle.kts` injects from `--dart-define-from-file` per flavor.

## Files in scope (max 12)

### New
- `lib/utility/location_exception.dart` — `LocationException` + `LocationStatus` enum
- `test/utility/location_service_test.dart`
- `test/utility/location_exception_test.dart`

### Edit — Dart
- `lib/utility/location_service.dart` — refactor, drop `BuildContext`, throw typed
- `lib/service/google_config.dart` — replace `darkMapStyle` with consolidated 9-rule variant
- `lib/config/env.dart` — drop hardcoded `defaultValue` for `GOOGLE_MAPS_KEY`
- `lib/features/auth/presentation/screens/signup1_screen.dart` — migrate to `LocationService`
- `lib/features/auth/presentation/widgets/signup1_form.dart` — delete local `_darkMapStyle`, use `GoogleConfig.darkMapStyle`
- `lib/features/profile/presentation/screens/edit_personal_details_screen.dart` — delete local `_darkMapStyle`, use service contract

### Edit — Native
- `ios/Runner/Info.plist` — rename `GoogleMapsAPIKey` → `GMSApiKey`, drop `NSLocationAlwaysAndWhenInUseUsageDescription`
- `ios/Runner/AppDelegate.swift` — verify/add `GMSServices.provideAPIKey(...)`
- `android/app/build.gradle.kts` — verify `manifestPlaceholders["GOOGLE_MAPS_KEY"]` per flavor

## Steps

### Sub-task A — Rotate keys (BLOCKER, user action) 🔴
- [ ] Revoke leaked key in Google Cloud Console
- [ ] Create restricted Android key (package + SHA-1 for debug + release)
- [ ] Create restricted iOS key (bundle ID)
- [ ] Create restricted Places key (API restriction)
- [ ] Add new keys to `env/dev.json` + `env/prod.json` (not committed)

### Sub-task B — Native fix 🟢
- [x] Rename `<key>GoogleMapsAPIKey</key>` → `<key>GMSApiKey</key>` in `ios/Runner/Info.plist`; value `$(GOOGLE_MAPS_KEY)` (xcconfig substitution)
- [x] Drop `NSLocationAlwaysAndWhenInUseUsageDescription` from `Info.plist`
- [x] `GMSServices.provideAPIKey(...)` in `AppDelegate.swift` reads `GMSApiKey` (was `GoogleMapsAPIKey`)
- [x] `android/app/build.gradle.kts` — drop hardcoded fallback, throw `GradleException` if `GOOGLE_MAPS_KEY` missing from `DART_DEFINES`
- [x] Drop hardcoded `defaultValue` from `Env.googleMapsKey` in `lib/config/env.dart`

### Sub-task B.1 — iOS xcconfig wiring 🟢
- [x] Add `#include? "GoogleMaps-<flavor>.xcconfig"` to all 6 flavor xcconfigs (Debug/Release/Profile × dev/prod)
- [x] `ios/Podfile` — `write_google_maps_xcconfig(flavor)` helper reads `env/<flavor>.json` and writes `ios/Flutter/GoogleMaps-<flavor>.xcconfig` on every `pod install`
- [x] `.gitignore` generated xcconfigs

### Sub-task C — Service refactor 🟢
- [x] Add `lib/utility/location_exception.dart` with `LocationStatus { serviceDisabled, denied, permanentlyDenied, unknown }` + `LocationException implements Exception`
- [x] Refactor `LocationService.getCurrentLocation()`:
  - Drop `BuildContext` param + `ScaffoldMessenger` calls
  - Return `Future<LatLng>` (non-null) — throws `LocationException(status)` on failure
  - Drop `import 'package:flutter/material.dart'`
- [x] Fix `getAddressFromLatLng` null bug: build parts list with null/empty guard, `parts.where(...).join(', ')`
- [x] Delete `searchLocation` (dead) + `updateLocation` (trivial wrapper)

### Sub-task D — Style consolidation 🟢
- [x] Move 9-rule long-variant style to `GoogleConfig.darkMapStyle` (replaced 6-rule short variant)
- [x] Delete `_darkMapStyle` const from `signup1_form.dart`
- [x] Delete `_darkMapStyle` const from `edit_personal_details_screen.dart`
- [x] Both screens reference `GoogleConfig.darkMapStyle` via `GoogleMap(style: ...)`

### Sub-task E — Screen migration 🟢
- [x] `signup1_screen.dart`: delete inline `_getCurrentLocation`. Call `LocationService.getCurrentLocation()` in try/catch with `LocationStatus` switch:
  - `serviceDisabled` → `Geolocator.openLocationSettings()`
  - `permanentlyDenied` → snack + `Geolocator.openAppSettings()`
  - `denied` → snack "Location needed to autofill address."
- [x] `signup1_screen.dart` `_updateLocationFromLatLng`: kept inline reverse-geocode (signup-specific plus-code filter + `name` field). Note: service helper used only by edit-profile screen.
- [x] `edit_personal_details_screen.dart` `loadCurrentLocation`: drops `context` arg, silently swallows `LocationException` by design (user can search manually). Drops unused `geocoding` import.
- [x] `edit_personal_details_screen.dart` `getAddressFromLatLng`: uses `LocationService.getAddressFromLatLng`.

### Sub-task F — Tests (per Phase 6 minimums) 🔴
- [ ] `location_exception_test.dart` — status enum equality, message field
- [ ] `location_service_test.dart` — `getAddressFromLatLng` happy / all-null placemark (expects `""`, not `"null, null"`) / empty list
- [ ] Widget test signup deny path → snack shown (uses test override of Geolocator channel)
- [ ] Widget test signup permanent-deny path → app-settings invoked
- [ ] Three cases minimum per function (happy / edge / error)

### Sub-task G — Verify 🟡
- [x] `flutter analyze` clean — `No issues found! (ran in 4.0s)` on 2026-06-15
- [x] `pod install` regenerates `GoogleMaps-{dev,prod}.xcconfig` from env JSON (verified 2026-06-15)
- [x] Compiled Debug-dev simulator app has a resolved, non-empty `GMSApiKey` in `Runner.app/Info.plist` for bundle id `com.app.cpbeige.dev` (verified 2026-06-15)
- [ ] `flutter test`
- [ ] `flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart` on iOS simulator: map tiles render dark style
- [ ] Same on Android emulator
- [ ] Manual: accept / deny / permanent-deny on both platforms for signup + edit profile

## Acceptance
- [ ] iOS map renders on `flutter run` dev flavor with rotated key
- [ ] No `AIzaSy...` literal in `lib/` or `ios/` or `android/`
- [ ] `rg "_darkMapStyle"` in `lib/` returns zero hits
- [ ] `LocationService.getCurrentLocation` signature does not import `flutter/material.dart`
- [ ] `signup1_screen.dart` no longer calls `Geolocator.checkPermission` directly
- [ ] All 3 denial states distinguishable at caller via `LocationException.status`
- [ ] `flutter analyze` + `flutter test` green
- [ ] Coverage delta does not regress location surface

## Decisions
- **API shape:** typed exceptions (`LocationException` + `LocationStatus`), not sealed result type. Matches existing `AppException` convention in network layer (CLAUDE.md Phase 4 Pattern).
- **Riverpod provider:** not introduced this task — signup notifier already owns lat/lng via `setCurrentLatLng`. Note as follow-up if a second consumer beyond the two screens appears.
- **Plus-code filter:** stays at caller (signup1), not inside service — caller-specific UX rule.

## Notes
Sub-task A (key rotation) is a hard blocker. Do not ship sub-task B onward against the leaked key — even if Gradle / xcconfig substitution works, the burned key stays burned. Coordinate rotation with whoever owns the GCP project before opening the branch.

`Info.plist` rename to `GMSApiKey` is the single most important line — current code silently falls back to a blank key on iOS, so map renders empty without throwing. Easy to miss in PR review.

When running from Xcode directly, native Maps can still receive the xcconfig-backed `GMSApiKey`, but Dart-side Places autocomplete reads `Env.googleMapsKey` from `--dart-define`. Use the Flutter flavor command with `--dart-define-from-file=env/dev.json` or add equivalent scheme wiring before debugging signup/edit-profile location search from Xcode.

### Execution log — 2026-06-15
Sub-tasks B, B.1, C, D, E executed. Analyzer clean. `pod install` confirms xcconfig generation.

iOS xcconfig wiring chosen over Run Script build phase to avoid pbxproj edits. Cost: user must re-run `pod install` after editing `env/<flavor>.json`. Acceptable since env values change rarely.

Reverse-geocode helper stayed inline in `signup1_screen.dart` because signup needs the `place.name` field + `isPlusCode` filter that the shared service intentionally omits (other callers do not want plus codes). Considered adding an `includeName: bool` flag to the service — rejected as caller-specific UX leakage into shared code.

Sub-task A (rotate) + F (tests) + manual G remain.

Follow-up diagnosis: inspected existing Debug-dev simulator artifact and confirmed `Runner.app/Info.plist` resolves `GMSApiKey` to a non-empty value for `com.app.cpbeige.dev`; the key is not left as literal `$(GOOGLE_MAPS_KEY)`. If iOS tiles still render blank, the remaining blocker is Google Cloud key state/restrictions: enable Maps SDK for iOS, restrict the iOS key to `com.app.cpbeige.dev` / `com.app.cpbeige`, and replace the old leaked key in local `env/{dev,prod}.json`, then rerun `pod install`.

White-map follow-up: simulator logs show the native SDK starts successfully (`Google Maps SDK for iOS version: 9.4.0.0`) and creates `GMSCacheStorage`, but `GMSDASHConnection` / Google fetcher requests repeatedly return HTTP `400`. That confirms the view is mounted and the key reaches the SDK; Google is rejecting the request. Treat this as key/API restriction until proven otherwise: verify Maps SDK for iOS is enabled on the key's project, the iOS application restriction includes `com.app.cpbeige.dev` for dev and `com.app.cpbeige` for prod, and the local `env/*.json` values have been rotated away from the leaked key.
