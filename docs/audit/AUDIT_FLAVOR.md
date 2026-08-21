# AUDIT_FLAVOR.md — Flavouring & Environment Audit (#8)

**Auditor role:** Senior Flutter Architect / Release engineer.
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** `pubspec.yaml`, full `android/app/build.gradle.kts`, `ios/Runner.xcodeproj` + `ios/Flutter/*.xcconfig`, all `main*.dart`, `lib/config/env.dart`, `AndroidManifest.xml`, `Info.plist`, `.env*`, `.gitignore`.
**Output convention:** all docs live in `docs/` per project rule.

---

## Maturity level: **Basic**

> Two seams exist (Dart entry points + Android `productFlavors`); neither is wired together, iOS has no flavour split, no per-environment secrets, no Firebase, no per-environment signing, no CI to enforce pairings. **Production releases are possible but not safe.**

Evidence:
- ✅ Two Dart entry points: `lib/main_dev.dart` (`startApp(Environment.dev)`), `lib/main_prod.dart` (`startApp(Environment.prod)`) — map § Entry points.
- ✅ Two Android product flavors declared in `android/app/build.gradle.kts:41-53`: `dev` (`applicationIdSuffix ".dev"`, `app_name = "BeigeCp Dev"`), `prod` (`app_name = "BeigeCp"`) — map § Pre-audit flag #5.
- ✅ `Env` class with per-environment static fields — `lib/config/env.dart:1-23`.
- ❌ **No per-flavor manifest folders** (`android/app/src/dev`, `android/app/src/prod`): `ls android/app/src/` → only `debug/`, `main/`, `profile/` (Flutter default).
- ❌ **No iOS flavor**: `ls ios/Runner.xcodeproj/xcshareddata/xcschemes/` → only `Runner.xcscheme`. `ios/Flutter/` only contains `Debug.xcconfig` + `Release.xcconfig` (default Flutter scaffold).
- ❌ **No `--dart-define` usage anywhere** — confirmed by map § Pre-audit flag #7 (`grep "dart-define"` → 0 across `*.json`, `*.gradle*`, `*.sh`, `*.yaml`).
- ❌ **No `.env` files** of any kind (`find . -name ".env*"` → 0). `.gitignore` has no `.env` entry.
- ❌ **No Firebase configs** anywhere (map § Config surface).
- ❌ **No CI** (no `.github/`, `bitrise.yml`, `codemagic.yaml`, `fastlane/`).
- ❌ **No `key.properties`** — release builds fall back to debug signing (map § Pre-audit flag #8).

---

## Worst case: "Could a prod build hit a dev API?"

**Yes — and the most plausible accident path is via a cross-wired `--target` flag.**

### Trace (most plausible accident path)

1. The release engineer runs:
   ```bash
   flutter build apk --release --flavor prod
   ```
2. Because there is no `Makefile` / `fastlane/Fastfile` / `.github/workflows/*.yml` enforcing the pairing of `--flavor` and `--target`, **`--target` defaults to `lib/main.dart`**.
3. `lib/main.dart` does *not* declare a top-level `main()` function — it only defines `startApp(Environment environment)` (`lib/main.dart:9-24`). The build **succeeds compilation** because Flutter's bootstrap injects a default `main()` if not present, OR fails at link time depending on toolchain version — observed behavior on Flutter ≥3.22 is that the build fails with `Error: Method not found: 'main'`.

   So path (1)–(3) is caught by the toolchain. But …

4. The engineer corrects to:
   ```bash
   flutter build apk --release --flavor prod -t lib/main_dev.dart
   ```
   *(simple typo: typed `main_dev.dart` instead of `main_prod.dart`)*
5. **The build succeeds.**
   - Android flavor `prod` → `applicationId = "com.beige_creative_app"`, `app_name = "BeigeCp"`, prod icon.
   - Dart entrypoint `main_dev.dart` → `startApp(Environment.dev)` → `Env.apiUrl = 'https://mobile.beige.app/api/'` (dev backend).
6. The APK is named, branded, and signed as `prod`, with the prod application ID — **but at runtime calls the dev API**. Users in production hit the dev backend.

### Why nothing catches this

- `android/app/build.gradle.kts` does not assert that `flutter.target` matches the flavor.
- Dart's `Env` class does not assert against any build-time flag.
- The two systems (Android `productFlavors` and Dart `Environment` enum) are **independent axes** that the build system does not cross-check.
- There is no CI that builds both pairings and fails if mismatched.

### Inverse worst case

```bash
flutter build apk --release --flavor dev -t lib/main_prod.dart
```
Result: `applicationId = "com.beige_creative_app.dev"`, `app_name = "BeigeCp Dev"`, but the binary calls `https://mobile.prod.beige.app/api/`. A QA tester who side-loads the "dev" APK from CI would silently exercise production data.

### Plus: invalid Stripe key path

`lib/config/env.dart:20` sets `stripePublishableKey = 'PLACE_HOLDER_LIVE_STRIPE_KEY';` for prod. Any production checkout flow throws at first `Stripe.instance.confirmPayment(...)` — but the failure happens at the payment screen, not at build time. **A prod build will reach the field without anyone catching it.**

---

## Findings (severity order)

### F1. 🔴 CRITICAL — Android flavor and Dart entry point are independent axes with no cross-check

```kotlin
// android/app/build.gradle.kts:41-53
flavorDimensions += "environment"
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "BeigeCp Dev")
    }
    create("prod") {
        dimension = "environment"
        resValue("string", "app_name", "BeigeCp")
    }
}
```
```dart
// lib/main_dev.dart:1-4
import 'config/env.dart';
import 'main.dart';
void main() => startApp(Environment.dev);
```
```dart
// lib/main_prod.dart:1-4
import 'config/env.dart';
import 'main.dart';
void main() => startApp(Environment.prod);
```

The Android flavor decides `applicationId` + `app_name` + (eventually) signing config. The Dart `-t main_*.dart` decides which backend the app talks to. **There is no enforcement that flavor `dev` is paired with `lib/main_dev.dart`** — see worst-case trace above.

#### Fix — runtime assertion + build-time `--dart-define`

```dart
// lib/config/env.dart  (after)
enum Environment { dev, prod }

class Env {
  static late final Environment current;
  static late final String apiUrl;
  static late final String imageUrl;
  static late final String stripePublishableKey;
  static late final String googleMapsKey;

  static void init() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    if (flavor.isEmpty) {
      throw StateError('FLAVOR not set. Pass --dart-define=FLAVOR=dev|prod at build time.');
    }
    current = Environment.values.byName(flavor);
    apiUrl              = const String.fromEnvironment('API_URL');
    imageUrl            = const String.fromEnvironment('IMAGE_URL');
    stripePublishableKey= const String.fromEnvironment('STRIPE_PK');
    googleMapsKey       = const String.fromEnvironment('GOOGLE_MAPS_KEY');
    assert(apiUrl.startsWith('https://'),               'API_URL must be HTTPS.');
    assert(stripePublishableKey.isNotEmpty,             'STRIPE_PK is required.');
    assert(!stripePublishableKey.contains('PLACE_HOLDER'), 'STRIPE_PK placeholder shipped.');
  }
}
```

```dart
// lib/main.dart  (after — single entry point)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();           // dies fast if --dart-define missing
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(isLoggedIn: prefs.getBool('isLoggedIn') ?? false));
}
```
Delete `lib/main_dev.dart`, `lib/main_prod.dart`. **Pairing now enforced at the `flutter build` command line.**

### F2. 🔴 CRITICAL — `lib/main.dart` cannot be a build target

`lib/main.dart` defines `startApp(...)` but no top-level `main()`. If a CI script runs `flutter build apk` without `-t lib/main_*.dart`, the build either fails or silently consumes the wrong entry point depending on toolchain. Combined with F1, this is the route to a wrong-environment binary.

**Fix:** delete the dev/prod main files (F1 refactor) and make `lib/main.dart` the *single* entrypoint with a `main()` that reads `--dart-define=FLAVOR`. Or keep the two files and forbid the empty `-t` via a Makefile (F-section below). The single-entry approach is cleaner.

### F3. 🔴 HIGH — iOS has no flavor at all

```
ios/Flutter/
├── Debug.xcconfig              # default Flutter scaffold
├── Release.xcconfig
├── Generated.xcconfig          # autogenerated
└── AppFrameworkInfo.plist
ios/Runner.xcodeproj/xcshareddata/xcschemes/
└── Runner.xcscheme             # only one scheme
```

`Debug.xcconfig` content (verbatim):
```
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
#include "Generated.xcconfig"
```
`Release.xcconfig` (verbatim):
```
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
#include "Generated.xcconfig"
```

iOS therefore has:
- **One bundle ID** (whatever the project file says — typically `com.example.beigeCreativeApp` or similar; not separately verified in this audit).
- **One app name** = `"Beige Creative App"` (`ios/Runner/Info.plist:7-8`).
- **One Info.plist** for both flavors.
- **One scheme** (`Runner`).

A `flutter run --flavor dev` on iOS today is *ignored at the Xcode layer* — the only differentiation that lands is the Dart `-t` flag. So:

| Flutter CLI | Android behavior | iOS behavior |
|-------------|------------------|--------------|
| `--flavor dev -t lib/main_dev.dart` | `com.beige_creative_app.dev`, "BeigeCp Dev" branding, dev API | Single bundle ID, "Beige Creative App", dev API |
| `--flavor prod -t lib/main_prod.dart` | `com.beige_creative_app`, "BeigeCp" branding, prod API | **Same** single bundle ID, **same** "Beige Creative App", prod API |

**Result: on iOS, dev and prod cannot be side-loaded simultaneously**, and an end-user cannot distinguish dev from prod by icon or name.

### F4. 🔴 HIGH — No per-flavor signing, no `key.properties`

`android/app/build.gradle.kts:55-62`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { path -> file(path as String) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}
```
`android/key.properties` is **not present on disk** (map § Pre-audit flag #8). Release builds fall back to the debug keystore (`docs/AUDIT_SEC.md` §F2). No separate signing config per flavor → if/when the team gets a release keystore, dev and prod will share it.

### F5. 🔴 HIGH — Per-flavor manifest folders absent

```
android/app/src/
├── debug/    # debug build type
├── main/     # shared
└── profile/  # profile build type
```
No `dev/` or `prod/`. Per-flavor `AndroidManifest.xml`, `res/values/strings.xml`, `mipmap-*/ic_launcher.png`, `network_security_config.xml`, and Google Maps API keys cannot be different between flavors. Today the same Google Maps key is hard-coded in `android/app/src/main/AndroidManifest.xml:22-24` and shared between flavors (`docs/AUDIT_SEC.md` S1).

**Failure mode:** the moment ops want a separate Maps quota for dev vs prod, the team will be forced into either (a) `manifestPlaceholders` (the right answer — see refactor), or (b) per-flavor `src/dev/AndroidManifest.xml` files. The infrastructure for (b) doesn't exist yet.

### F6. 🔴 HIGH — Secrets baked into source rather than passed at build time

```dart
// lib/config/env.dart:13-20
case Environment.dev:
  apiUrl = 'https://mobile.beige.app/api/';
  imageUrl = 'https://d1pgtgqp0jru64.cloudfront.net/';
  stripePublishableKey =
      'pk_test_51S5czd54hnPNgHXUq7sunp8uvTDW4ln6aw8Y3bP249JZmx4xuvoIED4mZTuNIkAFcOoCApICfgv9dM4VbbleJo7L00GqNEkj3I';
case Environment.prod:
  apiUrl = 'https://mobile.prod.beige.app/api/';
  imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/';
  stripePublishableKey = 'PLACE_HOLDER_LIVE_STRIPE_KEY';
```

Cross-ref `docs/AUDIT_SEC.md` S2. Two design problems compound:

1. **Rotation requires a code change**, a PR review, and a binary release. Mean-time-to-rotate-a-Stripe-key: days.
2. **The placeholder in prod ships unless someone notices**. A pre-release check that a real `pk_live_...` is present would catch it; the `assert` in F1's `Env.init` refactor provides this.

### F7. 🟠 MEDIUM — `flutter_dotenv` declared but unused

`pubspec.yaml:45` — `flutter_dotenv: ^5.0.2`. `grep -rln "flutter_dotenv\|DotEnv\|dotenv" lib` → **0** (map § Utilities). The team imported the dependency intending to drive env from `.env` files but never wired it. Either:

- (a) Adopt `--dart-define-from-file=env/dev.json` (Flutter ≥3.7) — JSON files committed under `env/`, secrets injected via CI, secrets file gitignored.
- (b) Use `flutter_dotenv`: ship a `.env.example`, gitignore `.env*` (currently NOT in `.gitignore`).

Pick (a). Modern best practice; supported natively; works with the `String.fromEnvironment` API.

### F8. 🟠 MEDIUM — No build commands documented, no Makefile/Fastfile

No `Makefile`, no `fastlane/Fastfile`, no `tool/build_*.sh`, no `Justfile`. The pairing `--flavor X -t lib/main_X.dart` is enforced only by developer memory. Each new contributor invents their own command.

### F9. 🟠 MEDIUM — No per-environment Firebase / Crashlytics

`grep -rn "FirebaseCrashlytics\|firebase_crashlytics\|firebase_analytics" lib pubspec.yaml` → **0** (re-confirmed from map § Config surface).

If/when crash reporting is added, the codebase needs:
- Per-flavor `google-services.json` in `android/app/src/{dev,prod}/google-services.json`.
- Per-flavor `GoogleService-Info.plist` linked into per-flavor Xcode build phase.
- A `--dart-define=FIREBASE_PROJECT_ID=...` if using `firebase_options.dart`.

None of this scaffolding exists today.

### F10. 🟡 LOW — `.env*` not in `.gitignore`

`.gitignore` (read at intake) does not list `.env`, `.env.*`, or `env/`. If the team starts using `.env` files (F7), they'll commit secrets by default. **Fix while it's still hypothetical**, before the first commit accidents.

### F11. 🟡 LOW — Current flavor not exposed in UI for debugging

The `Env.current` field exists (`lib/config/env.dart:4`) but no debug overlay shows it. A common QA technique is rendering a small "DEV" / "STAGING" / "PROD" badge in the top-right corner of every screen in non-prod builds. Not blocking; useful.

---

## Recommended Android setup

Replace `android/app/build.gradle.kts:33-77` with a flavor-aware variant that:
- Passes Google Maps key via `manifestPlaceholders` from a per-flavor property.
- Adds a `staging` flavor for completeness.
- Wires per-flavor `applicationId` (full, not just suffix) so all three flavors install side-by-side.
- Loads signing config from `key.properties` if present, falls back to `debug` only for debug builds.

```kotlin
// android/app/build.gradle.kts (excerpt — productFlavors block)

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.beige_creative_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.beige_creative_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "BeigeCp Dev")
            manifestPlaceholders["MAPS_API_KEY"] =
                (project.findProperty("MAPS_API_KEY_DEV") ?: "") as String
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "BeigeCp Stg")
            manifestPlaceholders["MAPS_API_KEY"] =
                (project.findProperty("MAPS_API_KEY_STAGING") ?: "") as String
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "BeigeCp")
            manifestPlaceholders["MAPS_API_KEY"] =
                (project.findProperty("MAPS_API_KEY_PROD") ?: "") as String
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias       = keystoreProperties["keyAlias"] as String
                keyPassword    = keystoreProperties["keyPassword"] as String
                storeFile      = file(keystoreProperties["storeFile"] as String)
                storePassword  = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled   = true
            isShrinkResources = true
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

