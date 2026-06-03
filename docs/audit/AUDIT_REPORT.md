# Flutter Code Audit Report

**Project:** `beige_creative_app` (BEIGE) — crew-side mobile client, Flutter ≥3.27 / Dart 3.10.4 (`docs/AUDIT_MAP.md` § Project metadata)
**Audited by:** Senior Flutter Architect
**Date:** 2026-05-20
**Severity scale:** 🔴 High | 🟠 Medium | 🟡 Low | ✅ Good

---

## Executive Summary

The codebase is **not production-ready**. A single root cause — 41 `StatefulWidget`s talking directly to a concrete `ApiService` instantiated 58 times across `lib/`, with no domain layer, no DI, no tests, and no CI — generates downstream failures in every other audited area. **Biggest single risk:** the device persists the user's **plaintext password** in `SharedPreferences` (`lib/auth/login/login.dart:111`) alongside a Bearer token (`lib/service/shared_service.dart:27`), both of which are also written to log output (`lib/service/api_service.dart:346`, `lib/Profile/myprofile.dart:601`) — a single `adb backup` or rooted-device dump yields full account takeover. **Biggest strength:** the team picked correct *primitives* (`go_router` 32 sites, modern widget APIs, broad `const` discipline, compile-time env split, centralized `ApiEndpoints` and `ColorCode` palettes) — the foundation supports the rewrite without re-platforming. **Production readiness: No.** **This week:** stop persisting the password, move tokens to `flutter_secure_storage`, remove the two `debugPrint(headers)` sites, and stand up GitHub Actions running `flutter analyze` + `flutter test` per PR.

## Overall Rating: **2 / 10**

## Audit Coverage

### 2026-06-03 Phase 6 CI Update

This audit report is still the original 2026-05-20 baseline, but Phase 6 now has CI coverage enforcement wired: GitHub Actions runs `flutter analyze --fatal-infos`, `flutter test --coverage`, uploads LCOV, and fails below `70%` line coverage. A separate `push`-to-`main` integration workflow is configured for Android emulator + iOS simulator. Current refreshed LCOV is `48.14%`, so release readiness is not yet claimed; task 6.14 remains the coverage-lift blocker.

| Area | Score | Highest Severity | Verdict |
|------|-------|------------------|---------|
| #1 Architecture | 2/10 | 🔴 | Survives 12 months only with major refactor |
| #2 State Management | 2/10 | 🔴 | Raw `setState`; ~87% async sites unguarded; ~80% of TextEditingControllers leak |
| #3 Project Structure | 2/10 | 🔴 | Onboarding friction HIGH; mixed casing, dead scaffolding, five `Data` class collisions |
| #4 Code Quality | 3/10 | 🔴 | Modern API discipline ✅; 8 files >1k lines, 60+ commented-out code blocks |
| #5 Performance | 3/10 | 🔴 | Janky on low-end; persistent `BackdropFilter`, 12 uncached `Image.network`, 0 debounce |
| #6 Security | ~1/10 | 🔴 CRITICAL | Plaintext password + token in `SharedPreferences`; token in logs; 0 secure storage |
| #7 Scalability | 2/10 | 🔴 | All three growth axes (users / features / team) fail on first scale event |
| #8 Flavouring & Env | 3/10 | 🔴 | Basic — flavor + entry-point are independent axes with no cross-check; iOS has no flavor |
| #9 Testing | 1/10 | 🔴 | 0% coverage; lone test does not compile; code is largely untestable |
| #10 Dependencies | 3/10 | 🔴 | 5 of 25 direct deps have **0 imports**; `http` + `dio` redundant; secure storage missing |

---

## Strengths

Specific assets to **preserve** through the refactor.

1. **`go_router` adopted across 32 files** with a single `GoRouter` in `lib/app/router.dart:47` and name constants in `lib/app/route_names.dart`. Routing is the most refactor-friendly surface in the repo. (`docs/AUDIT_ARCH.md` Strengths)
2. **Centralized endpoint registry** at `lib/service/api_endpoints.dart:1-81`. Modulo 4 bypass sites, every endpoint lives in one file — natural seam for interceptor-based `ApiClient`. (`docs/AUDIT_ARCH.md` Strengths)
3. **Centralized design tokens** — `lib/utility/colorcode.dart` (`ColorCode`) and `lib/utility/imges_icons.dart` (`AppImages`) keep palette and asset paths out of widget code; 21+ files use `AppImages`. (`docs/AUDIT_STRUCT.md` Strengths)
4. **Compile-time environment selection** — `lib/main_dev.dart`, `lib/main_prod.dart`, `lib/config/env.dart` give a clean env split with no `if (kDebugMode)` smell. (`docs/AUDIT_FLAVOR.md` Maturity)
5. **Android product flavors** declared in `android/app/build.gradle.kts:41-53` (`dev` + `prod` with `applicationIdSuffix`). Side-by-side install on Android works. (`docs/AUDIT_FLAVOR.md` F1)
6. **Modern widget API discipline.** 0 `WillPopScope`, 0 `RaisedButton`/`FlatButton`/`OutlineButton`, 0 legacy `+` string concat, **1,438** `const` constructor sites. (`docs/AUDIT_QUALITY.md` Strengths)
7. **`imageQuality: 80` cap** on `image_picker` calls at `lib/widgets/commonImagePicker.dart:10, 22`. Already a small bandwidth and decoded-bitmap win. (`docs/AUDIT_PERF.md` Strengths)
8. **No deep-link or WebView attack surface yet** — 0 `WebView` / `flutter_inappwebview`; only the default `MAIN/LAUNCHER` intent filter. (`docs/AUDIT_SEC.md` F10–F11)

---

## Issues & Risks

### Severity Summary

| Severity | Count |
|----------|-------|
| 🔴 High | 38 |
| 🟠 Medium | 28 |
| 🟡 Low | 11 |
| **Total** | **77** |

### All Issues (grouped by area, severity order within each)

