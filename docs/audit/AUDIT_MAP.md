# Project Map

Forensic intake. Facts only — no judgments. Source evidence cited inline. Generated 2026-05-20.

## Project metadata

| Field | Value | Source |
|-------|-------|--------|
| Project name | `beige_creative_app` | `pubspec.yaml:1` |
| Description | "A new Flutter project." (unchanged from template) | `pubspec.yaml:2` |
| Version | `1.0.0+1` | `pubspec.yaml:19` |
| Publish to pub.dev | disabled (`publish_to: 'none'`) | `pubspec.yaml:5` |
| Dart SDK constraint (pubspec) | `^3.10.4` | `pubspec.yaml:22` |
| Dart SDK (lock) | `>=3.10.4 <4.0.0` | `pubspec.lock:1153` |
| Flutter SDK (lock) | `>=3.27.0` | `pubspec.lock:1154` |
| Android namespace | `com.beige_creative_app` | `android/app/build.gradle.kts:20` |
| Android `applicationId` | `com.beige_creative_app` (`+.dev` for dev flavor) | `build.gradle.kts:34,46` |
| Android compileSdk / minSdk / targetSdk | `flutter.compileSdkVersion` / `flutter.minSdkVersion` / `flutter.targetSdkVersion` (no explicit override; uses Flutter 3.27 defaults: 35 / 21 / 35) | `build.gradle.kts:21,35-36` |
| Android Java / Kotlin JVM | Java 11 / JVM 11 | `build.gradle.kts:24-31` |
| Android NDK | `flutter.ndkVersion` (default) | `build.gradle.kts:22` |
| iOS deployment target | **not set** — `# platform :ios, '13.0'` is commented out in `Podfile:2` | `ios/Podfile:2` |
| iOS bundle display name | `"Beige Creative App"` | `ios/Runner/Info.plist:7-8` |
| iOS bundle name | `beige_creative_app` | `ios/Runner/Info.plist:15-16` |
| iOS supported orientations | Portrait + both Landscapes (iPad: + UpsideDown) | `ios/Runner/Info.plist:31-43` |
| Android label | `"BEIGECP"` (overridden per flavor to `BeigeCp` / `BeigeCp Dev`) | `AndroidManifest.xml:11`, `build.gradle.kts:47,51` |
| Targets declared (folder presence) | `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` (6) | filesystem |

## Dependencies (grouped tables)

Direct-only listed with both pubspec range and resolved version (lockfile). Group purpose inferred from import sites in `lib/`.

### State management

| Package | Pubspec range | Resolved | Imports in `lib/` | Purpose in this codebase |
|---------|---------------|----------|-------------------|--------------------------|
| `flutter_riverpod` | `^2.6.1` | `2.6.1` | **2 files** (all references are inside `lib/app/app.dart` block-comment) | **Not wired up at runtime.** `lib/app/app.dart` is entirely commented out; no `ProviderScope` in live tree. |

### Navigation

| Package | Pubspec range | Resolved | Imports in `lib/` | Purpose |
|---------|---------------|----------|-------------------|---------|
| `go_router` | `^14.8.1` | `14.8.1` | **32 files** | Single `GoRouter` in `lib/app/router.dart`. Routes invoked via `context.go(Named)` / `context.push(Named)` — 89 occurrences across `lib/`. |

(`Navigator.push*` direct calls: 32 occurrences across `lib/`, coexisting with the router-based ones.)

### Network

| Package | Pubspec range | Resolved | Imports in `lib/` | Purpose |
|---------|---------------|----------|-------------------|---------|
| `http` | `^1.4.0` | `1.6.0` | **1 file** (`lib/service/api_service.dart`) | GET/POST/PUT/DELETE in `ApiService`. |
| `dio` | `^5.9.0` | `5.9.2` | **5 files** | Multipart upload paths in `ApiService` + direct Dio usage at one widget site (registration step 3). |

### Local storage

