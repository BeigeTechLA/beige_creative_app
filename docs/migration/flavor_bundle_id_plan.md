# Flavor + Bundle ID Change Plan

> Generated: 2026-05-22
> Scope: Android + iOS native config only. Dart-side flavor entrypoints (`lib/main_dev.dart` / `lib/main_prod.dart`) unchanged. Companion to `MIGRATION_PLAN.md` (repo root) §2.C / Risk #5.

---

## 1. Target State

| Flavor | Android `applicationId` | iOS `PRODUCT_BUNDLE_IDENTIFIER` | Launcher / Display Name |
|---|---|---|---|
| `dev` | `com.app.cpbiege.dev` | `com.app.cpbiege.dev` | "BeigeCp Dev" |
| `prod` | `com.app.cpbiege` | `com.app.cpbiege` | "BeigeCp" |

Side-by-side install required (dev + prod on same device).
Dart entrypoint mapping unchanged:
- `flutter run --flavor dev  -t lib/main_dev.dart`
- `flutter run --flavor prod -t lib/main_prod.dart`

---

## 2. Current State (verified 2026-05-22)

### Android
- `android/app/build.gradle.kts:34` — `applicationId = "com.beige_creative_app"`, dev suffix `.dev` (`:46`). Current dev id: `com.beige_creative_app.dev`. Current prod id: `com.beige_creative_app`.
- `android/app/build.gradle.kts:20` — `namespace = "com.beige_creative_app"` (Kotlin package root for `MainActivity.kt`).
- `android/app/src/main/AndroidManifest.xml:11` — `android:label="BEIGECP"` hardcoded; overrides `app_name` resValue from flavors.
- Source sets: only `src/main`, `src/debug`, `src/profile`. No `src/dev` / `src/prod`.
- Maps key hardcoded at `AndroidManifest.xml:24`.

### iOS
- `ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER = com.example.beigeCreativeApp` at lines `371`, `550`, `572`. Default Flutter scaffold, never customized.
- Build configs: `Debug`, `Release`, `Profile`. No flavor-tagged configs.
- Schemes: single `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`. No `Runner-dev` / `Runner-prod`.
- xcconfig: `ios/Flutter/Debug.xcconfig` + `Release.xcconfig`. No flavor variants.
- `ios/Runner/Info.plist:8` — `CFBundleDisplayName = "Beige Creative App"` hardcoded.
- `ios/Runner/AppDelegate.swift` — no `GMSServices.provideAPIKey(...)` call.

---

## 3. Android Change Plan

### 3.1 `android/app/build.gradle.kts`

Replace:
```kotlin
namespace = "com.beige_creative_app"
...
applicationId = "com.beige_creative_app"
```
With:
```kotlin
namespace = "com.app.cpbiege"
...
applicationId = "com.app.cpbiege"
```

Keep flavor block as-is — `applicationIdSuffix = ".dev"` already yields `com.app.cpbiege.dev` once base is changed.

### 3.2 Move Kotlin package directory

Current path: `android/app/src/main/kotlin/com/beige_creative_app/MainActivity.kt`
Target path: `android/app/src/main/kotlin/com/app/cpbiege/MainActivity.kt`

Steps:
```bash
mkdir -p android/app/src/main/kotlin/com/app/cpbiege
git mv android/app/src/main/kotlin/com/beige_creative_app/MainActivity.kt \
       android/app/src/main/kotlin/com/app/cpbiege/MainActivity.kt
rmdir android/app/src/main/kotlin/com/beige_creative_app
```

Edit `MainActivity.kt` — change `package com.beige_creative_app` → `package com.app.cpbiege`.

### 3.3 Fix `AndroidManifest.xml` label

`android/app/src/main/AndroidManifest.xml:11`:
```diff
- android:label="BEIGECP"
+ android:label="@string/app_name"
```

This makes the launcher name flavor-driven (`BeigeCp Dev` vs `BeigeCp` from `build.gradle.kts:47,51`).

### 3.4 Optional: flavor source sets (deferred unless needed)

`android/app/src/dev/` + `android/app/src/prod/` only required if assets/icons/Firebase configs need to differ per flavor. Not in scope here — add when Firebase (Phase 3.F) or per-flavor icons land.

### 3.5 Uninstall old packages from devices

After install, the old packages stay on test devices:
```bash
adb uninstall com.beige_creative_app.dev
adb uninstall com.beige_creative_app
```
Document in release notes.

---

## 4. iOS Change Plan

### 4.1 Bundle id update in `project.pbxproj`

`ios/Runner.xcodeproj/project.pbxproj` — 3 hits to change (lines 371, 550, 572).

Without flavor schemes yet, set base id to **prod**: `com.app.cpbiege`. Per-flavor variants get added in §4.2.

