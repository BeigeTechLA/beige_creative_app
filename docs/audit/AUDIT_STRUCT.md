# AUDIT_STRUCT.md — Project Structure Audit (#3)

**Auditor role:** Senior Flutter Architect — onboarding & scalability lens.
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** every folder under `lib/`, `test/`, `assets/`, plus all barrel/index/theme/util files.
**Output convention:** all docs live under `docs/` per project rule.

---

## Verdict

**Onboarding friction: HIGH.**

A new mid-level Flutter dev cannot decide *where* a new screen goes from the existing layout. Top-level `lib/` mixes PascalCase folders (`Profile/`, `UpcomingShootViewdetils/` referenced in some imports) with `lowercase/` (`auth/`, `home/`, `shoots/`, `messages/`, `manageavailability/`). Two parallel design-token systems coexist: the **live one** is `ColorCode` in `lib/utility/colorcode.dart`, the **dead one** is the `AppColors`/`AppSpacing`/`AppTextStyles`/`AppRadii`/`AppShadows`/`AppDurations` family under `lib/app/*.dart` — three of those files have **zero** non-self references. Twenty-one widgets sit in a flat `lib/widgets/` directory mixing PascalCase, camelCase, and snake_case filenames, several with typos baked into the names (`Topmessgae.dart`, `app_loder.dart`, `commonFileViewer.dart`). The model directory `lib/model_class/` contains **five separate classes named `Data`** that collide on import unless aliased.

The "where do I put it?" question has at least three answers in this repo, all wrong in different ways. **Verdict: HIGH friction, would slow a new hire to one feature per fortnight until the layout is reorganised.**

## Structure score: **2 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | Feature-first layered, naming uniform, tokens single-sourced, tests mirror lib/, assets organised |
| 7–8  | Feature-first, minor naming drift, one design-token system in use |
| 5–6  | Hybrid layout but consistent within sections; some duplicate utilities |
| 3–4  | Mixed casing, scattered tokens, no tests mirror, asset chaos |
| 1–2  | Multiple parallel naming systems, dead scaffolding, no barrels, single broken test file |

Score breakdown — **Layout uniformity 0/2 · Naming 0/2 · Modularity/reuse 1/2 · Layered surfaces 0/2 · Asset+test hygiene 1/2** → 2/10.

---

## Strengths (with evidence)

1. **Top-level layout is feature-first in *shape*.** Despite naming drift, `lib/` does cluster by domain (`auth/`, `home/`, `shoots/`, `Profile/`, `file_manager/`, `manageavailability/`, `messages/`, `splash/`, `onboding/`, `upcomingshootviewdetils/`). The skeleton for a real feature-first refactor exists — see `docs/AUDIT_ARCH.md` recommended structure.
2. **Asset paths are centralised in code** — `lib/utility/imges_icons.dart` (`AppImages`) is referenced from 21 files (`grep -rln "AppImages\\." lib | wc -l`). Adding a new asset has exactly one canonical place to put the constant.
3. **Routes are name-constant-based** — `lib/app/route_names.dart` (`RouteNames`) maps to a single `GoRouter` in `lib/app/router.dart`. A new screen needs one name added in one file; no global string scatter.
4. **All model DTOs live in one folder** — `lib/model_class/` (10 files). It would be the right home if it were named correctly and the duplicate `Data` classes were split out.

---

## Pre-analysis — walk as a new mid-level Flutter dev

Imagine joining tomorrow. Boss says: *"Add a Notifications screen that lists in-app notifications."*