| Package | Pubspec range | Resolved | Imports in `lib/` | Purpose |
|---------|---------------|----------|-------------------|---------|
| `shared_preferences` | `^2.5.3` | `2.5.3` | **6 files** | Auth token + user fields persisted by `lib/service/shared_service.dart`. Also read directly in screens (`lib/main.dart`, `lib/auth/login/login.dart`, `lib/service/api_service.dart`). |

### Auth / payment

| Package | Pubspec range | Resolved | Purpose |
|---------|---------------|----------|---------|
| `flutter_stripe` | `^12.1.1` | `12.6.0` | Declared. No `Stripe.publishableKey` assignment found in `lib/` (live `startApp` does not initialize Stripe). |

### DI

| Package | Pubspec range | Resolved | Notes |
|---------|---------------|----------|-------|
| — | — | — | **None declared.** No `get_it`, `injectable`, `kiwi`, `riverpod_generator`, or manual DI module present. |

### Serialization

| Package | Pubspec range | Resolved | Notes |
|---------|---------------|----------|-------|
| `freezed_annotation` | (transitive only) | `3.1.0` | Pulled by `flutter_stripe`; not directly used. |
| `json_annotation` | (transitive only) | `4.11.0` | Pulled transitively; not directly used. |
| — | — | — | All models in `lib/model_class/` are hand-written `fromJson`. No code-gen tooling (`build_runner`, `json_serializable`, `freezed`) is declared as a dev dep. |

### UI / media

| Package | Pubspec range | Resolved | Purpose |
|---------|---------------|----------|---------|
| `cupertino_icons` | `^1.0.8` | `1.0.9` | Default icon font (no Cupertino-style code observed) |
| `flutter_svg` | `^2.0.10` | `2.2.0` | SVG asset rendering for tab/drawer icons |
| `cached_network_image` | `^3.3.1` | `3.4.1` | Profile / thumbnail caching |
| `lottie` | `^3.1.0` | `3.3.1` | Splash and success-state animations |
| `photo_view` | `^0.15.0` | `0.15.0` | Image zoom viewer |
| `auto_skeleton` | `^0.4.1` | `0.4.1` | Loading skeletons |
| `dotted_border` | `^3.1.0` | `3.1.0` | Decorative borders (file pickers) |
| `table_calendar` | `^3.0.9` | `3.1.3` | Availability / shoot calendar |
| `image_picker` | `^1.0.7` | `1.2.0` | Gallery/camera picker |
| `image_cropper` | `^10.0.0+1` | `10.0.0+1` | Crop after pick |
| `file_picker` | `^8.0.0` | `8.3.7` | Resume/portfolio file picker |
| `open_file` | `^3.3.2` | `3.5.11` | Open downloaded files |

### Location & maps

| Package | Pubspec range | Resolved | Purpose |
|---------|---------------|----------|---------|
| `google_maps_flutter` | `^2.6.0` | `2.12.3` | Map display |
| `google_places_flutter` | `^2.0.6` | `2.1.1` | Address autocomplete |
| `geocoding` | `^2.1.1` | `2.2.2` | Reverse geocode |
| `geolocator` | `^11.0.0` | `11.1.0` | Current position |

### Utilities

| Package | Pubspec range | Resolved | Purpose |
|---------|---------------|----------|---------|
| `intl` | `^0.19.0` | `0.19.0` | Date/time formatting (`DateFormat`) |
| `path_provider` | `^2.1.2` | `2.1.5` | Temp/app-doc directories |
| `flutter_dotenv` | `^5.0.2` | `5.2.1` | **Declared but not imported anywhere in `lib/`** — grep `flutter_dotenv\|DotEnv\|dotenv` over `lib/` returns 0 matches. |

### Dev tooling

| Package | Pubspec range | Resolved | Purpose |
|---------|---------------|----------|---------|
| `flutter_test` | sdk | sdk | Default Flutter test framework |
| `flutter_lints` | `^6.0.0` | `6.0.0` | Lint set (default `flutter.yaml`, no customization) |