Also create per-flavor folders for icons and `network_security_config.xml`:

```
android/app/src/
├── main/                              # shared
├── debug/                             # debug build type (kept)
├── profile/                           # profile build type (kept)
├── dev/
│   ├── AndroidManifest.xml            # optional, only if overriding main's <application>
│   └── res/mipmap-*/ic_launcher.png   # dev icon (e.g., bright orange)
├── staging/
│   └── res/mipmap-*/ic_launcher.png   # staging icon
└── prod/
    └── res/mipmap-*/ic_launcher.png   # prod icon
```

Replace the hardcoded Maps key in `AndroidManifest.xml:22-24` with:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}"/>
```

---

## Recommended iOS setup

iOS requires Xcode-level configuration. Plan:

### Schemes

Create three schemes by duplicating `Runner.xcscheme`:
- `Runner-Dev` → Debug-Dev / Release-Dev build configurations
- `Runner-Staging` → Debug-Staging / Release-Staging
- `Runner-Prod` → Debug-Prod / Release-Prod

### xcconfig files

```
ios/Flutter/
├── Generated.xcconfig
├── Debug-Dev.xcconfig
├── Debug-Staging.xcconfig
├── Debug-Prod.xcconfig
├── Release-Dev.xcconfig
├── Release-Staging.xcconfig
├── Release-Prod.xcconfig
└── Shared/
    ├── Dev.xcconfig            # PRODUCT_BUNDLE_IDENTIFIER, APP_DISPLAY_NAME, FLAVOR
    ├── Staging.xcconfig
    └── Prod.xcconfig