| Question | What I see | What I'd guess | Risk |
|----------|------------|----------------|------|
| Where does the folder go? | Top-level `lib/` mixes `Profile/` (PascalCase) with `auth/`, `home/`, `shoots/` (lowercase). | `lib/Notifications/` to match `Profile/`. | I just propagated PascalCase across a new feature. Linux CI will break later if I import it as lowercase elsewhere. |
| What pattern do I follow? | `lib/app/app.dart` is block-commented with a `ConsumerWidget` Riverpod scaffold. Every live screen is `StatefulWidget` + `setState`. | I'll copy `lib/shoots/shoots_screen.dart` because it's the smallest comparable list screen. | I've inherited the empty `on Exception catch (e) {}` swallow, the 0 `mounted` guards, and the direct `ApiService()` coupling. |
| What folder do the DTOs go in? | `lib/model_class/` exists, but imports across the codebase use `Model_Class/` (capital). | Whichever the file next to me uses. | Mixed-case imports continue propagating — Linux CI failure already certain. |
| Where do I put a re-usable empty-state widget? | `lib/widgets/` has 21 files mixing `commonFileViewer.dart`, `custom_text_field.dart`, `Topmessgae.dart`. | Pick one of the casings and live with the inconsistency. | I'm choosing between three "right" conventions in the same folder. |
| What color do I use? | `lib/utility/colorcode.dart` (`ColorCode`) AND `lib/app/colors.dart` (`AppColors`) both exist. | Whichever I find first via "Go to symbol". | If I use `AppColors`, my colors will silently differ from the rest of the app because `AppColors` is 8 references and `ColorCode` is hundreds. |
| What text style? | `lib/app/text_styles.dart` (`AppTextStyles`) exists but is referenced **2 times**. **45 files declare `TextStyle(` inline** (`grep -rln "TextStyle(" lib`). | Inline `TextStyle` like everyone else. | I've cemented the duplication. |
| Where do I add a util like `formatDate`? | `lib/utility/Utils.dart` (entire `Utils` class is commented out at `:13`) AND `lib/utility/app_utils.dart` (`AppUtils`). Plus `lib/widgets/date_time.dart` defines `DateTimeUtils`. | Three places. | Triple-source-of-truth. |
| Where do tests go? | `test/widget_test.dart` is the unmodified Flutter counter template (map § Test surface). | "We don't write tests." | Confirmed — no test infrastructure exists. |
| What about a barrel/index file? | `find lib -name "index.dart" -o -name "barrel.dart"` returns **0**. | Import each file individually with relative paths. | Already the convention; long import blocks per screen. |

Conclusion: **a new dev would guess wrong, duplicate code, and ship the mistakes**. The repo cannot self-document its conventions because there are no conventions — only patterns of prior decisions, each made under different rules.

---

## A. Folder Organisation

### A1. Layer-first vs feature-first 🟠 [MEDIUM]

**Hybrid, leaning feature-first at the top, layer-first per cross-cutting concern.**

Feature folders: `auth/`, `home/`, `shoots/`, `Profile/`, `file_manager/`, `manageavailability/`, `messages/`, `splash/`, `onboding/`, `upcomingshootviewdetils/` (10).
Layer folders: `app/` (routing + dead tokens), `config/`, `service/`, `model_class/`, `utility/`, `widgets/` (6).

Each "feature" is a folder of screens — **no internal layering** (no `data/`, `domain/`, `presentation/` per feature; re-confirmed from `docs/AUDIT_ARCH.md` §E2). Tokens/services/models live in shared layer-folders, so cross-feature reuse is *technically* possible — but only via the static-class anti-pattern that pervades everything (`ApiService()`, `ColorCode.kFoo`, `AppImages.bar`).

### A2. Consistency across features 🔴 [HIGH]

No two features share the same internal structure. A single file in each is typical:

| Feature | Internal files |
|---------|----------------|
| `home/` | `home_screen.dart` (1 file, 2,902 lines) |
| `splash/` | `splash_screen.dart` (1 file) |
| `messages/` | `messages_screen.dart` (1 file) |
| `onboding/` | `onboding_screen.dart` (1 file) |
| `upcomingshootviewdetils/` | `upcoming_shoot_view_detils.dart` (1 file) |
| `manageavailability/` | 2 flat files |
| `shoots/` | 4 flat files |
| `file_manager/` | 4 flat files |
| `auth/` | 1 misplaced file + 4 sub-folders (`login/`, `sign_up/`, `forgotpassword/`, `resetpassword/`) |
| `Profile/` | 7 flat files + 2 sub-folders (`deleteaccount/`, `profiledetils/`) |

Two features (`auth/`, `Profile/`) have **sub-folder grouping by flow**; the other eight don't. The flat-vs-grouped decision was made per-feature, not project-wide.

### A3. Nesting depth 🟢

Maximum depth is 4 (`lib/Profile/deleteaccount/delete_account_otp_screen.dart`). Comfortable. **Not a problem.**

### A4. Tests mirror `lib/`? 🔴 [HIGH]

**No.** `test/` contains exactly one file:
```
test/widget_test.dart       # unmodified Flutter "Counter" template (map § Test surface)
```
- It does **not** mirror `lib/`.
- It does **not** compile against the live `MyApp` (which requires `isLoggedIn: bool`) — map § Pre-audit flag #1.
- There is no `integration_test/` directory.