### Pubspec range vs resolved drift (direct deps)

| Package | Pubspec range | Resolved | Drift |
|---------|---------------|----------|-------|
| `http` | `^1.4.0` | `1.6.0` | +2 minor |
| `dio` | `^5.9.0` | `5.9.2` | +2 patch |
| `image_picker` | `^1.0.7` | `1.2.0` | +1 minor |
| `file_picker` | `^8.0.0` | `8.3.7` | +3 minor |
| `cached_network_image` | `^3.3.1` | `3.4.1` | +1 minor |
| `open_file` | `^3.3.2` | `3.5.11` | +2 minor |
| `lottie` | `^3.1.0` | `3.3.1` | +2 minor |
| `flutter_svg` | `^2.0.10` | `2.2.0` | +2 minor |
| `path_provider` | `^2.1.2` | `2.1.5` | +3 patch |
| `geolocator` | `^11.0.0` | `11.1.0` | +1 minor |
| `geocoding` | `^2.1.1` | `2.2.2` | +1 minor |
| `flutter_stripe` | `^12.1.1` | `12.6.0` | +5 minor |
| `google_maps_flutter` | `^2.6.0` | `2.12.3` | +6 minor |
| `table_calendar` | `^3.0.9` | `3.1.3` | +1 minor |

## Folder tree

```
lib/
├── main.dart                                # MyApp + startApp (StatelessWidget)
├── main_dev.dart                            # startApp(Environment.dev)
├── main_prod.dart                           # startApp(Environment.prod)
├── main_screen.dart                         # post-login shell (bottom nav + drawer)
├── app/                                     # router + (mostly unused) theme/token files
│   ├── app.dart                             # entire file is a block comment (ConsumerWidget root)
│   ├── assets.dart
│   ├── colors.dart
│   ├── durations.dart
│   ├── radii.dart
│   ├── route_names.dart                     # RouteNames constants
│   ├── router.dart                          # single GoRouter
│   ├── shadows.dart
│   ├── spacing.dart
│   ├── text_styles.dart
│   └── theme.dart
├── auth/
│   ├── view_details_screen .dart            # filename contains an embedded space character
│   ├── forgotpassword/
│   │   ├── forgot_password_otp_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── login/
│   │   └── login.dart
│   ├── resetpassword/
│   │   └── reset_password_screen.dart
│   └── sign_up/
│       ├── signup1_screen.dart
│       ├── signup2_screen.dart
│       └── signup3_screen.dart
├── config/
│   └── env.dart                             # Env { apiUrl, imageUrl, stripePublishableKey }
├── file_manager/
│   ├── file_manager_screen.dart
│   ├── post_production_screen.dart
│   ├── pre_production_screen.dart
│   └── view_details_screen.dart
├── home/
│   └── home_screen.dart
├── manageavailability/
│   ├── add_availability_screen.dart
│   └── manage_availability_screen.dart
├── messages/
│   └── messages_screen.dart
├── model_class/                             # imported as "Model_Class/" from 7+ sites
│   ├── create_dashboard_details_model.dart
│   ├── crewstatus_model.dart
│   ├── dashboard_count_model.dart
│   ├── edit_profile_model.dart
│   ├── myprofile_model.dart
│   ├── shoot_count_model.dart
│   ├── shoot_status_model.dart
│   ├── shoots_model.dart
│   ├── upcoming_shoots_model.dart
│   └── upcoming_shootview_model.dart
├── onboding/                                # spelled "onboding"
│   └── onboding_screen.dart
├── Profile/                                 # PascalCase folder
│   ├── app_preferences.dart
│   ├── certificates.dart
│   ├── featured_work_list.dart
│   ├── myprofile.dart
│   ├── myprofile_youre_all_set_screen.dart
│   ├── profile_new_passwrod_screen.dart    # "passwrod" typo
│   ├── resume_screen.dart
│   ├── deleteaccount/
│   │   ├── delete_account.dart
│   │   ├── delete_account_lottieScreen.dart
│   │   └── delete_account_otp_screen.dart
│   └── profiledetils/
│       ├── edit_personal_details_screen.dart
│       ├── enter_profile_details_screen.dart
│       └── profile_detils_1screen.dart
├── service/
│   ├── api_endpoints.dart
│   ├── api_service.dart                     # http + dio hybrid
│   ├── config.dart
│   ├── google_config.dart
│   └── shared_service.dart                  # static SharedPreferences helpers
├── shoots/
│   ├── shoot_cancelled_lotties_screen.dart
│   ├── shoot_cancelled_screen.dart
│   ├── shoot_request_accepted.dart
│   └── shoots_screen.dart
├── splash/
│   └── splash_screen.dart
├── upcomingshootviewdetils/                 # spelled "viewdetils"
│   └── upcoming_shoot_view_detils.dart
├── utility/
│   ├── Utils.dart                           # PascalCase filename
│   ├── app_utils.dart
│   ├── colorcode.dart                       # ColorCode constants
│   ├── imges_icons.dart                     # "imges" — AppImages asset registry
│   └── location_service.dart
└── widgets/
    ├── app_loder.dart                       # "loder" — AppLoader
    ├── commonFileViewer.dart                # camelCase filename
    ├── commonImagePicker.dart               # camelCase filename
    ├── common_calendar.dart
    ├── common_uploader.dart
    ├── custom_dropdown.dart
    ├── custom_dropdown_field.dart
    ├── custom_multi_selectfield.dart
    ├── custom_text_field.dart
    ├── date_time.dart
    ├── multi_arc_painter.dart
    ├── new_Textfield.dart                   # mixed case filename
    └── Topmessgae.dart                      # "messgae" typo, PascalCase filename
```

