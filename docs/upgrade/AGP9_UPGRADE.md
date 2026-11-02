# AGP 9 Upgrade Plan

Status: **Phases 0–2 complete, build green** (Gradle 9.1.0 + AGP 9.0.1,
legacy-compat). `assembleDevDebug` passes on JBR 21 → `app-dev-debug.apk`.
Remaining: Phase 3 (built-in-Kotlin flip), Phase 4–5 (runtime/device verify).
Owner: Android build.
Date: 2026-10-30.

Standalone plan, like `FLUTTER_IOS27_UPGRADE.md`. Not a migration phase. AGP 9
is **optional / future** — nothing in the current Flutter+iOS 27 upgrade
requires it. Track and execute separately.

---

## 0. Immediate: the JVM import error (NOT AGP 9)

The Android Studio dialog:

> The project's Gradle version Gradle 8.14.3 is incompatible with the Gradle
> JVM version 25. … select a JVM version that is at least 8 and at most 24.

Root cause — **not** AGP-related:

- Latest Android Studio bundles **JBR 25** (`flutter doctor -v` → AS Java =
  build 25.0.3).
- Project wrapper = **Gradle 8.14**. Gradle 8.14 supports Java up to **24**.
  Java 25 rejected.

**Fix (zero code change):** click **"Use JVM 21"** in the dialog. Permanent:
Android Studio → Settings → Build, Execution, Deployment → Build Tools →
Gradle → *Gradle JDK* = **21** (or 17). Installed JDKs: JBR 21.0.11, Oracle
17.0.9.

This unblocks the IDE import regardless of whether AGP 9 is ever adopted.

---

## 1. Current stack vs AGP 9 requirements

| Thing | Current | AGP 9.0 requires | Gap |
|---|---|---|---|
| AGP (`com.android.application`) | 8.11.1 | **9.0.1** | bump |
| Gradle wrapper | 8.14 | **9.1.0 min** | bump |
| JDK (build) | 17 + 21 available | **17 min** | OK |
| Kotlin | KGP 2.2.20 (applied) | built-in, KGP 2.2.10 runtime | remove KGP / legacy mode |
| Build Tools | 36.1.0 | 36.0.0 min | OK |
| compileSdk | 36 (Flutter) | 35+ | OK |
| Flutter | 3.47.0 | ≥ 3.44 supports AGP 9 | OK |
| NDK | Flutter default | r28c default | minor |

Flutter 3.47 already supports AGP 9 (official since 3.44) and Gradle 9. JDK and
SDK are already sufficient. Real work = Gradle 9 + AGP 9 + Kotlin DSL switch +
Firebase/gms plugin bumps.

## 2. AGP 9 breaking changes that affect this project

1. **Built-in Kotlin.** AGP 9 bundles Kotlin. Remove
   `org.jetbrains.kotlin.android` (settings.gradle.kts) + `kotlin-android`
   (app plugins block). Enable via `android.builtInKotlin=true` +
   `android.newDsl=true` in `gradle.properties`.
2. **JVM target DSL.** App's
   `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_11) } }` stays via
   the kotlin extension — verify under newDsl.
3. **Gradle 9 removed-API sweep.** Wrapper 8.14 → 9.1. Re-test root
   `android/build.gradle.kts` custom build-dir redirect + `evaluationDependsOn`.
4. **Firebase/gms plugin bumps** (see §4).
5. **Third-party plugin risk** under `newDsl=true` — see §3 watch items.
6. **NDK default → r28c** — affects native-code plugins (`jni`).

---

## 3. Phase 0 Dep Audit — Result: GREEN

Ground-truth from the pub cache (actual resolved versions in `pubspec.lock`),
not changelog guesses. 21 Android-native plugins inspected. All set
`namespace` → pass AGP 9 hard requirement. No removed APIs in build files.

Pure-Dart deps ship no Android code → zero AGP risk: `dio`, `lottie`,
`flutter_svg`, `cached_network_image`, `go_router`, `flutter_riverpod`,
`dartz`, `intl`, `table_calendar`, `dotted_border`, `google_places_flutter`,
`socket_io_client`.

### Plugin readiness matrix

| Plugin | Ver | AGP9 signal | Status |
|---|---|---|---|
| firebase_core | 5.0.0 | conditional KGP skip (`agpMajor>=9 && builtInKotlin`) | ready (AGP9-aware) |
| firebase_analytics | 13.0.0 | same conditional | ready (AGP9-aware) |
| firebase_crashlytics | 6.0.0 | same conditional | ready (AGP9-aware) |
| package_info_plus | 10.2.2 | conditional KGP skip | ready (AGP9-aware) |
| share_plus | 13.3.1 | conditional KGP skip | ready (AGP9-aware) |
| google_maps_flutter_android | 2.21.0 | new `compilerOptions` DSL | ready |
| image_picker_android | 0.8.13+25 | new `compilerOptions` DSL | ready |
| url_launcher_android | 6.3.33 | new `compilerOptions` DSL | ready |
| shared_preferences_android | 2.5.4 | new `compilerOptions` DSL | ready |
| geocoding_android | 5.1.0 | `compilerOptions`, compileSdk=36 hard | ready |
| connectivity_plus | 7.3.2 | Java, namespace | ready |
| flutter_plugin_android_lifecycle | 2.0.35 | Java, namespace | ready |
| geolocator_android | 5.2.1 | Java, namespace | ready |
| flutter_secure_storage | 11.2.0 | namespace, kts | ready |
| sqflite_android | 2.4.5 | Java, namespace | ready |
| path_provider_android | 2.3.1 | official latest | ready |
| **android_file_picker** | 2.1.2 | AGP9-conditional BUT self-tagged temp workaround + hacky `"kotlinOptions"{}`, upstream #2170 open | **watch** |
| **open_file_android** | 1.1.0 | compileSdk **34**, groovy, least-maintained | **watch** |
| **jni / jni_flutter** | 1.1.1 / 1.0.4+1 | native `.so`, compileSdk 35 hard, NDK-dependent | **watch** |