A new dev cannot find a test to copy from. CI cannot rely on `flutter test`.

---

## B. Naming Conventions — Violations

Dart effective style guide: folders + files `lower_snake_case.dart`, classes `PascalCase`, variables/methods/parameters `lowerCamelCase`, private members `_leadingUnderscore`. Cross-checked from `docs/AUDIT_MAP.md § Naming convention`.

### B1. File naming 🔴 [HIGH]

| Path | Violation | Correct |
|------|-----------|---------|
| `lib/auth/view_details_screen .dart` | **literal space before `.dart`** | `view_details_screen.dart` |
| `lib/utility/Utils.dart` | PascalCase | `utils.dart` |
| `lib/utility/imges_icons.dart` | typo "imges" | `images_icons.dart` or split into `app_images.dart` |
| `lib/widgets/Topmessgae.dart` | typo + PascalCase | `top_message.dart` |
| `lib/widgets/app_loder.dart` | typo "loder" | `app_loader.dart` |
| `lib/widgets/commonFileViewer.dart` | camelCase file | `common_file_viewer.dart` |
| `lib/widgets/commonImagePicker.dart` | camelCase file | `common_image_picker.dart` |
| `lib/widgets/new_Textfield.dart` | mixed case (`new_` + `Textfield`) | `custom_input_field.dart` (matches the class inside) |
| `lib/Profile/profile_new_passwrod_screen.dart` | typo "passwrod" | `profile_new_password_screen.dart` |
| `lib/Profile/deleteaccount/delete_account_lottieScreen.dart` | camelCase suffix | `delete_account_lottie_screen.dart` |

Plus directories: `lib/Profile/` (PascalCase top-level), `lib/onboding/` (typo), `lib/upcomingshootviewdetils/` (typo + concatenation), `lib/Profile/profiledetils/profile_detils_1screen.dart` (typo "detils" repeated). Asset folders `assets/Active/`, `assets/NonActive/`, `assets/svg/Shoot/` use PascalCase; sibling folders are lowercase.

#### Refactor diff (one example)

```bash
# Folder + file rename + import update
git mv lib/widgets/Topmessgae.dart lib/widgets/top_message.dart
# Update all imports
grep -rln "widgets/Topmessgae" lib | xargs sed -i '' "s|widgets/Topmessgae|widgets/top_message|g"
```
Plus update the **class** name from `TopMessage` (file mismatched) — actually `TopMessage` is already correct PascalCase; only the file is wrong. Confirm with `grep -n "class TopMessage" lib/widgets/Topmessgae.dart` → `lib/widgets/Topmessgae.dart:4`.

### B2. Class naming 🟠 [MEDIUM]

| Class | Location | Issue | Suggestion |
|-------|----------|-------|------------|
| `Myprofilemodel` | `lib/model_class/myprofile_model.dart:26` | should be `MyProfileModel` | `MyProfileModel` |
| `Upcomingshootsmodel`, `Upcomingshootviewmodel`, `Creatordashboarddetailsmodel`, `Shootcountmodel`, `Dashboardcountmodel`, `CrewStatsModel`, `ShootsModel` | `lib/model_class/*` | inconsistent — some are `XxxModel`, some `Xxxmodel` | normalise to `XxxModel` |
| `upcomingdatum` | `lib/model_class/upcoming_shoots_model.dart` | lowercase class name | `UpcomingDatum` |
| `shootstatusdata` | `lib/model_class/shoot_status_model.dart` | lowercase class name | `ShootStatusData` |
| `Mainscreen` | `lib/main_screen.dart:27` | should be `MainScreen` | `MainScreen` |
| `Myprofile` | `lib/Profile/myprofile.dart` | should be `MyProfile` | `MyProfile` |

### B3. Variable / method naming 🟠 [MEDIUM]

```dart
// lib/home/home_screen.dart:49  and 42 sister sites
profile.Data? Myprofile_user;
```
`Myprofile_user` is **PascalCase + underscore + lowercase** — violates both `lowerCamelCase` and `lower_snake_case`. Grep counts 43 references.

```dart
// lib/auth/sign_up/signup3_screen.dart:68
final TextEditingController enter_work_titleController = TextEditingController();
```
`enter_work_titleController` is snake_case + camelCase suffix.

```dart
// lib/Profile/featured_work_list.dart:37
final enter_work_titleController = TextEditingController();
```
Same name, different file — also snake_case prefix.