### File counts per top-level `lib/` folder

| Folder | `.dart` files |
|--------|---------------|
| `Profile/` | 13 |
| `widgets/` | 13 |
| `app/` | 11 |
| `model_class/` | 10 |
| `auth/` | 8 |
| `service/` | 5 |
| `utility/` | 5 |
| `file_manager/` | 4 |
| `shoots/` | 4 |
| `manageavailability/` | 2 |
| `config/` | 1 |
| `home/` | 1 |
| `messages/` | 1 |
| `onboding/` | 1 |
| `splash/` | 1 |
| `upcomingshootviewdetils/` | 1 |
| (root of `lib/`) | 4 (`main.dart`, `main_dev.dart`, `main_prod.dart`, `main_screen.dart`) |
| **Total** | **85** |

### Naming convention per folder

| Folder | Folder casing | File casing |
|--------|---------------|-------------|
| `Profile/`, `Profile/deleteaccount/`, `Profile/profiledetils/` | PascalCase / lowercase nested | snake_case + one camelCase (`delete_account_lottieScreen.dart`) |
| `auth/`, `auth/forgotpassword/`, `auth/login/`, `auth/resetpassword/`, `auth/sign_up/` | lowercase | snake_case + one with a literal space (`view_details_screen .dart`) |
| `widgets/` | lowercase | mixed: `snake_case`, `camelCase` (`commonFileViewer.dart`, `commonImagePicker.dart`), `PascalCase` (`Topmessgae.dart`), `mixed_Case` (`new_Textfield.dart`) |
| `utility/` | lowercase | mostly snake_case; `Utils.dart` PascalCase |
| `app/`, `config/`, `file_manager/`, `home/`, `manageavailability/`, `messages/`, `model_class/`, `onboding/`, `service/`, `shoots/`, `splash/`, `upcomingshootviewdetils/` | lowercase | snake_case |

## Largest files