```

`ios/Flutter/Shared/Dev.xcconfig`:
```
PRODUCT_BUNDLE_IDENTIFIER = com.beige_creative_app.dev
APP_DISPLAY_NAME          = BeigeCp Dev
FLAVOR                    = dev
GOOGLE_MAPS_KEY           = $(GOOGLE_MAPS_KEY_DEV)
STRIPE_PK                 = $(STRIPE_PK_DEV)
API_URL                   = https:/$()/mobile.beige.app/api/
IMAGE_URL                 = https:/$()/d1pgtgqp0jru64.cloudfront.net/
```

`ios/Flutter/Debug-Dev.xcconfig`:
```
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
#include "Generated.xcconfig"
#include "Shared/Dev.xcconfig"
```

(Repeat the pattern for staging + prod.)

### Info.plist

`ios/Runner/Info.plist` already uses `$(EXECUTABLE_NAME)`, `$(FLUTTER_BUILD_NAME)`, etc. Add:

```xml
<key>CFBundleDisplayName</key>
<string>${APP_DISPLAY_NAME}</string>
<key>FLAVOR</key>
<string>${FLAVOR}</string>
```

Plus all the `NS*UsageDescription` strings missing today (`docs/AUDIT_SEC.md` §F7).

### Bundle IDs

In Xcode → Runner target → Build Settings → `PRODUCT_BUNDLE_IDENTIFIER`:
- per-config to `$(PRODUCT_BUNDLE_IDENTIFIER)` reading from the xcconfig.

### Side-by-side install

After the above, `com.beige_creative_app.dev`, `com.beige_creative_app.staging`, `com.beige_creative_app` all install simultaneously on iOS — same as Android.

---

## Recommended Dart entry points

**Two viable patterns. Recommend (B) for this codebase.**

### Pattern (A) — keep `main_dev.dart` / `main_prod.dart`, add staging

```dart
// lib/main_dev.dart
import 'config/env.dart';
import 'main.dart';
void main() => startApp(Environment.dev);
```
```dart
// lib/main_staging.dart
import 'config/env.dart';
import 'main.dart';
void main() => startApp(Environment.staging);
```
```dart
// lib/main_prod.dart
import 'config/env.dart';
import 'main.dart';
void main() => startApp(Environment.prod);
```

Pairing risk remains (F1). Only worth keeping if the team strongly prefers the convention.

### Pattern (B) — single `lib/main.dart` + `--dart-define` (recommended)

```dart
// lib/main.dart  (full)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'config/env.dart';
import 'utility/colorcode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();                                    // throws if --dart-define missing
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      routerConfig: appRouter,
      theme: _buildTheme(),
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          if (Env.current != Environment.prod) const _FlavorBadge(),  // F11
        ],
      ),
    );
  }

  ThemeData _buildTheme() => ThemeData(
        scaffoldBackgroundColor: ColorCode.backgroundColor,
        // ... existing theme
      );
}

