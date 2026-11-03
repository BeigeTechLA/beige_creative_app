# CP App — Flutter 3.47 / iOS 27 / AGP 9 Gap-Closure Plan

**Created:** 2026-11-03
**Branch:** `feature-flutter-upgrade`
**Sibling reference:** `biegeapp` (client app) — same migration, code-complete 2026-11-02.
**Scope:** This is **not** a fresh upgrade. CP already landed Flutter 3.47, iOS 27
UIScene + SDK build, Firebase majors, the full plugin sweep, and AGP 9 in
parallel with beige. This plan closes the **remaining deltas** vs the completed
beige reference and drives the app to a shippable, QA-signed state.

---

## Context — CP already mirrors beige

| Item | beige (done) | CP app | Gap |
|------|------|--------|-----|
| Flutter / Dart | 3.47.0 / 3.13.0 | **3.47.0 / 3.13.0** (`.fvmrc`) | none |
| Riverpod 3 / go_router 18 | ✓ | **3.4.3 / 18.1.1** | none |
| Firebase majors | core 5.1 / analytics 13 / crashlytics 6 | **core 5.0 / analytics 13 / crashlytics 6** | none (CP pins exact) |
| Plugin sweep (file_picker 13, geocoding 5, socket_io 3, connectivity 7, share_plus 13, secure_storage 11, cached_network_image 4) | ✓ | **✓** | none |
| iOS 27 UIScene lifecycle | ✓ | **✓** (`cbe21d9`) | none |
| iOS 27.1 SDK build | ✓ | **✓** (unsigned dev) | device QA |
| AGP 9.0.1 / Gradle 9.1.0 / Kotlin 2.3.20 | ✓ (legacy-compat) | **✓** (legacy-compat, `58c2349`) | none |
| `resValues` opt-in | ✓ | **✓** | none |
| `proguard-rules.pro` | present (692B) | **WAS MISSING** → created 2026-11-03 | **fixed** |

### Deltas that DON'T apply to CP
- **No `flutter_stripe`** → beige's Stripe 14 migration and its
  `lint { checkReleaseBuilds = false }` workaround (stripe_android lint-vital
  pulling unresolvable `play-services-tapandpay`) are **N/A**.
- **No `calendar_date_picker2`** (CP uses `table_calendar`) → beige's Tier B
  calendar bump + `material_ui` test-host gotcha is **N/A**.
- **Firebase iOS CocoaPods landmine — CP dodged it.** beige's `firebase_core ^5.1`
  pinned native SDK `12.19.3`, but Firebase stopped publishing to CocoaPods
  (Oct 2026) so Analytics/Crashlytics capped at `12.19.0` — beige needed a
  `$FirebaseSDKVersion = '12.19.0'` override in `ios/Podfile`. CP pins **exact
  `firebase_core 5.0.0`**, and `ios/Podfile.lock` resolved clean at native
  **12.19.0** with no override. ⚠️ **Latent watch item** — the moment CP bumps
  `firebase_core` past 5.0.0, add the `$FirebaseSDKVersion = '12.19.0'` Podfile
  override (beige's lesson).

### Decision (user, 2026-11-03)
**Skip the built-in-Kotlin flip** (CP's old AGP9 Phase 3). Match beige: stay
`builtInKotlin=false` / `newDsl=false`. The KGP build warning is informational
and only breaks on a *future* Flutter release — it is NOT an AGP-9 blocker.
Flipping would force re-verification of `android_file_picker`'s hacky
`kotlinOptions` workaround, `open_file_android` (compileSdk 34), and the `jni`
native build under `newDsl` — risk beige judged not worth taking. Mark CP's
AGP9 Phase 3 **Deferred**.

---

## Verification gate — RUN 2026-11-03 (GREEN)

| Check | Command | Result |
|-------|---------|--------|
| Static | `flutter analyze` | **0 issues** (cleaner than beige's 57 baseline) |
| Tests | `flutter test` | **749 / 749 pass** (no baseline failures) |
| Dev release APK | `flutter build apk --flavor dev …  --release` | ✓ **74.8MB** |
| Prod release APK | `flutter build apk --flavor prod … --release` | ✓ **74.8MB** |

**Blocker found & fixed during the gate:** the release build failed
`:app:minifyDevReleaseWithR8` — `app/build.gradle.kts:99-102` references
`proguard-rules.pro` but the file **did not exist** (CP had only ever verified a
*debug* build post-AGP-9; release/R8 was never exercised). Created
`android/app/proguard-rules.pro` (OkHttp `-dontwarn` block; Stripe rules omitted
— CP has no Stripe). Both release APKs built clean afterward.

---

## Phased execution plan

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | **Unblock release R8** — create missing `proguard-rules.pro` | `android/app/proguard-rules.pro` | Both-flavor release APK builds green | **Completed** (2026-11-03, verified) |
| 2 | **Commit in-flight work** — stray docs + the proguard fix | `MIGRATION_LOG.md`, `docs/upgrade/AGP9_UPGRADE.md`, `android/app/proguard-rules.pro`, this doc | Clean `git status`; AGP9 Phase 3 marked Deferred | Not Started |
| 3 | **AAB path** — confirm the Play Store artifact (same R8 path as APK) | — | `build-prod-aab` + `build-dev-aab` produce signed AAB | Not Started |
| 4 | **Crashlytics mapping upload** — verify `mappingFileUploadEnabled=true` under AGP 9 | — | Forced crash symbolicates in Crashlytics console | Not Started |
| 5 | **Full device regression** — both flavors on real Android + iOS 27 device | — | QA checklist below all green | Not Started |
| 6 | **iOS device / TestFlight** — signed IPA, cold launch, UIScene runtime | — | TestFlight build installs + smoke passes on iOS 27 | Not Started |

> Phase 1 was executed to complete the user-requested verification gate; it is
> recorded here for traceability. Everything from Phase 2 on is pending.

---

## Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | `make build-dev-android` / `build-prod-android` | Both release APKs build (✓ done, 74.8MB) | R8 full-mode missing-class errors (add `-dontwarn`) |
| 2 | `make build-prod-aab` | Signed AAB produced | release signing config intact |
| 3 | Install prod release on real Android device, cold launch | App launches past splash | ANR / native crash vs pre-AGP-9 |
| 4 | Login → core crew flow → file pick + upload → open file | All succeed | `android_file_picker` legacy-compat; `open_file_android` |
| 5 | Maps render + current location + geocode | Correct under geolocator 14 / geocoding 5 | location permission paths |
| 6 | Messages socket connect / send / reconnect on background | socket_io_client 3 stable | reconnect after backgrounding |
| 7 | Trigger forced crash → Crashlytics console | Symbolicated stack, mapping uploaded | `mappingFileUploadEnabled` under AGP 9 |
| 8 | iOS 27: cold launch, background→resume, deep links | UIScene lifecycle correct | FlutterSceneDelegate / Info.plist manifest |
| 9 | Riverpod 3 error/loading/retry UX | No behavior change vs pre-upgrade | auto-retry-on-error default |
| 10 | App version shown, url_launcher links, lottie/svg render | Correct | — |

---

## Rollback
Phase 1 is additive (a new file) — delete `android/app/proguard-rules.pro` to
revert, though that re-breaks release R8. No other code touched by this plan;
all prior upgrade work is already committed on `feature-flutter-upgrade`.