| # | Path | Lines |
|---|------|-------|
| 1 | `lib/auth/sign_up/signup3_screen.dart` | 3,465 |
| 2 | `lib/home/home_screen.dart` | 2,902 |
| 3 | `lib/Profile/myprofile.dart` | 2,834 |
| 4 | `lib/auth/sign_up/signup1_screen.dart` | 1,959 |
| 5 | `lib/Profile/featured_work_list.dart` | 1,703 |
| 6 | `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` | 1,396 |
| 7 | `lib/auth/sign_up/signup2_screen.dart` | 1,328 |
| 8 | `lib/shoots/shoots_screen.dart` | 1,079 |
| 9 | `lib/Profile/profiledetils/enter_profile_details_screen.dart` | 950 |
| 10 | `lib/manageavailability/add_availability_screen.dart` | 915 |

## Entry points and flavors

### Dart entrypoints

| File | Body |
|------|------|
| `lib/main_dev.dart` | `void main() => startApp(Environment.dev);` |
| `lib/main_prod.dart` | `void main() => startApp(Environment.prod);` |
| `lib/main.dart` | defines `startApp(Environment environment)` → `Env.init(environment)` → reads `isLoggedIn` from `SharedPreferences` → `runApp(MyApp(isLoggedIn: ...))`. **Not itself runnable as a default `main()` — the file declares no top-level `main()`.** |

`MyApp` is a `StatelessWidget` mounting `MaterialApp.router(routerConfig: appRouter)` with inline theme (see `lib/main.dart:38-101`).

### Android product flavors (verbatim)

From `android/app/build.gradle.kts:41-53`:

```kotlin
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

Build types from `android/app/build.gradle.kts:55-76`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { path -> file(path as String) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}

buildTypes {
    release {
        signingConfig = if (keystorePropertiesFile.exists()) {
            signingConfigs.getByName("release")
        } else {
            signingConfigs.getByName("debug")
        }
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

`android/key.properties` is **not present** on disk → release builds fall back to the debug keystore.

Per-flavor manifest folders (`android/app/src/dev`, `android/app/src/prod`) are **not present**; the only flavor differentiation is the `app_name` resource value. Existing flavor-aware manifests are only `src/main`, `src/debug`, `src/profile`.

### iOS schemes

`ios/Podfile:7-11`:

```ruby
project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}
```

Only the default `Runner` scheme is configured. No dev/prod scheme split is declared on the iOS side; `ios/Runner.xcodeproj/project.pbxproj` is present but no flavor schemes were enumerated by name in the Podfile.

`ios/Podfile:2` — `# platform :ios, '13.0'` is commented; deployment target defers to Xcode default.

### `--dart-define` and external launch tooling

| Source | Result |
|--------|--------|
| `grep "dart-define"` over `.json`, `.sh`, `.gradle*`, `Makefile`, `*.yaml` | no matches |
| `launch.json` (VS Code) | not present |
| `.idea/runConfigurations/` | not present |
| `Makefile` | not present |
| `fastlane/` | not present |
| `ios/Flutter/flutter_export_environment.sh` | auto-generated by Flutter tooling; not user-authored |

## Detected patterns (import counts as evidence)

All counts are over `lib/` only.

| Pattern | Evidence | Count |
|---------|----------|-------|
| State management — Riverpod | `grep -rln "package:flutter_riverpod" lib` | 2 files (all references inside the commented-out `lib/app/app.dart`) |
| State management — Provider / BLoC / GetX / MobX | grep `package:provider\|flutter_bloc\|get/get\|mobx` | 0 |
| Navigation — `go_router` | `grep -rln "package:go_router" lib` | 32 files |
| Navigation — `context.go*` / `context.push*` / `context.pop` | grep | 89 occurrences |
| Navigation — raw `Navigator.push*` / `Navigator.pushNamed` / `Navigator.pushReplacement` / `Navigator.pushAndRemoveUntil` | grep | 32 occurrences |
| HTTP — `package:http` | grep | 1 file (`lib/service/api_service.dart`) |
| HTTP — `package:dio` | grep | 5 files |
| Local storage — `SharedPreferences` | grep | 6 files |
| Env loader — `flutter_dotenv` / `DotEnv` / `dotenv` | grep | **0** (declared in `pubspec.yaml` but never imported) |
| DI container — `get_it` / `injectable` / equivalents | grep / `pubspec.yaml` | 0 |
| HTTP service instantiation — `ApiService()` constructor call | grep `ApiService()` | 58 occurrences across screens |