#### Area #1 — Architecture

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `lib/service/api_service.dart` + 58 sites | UI imports HTTP directly; no abstraction, no DI | Introduce `core/network/ApiClient` behind Riverpod provider; ban `ApiService()` from features |
| 🔴 | `lib/` (no domain) | No domain layer; DTOs used as widget state types | Add `features/<x>/domain/` with entities + use cases + abstract repos |
| 🔴 | `lib/app/app.dart` | Riverpod `ConsumerWidget` root entirely block-commented | Uncomment, wire `ProviderScope` at `runApp` |
| 🔴 | `lib/Profile/myprofile.dart:597-598` and `:2579-2583`; `signup3_screen.dart:240-241`; `upcoming_shoot_view_detils.dart:75-84` | 4 hard-coded endpoint strings bypass `ApiEndpoints` | Add to `ApiEndpoints`; route via `ApiClient` |
| 🔴 | `lib/service/shared_service.dart:44-49` | `logout()` calls `prefs.clear()` — wipes all keys | Key-scoped removal; route session storage through `SessionStore` interface |
| 🔴 | `lib/auth/login/login.dart:7` | `auth/` feature imports the shell `main_screen.dart` | Remove import; navigation belongs in router |
| 🟠 | `lib/home/home_screen.dart:68-76` | `if/else` over magic strings for filter mapping | Replace with `enum DashboardRange { week, month, year }` |
| 🟠 | `lib/app/app.dart`, `lib/utility/Utils.dart`, `lib/service/config.dart` | Multiple parallel dead artefacts | Delete after migration |

#### Area #2 — State Management

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `lib/` (41 StatefulWidget, 8 dispose) | 50+ leaked `TextEditingController`s | Add `dispose()` to every state class with TECs |
| 🔴 | `lib/` (266 `setState` / 35 `mounted`) | ~87% of async `setState` lack `mounted` guard | Add `if (!mounted) return;` before every post-`await` `setState` |
| 🔴 | `lib/auth/login/login.dart:182-184` | `setState(() {})` listener rebuilds entire screen per keystroke | `ListenableBuilder` over the submit button only |
| 🔴 | `lib/main_screen.dart:50-87` + `lib/home/home_screen.dart:83-124` | `fetchprofiledata` duplicated; profile re-fetched twice on login | Single `currentUserProvider` (`AsyncNotifier<UserSession>`) |
| 🔴 | `lib/home/home_screen.dart:314-322` | 7 fetchers in `initState`, fire-and-forget, no `Future.wait` | Single `_load()` coordinator with `Future.wait` |
| 🔴 | `lib/shoots/shoots_screen.dart:88-90`, `lib/auth/login/login.dart:140`, `add_availability_screen.dart:374` | Empty `catch` swallows all errors | Surface as `AsyncValue.error` |
| 🔴 | `lib/shoots/shoots_screen.dart:96-119` | `fetchshootmodel` has no `try/catch`; crashes leak to framework | Wrap; emit error state |
| 🟠 | `lib/auth/sign_up/signup3_screen.dart:63-110` | 35-field god state class with parallel-list invariant | Aggregate into `FeaturedWork` domain object |

#### Area #3 — Project Structure

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `lib/main_screen.dart:17`; `lib/home/home_screen.dart:13-21`; `lib/shoots/shoots_screen.dart:9-11` | `Model_Class/` vs `model_class/` case-mismatched imports; Linux CI breaks | `git mv` to `snake_case`; fix imports |
| 🔴 | `lib/home/home_screen.dart:18-21` | Same model file imported 3 times (2 aliased + 1 unaliased) | Single canonical import per file |
| 🔴 | `lib/model_class/` | 5 classes named `Data` collide | Rename to `ProfileData`, `ShootsData`, etc. |
| 🔴 | `lib/auth/view_details_screen .dart` | Literal space in filename before `.dart` | Rename |
| 🔴 | `lib/widgets/`, `lib/Profile/`, etc. | Mixed casing + typos (`Topmessgae`, `app_loder`, `imges_icons`, `onboding`, `detils`, `passwrod`) | Bulk rename to `snake_case` |
| 🔴 | `lib/utility/colorcode.dart` vs `lib/app/colors.dart` | Two parallel design-token namespaces | Pick one; delete the other |
| 🔴 | `lib/utility/Utils.dart`, `app_utils.dart`, `widgets/date_time.dart`, inline helpers in screens | 4 sources of truth for date format / utils | Consolidate into `core/format/` + `core/permissions/` |
| 🔴 | `test/widget_test.dart` | Counter template; does not compile against current `MyApp(isLoggedIn:)` | Replace with smoke test |
| 🟠 | `lib/app/durations.dart` (0 refs), `lib/app/shadows.dart` (0), `lib/app/radii.dart` (1), `lib/app/text_styles.dart` (2) | Dead scaffolding files | Delete or actually use |