Spot offenders found via `grep -rnE "  (final|var|int|bool|String|List<|File\?) [a-z]+_[a-z]" lib`.

### B4. Private members with leading underscore 🟢

State classes correctly use `_` prefix (`_HomeScreenState`, `_LoginState`). Private fields are inconsistent — e.g., `_currentIndex`, `_focusedDay`, `_controller` in `home_screen.dart` are private (good), but `selectedDashboardIndex`, `isExpanded`, `selectedRange` are public on the state class for no reason. **Not project-blocking** but indicates intent never set.

### B5. Suffix conventions 🟠 [MEDIUM]

| Suffix | Where used |
|--------|------------|
| `_screen.dart` | most feature files: `login_screen.dart` ❌ actually `login.dart`; `home_screen.dart` ✓; `splash_screen.dart` ✓; `onboding_screen.dart` ✓; `messages_screen.dart` ✓; `shoots_screen.dart` ✓; `signup1_screen.dart` ✓ |
| (no suffix) | `lib/auth/login/login.dart`, `lib/Profile/myprofile.dart`, `lib/Profile/certificates.dart`, `lib/Profile/resume_screen.dart` (this last one is fine) |
| `_widget.dart` | not used; widgets in `lib/widgets/` use varied naming |
| `_page.dart` | not used |

`login.dart` is the canonical entry-point of the auth flow — should be `login_screen.dart` to match every other screen. Same for `myprofile.dart` (should be `my_profile_screen.dart`) and `certificates.dart` (`certificates_screen.dart`).

### B6. BLoC naming 🟢

**Not applicable — this codebase does not use `flutter_bloc`.** (Map § State management.)

---

## C. Modularity & Reusability

### C1. Reusable widgets extracted to `shared/` or `common/widgets/` 🟠 [MEDIUM]

`lib/widgets/` exists (13 files) and is the de-facto shared folder:

```
lib/widgets/
├── Topmessgae.dart                 # TopMessage (snack bar)
├── app_loder.dart                  # AppLoader
├── commonFileViewer.dart           # CommonFileViewer
├── commonImagePicker.dart          # CommonImagePicker
├── common_calendar.dart            # CommonCalendar
├── common_uploader.dart            # CommonUploader
├── custom_dropdown.dart            # CustomDropdown<T>
├── custom_dropdown_field.dart      # CustomDropdownField
├── custom_multi_selectfield.dart   # CustomMultiSelectField
├── custom_text_field.dart          # CustomTextField
├── date_time.dart                  # DateTimeUtils  ← NOT a widget, belongs in utility/
├── multi_arc_painter.dart          # MultiArcPainter (CustomPainter)
└── new_Textfield.dart              # CustomInputField  ← class/file name mismatch
```

Issues: `date_time.dart` is a utility class living in a widget folder; `new_Textfield.dart` defines `CustomInputField` (file name has nothing to do with the class). Three different idioms in one folder: `CustomXxx`, `CommonXxx`, `AppXxx`/`TopXxx`/`MultiXxx`. **A new dev would invent a fourth idiom rather than match an existing one.**

### C2. Utilities centralised or duplicated 🔴 [HIGH]

**Three parallel "utils" surfaces:**

```dart
// lib/utility/Utils.dart:13
// class Utils  ← entirely commented out
```
```dart
// lib/utility/app_utils.dart:7-110
class AppUtils {
  static void showSnack(...) {...}
  static Future<DateTime?> pickDate(BuildContext context) async {...}
  static String formatDate(DateTime date) {...}
  static Future<File?> pickImage() async {...}
  static Future<File?> pickFile() async {...}
  static Future<File?> showPicker(BuildContext context) async {...}
  static void showLoading(BuildContext context) {...}
  static void hideLoading(BuildContext context) {...}
}
```
```dart
// lib/widgets/date_time.dart:3
class DateTimeUtils {...}    // duplicate of formatDate from AppUtils
```
Plus inline `formatDate` / `formatTime` / `formatDateTime` helpers in `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:34-58`. Four sources of "format a date." A new dev picks one and the codebase grows a fifth.

**Repository-wide signal:** 45 files declare `TextStyle(` inline (`grep -rln "TextStyle("` over `lib`), and 0 files reference `lib/app/durations.dart` or `lib/app/shadows.dart`. Tokens are not adopted; widgets keep redeclaring the same `TextStyle(fontFamily: "Outfit", fontSize: 14, color: ColorCode.white)` permutation in every screen.