## Test surface

- `test/` exists. **1 file:** `test/widget_test.dart`.
- `integration_test/` directory: **not present.**
- Mirror of `lib/`: **no.** The single file is the unmodified Flutter "counter app" template:

  ```dart
  // test/widget_test.dart:13-29
  void main() {
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  }
  ```

  It calls `MyApp()` with no arguments, but the live `MyApp` in `lib/main.dart:30-33` requires `isLoggedIn: bool` — the test would not compile if executed.

- Test types: unit — 0; widget — 1 (boilerplate); golden — 0; integration — 0.

## Config surface

| Surface | Present? | Detail |
|---------|----------|--------|
| `lib/config/env.dart` | yes | `Environment { dev, prod }` enum + static `Env.{apiUrl, imageUrl, stripePublishableKey}` initialized by `Env.init(Environment)`. URLs and Stripe keys are hard-coded inline. |
| `.env` / `.env.dev` / `.env.prod` | **no** | None present anywhere in the working tree. |
| `lib/service/config.dart` | yes | (not opened during this intake — record only) |
| `lib/service/google_config.dart` | yes | (not opened during this intake — record only) |
| `app_config.dart` / `constants.dart` / `flavors.dart` | **no** | Not present. |
| `firebase_options.dart` | **no** | Not present. |
| `google-services.json` (Android) | **no** | Not present in `android/app/`. |
| `GoogleService-Info.plist` (iOS) | **no** | Not present in `ios/Runner/`. |
| Google Maps Android key | hard-coded in `android/app/src/main/AndroidManifest.xml:22-24`: `AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc` (single key shared by both dev and prod flavors) | |
| iOS Google Maps key | not located in `Info.plist`; likely set in Swift code (not read during this intake) | |
| `android/key.properties` | **no** | Referenced by `build.gradle.kts:13-17`; absence causes release builds to fall back to debug signing (`build.gradle.kts:66-70`). |
| Stripe publishable key (dev) | hard-coded literal in `lib/config/env.dart:15-16` | |
| Stripe publishable key (prod) | placeholder string `'PLACE_HOLDER_LIVE_STRIPE_KEY'` in `lib/config/env.dart:20` | |
| Backend URLs | hard-coded in `lib/config/env.dart` — dev `https://mobile.beige.app/api/`, prod `https://mobile.prod.beige.app/api/`; image CDNs at `d1pgtgqp0jru64.cloudfront.net` / `d2jhn32fsulyac.cloudfront.net` | |