#### Area #4 — Code Quality

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `lib/auth/sign_up/signup3_screen.dart` (3,465), `lib/home/home_screen.dart` (2,902), `lib/Profile/myprofile.dart` (2,834) + 5 more files >1k lines | God files | Split per `docs/AUDIT_ARCH.md` Migration plan |
| 🔴 | `lib/home/home_screen.dart` (10+ blocks), `lib/main_screen.dart`, `lib/onboding/onboding_screen.dart` | 60+ multiline `/* */` and 104 single-line dead-code comments | Bulk delete |
| 🔴 | 43 `catch` blocks only call `debugPrint` | UI silently fails | Convert to `Failure` mapping + error state |
| 🔴 | `lib/` (242 `print`/`debugPrint`) | Production logs noisy; token leakage at `api_service.dart:346`, `myprofile.dart:601` | `AppLogger` no-op in release; sanitise keys |
| 🟠 | `lib/auth/login/login.dart:151-156`, `signup1_screen.dart:63`, `edit_personal_details_screen.dart:35` | Duplicated email + plus-code regex | Extract to `core/validation/` |
| 🟠 | `lib/auth/sign_up/signup3_screen.dart:111-125`, `:129-146` | `final List<String> Portfoliolname` etc. should be `static const` | Promote to compile-time constants |
| 🟠 | `lib/service/api_service.dart:350` | `imageFile.lengthSync()` blocks main thread | `await imageFile.length()` |
| 🟠 | `lib/app/`, `lib/utility/Utils.dart`, `lib/service/config.dart` | Dead public classes | Remove |
| 🟡 | `analysis_options.yaml:23-25` | Lints uncustomised | Add `prefer_const_constructors`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print` |

#### Area #5 — Performance

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `lib/main_screen.dart:132-141` | Persistent `BackdropFilter(sigmaX: 80, sigmaY: 70)` on bottom nav | Remove; use opaque `backgroundColor` |
| 🔴 | 12 `Image.network` sites (home, profile, shoots, certificates, featured_work, …) | `cached_network_image` dep installed; 0 imports | Migrate to `CachedNetworkImage` with `memCacheWidth`/`memCacheHeight` |
| 🔴 | `lib/shoots/shoots_screen.dart:247` | `onChanged: searchShoots` — no debounce, filters on every keystroke | 250ms `Timer` debounce |
| 🔴 | `lib/home/home_screen.dart:314-322` | 7 parallel fetchers triggering 7 separate rebuilds | Single `_load()` + `Future.wait` |
| 🔴 | `lib/shoots/shoots_screen.dart:203` | `ListView(children: ...)` for unbounded list | `ListView.builder` |
| 🔴 | None of the dashboard endpoints support pagination | Server + client | Add `limit`/`offset`; consume via `infinite_scroll_pagination` |
| 🔴 | No caching anywhere | Re-fetches on every navigation | 30s in-memory cache + in-flight dedup in `ApiClient` |
| 🟠 | 33 `SingleChildScrollView` + 19 wrap a `Column` | Materialises off-screen content | `CustomScrollView` + slivers for god screens |
| 🟠 | All `Image.asset` calls lack `cacheWidth`/`cacheHeight` | Decoded bitmaps at native resolution | Specify intrinsic size × 2 |
| 🟠 | 0 `compute()` / `Isolate` | JSON decode on platform thread | Wrap large responses in `compute(jsonDecode, body)` |

#### Area #6 — Security

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 CRITICAL | `lib/auth/login/login.dart:111` | **Plaintext password persisted in `SharedPreferences`** | Stop persisting; remember only email |
| 🔴 CRITICAL | `lib/service/shared_service.dart:27` | Auth token in plain `SharedPreferences` | Migrate to `flutter_secure_storage` |
| 🔴 CRITICAL | `lib/service/google_config.dart:3`, `android/app/src/main/AndroidManifest.xml:24` | Google Maps API key `AIza…` committed in both places, same for dev + prod | Rotate; inject via `--dart-define` + `manifestPlaceholders` |
| 🔴 CRITICAL | `lib/config/env.dart:15-16` | Stripe `pk_test` literal in source | Move to `--dart-define`; rotate |
| 🔴 HIGH | `lib/Profile/myprofile.dart:601`, `lib/service/api_service.dart:346` | `debugPrint("Headers: $headers")` leaks Bearer token to logs | Sanitise; gate logging behind release-no-op |
| 🔴 HIGH | `android/app/src/main/AndroidManifest.xml:14` | `usesCleartextTraffic="true"` global | Set false; add `networkSecurityConfig` |
| 🔴 HIGH | `android/key.properties` missing | Release falls back to debug signing key | Create real keystore + properties |
| 🔴 HIGH | `android/app/build.gradle.kts:71-74` references `proguard-rules.pro` but `isMinifyEnabled` not set; file does not exist | No code obfuscation / minification | Enable R8; add `--obfuscate --split-debug-info` |
| 🔴 HIGH | 0 `connectTimeout`/`receiveTimeout`/`sendTimeout` | Slow-loris DoS path open | Set timeouts on canonical Dio client |
| 🔴 HIGH | No certificate pinning | MITM via hostile CA possible | Add Dio interceptor with pinned SPKI |
| 🟠 | `ios/Runner/Info.plist` | Missing `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription` | App Store rejects + image_picker/geolocator crash on first use |
| 🟠 | `AndroidManifest.xml:6-8` | Legacy `WRITE_EXTERNAL_STORAGE` likely unneeded | Remove |
| 🟠 | `AndroidManifest.xml` | `allowBackup` defaults true on minSdk 21 | `android:allowBackup="false"` |

#### Area #7 — Scalability

| Severity | Where | One-line description | One-line fix |
|----------|-------|----------------------|--------------|
| 🔴 | no `.github/`, no Fastfile, no Makefile | No CI at all | GitHub Actions: `flutter analyze` + `flutter test` + `flutter build apk --debug` per PR |
| 🔴 | No retry/backoff anywhere | 10× users → retry storm on any backend stutter | `dio_smart_retry` interceptor |
| 🔴 | No feature flag / remote config | MTTR for bad release = days (store rollout) | Firebase Remote Config or equivalent |
| 🔴 | `README.md` is unmodified Flutter template; no `CONTRIBUTING.md` / `ARCHITECTURE.md` | New-dev onboarding 2-3 weeks | Replace README; add contributor docs |
| 🔴 | Adding a feature touches 6 shared files | Merge-conflict hotspots at 3 devs | Feature modules with barrel files + public API |
| 🔴 | `lib/app/router.dart` 369 lines, imports every screen | Single-file merge bottleneck | Per-feature route fragments |

#### Area #8 — Flavouring & Env

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `lib/main_dev.dart` + Android flavor | Dart entry point + Android flavor are independent axes — `--flavor prod -t lib/main_dev.dart` is plausible | Single `lib/main.dart` + `--dart-define-from-file=env/<flavor>.json` |
| 🔴 | iOS — only `Runner` scheme + default xcconfig | iOS has no flavor; cannot side-load dev + prod | Add Debug-Dev/Release-Prod schemes + xcconfig hierarchy |
| 🔴 | `android/app/src/` (only `main/debug/profile`) | No per-flavor manifest folders | Add `src/dev` + `src/prod` (or use `manifestPlaceholders`) |
| 🔴 | `lib/config/env.dart:20` | Stripe prod = `'PLACE_HOLDER_LIVE_STRIPE_KEY'` literal | Fail-fast assert + inject via `--dart-define` |
| 🟠 | `flutter_dotenv` declared, 0 imports | Dead dep, intended path abandoned | Remove |
| 🟠 | No `Makefile` / `Fastfile` / `tool/build.sh` | Pairing of `--flavor`/`-t` enforced by memory | Ship Makefile with per-flavor targets |
| 🟡 | `.gitignore` lacks `.env*` | Future leakage path | Add ignore entry |

#### Area #9 — Testing

| Severity | file:line | One-line description | One-line fix |
|----------|-----------|----------------------|--------------|
| 🔴 | `test/widget_test.dart:14-29` | Counter template; references non-existent `MyApp()` | Replace with compiling smoke test |
| 🔴 | `pubspec.yaml` | 0 mocking library (no mocktail/mockito/patrol) | Add `mocktail` to `dev_dependencies` |
| 🔴 | `lib/` — 0 `abstract class` | No mocking seam | Add abstractions per `docs/AUDIT_ARCH.md` |
| 🔴 | 11 `DateTime.now()` / `Random()` sites | Non-deterministic logic untestable | Inject a `Clock` abstraction |
| 🔴 | No `integration_test/`, no `test/_helpers/`, no fixtures | Zero test scaffolding | Create + add `pump_app` helper |

#### Area #10 — Dependencies

| Severity | Package | One-line description | One-line fix |
|----------|---------|----------------------|--------------|
| 🔴 | `flutter_stripe` | 0 imports — Stripe SDK never used | Remove until checkout ships |
| 🔴 | `flutter_dotenv` | 0 imports | Remove |
| 🔴 | `image_cropper` | 0 imports | Remove (or wire to image_picker flow) |
| 🔴 | `photo_view` | 0 imports | Remove |
| 🔴 | `cached_network_image` | 0 imports, but 12 `Image.network` sites should use it | Migrate sites; keep dep |
| 🔴 | `http` + `dio` | Two HTTP stacks for one job | Drop `http`; consolidate on Dio |
| 🔴 | `flutter_secure_storage` | Missing | Add — required for token storage |
| 🔴 | `sentry_flutter` | Missing | Add — required before production rollout |
| 🟠 | `connectivity_plus` | Missing | Add for offline UX |
| 🟠 | `flutter_lints` | Baseline-only | Upgrade to `very_good_analysis` |
| 🟠 | `geolocator 11.x`, `geocoding 2.x` | 1-2 majors behind | `flutter pub upgrade --major-versions` |
| 🟠 | No `build_runner` / `freezed` / `json_serializable` | Hand-written DTOs untestable | Add code-gen |

---

## Architecture Review

### Current Architecture

**Pattern: none.** Screen-centric `StatefulWidget` + `setState` with a single concrete HTTP service. Verbatim from `docs/AUDIT_ARCH.md` §A1: *"a flat list of screens, each self-sufficient, each duplicating the same fetch/parse/setState cycle."*

Dependency direction (today):

```
UI (screens/, widgets/)
        │ direct import (no abstraction)
        ▼