### C3. Constants centralised? 🟠 [MEDIUM]

| Centralised | Where | Used |
|-------------|-------|------|
| Colors | `lib/utility/colorcode.dart` (`ColorCode`) | **live**, hundreds of refs (map § E2 Strengths) |
| Colors (parallel) | `lib/app/colors.dart` (`AppColors`) | 8 file references — **mostly dead** |
| Asset paths | `lib/utility/imges_icons.dart` (`AppImages`) | live, 21 file refs |
| Asset paths (parallel) | `lib/app/assets.dart` (`AppAssets`) | 21 references via the same grep — likely overlap; needs reconciliation |
| Route names | `lib/app/route_names.dart` (`RouteNames`) | live |
| API endpoints | `lib/service/api_endpoints.dart` (`ApiEndpoints`) | live (with 2 bypass sites — see `docs/AUDIT_ARCH.md` §B6) |
| Spacing | `lib/app/spacing.dart` (`AppSpacing`) | 9 references — **partially adopted** |
| Radii | `lib/app/radii.dart` (`AppRadii`) | 1 reference — **dead** |
| Shadows | `lib/app/shadows.dart` (`AppShadows`) | **0 references** — dead |
| Durations | `lib/app/durations.dart` (`AppDurations`) | **0 references** — dead |
| Text styles | `lib/app/text_styles.dart` (`AppTextStyles`) | 2 references — effectively dead |
| Strings (i18n) | — | **does not exist** — no `AppStrings`, no `intl_translation`, no `.arb` files (despite `intl` being a dep) |
| Dimensions | — | **does not exist** — magic numbers everywhere |

### C4. AppColors / AppTextStyles / AppDimensions / AppStrings / AppRoutes presence and uniform use 🔴 [HIGH]

**Present but split across two namespaces** with the live code preferring the older one:

- `ColorCode` (`lib/utility/colorcode.dart`) — used.
- `AppColors` (`lib/app/colors.dart`) — exists but only 8 callers; would silently diverge if used in a new feature.

**`AppRoutes`** does not exist by that name; the equivalent is `RouteNames` in `lib/app/route_names.dart`. Naming would benefit from `AppRoutes` for consistency with the `App*` family.

**`AppStrings`** does not exist. Every user-facing string is inline literal Dart in widgets (e.g., `'Enter your details to access your account.'` at `lib/auth/login/login.dart:258`). Internationalisation would require touching every screen.

**`AppDimensions`** does not exist. Spacing is partially in `AppSpacing`, but most screens use literal `SizedBox(height: 20)` / `padding: EdgeInsets.all(16)` — confirm with `grep -nE "EdgeInsets\\.(all|symmetric|only)\(" lib | wc -l`.

---

## D. Missing Layers

### D1. `domain/` layer 🔴 [HIGH]

**Not present.** Re-confirmed from `docs/AUDIT_ARCH.md` §B2. No entities, no repository interfaces, no use cases. Business types are the JSON DTOs in `lib/model_class/`.

### D2. `data/` layer 🔴 [HIGH]

**Not present.** `lib/service/api_service.dart` is the *implementation*; there is no abstraction it implements. DTOs (`lib/model_class/`) are not separated from entities.

### D3. `core/` or `shared/` layer 🟠 [MEDIUM]

**Partially present, scattered:**

| Concept | Where it lives today |
|---------|----------------------|
| Routing | `lib/app/router.dart`, `lib/app/route_names.dart` |
| Env | `lib/config/env.dart` |
| HTTP | `lib/service/api_service.dart` |
| Auth/session | `lib/service/shared_service.dart` (static class — see `docs/AUDIT_ARCH.md` §D4) |
| Theme | `lib/app/theme.dart` (3 references — partially dead) + `lib/utility/colorcode.dart` (live) |
| Error model | — does not exist |
| Result type | — does not exist |
| DI container | — does not exist |
| Base classes (BaseScreen, BaseController) | — do not exist |

A `core/` layer would consolidate this. Today these concerns are spread across `app/`, `config/`, `service/`, `utility/`, and the screens themselves.

### D4. Services (auth, analytics, notifications, deep links) properly separated 🟠 [MEDIUM]

`lib/service/` (5 files):