`analysis_options.yaml` (full content):

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule
```

No custom lint rules, no `analyzer:` exclusion block, no `errors:` map.

## Pre-audit flags (factual observations only)

Observations, not judgments. Each flag cites file:line.

1. **Default-template `widget_test.dart` will not compile against the live `MyApp`.** The test constructs `MyApp()` with no arguments (`test/widget_test.dart:16`), but the live class signature is `MyApp({super.key, required this.isLoggedIn})` (`lib/main.dart:30-33`).
2. **`analysis_options.yaml` has no project customization.** Uses only the upstream `package:flutter_lints/flutter.yaml`.
3. **`flutter_dotenv` declared but unused.** Zero imports under `lib/` (grep verified).
4. **`flutter_riverpod` declared, only mentioned in `lib/app/app.dart`, which is entirely block-commented.** No `ProviderScope` exists in the live tree (`lib/main.dart:36-103` is a plain `StatelessWidget` with `MaterialApp.router`).
5. **Android product flavors `dev` and `prod` are declared** (`android/app/build.gradle.kts:41-53`) **but no per-flavor `src/dev` or `src/prod` directories exist.** Only `src/main`, `src/debug`, `src/profile` are present on disk.
6. **iOS Podfile does not pin a deployment target** (`# platform :ios, '13.0'` is commented at `ios/Podfile:2`). No iOS scheme split exists for dev/prod.
7. **Dart entrypoint and Android flavor are independent axes.** `lib/main_dev.dart` and `lib/main_prod.dart` select `Environment` at runtime; Android `dev`/`prod` flavors only change `app_name`. The two must be combined consistently at build time (e.g., `flutter build apk --flavor prod -t lib/main_prod.dart`); nothing in repo enforces the pairing.
8. **No `android/key.properties` file.** Release builds will be signed with the debug keystore (`android/app/build.gradle.kts:66-70`).
9. **Google Maps Android API key is checked into VCS** as cleartext in `android/app/src/main/AndroidManifest.xml:22-24`.
10. **`android:usesCleartextTraffic="true"` set globally in main manifest** (`android/app/src/main/AndroidManifest.xml:14`). Applies to both flavors.
11. **Stripe prod publishable key is a placeholder** (`lib/config/env.dart:20` — `'PLACE_HOLDER_LIVE_STRIPE_KEY'`). Dev key is a real `pk_test_...` literal.
12. **iOS `Podfile` is gitignored** (it exists locally but appears as `?? ios/Podfile` in `git status`). Same for `macos/Podfile`. `flutter pub get` regenerates them.
13. **HTTP layer mixes `package:http` and `package:dio`.** Both are direct deps; `ApiService` uses each for different methods.
14. **`ApiService()` is instantiated 58 times across `lib/`** (grep). No DI registration code exists.
15. **Mixed navigation paradigm.** 89 `context.go*/push*/pop` calls coexist with 32 raw `Navigator.*` calls.
16. **Models directory uses two casings in imports.** Folder on disk is `lib/model_class/`; 7+ imports reference `Model_Class/` (capital `M`/`C`). Builds on macOS/APFS because that filesystem is case-insensitive.
17. **Filename anomalies:**
    - `lib/auth/view_details_screen .dart` — literal space before `.dart` extension.
    - `lib/Profile/profile_new_passwrod_screen.dart` — "passwrod".
    - `lib/Profile/deleteaccount/delete_account_lottieScreen.dart` — camelCase suffix.
    - `lib/widgets/Topmessgae.dart` — "messgae" + PascalCase.
    - `lib/widgets/app_loder.dart` — "loder".
    - `lib/widgets/new_Textfield.dart` — mixed case.
    - `lib/widgets/commonFileViewer.dart`, `lib/widgets/commonImagePicker.dart` — camelCase.
    - `lib/utility/Utils.dart`, `lib/utility/imges_icons.dart` — PascalCase / "imges".
    - `lib/onboding/onboding_screen.dart`, `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart`, `lib/Profile/profiledetils/profile_detils_1screen.dart` — repeated "ding"/"detils" misspellings.
18. **TODO/FIXME counts:** `TODO` 5, `FIXME` 0, `HACK` 0, `XXX` 7 (grep, case-insensitive over `lib/`).
19. **`debugPrint(` + `print(` occurrences in `lib/`: 242** (grep). `avoid_print` lint not customized to suppress in production builds.
20. **Pubspec drift.** 14 of 25 direct deps are now several minor versions ahead of the `^` lower bound (largest drift: `google_maps_flutter` +6 minor, `flutter_stripe` +5 minor).
21. **No Firebase configuration of any kind.** No `firebase_options.dart`, no `google-services.json`, no `GoogleService-Info.plist`.
22. **No CI / build automation in repo.** No `Makefile`, `fastlane/`, `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/`, or `bitrise.yml`.
23. **6 platform folders present** (`android`, `ios`, `macos`, `linux`, `windows`, `web`). No platform check (`Platform.isAndroid`/`kIsWeb`) guards observed during spot reads of HTTP/file-picker code paths.