```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.example.beigeCreativeApp;
+ PRODUCT_BUNDLE_IDENTIFIER = com.app.cpbiege;
```

Also update `RunnerTests` ids (lines 387, 404, 419):
```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.example.beigeCreativeApp.RunnerTests;
+ PRODUCT_BUNDLE_IDENTIFIER = com.app.cpbiege.RunnerTests;
```

### 4.2 Add Xcode build configs for flavors

Open `ios/Runner.xcworkspace` in Xcode. **Project navigator → Runner project → Info tab → Configurations**.

Duplicate each existing config into `-dev` + `-prod` pair:

| Source | New configs |
|---|---|
| `Debug` | `Debug-dev`, `Debug-prod` |
| `Release` | `Release-dev`, `Release-prod` |
| `Profile` | `Profile-dev`, `Profile-prod` |

Delete the unsuffixed `Debug` / `Release` / `Profile` after duplication (Flutter `--flavor` requires every config to be flavor-tagged).

### 4.3 xcconfig per flavor

Create:
```
ios/Flutter/Debug-dev.xcconfig
ios/Flutter/Release-dev.xcconfig
ios/Flutter/Profile-dev.xcconfig
ios/Flutter/Debug-prod.xcconfig
ios/Flutter/Release-prod.xcconfig
ios/Flutter/Profile-prod.xcconfig
```

**Debug-dev.xcconfig:**
```
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.app.cpbiege.dev
APP_DISPLAY_NAME = BeigeCp Dev
```

**Release-dev.xcconfig** / **Profile-dev.xcconfig**: same but include the `release`/`profile` Pods xcconfig respectively.

**Debug-prod.xcconfig:**
```
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.app.cpbiege
APP_DISPLAY_NAME = BeigeCp
```

Wire each xcconfig to its matching Xcode config in **Project → Info → Configurations** (set the file for each row).

### 4.4 `Info.plist` display name

`ios/Runner/Info.plist:7-8`:
```diff
  <key>CFBundleDisplayName</key>
- <string>Beige Creative App</string>
+ <string>$(APP_DISPLAY_NAME)</string>
```

### 4.5 Build Settings — clear hardcoded bundle id

In Xcode → Runner target → Build Settings → search `PRODUCT_BUNDLE_IDENTIFIER`. If set per-config in the project file, **delete the override** so the xcconfig value wins. Verify on each of the 6 configs.

### 4.6 Schemes

Create two shared schemes (Xcode → Product → Scheme → Manage Schemes → duplicate `Runner`):

- `Runner-dev` — Run / Test / Profile / Analyze / Archive all use `*-dev` configs.
- `Runner-prod` — all use `*-prod` configs.

Mark both **Shared** (checkbox in Manage Schemes). Delete the original `Runner` scheme.

Files land at:
```
ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-dev.xcscheme
ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-prod.xcscheme
```

### 4.7 macOS scheme (if macOS target shipped)

Same pattern under `macos/Runner.xcodeproj/`. Skip if macOS not a deliverable.

---

## 5. Dart-side adjustments (none required)

`lib/main_dev.dart` / `lib/main_prod.dart` already select `Environment.dev` / `Environment.prod`. No code change. CLAUDE.md command list updates only (§7 below).

---

## 6. Verification

### 6.1 Android
```bash
flutter clean
flutter pub get
flutter run --flavor dev  -t lib/main_dev.dart
# Check: app installs as "BeigeCp Dev", package com.app.cpbiege.dev
adb shell pm list packages | grep cpbiege

flutter run --flavor prod -t lib/main_prod.dart
# Check: app installs as "BeigeCp", package com.app.cpbiege
```

### 6.2 iOS
```bash
flutter clean
cd ios && pod install && cd ..
flutter run --flavor dev  -t lib/main_dev.dart
# Check: Settings → General → iPhone Storage → "BeigeCp Dev", bundle com.app.cpbiege.dev

flutter run --flavor prod -t lib/main_prod.dart
# Check: "BeigeCp", bundle com.app.cpbiege
```

### 6.3 Side-by-side install
Run dev then prod on same device. Both icons must appear simultaneously.

### 6.4 Release build smoke
```bash
flutter build apk      --flavor dev  -t lib/main_dev.dart  --release
flutter build apk      --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
flutter build ios      --flavor prod -t lib/main_prod.dart --release --no-codesign
```

---

## 7. Documentation Updates

### 7.1 `CLAUDE.md` — `## Commands` block

Replace current commands with:
```bash
flutter run --flavor dev  -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart

flutter build apk       --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
flutter build ios       --flavor prod -t lib/main_prod.dart --release
```

Remove the line "There are NO Android product flavors" — incorrect.