### Watch items (not blockers)

1. **android_file_picker 2.1.2** — its `android/build.gradle.kts` says
   *"Temporary workaround … Flutter's own AGP 9 `newDsl` migration still in
   [progress] (#2170)"* and string-invokes `kotlinOptions`. Handles AGP 9, but
   hacky. Test file-pick + multipart upload first under newDsl; bump when the
   upstream fix ships.
2. **open_file_android 1.1.0** — compileSdk 34 (app = 36, so AGP 9
   consumer-≥-library rule is satisfied). Oldest / least maintained. Verify the
   "open file" flow builds.
3. **jni / jni_flutter** — transitive, native libs, compileSdk 35 hardcoded.
   AGP 9 default NDK → **r28c** may affect the native build. Verify source
   plugin + NDK after the bump.

### compileSdk rule

App `compileSdk` = `flutter.compileSdkVersion` (36). All libraries ≤ 36. AGP 9
"consumer must use same-or-higher compile SDK than the library" → satisfied.

---

## 4. App-side Gradle plugin bumps

`android/settings.gradle.kts` + `android/gradle/wrapper/gradle-wrapper.properties`:

| Plugin | Now | Target | Reason |
|---|---|---|---|
| `com.android.application` (AGP) | 8.11.1 | **9.0.1** | AGP 9 |
| Gradle wrapper | 8.14 | **9.1.0+** | AGP 9 min = Gradle 9.1 |
| `com.google.gms.google-services` | 4.4.2 | **4.5.0** | Gradle 9 |
| `com.google.firebase.crashlytics` | 3.0.2 | **3.0.7** | 3.0.6+ confirmed AGP9-OK (firebase-android-sdk #7652 = classpath, not plugin bug) |
| `org.jetbrains.kotlin.android` | 2.2.20 | **2.3.20** (kept in legacy mode) | Flutter drops KGP < 2.3.20 support soon; remove entirely at Phase 3 |

### Execution fixes applied (2026-10-30)

Surfaced by the first build and fixed to reach green:

1. **`resValues` opt-in** — AGP 9 disables the `resValues` build feature by
   default. App flavors use `resValue("string", "app_name", ...)`, so added
   `buildFeatures { resValues = true }` to `android/app/build.gradle.kts`.
2. **Kotlin 2.2.20 → 2.3.20** — Flutter warned the current KGP will be dropped
   soon (wants ≥ 2.3.20).

Remaining build warnings are benign in legacy-compat mode: Flutter's "app +
firebase_* apply KGP → future build failures" note (exactly what Phase 3
resolves), plus cosmetic `source/target 8 obsolete` and a `geolocator_android`
deprecated-API note.

---

## 5. Phased execution plan

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 0 | Dep audit: confirm each plugin + Firebase/gms AGP9-ready | pubspec.lock, pub cache | GREEN, 3 watch items, 5 bumps listed | Completed |
| 1+2 | **Merged** — Gradle 9.1.0 + AGP 9.0.1 + gms 4.5.0 + crashlytics 3.0.7, Kotlin 2.3.20, **legacy-compat** (`builtInKotlin=false`, `newDsl=false`) | `gradle-wrapper.properties`, `settings.gradle.kts`, `gradle.properties`, `app/build.gradle.kts` | dev debug build green on JBR 21 | Completed |
| 3 | Flip to built-in Kotlin (`builtInKotlin=true`, `newDsl=true`); drop KGP plugin | `settings.gradle.kts`, `app/build.gradle.kts`, `gradle.properties` | Kotlin compiles, jvmTarget 11 intact, build green | Not Started |
| 4 | Firebase mapping-upload verify | — | Crashlytics mapping upload + google-services work | Not Started |
| 5 | Full regression: both flavors APK+AAB+release, on-device smoke | — | All build variants pass; maps/auth/upload/file flows work | Not Started |

Recommendation: do **legacy-compat mode first** (Phase 2) to de-risk
android_file_picker's hack, then flip to built-in Kotlin (Phase 3) once Phases
1–2 are green and file_picker upstream settles.

---

## 6. Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Set Gradle JDK 21, reimport in Android Studio | Import succeeds, no JVM error | AS reverts to bundled JDK 25 after an update |
| 2 | `make build-dev-android` after each phase | APK builds green | Google Maps key injection still works |
| 3 | `make build-prod-aab` | Signed AAB produced | release signing config intact |
| 4 | Launch dev on device | Maps render, login, file pick + upload, open file OK | android_file_picker under newDsl; open_file_android |
| 5 | Trigger a crash → Crashlytics console | Mapping file uploaded, symbolicated stack | `mappingFileUploadEnabled` under AGP 9 |
| 6 | Verify native-lib plugins (`jni`) load | No `UnsatisfiedLinkError` at runtime | AGP 9 NDK r28c default |

---

## 7. References

- AGP 9.0.0 release notes — https://developer.android.com/build/releases/agp-9-0-0-release-notes
- Gradle 9 upgrade guide — https://docs.gradle.org/current/userguide/upgrading_major_version_9.html
- Flutter "Fully Supports AGP 9" tracking #181557 — https://github.com/flutter/flutter/issues/181557
- Flutter migrate to built-in Kotlin — https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin
- Crashlytics Gradle plugin v3 upgrade — https://firebase.google.com/docs/crashlytics/upgrade-to-crashlytics-gradle-plugin-v3
- Crashlytics AGP 9 issue #7652 — https://github.com/firebase/firebase-android-sdk/issues/7652