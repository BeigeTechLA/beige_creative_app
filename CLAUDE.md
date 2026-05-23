# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app `beige_creative_app` (BEIGE) — crew-side mobile client for a creative-services platform. Targets iOS, Android, web, macOS, Windows, Linux. Dart SDK `^3.10.4`. UI is dark-themed; backend is a hosted REST API at `mobile.beige.app` / `mobile.prod.beige.app`.

## Commands

```bash
# Install deps (run after pulling, after pubspec.yaml changes, after switching branches)
flutter pub get

# Run — pass --flavor AND -t. Android product flavors (dev/prod) and iOS schemes
# (dev/prod) live in the native projects; Dart entrypoint still selected via -t.
# Bundle ids: dev = com.app.cpbiege.dev, prod = com.app.cpbiege.
flutter run --flavor dev  -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart

# Lint / static analysis
flutter analyze

# Tests
flutter test                              # all
flutter test test/widget_test.dart        # single file
flutter test --name "pattern"             # filter by test name

# Release builds — always pass --flavor + -t
flutter build apk       --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
flutter build ios       --flavor prod -t lib/main_prod.dart --release
```

iOS/macOS: `Podfile`s under `ios/` and `macos/` are gitignored — `flutter pub get` regenerates them. If pods misbehave after a dep change, `cd ios && pod install --repo-update`.

## Architecture

### Entrypoints and environment selection

`lib/main.dart` defines `startApp(Environment)` but is **not** itself a runnable entrypoint. The two runnable mains are:

- `lib/main_dev.dart` → `startApp(Environment.dev)`
- `lib/main_prod.dart` → `startApp(Environment.prod)`

`startApp` calls `Env.init(...)` (`lib/config/env.dart`), which sets `Env.apiUrl`, `Env.imageUrl`, `Env.stripePublishableKey` as static fields read everywhere downstream. URLs are **hardcoded** in `env.dart` — `flutter_dotenv` is a dependency but no `.env` is loaded. To change a backend URL, edit `lib/config/env.dart`. The prod Stripe key is currently a placeholder string.

`startApp` also reads `isLoggedIn` from `SharedPreferences` before `runApp`, then `MaterialApp.router` mounts `appRouter`. The router's `initialLocation` is `/splash` regardless of login state — the splash screen is responsible for routing onward (do not assume `isLoggedIn` gates the initial route at the router level).

### Routing — `go_router`, names-only

Single `GoRouter` in `lib/app/router.dart`. Route name constants live in `lib/app/route_names.dart` (`RouteNames`). Navigate by name with `context.pushNamed(RouteNames.X, extra: {...})`. **Arguments are passed via `state.extra` as `Map<String, dynamic>`** (not via path/query params) — the router builders unpack the map and forward keys to the screen constructor. When adding a route that needs arguments, follow this pattern; don't add path params.

`lib/app/app.dart` is a commented-out Riverpod-based root (`App` ConsumerWidget). The live root is `MyApp` in `lib/main.dart` — a plain `StatelessWidget`. `flutter_riverpod` is in `pubspec.yaml` but **not wired up**; do not assume providers are available globally.

### Networking — `ApiService`

`lib/service/api_service.dart` exposes a hand-rolled HTTP layer that mixes `package:http` and `package:dio`:

- `ApiService()` is instantiated per call site (no DI). `_baseUrl` is read from `Env.apiUrl`.
- `createAuthorizationHeader()` reads `token` from `SharedPreferences` on every request and adds `Authorization: Bearer <token>` when present.
- `static String imageURL = Env.imageUrl;` — prefix relative image paths from API responses with this when building `NetworkImage` URLs.
- Methods: `fetchData(url)` (GET), `postData(url, map)`, `putData`, `deleteData`. They throw `Exception('Failed to ...')` on non-2xx — callers typically `try/catch` and `debugPrint` rather than surface typed errors.
- Multipart variants are **specialized**, not generic:
  - `postMultipart(url, fields, file?)` — sends file as `profile_photo` (used for profile photo upload).
  - `postMultipartData(url, fields, file?)` — sends as `files[]`.
  - `postMultipartDataMultiple(url, fields, files)` — multiple `files[]`.
  - `postMultipartStep3(url, ...)` — registration step 3 only; sends `resume`, `portfolio`, `certifications` (multi), and `recent_work_media` + `recent_work_media_index` pairs. Uses Dio directly **without** injecting the auth header — verify before reusing.

All endpoint paths are centralized in `lib/service/api_endpoints.dart` (`ApiEndpoints`). The base URL already ends with `api/`, so endpoint strings should not start with `/` — but `add_availability` does. Be careful with leading slashes when adding endpoints.

### Auth / session

`lib/service/shared_service.dart` (`SharedService`):