class _FlavorBadge extends StatelessWidget {
  const _FlavorBadge();
  @override
  Widget build(BuildContext context) => Positioned(
    top: 8, right: 8,
    child: IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        color: Env.current == Environment.dev ? Colors.orange : Colors.purple,
        child: Text(
          Env.current.name.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
```

Then delete `lib/main_dev.dart` and `lib/main_prod.dart`. The Android/iOS flavors continue to drive branding/signing; Dart side reads everything from `--dart-define`. **One entry point, multiple build configurations.**

---

## AppConfig pattern

```dart
// lib/config/env.dart  (full)

enum Environment { dev, staging, prod }

class Env {
  Env._();    // no instances

  static late final Environment current;
  static late final String apiUrl;
  static late final String imageUrl;
  static late final String stripePublishableKey;
  static late final String googleMapsKey;

  static bool get isProd => current == Environment.prod;
  static bool get isDev  => current == Environment.dev;

  static void init() {
    const flavor = String.fromEnvironment('FLAVOR');
    if (flavor.isEmpty) {
      throw StateError(
        'FLAVOR not set. Build with --dart-define-from-file=env/<flavor>.json',
      );
    }
    current = Environment.values.byName(flavor);

    apiUrl               = const String.fromEnvironment('API_URL');
    imageUrl             = const String.fromEnvironment('IMAGE_URL');
    stripePublishableKey = const String.fromEnvironment('STRIPE_PK');
    googleMapsKey        = const String.fromEnvironment('GOOGLE_MAPS_KEY');

    // Fail-fast guards prevent the worst-case path documented above.
    assert(apiUrl.isNotEmpty,                 'API_URL not provided.');
    assert(apiUrl.startsWith('https://'),     'API_URL must be HTTPS.');
    assert(imageUrl.isNotEmpty,               'IMAGE_URL not provided.');
    assert(stripePublishableKey.isNotEmpty,   'STRIPE_PK not provided.');
    assert(
      !stripePublishableKey.contains('PLACE_HOLDER'),
      'Refusing to boot: STRIPE_PK is a placeholder.',
    );
    assert(googleMapsKey.isNotEmpty,          'GOOGLE_MAPS_KEY not provided.');

    // Belt-and-braces: prod must not point at a dev URL.
    if (current == Environment.prod) {
      assert(apiUrl.contains('prod'),         'PROD flavor with non-prod API_URL.');
    }
  }
}
```

`env/` directory (gitignore the secret variant; commit `*.example`):

```
env/
├── .gitignore       # ignores *.json except *.example.json
├── dev.example.json
├── staging.example.json
├── prod.example.json
├── dev.json         # gitignored
├── staging.json     # gitignored
└── prod.json        # gitignored
```

```json
// env/dev.example.json
{
  "FLAVOR": "dev",
  "API_URL": "https://mobile.beige.app/api/",
  "IMAGE_URL": "https://d1pgtgqp0jru64.cloudfront.net/",
  "STRIPE_PK": "pk_test_REDACTED",
  "GOOGLE_MAPS_KEY": "REDACTED"
}
```

`.gitignore` additions:
```
# environment secrets
env/*.json
!env/*.example.json
.env
.env.*
```

---

## Build commands

Tracking enforcement: ship a `Makefile` so every contributor and every CI job uses the same incantation.

```makefile
# Makefile

FLUTTER ?= flutter

# Default to dev for safety
.DEFAULT_GOAL := run-dev

# ─── run ────────────────────────────────────────────────────────────────
run-dev:
	$(FLUTTER) run --flavor dev --dart-define-from-file=env/dev.json

run-staging:
	$(FLUTTER) run --flavor staging --dart-define-from-file=env/staging.json

run-prod:
	$(FLUTTER) run --flavor prod --dart-define-from-file=env/prod.json

# ─── build android ──────────────────────────────────────────────────────
build-android-dev:
	$(FLUTTER) build apk --flavor dev --dart-define-from-file=env/dev.json --release

build-android-staging:
	$(FLUTTER) build appbundle --flavor staging --dart-define-from-file=env/staging.json --release

build-android-prod:
	$(FLUTTER) build appbundle --flavor prod --dart-define-from-file=env/prod.json \
		--release --obfuscate --split-debug-info=build/symbols/android/$$(date +%Y%m%d)

# ─── build ios ──────────────────────────────────────────────────────────
build-ios-dev:
	$(FLUTTER) build ios --flavor dev --dart-define-from-file=env/dev.json --release --no-codesign

build-ios-staging:
	$(FLUTTER) build ipa --flavor staging --dart-define-from-file=env/staging.json --export-options-plist=ios/ExportOptions-Staging.plist

build-ios-prod:
	$(FLUTTER) build ipa --flavor prod --dart-define-from-file=env/prod.json \
		--release --obfuscate --split-debug-info=build/symbols/ios/$$(date +%Y%m%d) \
		--export-options-plist=ios/ExportOptions-Prod.plist

# ─── lint + test ────────────────────────────────────────────────────────
analyze:
	$(FLUTTER) analyze --fatal-infos

test:
	$(FLUTTER) test

ci: analyze test build-android-dev
```

CI workflow (`.github/workflows/ci.yml`):

```yaml
name: CI
on: [pull_request]

jobs:
  flutter:
    runs-on: ubuntu-latest         # case-sensitive — surfaces import-casing bugs
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze --fatal-infos
      - run: flutter test
      - name: Build dev APK
        run: |
          echo '${{ secrets.ENV_DEV_JSON }}' > env/dev.json
          flutter build apk --flavor dev --dart-define-from-file=env/dev.json
```

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Collapse `lib/main_dev.dart` + `lib/main_prod.dart` into a single `lib/main.dart` + `--dart-define-from-file=env/<flavor>.json`.** *Effort: 0.5 dev-day.* *Impact:* eliminates the cross-wiring path (`--flavor prod -t lib/main_dev.dart`). Single entry, single source of truth, asserts fail fast if env vars are missing. (F1, F2, F6.)

2. 🔴 **Add a `Makefile` (or `tool/build.sh`) with one target per flavor that pairs `--flavor` with `--dart-define-from-file`.** *Effort: 1 dev-hour.* *Impact:* converts the pairing from "developer memory" to "filesystem". CI uses the same targets. No "what command did Bob use?" Slack threads. (F8.)

3. 🔴 **Replace hard-coded Maps + Stripe keys with `--dart-define` (Dart) and `manifestPlaceholders` (Android); add per-flavor xcconfig (iOS).** *Effort: 1 dev-day.* *Impact:* keys rotate without code changes; per-environment keys; prod key restriction in vendor consoles becomes effective. Combined with `docs/AUDIT_SEC.md` Top-fix #2.

4. 🔴 **Stand up iOS schemes + xcconfig for dev/staging/prod.** *Effort: 1 dev-day.* *Impact:* iOS gains per-flavor bundle ID + display name + side-by-side install (currently impossible). Closes the iOS-side asymmetry (F3).

5. 🟠 **Add `env/*.json` (gitignored), `env/*.example.json` (committed), update `.gitignore`, and add a startup `_FlavorBadge` widget for non-prod builds.** *Effort: 1 dev-hour.* *Impact:* contributors copy the example, set their own secrets, and any debug build visually announces its flavor. (F7, F10, F11.)

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and the audit set `docs/AUDIT_ARCH.md` / `docs/AUDIT_STATE.md` / `docs/AUDIT_STRUCT.md` / `docs/AUDIT_QUALITY.md` / `docs/AUDIT_PERF.md` / `docs/AUDIT_SEC.md` / `docs/AUDIT_SCALE.md`. All `.md` artefacts under `docs/` per project rule.*