### 7.2 `MIGRATION_PLAN.md` (repo root) §5 Decision #8

Update **Flavor mechanism** row:
```
Choice: Android product flavors (dev/prod) + iOS schemes (Runner-dev/Runner-prod) + per-flavor xcconfigs.
        Dart entrypoint still selected via -t lib/main_<flavor>.dart.
        Bundle id base: com.app.cpbiege (prod), com.app.cpbiege.dev (dev).
```

### 7.3 `docs/migration/phase2_structure_and_unblock.md`

Reference this doc from Phase 2.C — flavor + bundle id rename is a prerequisite to secrets migration (so each flavor can carry distinct keys via xcconfig + manifestPlaceholders).

---

## 8. External Side-Effects (out-of-repo)

After id change, the following resources must be updated **before** any release / TestFlight / Play submission. Track as separate tickets:

| System | Action |
|---|---|
| Apple App Store Connect | Create new app records for `com.app.cpbiege.dev` + `com.app.cpbiege`. Old `com.example.beigeCreativeApp` was never submitted; safe to ignore. Generate provisioning profiles + signing certs per id. |
| Apple Developer Portal | Register both App IDs; enable required capabilities (Push, Sign in with Apple if used). |
| Google Play Console | Create new app for `com.app.cpbiege`. Internal-testing track for `com.app.cpbiege.dev` if desired. |
| Google Cloud Console (Maps) | Add new Android SHA-1 + package `com.app.cpbiege` and `com.app.cpbiege.dev` to API key restrictions. Add new iOS bundle ids. **Rotate key** if previously exposed (it is — see plan Risk #5). |
| Stripe Dashboard | No bundle-id constraint; no change required. |
| Firebase (when wired) | New iOS apps + Android apps per flavor; download `google-services.json` + `GoogleService-Info.plist` per flavor. |
| Backend (`mobile.beige.app`) | If push tokens / device records keyed by bundle id, coordinate with backend lead to accept the new ids. |

---

## 9. Risk Register

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| 1 | Provisioning profile mismatch breaks iOS build | H | Generate profiles for both ids before first iOS build; keep Automatic Signing on during dev. |
| 2 | Maps API quota tied to old SHA / package — Maps blank | H | Add new package + SHA to key **before** first run. Verify on a real device, not emulator. |
| 3 | Firebase setup later requires re-download per flavor | M | Phase 3.F creates flavor source sets at the same time; flag in that batch. |
| 4 | Existing testers have old package — won't auto-update | M | Communicate uninstall+reinstall in release notes. Side-by-side install softens it. |
| 5 | Xcode config duplication misses an xcconfig wire-up | M | Verify all 6 configs (Debug-dev/prod, Release-dev/prod, Profile-dev/prod) point at xcconfig files; build each. |
| 6 | `PRODUCT_BUNDLE_IDENTIFIER` override in Build Settings beats xcconfig | M | After §4.5 deletion, run `flutter build ios --flavor dev --no-codesign` and inspect `Generated.xcconfig` output. |
| 7 | macOS / Windows / Linux targets diverge | L | Out of scope. Document explicitly that desktop targets keep current ids until needed. |

---

## 10. Effort + Ordering

| Step | Platform | Effort |
|---|---|---|
| 3.1–3.3 Android base id + manifest label + package move | Android | 0.5d |
| 3.5 Uninstall old packages from test devices | Android | 0.05d |
| 4.1 iOS pbxproj id update | iOS | 0.1d |
| 4.2–4.3 Xcode configs + xcconfig files | iOS | 0.5d |
| 4.4–4.5 `Info.plist` + Build Settings cleanup | iOS | 0.1d |
| 4.6 Schemes | iOS | 0.2d |
| 6 Verification (both flavors, both platforms, side-by-side, release smoke) | both | 0.3d |
| 7 Doc updates (CLAUDE.md + MIGRATION_PLAN.md + phase2) | docs | 0.1d |
| 8 External side-effects coordination | out-of-repo | 0.3d |
| | **Total** | **~2.2d** |

**Order:**
1. Android first (lower risk, no Apple signing involvement).
2. iOS next.
3. Verification on both before merge.
4. External side-effects scheduled in parallel — Maps key update **must precede** first device test on iOS.

**Single PR vs split:**
- One PR per platform recommended. Easier review, isolated rollback.
- Order: PR-A Android → PR-B iOS → PR-C doc updates.

---

## 11. Out of Scope

- Secrets migration to `--dart-define-from-file` (Phase 2.C).
- Firebase config files per flavor (Phase 3.F).
- Signing-config split per flavor on Android (`key.properties` setup — separate concern).
- iOS App Group / Keychain Sharing entitlements per flavor.
- macOS / Windows / Linux bundle ids.