- `setLoginDetails(response)` extracts `data.token`, `data.user.{id,name,email,role,user_type,profile_image_url}` from the login API response and persists them to `SharedPreferences`, plus sets `isLoggedIn = true`. Call this after a successful login or any flow that yields a token.
- `logout()` calls `prefs.clear()` — wipes everything in SharedPreferences, not just auth keys. If you add non-auth prefs that must survive logout, change this.

`token` is the single source of truth for "logged in" at the network layer; `isLoggedIn` is only read in `startApp` to choose the boot path.

### Feature folder layout

Top-level under `lib/`: `splash/`, `onboding/` (sic), `auth/`, `Home/` (capitalized!), `Shoots/`, `file_manager/`, `messages/`, `manageavailability/`, `Profile/`, `UpcomingShootViewdetils/` (sic), `widgets/` (shared), `model_class/`, `service/`, `config/`, `utility/`, `app/`.

**Casing is inconsistent and the imports rely on it.** Examples in the codebase: `import '../Home/home_screen.dart'`, `import '../Profile/myprofile.dart'`, `import 'Model_Class/myprofile_model.dart'` vs the actual folder `model_class/`. macOS HFS+/APFS is case-insensitive by default so this works locally, but it will break case-sensitive filesystems (Linux CI, some Docker images). Match the on-disk casing exactly when adding imports, and prefer lower_snake_case for any new folder.

`model_class/` holds DTOs with hand-written `fromJson` constructors (no `json_serializable`). When changing an API response shape, update the model manually.

### Shell, theme, navigation

`lib/main_screen.dart` (`Mainscreen`) is the post-login shell: a bottom nav with 4 tabs (Dashboard / Shoots / File Manager / Messages) plus a drawer that exposes a 5th destination (Manage Availability) and the profile entry. `_pages` is a `late final` list of screens indexed by `_selectedIndex` — the body is `_pages[_selectedIndex]` (no `IndexedStack`, so tab state is lost on switch).

`fetchprofiledata()` on `Mainscreen` re-runs on construction and after returning from the profile route. The drawer route push is `context.pushNamed(RouteNames.myProfile).then((_) => fetchprofiledata())`.

Theme is configured inline in `MyApp.build` (`lib/main.dart`) — dark `colorScheme`, brand `scaffoldBackgroundColor = ColorCode.backgroundColor` (`#1D1D1B`), and all splash/highlight/hover colors removed. `lib/app/theme.dart`, `colors.dart`, `text_styles.dart`, etc. exist but the live theme does not use them. Treat `lib/app/*.dart` (except `router.dart` and `route_names.dart`) as **unused scaffolding**, not the source of truth.

### Design tokens

- `lib/utility/colorcode.dart` — `ColorCode.*` is the canonical palette. Use these constants; avoid raw `Color(0xFF...)` in widgets.
- `lib/utility/imges_icons.dart` — `AppImages.*` is the canonical asset-path registry. New assets should be added here, not referenced as raw strings at call sites.
- Fonts: `Unbounded` (400/500/600) and `Outfit` (400/500/600/700), declared in `pubspec.yaml`.

### Third-party integrations

- **Stripe** (`flutter_stripe`) — publishable key is set in `Env.stripePublishableKey`; ensure `Stripe.publishableKey` is assigned before any payment flow runs (currently not wired in `startApp` — check before using).
- **Google Maps + Places + Geolocator + Geocoding** — used in location pickers. API keys for Maps live in the native side (`android/app/src/main/AndroidManifest.xml`, `ios/Runner/AppDelegate.swift` or `Info.plist`), not in Dart.
- **Lottie** (`assets/lottie/`) — used for splash and success/cancelled screens.
- **image_picker + image_cropper + file_picker** — used in profile photo upload and registration step 3.

## Conventions to follow

- New screens: place under the matching feature folder; register the route in `lib/app/router.dart` and add the name constant to `lib/app/route_names.dart`.
- Argument passing: always via `state.extra` as `Map<String, dynamic>`; do not introduce path/query params unless the route should be deep-linkable.
- Colors: `ColorCode.*`. Asset paths: `AppImages.*`. Endpoints: `ApiEndpoints.*`.
- Network calls: instantiate `ApiService()` locally; expect `Exception` on non-2xx. Don't add a global client unless you also refactor existing call sites.
- Avoid introducing Riverpod providers unless you also un-comment and migrate to `lib/app/app.dart` — the current tree has no `ProviderScope`.

## Workflow Rules

- **Always ask questions before writing a plan.** Before proposing or executing any plan, ask clarifying questions to understand scope, constraints, and preferences. Do not assume — confirm first, then plan.
- **All Markdown documentation lives in `docs/`.** Any new `.md` file (audits, design notes, RFCs, ADRs, runbooks) must be created at `docs/<name>.md`. Do not write `.md` files to the repo root. The only exceptions are repo-root conventions: `CLAUDE.md`, `README.md`. When updating an existing top-level doc, leave it where it is; when creating a new one, place it under `docs/`.