lib/service/api_service.dart  →  lib/config/env.dart
lib/model_class/*.dart   (used directly as widget state types)
```

`lib/app/app.dart` Riverpod `ConsumerWidget` root is entirely block-commented. `flutter_riverpod` is in `pubspec.yaml` but unused at runtime.

### Recommended Architecture

**Feature-first Clean-lite + Riverpod-driven controllers** (`docs/AUDIT_ARCH.md` Migration plan).

Three layers per feature, plus shared `core/`. Justification specific to this codebase:

1. **`flutter_riverpod` is already paid for** (`pubspec.lock:260-264`). Migration = un-commenting `lib/app/app.dart` + wiring `ProviderScope` at `runApp`. No new framework decision.
2. **A single `currentUserProvider` collapses the duplicate `fetchprofiledata`** between `lib/main_screen.dart:50-87` and `lib/home/home_screen.dart:83-124`. One profile fetch on login instead of two.
3. **Disposal hygiene is unrecoverable inside `setState`.** With 41 `StatefulWidget`s and 58 `TextEditingController` constructions, retrofitting `dispose()` everywhere is forensic. Controller-owned state via `StateNotifier`/`AsyncNotifier` moves controllers into the controller's lifetime; the widget owns nothing to dispose.

### Recommended Folder Structure

```
lib/
├── main.dart                              # single entry, reads --dart-define=FLAVOR
├── app/
│   ├── app.dart                           # ProviderScope + MaterialApp.router (live, un-commented)
│   ├── router.dart                        # GoRouter declaration only
│   ├── route_names.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── color_tokens.dart              # canonical (merge ColorCode + AppColors)
│       ├── text_styles.dart
│       ├── spacing.dart
│       ├── radii.dart
│       ├── shadows.dart
│       └── durations.dart
├── core/
│   ├── env/env.dart                       # static, but reads --dart-define only
│   ├── network/
│   │   ├── api_client.dart                # the only file importing dio
│   │   ├── api_endpoints.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── retry_interceptor.dart
│   │       └── logging_interceptor.dart   # sanitises Authorization header
│   ├── storage/
│   │   └── session_store.dart             # behind flutter_secure_storage
│   ├── error/
│   │   ├── failure.dart                   # sealed class
│   │   └── exceptions.dart
│   ├── result.dart
│   ├── time/clock.dart                    # injectable Clock for tests
│   ├── format/
│   │   ├── date_format.dart               # absorbs DateTimeUtils + inline helpers
│   │   └── currency.dart
│   ├── validation/
│   │   ├── email.dart                     # extracted from login.dart:151-156
│   │   └── plus_code.dart                 # extracted from signup1_screen.dart:63 + edit_personal_details:35
│   ├── logger/logger.dart                 # replaces 242 print/debugPrint
│   ├── strings/app_strings.dart           # ready for intl
│   └── di/providers.dart
├── features/
│   ├── auth/
│   │   ├── data/{dtos,auth_repository_impl.dart}
│   │   ├── domain/{entities,auth_repository.dart,use_cases/}
│   │   └── presentation/{controllers,screens,widgets}
│   ├── signup/                            # extracted from auth/sign_up/
│   ├── forgot_password/                   # rename from forgotpassword/
│   ├── reset_password/                    # rename from resetpassword/
│   ├── home/                              # home_screen split into ~8 widgets
│   ├── profile/                           # rename from Profile/
│   ├── shoots/
│   ├── shoot_details/                     # rename from upcomingshootviewdetils/
│   ├── availability/                      # rename from manageavailability/
│   ├── file_manager/
│   ├── messages/
│   ├── splash/
│   └── onboarding/                        # rename from onboding/
└── shared/
    ├── widgets/                           # genuinely cross-feature only
    │   ├── app_loader.dart                # rename from app_loder.dart
    │   ├── top_message.dart               # rename from Topmessgae.dart
    │   ├── custom_text_field.dart
    │   ├── custom_dropdown.dart
    │   ├── custom_dropdown_field.dart
    │   ├── custom_multi_select_field.dart
    │   ├── custom_input_field.dart        # rename from new_Textfield.dart
    │   ├── common_calendar.dart
    │   ├── common_uploader.dart
    │   ├── common_file_viewer.dart        # rename from commonFileViewer.dart
    │   ├── common_image_picker.dart       # rename from commonImagePicker.dart
    │   └── multi_arc_painter.dart
    ├── assets/assets.dart                 # canonical AppImages
    └── extensions/
```

Hard rules:
- No widget file imports `core/network/` directly. Only `*_repository_impl.dart` does.
- No `presentation/` file imports `data/`. `presentation/` ↔ `domain/`; `data/` → `domain/`; `domain/` depends on nothing.
- No `features/<x>/` imports `features/<y>/`.
- DTOs in `data/` with `fromJson`. Entities in `domain/` with no JSON awareness. Mappers connect them.
- All folders + files `snake_case`. Linux runner enforces.

---

## State Management Review

### Current Approach

**Raw `setState` on 41 `StatefulWidget`s.** 266 `setState` calls; 35 `mounted` references (~87% of async sites unguarded). 0 `ChangeNotifier` / `ValueNotifier` / `StreamController` / `StreamSubscription` / `Equatable`. 8 `dispose()` overrides for 41 stateful classes. 58 `TextEditingController()` constructions — most leak. (`docs/AUDIT_STATE.md` §A1, §C4.)

### Recommendation

**Migrate to Riverpod (`StateNotifier` / `AsyncNotifier`) — already a paid-for dependency.** Three reasons grounded in this codebase:

1. **Disposal hygiene** — controllers move into controller lifetimes; the widget owns nothing. The 50+ `TextEditingController` leak class becomes impossible.
2. **Cross-screen state already demands it** — `fetchprofiledata` is duplicated between `lib/main_screen.dart:50-87` and `lib/home/home_screen.dart:83-124`. A single `currentUserProvider` deduplicates this on day one.
3. **Riverpod is already in `pubspec.lock:260-264`** and `lib/app/app.dart:17-32` contains a (commented) `ConsumerWidget` scaffold. Migration = un-commenting + wiring `ProviderScope`, not introducing a new framework.

Acceptance gates after migration:
- `grep -rn "setState" lib/features/` → 0
- `grep -rn "TextEditingController" lib/features/ | grep -v "dispose"` → 0
- `grep -rn "ApiService()" lib/features/` → 0

---

## Performance Findings

Top items with frame/memory impact + fix.

1. 🔴 **`BackdropFilter(sigmaX: 80, sigmaY: 70)` mounted permanently around bottom nav** (`lib/main_screen.dart:132-141`). **Frame cost: 4–6ms/frame on mid-range Android, always-on.** Fix: remove; use opaque `backgroundColor`. **~5 min.**
2. 🔴 **12 `Image.network` sites, 0 `CachedNetworkImage` despite `cached_network_image: 3.4.1` in `pubspec.lock:44-51`.** Network re-downloads on rebuild; decoded bitmaps full-resolution. **Memory cost: ~4.4MB per 1080-px image rendered at 60-dp.** Fix: migrate with `memCacheWidth`/`memCacheHeight`. **~25 min.**
3. 🔴 **7 parallel fetchers fire-and-forget in `lib/home/home_screen.dart:314-322`, 0 `Future.wait`, 0 `mounted` guards.** 7 separate rebuilds in first few hundred ms; "setState after dispose" crashes on back-press. Fix: single `_load()` with `Future.wait`. **~30 min.**
4. 🔴 **Search filter without debounce at `lib/shoots/shoots_screen.dart:247`** (`onChanged: searchShoots`). O(n) filter + `setState` every keystroke. Fix: 250ms `Timer` debounce. **~15 min.**
5. 🔴 **Empty `SharedPreferences` cache; no in-flight dedup; no client cache.** `fetchprofiledata` fires twice on login. Fix: 30s in-memory cache + dedup in `ApiClient`. **~1 dev-day.**
6. 🟠 **Sync IO `imageFile.lengthSync()` at `lib/service/api_service.dart:350`.** Blocks platform thread before multipart upload. Fix: `await imageFile.length()`. **~2 min.**
7. 🟠 **0 `cacheWidth`/`cacheHeight` on `Image.asset`** — full-resolution decodes. Fix: specify intrinsic size × 2. **~10 min, drops ~10MB decoded RAM.**
8. 🟠 **33 `SingleChildScrollView` + 19 wrap a `Column`** — root layout of god screens materialises off-screen content. Fix: `CustomScrollView` + slivers for worst-3 screens. **~1 dev-day per screen.**

---

## Security Review

### Risk Level: **CRITICAL**

> Worst-case one-sentence scenario: *an attacker who obtains the device's `SharedPreferences` XML — through `adb backup`, rooted-device extraction, or a malicious "free Wi-Fi" cleartext-traffic MITM (currently allowed by manifest) — gets a never-expiring bearer token and the user's plaintext password, enabling full account takeover and cross-service credential stuffing.* (`docs/AUDIT_SEC.md`.)

### Critical Findings

| # | Finding | Evidence |
|---|---------|----------|
| S1 | Google Maps API key `AIza…` committed in both `lib/service/google_config.dart:3` and `android/app/src/main/AndroidManifest.xml:24`; same key for dev + prod | Rotate; restrict at GCP console; inject via `--dart-define` + `manifestPlaceholders` |
| S2 | Stripe `pk_test_51S5czd…` literal in `lib/config/env.dart:16`; prod is placeholder | Move to `--dart-define`; fail-fast assert in `Env.init` |
| S3 | Plaintext password persisted in `SharedPreferences` (`lib/auth/login/login.dart:111`); auth token alongside (`lib/service/shared_service.dart:27`) | Add `flutter_secure_storage`; stop persisting password |
| S4 | Bearer token leaked to logs (`lib/service/api_service.dart:346` + `lib/Profile/myprofile.dart:601`) | Remove sites; gate logging behind release no-op |
| F1 | `usesCleartextTraffic="true"` set globally in main manifest (`android/app/src/main/AndroidManifest.xml:14`) | Set `false`; add `networkSecurityConfig` |
| F2 | `android/key.properties` not present; release uses debug keystore (`build.gradle.kts:66-70`) | Create release keystore + properties |
| F3 | No `isMinifyEnabled`, no `proguard-rules.pro` file | Enable R8; ship `--obfuscate --split-debug-info` |
| F4 | 0 Dio timeouts | Set connect/receive/send timeouts |
| F5 | No certificate pinning | Add Dio interceptor with pinned SPKI |
| F7 | iOS `Info.plist` missing every `NS*UsageDescription` | App Store rejects; image_picker/geolocator crash on first call |
| F13 | `allowBackup` not set; defaults true on minSdk 21 | Set `android:allowBackup="false"` |

### Security Hardening Checklist

**4 ✅ · 2 ⚠️ · 13 ❌.** Full list in `docs/AUDIT_SEC.md` § Security hardening checklist.

---

## Code Quality Review

Top 5 highest-impact fixes (from `docs/AUDIT_QUALITY.md` Top-5):

1. 🔴 **Eliminate empty / print-only `catch` blocks.** 3 confirmed empties (`shoots_screen.dart:88-90`, `login.dart:140`, `add_availability_screen.dart:374`) + 43 catch-only-print blocks. Wrap into a single `try`-`catch` helper that surfaces `AsyncValue.error`. **1 dev-day.**
2. 🔴 **Delete commented-out code in bulk.** 60+ multiline blocks + 104 single-line dead lines; `home_screen.dart` alone has 10+ blocks at `:78`, `:380`, `:625`, `:746`, `:840`, `:1064`, `:1096`, `:1407`, `:1511`. **1 dev-hour.**
3. 🔴 **Replace 242 `debugPrint`/`print` with an `AppLogger` that no-ops in release.** Also fixes the `Authorization: Bearer $token` leakage at `api_service.dart:346` and `myprofile.dart:601`. **1 dev-day.**
4. 🟠 **Extract `fetchprofiledata` duplicate, inline email/plus-code regexes, and inline `DateFormat` helpers** into `core/format/` + `core/validation/` + a single `currentUserProvider`. **1 dev-day.**
5. 🟠 **Turn on lints** `prefer_const_constructors`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print`, `prefer_final_fields`, `unnecessary_const`; run `dart fix --apply`. **30 minutes + half a dev-day to triage.**

---

## Scalability Assessment

| Axis | Status | Breaking Point | Fix |
|------|--------|----------------|-----|
| Users 10× | 🔴 Will fail | First popular content drop — no client cache, no request dedup (`docs/AUDIT_PERF.md` §D4/D5), no pagination on shoots/dashboard endpoints (`docs/AUDIT_PERF.md` §D2), 0 timeouts → retry storm | `ApiClient` with 30s cache + dedup + retry/backoff + timeouts (combines with security F4 + perf top-fixes) |
| Features 2× | 🔴 Will fail | `lib/app/router.dart` (369 lines, imports every screen) + `lib/main_screen.dart` shell + `lib/service/api_endpoints.dart` become merge-conflict hotspots; 5 classes named `Data` already collide in `lib/model_class/` | Feature modules with barrel + public-API surfaces; rename DTOs; per-feature route fragments |
| Team 3× | 🔴 Will fail | No CI, no test gate, mixed casing → Linux runner breaks, three god files (~9,200 lines) generate unmergeable conflicts | Stand up GitHub Actions; normalise casing; split god screens (`docs/AUDIT_ARCH.md` Top-fix #2) |

---

## Flavouring & Environment Setup

### Current Gaps

- Dart entry point + Android flavor are independent axes; `flutter build apk --flavor prod -t lib/main_dev.dart` builds a prod-branded binary that talks to dev API (`docs/AUDIT_FLAVOR.md` Worst case).
- iOS has **no flavor** — single `Runner` scheme, single Info.plist, single bundle ID. Dev + prod cannot side-load on iOS.
- No per-flavor manifest folders (`android/app/src/dev`, `src/prod` absent).
- No `key.properties`; release builds use debug keystore.
- No `--dart-define-from-file` usage anywhere.
- `flutter_dotenv` declared but 0 imports.
- Stripe prod = `'PLACE_HOLDER_LIVE_STRIPE_KEY'` literal — ships silently.

### Recommended Setup

Single `lib/main.dart` driven by `--dart-define-from-file=env/<flavor>.json`. Fail-fast `Env.init`:

```dart
// lib/config/env.dart (after)
enum Environment { dev, staging, prod }

class Env {
  Env._();
  static late final Environment current;
  static late final String apiUrl;
  static late final String imageUrl;
  static late final String stripePublishableKey;
  static late final String googleMapsKey;
  static bool get isProd => current == Environment.prod;

  static void init() {
    const flavor = String.fromEnvironment('FLAVOR');
    if (flavor.isEmpty) {
      throw StateError('FLAVOR not set. Build with --dart-define-from-file=env/<flavor>.json');
    }
    current              = Environment.values.byName(flavor);
    apiUrl               = const String.fromEnvironment('API_URL');
    imageUrl             = const String.fromEnvironment('IMAGE_URL');
    stripePublishableKey = const String.fromEnvironment('STRIPE_PK');
    googleMapsKey        = const String.fromEnvironment('GOOGLE_MAPS_KEY');

    assert(apiUrl.startsWith('https://'),                 'API_URL must be HTTPS.');
    assert(stripePublishableKey.isNotEmpty,               'STRIPE_PK is required.');
    assert(!stripePublishableKey.contains('PLACE_HOLDER'),'STRIPE_PK placeholder shipped.');
    if (current == Environment.prod) {
      assert(apiUrl.contains('prod'),                     'PROD flavor with non-prod API_URL.');
    }
  }
}
```

`Makefile` enforces the pairing:

```makefile
run-dev:
	flutter run --flavor dev --dart-define-from-file=env/dev.json

build-android-prod:
	flutter build appbundle --flavor prod --dart-define-from-file=env/prod.json \
		--release --obfuscate --split-debug-info=build/symbols/android/$$(date +%Y%m%d)
```

iOS gains schemes `Runner-Dev`, `Runner-Staging`, `Runner-Prod`, each with its own xcconfig that sets `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`, and the four secret strings. Android adds `manifestPlaceholders["MAPS_API_KEY"]` per flavor; the manifest reads `${MAPS_API_KEY}`.

(Full Android `productFlavors` block + iOS xcconfig hierarchy in `docs/AUDIT_FLAVOR.md` § Recommended Android setup / § Recommended iOS setup.)

---

## Testing Recommendations

### Coverage Estimate

**0%.** Lone test (`test/widget_test.dart`) is the unmodified Flutter counter-app template; calls `MyApp()` without the required `isLoggedIn` argument (`lib/main.dart:30-33`). Does not compile, let alone pass. No integration_test/.

### Refactors Required to Enable Testing

Hard prerequisite chain (`docs/AUDIT_TEST.md` § Refactoring required):

1. Introduce `core/network/ApiClient` abstract + Riverpod provider — replaces 58 `ApiService()` constructor calls.
2. Introduce `core/storage/SessionStore` abstract + provider — replaces static `SharedService`.
3. Introduce `core/time/Clock` abstract + provider — replaces direct `DateTime.now()`.
4. Wire `ProviderScope` at app root (un-comment `lib/app/app.dart`).
5. Extract validation, format, role-mapping helpers from widgets into `core/`.
6. Migrate auth + home features to `features/<x>/{data,domain,presentation}`.
7. Replace inline JSON DTOs with named DTOs per feature; add fixture files.
8. Add `mocktail`, `network_image_mock`, optionally `golden_toolkit` to `dev_dependencies`.
9. Add `test/_helpers/pump_app.dart` + `test/_helpers/test_fakes.dart`.
10. Stand up GitHub Actions running `flutter test --coverage`.

### Priority Test Plan

15-row prioritised test plan in `docs/AUDIT_TEST.md` § Priority test plan. First 5 (~3 weeks of focused work yields ~70% of new `core/` + `domain/` coverage):

| # | Test | Type | Blocker |
|---|------|------|---------|
| 1 | `core/validation/email_test.dart` | unit | Extract `isValidEmail` to `core/validation/` |
| 2 | `core/validation/plus_code_test.dart` | unit | Extract plus-code regex |
| 3 | `core/format/date_format_test.dart` | unit | Consolidate `DateTimeUtils` + inline helpers |
| 4 | `data/auth/login_response_dto_test.dart` | unit | DTOs in `data/`; sealed `Result<T>` |
| 5 | All `lib/model_class/*.dart` `fromJson` round-trip tests | unit | DTOs migrated; fixtures committed |

---

## Dependency Review

### Per-package verdict (highlights — full table in `docs/AUDIT_DEPS.md`)

| Package | Usage | Verdict | Why |
|---------|-------|---------|-----|
| `go_router`, `flutter_svg` | 32 each | KEEP | Pervasive, modern |
| `dio` | 5 | KEEP (promote) | Make single network client |
| `http` | 1 | REMOVE | Redundant with `dio` |
| `flutter_riverpod` | 1 (commented) | KEEP (must wire) | Already paid for; migration target |
| `cached_network_image` | 0 | KEEP (must use) | 12 `Image.network` sites should migrate |
| `flutter_stripe` | 0 | REMOVE (defer) | Never used; ~50MB of native code |
| `flutter_dotenv` | 0 | REMOVE | Replaced by `--dart-define-from-file` |
| `image_cropper` | 0 | REMOVE | Never imported |
| `photo_view` | 0 | REMOVE | Never imported |
| `geolocator` | 3 | UPDATE | 2 majors behind |
| `geocoding` | 3 | UPDATE | 1 major behind |
| `flutter_lints` | dev | REPLACE | Upgrade to `very_good_analysis` |

### Critical Actions

1. Add `flutter_secure_storage`; migrate auth token off `SharedPreferences`; stop persisting password.
2. Remove `http`; consolidate on Dio; add timeouts + auth interceptor + retry interceptor.
3. Add `sentry_flutter`; wire `--split-debug-info` symbol upload.
4. Replace `flutter_dotenv` with `--dart-define-from-file=env/<flavor>.json`; delete the dep.
5. Remove or wire `flutter_stripe` (decide).
6. Migrate 12 `Image.network` sites to `CachedNetworkImage`.
7. Add `mocktail` to `dev_dependencies`.

### Recommended Additions

```yaml
dependencies:
  flutter_secure_storage: ^9.2.4
  sentry_flutter: ^8.13.0
  connectivity_plus: ^6.1.5
  dio_smart_retry: ^7.0.0
  logger: ^2.4.0

dev_dependencies:
  very_good_analysis: ^7.0.0
  mocktail: ^1.0.4
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

---

## Final Recommendations

### Top 10 Actionable Improvements (Priority Ordered)

| # | Action | Area | Effort | Impact | Why Now |
|---|--------|------|--------|--------|---------|
| 1 | Stop persisting the password (`login.dart:111`); migrate token to `flutter_secure_storage` | Security | S | Closes account-takeover via SharedPreferences extraction | Catastrophic data-exposure vector; trivial fix; nothing depends on it |
| 2 | Remove `debugPrint(headers)` at `api_service.dart:346` + `myprofile.dart:601`; gate all logging behind release-no-op `AppLogger` | Security / Quality | S | Stops Bearer-token leakage to logcat; reduces 242 noisy log sites | Mechanical pass; no architectural prerequisite |
| 3 | Stand up GitHub Actions: `flutter analyze` + `flutter test` + `flutter build apk --debug` per PR (Linux runner) | Scale / Test | S | Every later fix becomes enforceable; surfaces casing/import drift; coverage trackable | Without this, regressions land within a release |
| 4 | Normalise folder + file casing to `snake_case`; fix `Model_Class/` imports; rename `Topmessgae`, `app_loder`, `onboding`, `imges_icons`, `view_details_screen .dart` | Structure | S | Unblocks Linux CI; removes 7+ case-mismatch hotspots | One dev-day; cleanest possible time is before #3 lands |
| 5 | Replace 7 hard-coded keys (`AIza…` Maps × 2, `pk_test_…` Stripe, prod placeholder) with `--dart-define-from-file=env/<flavor>.json` + `manifestPlaceholders`; rotate the leaked keys | Security / Flavor | M | Closes cleartext-secret leak; per-environment keys; rotation without code change | Required before any public APK ships |
| 6 | Migrate 12 `Image.network` sites to `CachedNetworkImage` with `memCacheWidth`/`memCacheHeight` | Performance | S | Halves bitmap memory; eliminates re-download on scroll; activates a paid-for dep | 25-minute mechanical pass |
| 7 | Introduce `core/network/ApiClient` behind Riverpod provider; ban `ApiService()` from features; add timeouts + retry + auth interceptor + 30s cache + in-flight dedup | Architecture / Scale / Perf | L | Single seam for every cross-cutting network concern; unlocks tests, mocking, and pagination | Foundation for #8, #9, #10 |
| 8 | Replace `SharedService` static class with `SessionStore` interface (behind `flutter_secure_storage`); replace `prefs.clear()` with key-scoped removal | Architecture / Security | M | Per-key control; testable; future feature prefs survive logout | Pairs with #1 and #7 |
| 9 | Split the four largest screens (`signup3_screen.dart` 3,465; `home_screen.dart` 2,902; `myprofile.dart` 2,834; `signup1_screen.dart` 1,959) into controllers + sub-widgets; introduce `dispose()` coverage for every TEC | Architecture / State / Quality | L | Eliminates the largest merge-conflict targets, 50+ TEC leaks, 87% unguarded-async setState | Once #7 lands, this is the natural follow-on |
| 10 | Replace `test/widget_test.dart` with compiling smoke test + first `core/validation/email_test.dart` (mocktail + `pump_app` helper); set up coverage reporting | Test | M | Restores `flutter test` as CI gate; establishes the pattern future PRs copy | Cheap once #3 and #7 land |

### Migration Roadmap

| Phase | What | Files Affected | Effort | Timeline | Success Metric |
|-------|------|----------------|--------|----------|----------------|
| **Phase 1 — Quick wins** | Top 10 items #1–#6 above: stop password persist + `flutter_secure_storage` + remove log leakage + GitHub Actions + casing normalisation + secrets via `--dart-define` + `CachedNetworkImage` migration | `login.dart`, `shared_service.dart`, `api_service.dart`, `myprofile.dart` (`:601`), `env.dart`, `AndroidManifest.xml`, 12 `Image.network` sites, all `Model_Class/` imports, casing across `lib/` | Low | **Week 1 (5 dev-days)** | `flutter analyze --fatal-infos` passes on Linux; release APK is signed (after keystore); 0 cleartext API keys in `git ls-files`; profiling shows ≥30% reduction in scroll-frame cost on image-heavy screens |
| **Phase 2 — Structural** | `ApiClient` + interceptors + `SessionStore`; `ProviderScope` wired; un-comment `lib/app/app.dart`; extract validation/format/regex helpers into `core/`; introduce `Clock` abstraction; replace `flutter_dotenv` with `--dart-define-from-file`; consolidate on Dio (drop `http`); add `mocktail` + `sentry_flutter` + `connectivity_plus` + `dio_smart_retry`; iOS schemes + xcconfig + `Makefile`; iOS `NS*UsageDescription`; manifest hardening (`allowBackup="false"`, `usesCleartextTraffic="false"`, `networkSecurityConfig`); real release keystore + R8 + `--obfuscate` | `lib/app/app.dart`, `lib/service/`, `lib/config/env.dart`, `pubspec.yaml`, `Info.plist`, `AndroidManifest.xml`, `build.gradle.kts`, `ios/Flutter/*.xcconfig`, `ios/Runner.xcodeproj`, `tool/Makefile`, all auth feature files | Medium | **Month 1 (4 weeks)** | 0 direct `ApiService()` constructor calls in `lib/features/`; 0 `debugPrint(`/`print(` in release; iOS app side-loads dev + prod simultaneously; Sentry receives crashes in dev; `flutter test --coverage` reports ≥30% on `core/` |
| **Phase 3 — Architectural alignment** | Feature migration to `features/<x>/{data,domain,presentation}` (auth → home → profile → shoots → file_manager → messages → availability → onboarding); split the four largest screens; replace all `setState` with controllers; introduce `AsyncValue<T>`-style loading/error/empty; pagination on shoots/dashboard endpoints (client + server); barrel files per feature; `freezed` + `json_serializable` for new DTOs; `ARCHITECTURE.md` + `CONTRIBUTING.md`; `intl` + `.arb` setup; certificate pinning interceptor; feature flag / remote config (Firebase Remote Config or similar) | Every screen file under `lib/features/`; all `lib/model_class/` DTOs; new `lib/core/` tree; `lib/app/router.dart` per-feature split; `docs/` updates | High | **Quarter 1 (10–12 weeks)** | 0 files in `lib/features/<x>/presentation/screens/` over 300 lines; `grep -rn "setState" lib/features/` → 0; controller-test coverage ≥60%; merge-conflict rate (PRs/week with auto-conflict) drops below 1; new feature add affects ≤2 shared files; 99.5% Sentry crash-free rate |

### Production Readiness Gate

Checklist of what must be done before safe public release. **Today: 0 / 16 satisfied.**

- [ ] `flutter_secure_storage` adopted; auth token migrated off plain `SharedPreferences`; password persistence removed.
- [ ] All secrets (Google Maps × 2 entries, Stripe dev + prod) injected via `--dart-define-from-file` + `manifestPlaceholders`; leaked keys rotated; API-key restrictions in vendor consoles configured.
- [ ] All `debugPrint(headers/$token)` sites removed; `print`/`debugPrint` gated behind release no-op.
- [ ] `usesCleartextTraffic="false"`; `android:networkSecurityConfig` added; `android:allowBackup="false"`.
- [ ] Real release keystore + `key.properties` in CI secret; release builds verified Play-uploadable (no debug-key fallback).
- [ ] R8 / minification enabled; `--obfuscate --split-debug-info` per release; symbols stored.
- [ ] Dio `connectTimeout`/`receiveTimeout`/`sendTimeout` set; retry/backoff interceptor active; certificate pinning interceptor active.
- [ ] iOS `Info.plist` declares `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription` (App-Store-required).
- [ ] iOS schemes for dev/staging/prod (or at least dev/prod) configured; bundle IDs distinct; side-by-side install verified.
- [ ] `flutter_stripe` initialised at boot if checkout ships; prod Stripe `pk_live_…` confirmed real (no `PLACE_HOLDER`).
- [ ] Sentry receives release crashes with symbolicated stacks.
- [ ] GitHub Actions CI runs `flutter analyze --fatal-infos`, `flutter test --coverage`, builds per flavor, gates merges.
- [ ] `test/widget_test.dart` template replaced; ≥10 controller/validation tests passing.
- [ ] `Image.network` migrated to `CachedNetworkImage` with explicit decode sizes.
- [ ] Folder + file casing normalised to `snake_case`; Linux runner build passes.
- [ ] `ARCHITECTURE.md` + `CONTRIBUTING.md` published; template `README.md` replaced.

---

*Senior Flutter Architect audit. All findings traceable to `docs/AUDIT_MAP.md`, `docs/AUDIT_ARCH.md`, `docs/AUDIT_STATE.md`, `docs/AUDIT_STRUCT.md`, `docs/AUDIT_QUALITY.md`, `docs/AUDIT_PERF.md`, `docs/AUDIT_SEC.md`, `docs/AUDIT_SCALE.md`, `docs/AUDIT_FLAVOR.md`, `docs/AUDIT_TEST.md`, `docs/AUDIT_DEPS.md`. All `.md` artefacts under `docs/` per project rule.*