| File | Class | Purpose |
|------|-------|---------|
| `api_endpoints.dart` | `ApiEndpoints` | endpoint registry (live) |
| `api_service.dart` | `ApiService` | HTTP god class (live) |
| `config.dart` | `AppConfig` | (legacy, unused — `ApiService` now reads from `Env` not `AppConfig`) |
| `google_config.dart` | (not opened during this audit) | (presumed Google Maps/Places setup) |
| `shared_service.dart` | `SharedService` | static SharedPreferences helpers |

**Missing services:** `AnalyticsService`, `NotificationService` (push), `DeepLinkService`, `LoggerService`. `print()` and `debugPrint()` are used 242 times across `lib/` (map § Pre-audit flag #19) in lieu of a logger.

---

## E. Barrel Files & Exports

### E1. Barrel files (`index.dart`) used? 🟢

**Not applicable — this codebase uses no barrel files.** `find lib -name "index.dart" -o -name "barrel.dart"` returns 0 results. Imports are direct relative paths (often 5–10 per screen file). **Recommendation:** introducing barrels per feature (`lib/features/<x>/<x>.dart`) is part of the AUDIT_ARCH migration — adds, doesn't remove, structure.

### E2. Circular import risk 🟢

No barrels exist; no barrel-mediated cycles possible. `docs/AUDIT_ARCH.md` §E3 confirmed no Dart import cycles in spot-check. **Not applicable.**

### E3. Public vs internal exports per feature 🟠 [MEDIUM]

Without barrels, every file is "public." A consumer outside `lib/auth/sign_up/` can import `signup3_screen.dart` directly and reach into the private state class via the file (e.g., to grab the `Portfoliolname` constant at `:111`). **Failure mode:** refactors inside one feature can break callers in another silently, because there is no declared surface area.

---

## F. Asset Organisation

### F1. `assets/` layout 🟠 [MEDIUM]

```
assets/
├── Active/                       # PascalCase           — 5 files
├── NonActive/                    # PascalCase           — 5 files
├── fonts/                                                12 font files
├── home/                                                 1 file
├── images/                                               3 files
├── lottie/                                               4 files
├── onboding/                     # typo                  1 file
└── svg/
    └── Shoot/                    # PascalCase nested     (subset of 61 SVG files)
```

Mixed casing (`Active/` + `NonActive/` + `Shoot/` PascalCase, others lowercase). `onboding/` is the same typo as `lib/onboding/`. Asset categories are split by *theme purpose* (Active/NonActive — nav icons) and by *format* (svg/lottie/fonts/images) and by *screen* (home/onboding) — three different axes. A new icon could plausibly belong to `Active/`, `NonActive/`, `home/`, or `svg/`.

### F2. Unused assets 🟡 [LOW]

Cross-reference of asset paths used in `AppImages` against `pubspec.yaml:90-102` declared paths was not exhaustively performed in this audit. Spot-check: `assets/images/` has 3 files; `assets/onboding/` has 1; `assets/home/` has 1. **Recommendation:** run `flutter pub run dart_apptool` (or `dart run flutter_gen` if introduced) and `grep` each asset path against `AppImages` references; remove unreferenced files. Not a blocker now.

### F3. Font registration 🟢

Two font families (`Unbounded`, `Outfit`) are declared with weights in `pubspec.yaml:118-138`. **Correct.** Fonts are loaded as `family:` in `TextStyle` calls. (See C3 — these are mostly inlined rather than going through `AppTextStyles`.)

---

## Recommended folder structure (full tree for THIS project)

```
lib/
├── main.dart                       # boot — Env.init → ProviderScope → runApp
├── main_dev.dart
├── main_prod.dart
├── app/
│   ├── app.dart                    # MaterialApp.router (live)
│   ├── router.dart                 # GoRouter only
│   ├── route_names.dart            # renamed to AppRoutes for consistency
│   └── theme/
│       ├── app_theme.dart          # ThemeData composition
│       ├── color_tokens.dart       # canonical (merge ColorCode + AppColors)
│       ├── text_styles.dart        # canonical AppTextStyles
│       ├── spacing.dart            # canonical AppSpacing
│       ├── radii.dart
│       ├── shadows.dart
│       └── durations.dart
├── core/
│   ├── env/env.dart
│   ├── network/
│   │   ├── api_client.dart         # the only file importing dio
│   │   ├── api_endpoints.dart
│   │   └── interceptors/
│   ├── storage/
│   │   └── session_store.dart      # replaces SharedService static
│   ├── error/
│   │   ├── failure.dart
│   │   └── exceptions.dart
│   ├── result.dart
│   ├── format/
│   │   ├── date_format.dart        # absorb DateTimeUtils + inline helpers
│   │   └── currency.dart
│   ├── validation/
│   │   ├── email.dart
│   │   └── password.dart
│   ├── logger/
│   │   └── logger.dart             # replace 242 print/debugPrint calls
│   ├── strings/
│   │   └── app_strings.dart        # central, ready for intl
│   └── di/providers.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── controllers/
│   │       ├── screens/login_screen.dart      # rename from login.dart
│   │       └── widgets/
│   ├── signup/                                # extracted out of auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── screens/                       # split each of the 1k-3k line files
│   │           ├── signup_step1_screen.dart
│   │           ├── signup_step2_screen.dart
│   │           └── signup_step3_screen.dart
│   ├── forgot_password/                       # rename from forgotpassword/
│   ├── reset_password/                        # rename from resetpassword/
│   ├── home/
│   ├── profile/                               # rename from Profile/
│   ├── shoots/
│   ├── shoot_details/                         # rename from upcomingshootviewdetils/
│   ├── availability/                          # rename from manageavailability/
│   ├── file_manager/
│   ├── messages/
│   ├── splash/
│   └── onboarding/                            # rename from onboding/
└── shared/
    ├── widgets/                               # genuinely cross-feature
    │   ├── app_loader.dart                    # rename from app_loder.dart
    │   ├── top_message.dart                   # rename from Topmessgae.dart
    │   ├── custom_text_field.dart
    │   ├── custom_dropdown.dart
    │   ├── custom_dropdown_field.dart
    │   ├── custom_multi_select_field.dart     # rename
    │   ├── custom_input_field.dart            # rename from new_Textfield.dart
    │   ├── common_calendar.dart
    │   ├── common_uploader.dart
    │   ├── common_file_viewer.dart            # rename from commonFileViewer.dart
    │   ├── common_image_picker.dart           # rename from commonImagePicker.dart
    │   └── multi_arc_painter.dart
    ├── assets/assets.dart                     # canonical AppImages (merge)
    └── extensions/
```

Hard rules:
- All folders + files `snake_case`. No PascalCase, no camelCase, no typos.
- Every model class `XxxModel`/`XxxDto`/`XxxEntity` — pick one suffix per layer.
- Every screen file ends in `_screen.dart`. Every controller ends in `_controller.dart`.
- One theme namespace (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`). Delete the dead lib/utility/colorcode.dart after migration.
- One utils namespace, organised by domain (`format/`, `validation/`, `permissions/`), not a `AppUtils` god-class.
- `assets/` mirrors logical groups — flat `icons/`, `images/`, `lottie/`, `fonts/`, `svg/` — without theme-state subfolders (`active/inactive` should be variants in code, not directories).
- `test/` mirrors `lib/`. One `*_test.dart` per controller minimum.

---

## Naming convention table

| Type | Convention | Violations found |
|------|------------|------------------|
| **Top-level folders** | `lower_snake_case` | `Profile/` (PascalCase); `onboding/`, `upcomingshootviewdetils/` (typos/concatenation); `manageavailability/` (no underscore) |
| **Sub-folders** | `lower_snake_case` | `Profile/deleteaccount/` (no underscore), `Profile/profiledetils/` (typo), `auth/forgotpassword/`, `auth/resetpassword/`, `auth/sign_up/` (only this one has the underscore) |
| **Dart files** | `lower_snake_case.dart` | `Topmessgae.dart`, `app_loder.dart`, `commonFileViewer.dart`, `commonImagePicker.dart`, `new_Textfield.dart`, `Utils.dart`, `imges_icons.dart`, `view_details_screen .dart` (literal space), `delete_account_lottieScreen.dart`, `profile_new_passwrod_screen.dart`, `myprofile.dart` (should be `my_profile_screen.dart`), `certificates.dart` (should be `certificates_screen.dart`), `login.dart` (should be `login_screen.dart`) |
| **Classes** | `PascalCase` | `Myprofilemodel`, `Upcomingshootsmodel`, `Upcomingshootviewmodel`, `Creatordashboarddetailsmodel`, `Shootcountmodel`, `Dashboardcountmodel`, `upcomingdatum`, `shootstatusdata`, `Mainscreen`, `Myprofile` |
| **Variables / fields** | `lowerCamelCase` | `Myprofile_user` (43 sites), `enter_work_titleController` (multiple files), `Portfoliolname` (`signup3_screen.dart:111`), `Portfolioicons` (`:117`) |
| **Private members** | leading `_` | inconsistent — partially applied. Spot offenders: `selectedDashboardIndex`, `isExpanded`, `selectedRange` in `_HomeScreenState` are public for no reason |
| **Suffix `_screen.dart`** | applies to screens | missing on `login.dart`, `myprofile.dart`, `certificates.dart` |
| **Suffix `_widget.dart`** | applies to shared widgets | not used (acceptable — many use descriptive names) |
| **Suffix `_model.dart`** | applies to DTOs | applied (✓) — only the class name needs normalising |
| **Asset folder casing** | `lower_snake_case` | `Active/`, `NonActive/`, `svg/Shoot/`, `onboding/` |
| **Asset filenames** | `lower_snake_case.svg/png/json` | inconsistent — e.g., `assets/NonActive/shoots(1).svg`, `manageavailability(2).svg`, `filemanager(1).svg` (literal parentheses + digit) |
| **BLoC files** | `feature_bloc.dart`, `_event.dart`, `_state.dart` | **Not applicable — no BLoC** |

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Normalise folder + file casing to `snake_case` across `lib/` and `assets/` (Linux CI gate).** *Effort: 1 dev-day with `git mv` + import sweep.* *Impact:* eliminates the entire mixed-casing risk (map § Pre-audit flag #16), removes the `Model_Class/` vs `model_class/` confusion in `home_screen.dart:13-21` and `shoots_screen.dart:9-11`, makes the project portable to a Linux runner. Includes renaming typos: `Topmessgae` → `top_message`, `app_loder` → `app_loader`, `onboding` → `onboarding`, `upcomingshootviewdetils` → `shoot_details`, `passwrod` → `password`, `imges_icons` → `app_images`, `Utils.dart` → `utils.dart`, plus the screen filename without the literal space.

2. 🔴 **Pick *one* design-token namespace; delete the dead one.** *Effort: 0.5 dev-day.* *Impact:* removes the `ColorCode` vs `AppColors` fork (one is live with hundreds of refs, the other has 8); deletes `lib/app/durations.dart`, `lib/app/shadows.dart`, `lib/app/radii.dart` (0–1 references); migrates `AppSpacing` and `AppTextStyles` into the active namespace; gives a new dev one place to look. Decision: keep the `App*` family (cleaner names, prefix consistency), migrate `ColorCode.k...` → `AppColors.k...`.

3. 🔴 **Resolve `Data` class collisions and rename DTOs to `PascalCase` with a `Model` suffix.** *Effort: 1 dev-day.* *Impact:* `grep -rn "^class Data " lib` returns **5** files defining a class named `Data`. Imports like `import '../Model_Class/myprofile_model.dart' as profile;` exist only to disambiguate. Replace `Data` (in `myprofile_model.dart`) with `ProfileData`, the one in `shoots_model.dart` with `ShootsData`, etc. Removes the alias-import gymnastics in `home_screen.dart:18-21` and the unaliased duplicate import on `:21`.

4. 🟠 **Unify utilities — collapse `lib/utility/Utils.dart`, `lib/utility/app_utils.dart`, `lib/widgets/date_time.dart`, and the per-screen inline `formatDate`/`formatTime` helpers into `lib/core/format/` and `lib/core/permissions/`.** *Effort: 1 dev-day.* *Impact:* eliminates the 4-source-of-truth date format problem (B-references C2 above), retires the `Utils.dart` block-commented file, moves `DateTimeUtils` out of `lib/widgets/` where it doesn't belong.

5. 🟠 **Stand up `test/` mirroring `lib/` and replace `widget_test.dart` template with at least one passing test.** *Effort: 0.5 dev-day for the scaffolding; iterative thereafter.* *Impact:* restores `flutter test` as a CI signal (today it errors because `MyApp()` lacks the required `isLoggedIn` argument — map § Pre-audit flag #1). Create `test/utility/colorcode_test.dart`, `test/widgets/top_message_test.dart`, and a controller test once the migration in `docs/AUDIT_STATE.md` lands. Mirror enforces the structure.

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and informs `docs/AUDIT_ARCH.md` + `docs/AUDIT_STATE.md`. All `.md` artefacts under `docs/` per project rule.*
