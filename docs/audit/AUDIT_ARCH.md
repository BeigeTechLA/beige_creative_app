# AUDIT_ARCH.md — Architecture Audit (#1)

**Auditor role:** Senior Flutter Architect — Clean Architecture / DDD lens.
**Reference map:** `docs/AUDIT_MAP.md` (read before this audit). Cross-references use the form *(map § Pre-audit flags #N)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** all 85 `.dart` files under `lib/`; build configuration cross-checked.
**Output convention:** all docs live in `docs/` per project rule.

---

## Verdict

**Survives 12 months + 3 devs? No — requires major refactor.**

`docs/AUDIT_MAP.md` confirms the codebase has no domain layer, no DI surface, an unwired Riverpod dependency, and a single static `ApiService` instantiated **58 times** directly from `StatefulWidget` state classes. Eight files in `lib/` are over 1,000 lines and the largest screen (`signup3_screen.dart`) is **3,465 lines**. Adding a second backend, a swappable HTTP client, a feature flag, or a unit test suite is impossible without rewriting every screen. Two of the three things that look architectural — `lib/app/app.dart` (Riverpod root) and `lib/config/env.dart` (env loader) — are respectively block-commented and never reloaded from `.env` despite `flutter_dotenv` being a dependency.

## Architecture score: **2 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | Clean/DDD with full DI, testable, scales linearly with devs |
| 7–8  | Feature-first MVVM or BLoC with consistent layering, minor leaks |
| 5–6  | Layered MVC, some abstractions, manageable god-files |
| 3–4  | Screen-centric, direct service calls, inconsistent layering |
| 1–2  | No layering, god widgets, no DI, no abstractions |

Score breakdown — **Pattern uniformity 1/2 · Layer separation 0/2 · Logic placement 0/2 · DI 0/2 · Structural hygiene 1/2** → 2/10.

---

## Strengths (with evidence)

Three architectural assets keep the score above 1. Preserve these through the refactor.

1. **Centralized endpoint registry** — `lib/service/api_endpoints.dart`.
   ```dart
   // lib/service/api_endpoints.dart:9-20
   static const String login = "auth/login";
   static const String dashboardcount = "creator/dashboard-count";
   static const String forgotpassword = "auth/forgot-password-check";
   ...
   static String crewStats(String filter) => "creator/get-crew-stats?date_filter=$filter";
   ```

2. **Centralized design tokens** — `lib/utility/colorcode.dart` and `lib/utility/imges_icons.dart` keep the palette and asset paths out of widget code.
   ```dart
   // lib/utility/colorcode.dart:20-22
   static const Color backgroundColor = Color(0xFF1D1D1B);
   static const Color k262624 = Color(0xFF262624);
   ```

3. **Compile-time environment selection** — `lib/main_dev.dart` and `lib/main_prod.dart` give a clean env split (no `if (kDebugMode)` smell):
   ```dart
   // lib/main_dev.dart:1-4
   import 'config/env.dart';
   import 'main.dart';
   void main() => startApp(Environment.dev);
   ```
   Android product flavors `dev`/`prod` are also declared in `android/app/build.gradle.kts:41-53`, but their differentiation is *only* an `app_name` resValue — there is no per-flavor `src/dev`/`src/prod` source set on disk (map § Pre-audit flag #5).

---

## Pre-analysis: 5 most central files

By router wiring + import fan-in:

| File | Lines | Role | What pulls it / what it pulls |
|------|-------|------|-------------------------------|
| `lib/main.dart` | 104 | `MaterialApp.router` root + boot | imports `app/router.dart`, `config/env.dart`, `utility/colorcode.dart` |
| `lib/app/router.dart` | 369 | Single `GoRouter` | imports **every** screen file |
| `lib/main_screen.dart` | 396 | Post-login shell (bottom nav, drawer) | imports every primary feature page + `service/*` + `model_class/*` |
| `lib/service/api_service.dart` | 399 | HTTP god class (`http` + `dio`) | imports `config/env.dart`; called from 58 widget sites |
| `lib/home/home_screen.dart` | 2,902 | Dashboard | imports `service/*`, 6 `Model_Class/*` models, `widgets/*`, `app/route_names.dart` |

**Dependency direction (today):**

```
UI (screens/, widgets/)
        │ direct import (no abstraction)
        ▼
service/api_service.dart  →  config/env.dart
model_class/*.dart   (used directly as widget state types)
```

Clean Architecture expects `UI → presentation → domain ← data`. This codebase has only the leftmost arrow — and it points straight at HTTP. There is no domain layer to invert through. Every UI file is a hard-coupled consumer of `package:http` + `package:dio` semantics, transitively.

---

## A. Architecture Pattern Identification

### A1. Identified pattern: **None / "Screen + static Service"** 🔴 [HIGH]

The codebase implements no recognised pattern. It is a flat list of screens that each own their own data fetching, parsing, branching, and SharedPreferences I/O. The closest historical label is "1990s VB-style form code."

Three files exemplify the absence:

- **`lib/home/home_screen.dart`** — 8 fetch methods inside `_HomeScreenState`, each calling `ApiService()` directly, each parsing JSON inline, each `setState`-ing on success:
  ```dart
  // lib/home/home_screen.dart:83-124
  Future<void> fetchprofiledata() async {
    try {
      setState(() { isloading = true; });
      final rawResponse = await ApiService().postData(ApiEndpoints.profiledetails, {});
      debugPrint("📦 RAW API RESPONSE: $rawResponse");
      final response = Myprofilemodel.fromJson(rawResponse);
      ...
      if (response.error == false) {
        ...
        setState(() { Myprofile_user = response.data; });
      } else {
        debugPrint("❌ API ERROR: ${response.message}");
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
    } finally {
      setState(() { isloading = false; });
    }
  }
  ```

- **`lib/auth/login/login.dart`** — login flow inlines validation, API call, SharedPreferences persistence, `context.goNamed` navigation, and ad-hoc regex parsing of error strings:
  ```dart
  // lib/auth/login/login.dart:50-148
  Future<void> _fetchLogin() async {
    ...
    final response = await ApiService().postData(ApiEndpoints.login, {"email": email, "password": password});
    ...
    await SharedService.setLoginDetails(response);
    ...
    context.goNamed(RouteNames.home);
    } catch (e) {
      ...
      if (e.toString().contains("{") && e.toString().contains("message")) {
        final match = RegExp(r'"message":"(.*?)"').firstMatch(e.toString());
        if (match != null) errorMessage = match.group(1) ?? errorMessage;
      }
      TopMessage.show(context, errorMessage);
    }
  }
  ```

- **`lib/Profile/myprofile.dart`** — API call inside a **nested modal sheet builder**, ~1,700 lines into a single `build()` tree:
  ```dart
  // lib/Profile/myprofile.dart:2579-2596
  final response = await ApiService().postData(
    "creator/profile/edit-portfolio-link/$id",
    {"url": url, "platform": platform, "title": Portfoliolname[selectedPortfolioIndex]},
  );
  if (response["error"] == false) {
    await fetchprofiledata();
    if (mounted) Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"] ?? "Edit failed")),
    );
  }
  ```
  *Note:* this site uses a **hard-coded endpoint string literal** that bypasses `ApiEndpoints` entirely.

**Rationale:** No abstraction = no test seam, no parallel feature work, no swap-in/swap-out of HTTP or storage. **Failure mode:** any API change cascades through 58 widget sites; any reskin requires touching the data-fetching code that lives in the same file. **Why juniors do this:** the first screen written set the pattern, and every subsequent screen copy-pasted the `try / await ApiService().xxx / setState / catch debugPrint / finally setState` skeleton — the codebase has no example to follow.

### A2. Uniformly applied? **Yes — uniformly absent.** 🔴 [HIGH]

`pubspec.yaml:60` declares `flutter_riverpod: ^2.6.1`, but the only Riverpod surface in the whole repository is **block-commented** in `lib/app/app.dart` (entire file is a comment block — map § State management):
```dart
// lib/app/app.dart:17-32  (entire file is /* */)
class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}
```
No `ProviderScope`, no live `ConsumerWidget`, no `ref.read`/`ref.watch` in production code. **Riverpod is a dead dependency.**

Likewise, `flutter_dotenv: ^5.0.2` is in `pubspec.yaml:45` but `grep -rln "flutter_dotenv\|DotEnv\|dotenv" lib/` returns **zero** matches (map § Utilities). The "env" abstraction is hard-coded URLs in `lib/config/env.dart:13-20`.

---

## B. Layer Separation

### B1. UI importing data/HTTP directly — pervasive 🔴 [HIGH]

Every screen imports `service/api_service.dart` and `service/api_endpoints.dart` and calls `ApiService()` inline. Distribution (from `grep -rn "ApiService()" lib/`, total **58** sites):

| File | Sites |
|------|-------|
| `lib/Profile/myprofile.dart` | 9 |
| `lib/home/home_screen.dart` | 8 |
| `lib/auth/sign_up/signup2_screen.dart` | 5 |
| `lib/shoots/shoots_screen.dart` | 4 |
| `lib/auth/sign_up/signup3_screen.dart` | 2 |
| `lib/auth/forgotpassword/forgot_password_otp_screen.dart` | 2 |
| `lib/main_screen.dart`, `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart`, `lib/auth/login/login.dart`, `lib/auth/sign_up/signup1_screen.dart`, `lib/auth/forgotpassword/forgot_password_screen.dart`, `lib/auth/resetpassword/reset_password_screen.dart`, `lib/shoots/shoot_cancelled_screen.dart` | 1 each |
| ... (balance accounted for by `getImageURL`, `createAuthorizationHeader`, `baseUrl` reads inside `home_screen` / `myprofile`) | — |

**Rationale:** Every widget file now has a transitive build-time dependency on `dart:io`, `package:http`, and `package:dio`. None can be unit-tested without mocking at the platform-channel level. A backend swap, an API base-URL split, a retry/cache wrapper, or a logging interceptor requires editing **58** files. **Failure mode:** if an endpoint's response shape changes by one field, `fromJson` throws inside the widget's `setState` chain — see C2 for several silent-swallow sites that *mask* the error and leave the UI permanently in a loading or empty state.

#### Refactor diff (apply pattern to all 58 sites)

```dart
// BEFORE — lib/auth/login/login.dart:50-80 (excerpt)
Future<void> _fetchLogin() async {
  ...
  try {
    final response = await ApiService().postData(
      ApiEndpoints.login,
      {"email": email, "password": password},
    );
    if (response == null) { ... }
    if (response["error"] == true) { ... }
    if (response["data"] == null || response["data"]["user"] == null) { ... }
    await SharedService.setLoginDetails(response);
    context.goNamed(RouteNames.home);
  } catch (e) { ... }
}
```

```dart
// AFTER — lib/features/auth/domain/auth_repository.dart
abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
}

// AFTER — lib/features/auth/data/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client, this._sessionStore);
  final ApiClient _client;
  final SessionStore _sessionStore;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final json = await _client.post(ApiEndpoints.login, {'email': email, 'password': password});
    final dto = LoginResponseDto.fromJson(json);
    if (dto.error) throw AuthFailure(dto.message);
    final session = dto.data.toDomain();
    await _sessionStore.save(session);
    return session;
  }
}

// AFTER — lib/features/auth/domain/login_use_case.dart
class LoginUseCase {
  LoginUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthSession> call(String email, String password) =>
      _repo.login(email: email, password: password);
}

// AFTER — lib/features/auth/presentation/login_controller.dart
final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, AsyncValue<void>>(
  (ref) => LoginController(ref.read(loginUseCaseProvider)),
);
class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController(this._login) : super(const AsyncValue.data(null));
  final LoginUseCase _login;
  Future<void> submit(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _login(email, password));
  }
}

// AFTER — lib/features/auth/presentation/login_screen.dart (widget only)
onPressed: () => ref.read(loginControllerProvider.notifier)
    .submit(emailCtrl.text.trim(), passwordCtrl.text.trim()),
```
The widget no longer imports `ApiService`, `ApiEndpoints`, `SharedPreferences`, `dart:io`, or `go_router` for the navigation listener (move that to `ref.listen`). It compiles in a unit-test harness.

### B2. Domain layer purity 🔴 [HIGH]

**Not applicable in the affirmative — no domain layer exists.** There is no `lib/domain/`, no `lib/core/`, no `lib/features/<x>/domain/`. The only "business" types are JSON DTOs in `lib/model_class/`:
```dart
// lib/model_class/myprofile_model.dart:26-37
class Myprofilemodel {
  final bool error;
  final int code;
  final String message;
  final Data data;
  ...
}
```
Note `error: bool` and `code: int` — transport-level fields embedded in the business type. The domain has been collapsed into the transport layer.

### B3. DTOs used as widget state types 🔴 [HIGH]

```dart
// lib/home/home_screen.dart:49
profile.Data? Myprofile_user;
```
```dart
// lib/main_screen.dart:39
Data? Myprofile_user;
```
```dart
// lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:61
MyData? mydata;
```

The widget knows about `crew_files_id`, `file_type`, `file_path` — wire field names — because the DTO *is* the model. Any rename on the server cascades into widget code.

**Cross-file evidence — the same DTO leaks across 7+ files:**
- `lib/main_screen.dart:17` — `import 'Model_Class/myprofile_model.dart';`
- `lib/home/home_screen.dart:18-21` — three imports of the same physical file, one aliased `as dashboard`, one aliased `as profile`, one unaliased. The Dart analyzer's `duplicate_import` rule is being silently ignored.
- `lib/Profile/myprofile.dart`, `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart`, `lib/shoots/shoots_screen.dart`, etc.

### B4. Models defined inside widget files 🟢

**Not applicable — this codebase does not define models inside widget files.** Models are consistently externalised into `lib/model_class/`. **One genuine architectural win — preserve it during refactor.**

### B5. URL string concatenation leaks transport details into UI 🔴 [HIGH]

Two confirmed sites:
```dart
// lib/auth/sign_up/signup3_screen.dart:240-241
final response = await ApiService().postMultipartStep3(
  ApiService().baseUrl + ApiEndpoints.register_step3, // ✅ FULL URL
  ...
);
```
```dart
// lib/Profile/myprofile.dart:597-598
final url =
    "${ApiService().baseUrl}creator/profile/upload-profile-photo";
```
The widget is now responsible for assembling URLs — a transport concern. `postMultipartStep3` accepts an *absolute* URL (and per CLAUDE.md uses a bare Dio instance **without auth headers**), while every other multipart method accepts a *relative* path. The asymmetry is invisible at the call site and will produce a 401 the moment auth is required on `register_step3`. The `myprofile.dart:598` URL string is also hard-coded — it is not in `ApiEndpoints`.

### B6. Hard-coded endpoint string outside `ApiEndpoints` 🟠 [MEDIUM]

```dart
// lib/Profile/myprofile.dart:2579-2583
final response = await ApiService().postData(
  "creator/profile/edit-portfolio-link/$id",
  ...
);
```
```dart
// lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:75-84
final url = 'creator/project-details/${widget.projectid}';
...
final rawResponse = await ApiService().fetchData(url);
```
Two sites bypass the single-source-of-truth endpoint registry. A future search-and-replace of an endpoint will miss them.

---

## C. Business Logic Placement

### C1. Worst-5 build/state classes by logic-in-widget volume 🔴 [HIGH]

| File | Total lines | `build()` start | What lives in `State<T>` |
|------|-------------|-----------------|--------------------------|
| `lib/auth/sign_up/signup3_screen.dart` | **3,465** | 320 | file pickers, multipart assembly, navigation, validation, dozens of helpers |
| `lib/home/home_screen.dart` | **2,902** | 513 | 8 fetchers, role mapping, chart math, calendar event prep, date-filter mapping |
| `lib/Profile/myprofile.dart` | **2,834** | 879 | 9 API calls, modal-sheet builders containing API calls, raw photo upload via Dio at `:594-613` |
| `lib/auth/sign_up/signup1_screen.dart` | **1,959** | (n/a) | Google Places autocomplete, permission flow, sign-up step 1 multipart |
| `lib/Profile/featured_work_list.dart` | **1,703** | (n/a) | media gallery + upload + delete + reorder, all in one `State` |

`signup3_screen.dart:1-150` already imports `dart:io`, `dart:convert`, `dart:math`, `dart:ui`, `file_picker`, `dotted_border`, `lottie`, `open_file`, `flutter_svg`, `go_router`, plus the entire service layer — a single widget file pulling 12 packages. Analyzer/IDE responsiveness degrades visibly here.

### C2. API calls fired from `initState` / build / onPressed — pervasive, and several silently swallow errors 🔴 [HIGH]

Representative pattern from `lib/shoots/shoots_screen.dart`:
```dart
// lib/shoots/shoots_screen.dart:29-34
@override
void initState() {
  super.initState();
  fetchshootmodel();
  fetchshootcount();
}
```
No debounce, no cancellation token, no lifecycle observer. Several sites silently swallow exceptions:
```dart
// lib/shoots/shoots_screen.dart:64-93  (fetchshootcount)
} on Exception catch (e) {

}
```
That is an **empty catch block** — any exception (network, JSON parse, server 500) leaves `mycompletedShoots/mypendingRequests/...` at their initial `0` and the UI shows zeros indefinitely. The same pattern occurs in `fetchshootmodel` (`:96-119`), which has **no `try/catch` at all** — a thrown exception surfaces as a top-level Flutter framework error rather than recoverable UI state. Same screen uses `print()` directly at `:104`:
```dart
// lib/shoots/shoots_screen.dart:104
print("🔥 API RESPONSE 👉 $rawResponse");
```
Confirm scope with: `grep -nE "on Exception catch.*\{$" lib/` and `grep -nE "catch \(_\)" lib/`. Map § Pre-audit flag #19 counts 242 `print`/`debugPrint` calls in `lib/` — production logs leak request/response bodies.

### C3. Date/time, currency, validation logic inside widgets 🟠 [MEDIUM]

Email regex inside the login state class:
```dart
// lib/auth/login/login.dart:151-156
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}
```
Date-filter mapping inside the dashboard state:
```dart
// lib/home/home_screen.dart:68-76
String getFilterValue() {
  if (selectedRange == "Week") return "this_week";
  else if (selectedRange == "Month") return "this_month";
  else return "this_year";
}
```
Calendar event derivation inside the dashboard state:
```dart
// lib/home/home_screen.dart:290-302
void prepareAvailabilityEvents(Map<String, dynamic> availability) {
  events.clear();
  availability.forEach((dateString, value) {
    final date = DateTime.parse(dateString);
    final cleanDate = DateTime(date.year, date.month, date.day);
    final isAvailable = value["available"] == true;
    final isAssigned = value["projectAssigned"] == true;
    if (isAssigned) events[cleanDate] = "Shoot";
    else if (isAvailable) events[cleanDate] = "Available";
  });
}
```
Three date-formatting helpers inside an "upcoming shoot detail" screen:
```dart
// lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:34-58
String formatDateTime(String dateTime) { try { ... DateFormat("MMM d, yyyy h:mm a") ... } catch (e) { return dateTime; } }
String formatTime(String time) { ... DateFormat("HH:mm:ss").parse(time) ... }
String formatDate(String? rawDate) { ... DateFormat('MMM dd, yyyy').format(dt) ... }
```
All of these belong in pure-Dart helpers (`core/format/date_format.dart`) or use cases. As written they are untestable without a Flutter binding and are copy-pasted across screens.

#### Refactor diff (validation)

```dart
// BEFORE — inline in login.dart:151-156
bool isValidEmail(String email) { ... }
```
```dart
// AFTER — lib/core/validation/email.dart
final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
bool isValidEmail(String email) => _emailRegex.hasMatch(email);
```
Pure Dart, runs under `dart test`, reusable from the sign-up screens (which today contain copies of the same regex — confirm with `grep -n "RegExp(r'\^" lib/`).

---

## D. Dependency Inversion

### D1. Repositories behind abstract classes? **No.** 🔴 [HIGH]

```bash
$ grep -rn "abstract class" lib/
(no results)
```
**The codebase contains zero `abstract class` declarations.** Every widget binds to the concrete `ApiService`. The dependency graph has no inversion points.

### D2. Use cases? **None.** 🔴 [HIGH]

No `usecase/`, `use_case/`, `interactor/`, `command/`, `query/` directories. Business actions exist only as private methods on `State<T>` classes (e.g., `_fetchLogin`, `fetchprofiledata`, `fetchshootcount`, `deleteSocialLink`).

### D3. DI approach: **None — direct `new`.** 🔴 [HIGH]

`ApiService()` is constructed at every call site (58 times). **Map § Detected patterns** confirms 0 references to `get_it`, `injectable`, `kiwi`, or any DI helper. No `ProviderScope` wraps the app (map § Pre-audit flag #4). Each `ApiService` instance re-reads `Env.apiUrl` and re-allocates internal Dio in some paths (e.g., `lib/Profile/myprofile.dart:594` `final dio = Dio();`).

**Registration code: none exists to quote.**

### D4. Concrete classes injected where abstractions should be 🔴 [HIGH]

`SharedService` is a static utility class with global mutation of SharedPreferences:
```dart
// lib/service/shared_service.dart:7-49
class SharedService {
  static Future<void> setLoginDetails(Map<String, dynamic> response) async { ... }
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();   // wipes ALL keys
    print("🗑️ User data cleared from SharedPreferences");
  }
}
```
`logout()` calls `prefs.clear()` — this destroys **every** SharedPreferences key, including any non-auth preference (saved email/password from `lib/auth/login/login.dart:109-112`, theme prefs, draft saves, last-viewed tab, etc.). When a feature adds a non-auth pref next quarter, logout silently nukes it.

---

## E. Structural Anti-patterns

### E1. God files — every `.dart` over 300 lines 🔴 [HIGH]

Twenty-four `.dart` files over 400 lines. Top 10 (from map):

| File | Lines |
|------|-------|
| `lib/auth/sign_up/signup3_screen.dart` | 3,465 |
| `lib/home/home_screen.dart` | 2,902 |
| `lib/Profile/myprofile.dart` | 2,834 |
| `lib/auth/sign_up/signup1_screen.dart` | 1,959 |
| `lib/Profile/featured_work_list.dart` | 1,703 |
| `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` | 1,396 |
| `lib/auth/sign_up/signup2_screen.dart` | 1,328 |
| `lib/shoots/shoots_screen.dart` | 1,079 |
| `lib/Profile/profiledetils/enter_profile_details_screen.dart` | 950 |
| `lib/manageavailability/add_availability_screen.dart` | 915 |

Additional offenders 400–900 lines: `manage_availability_screen.dart` (834), `file_manager_screen.dart` (661), `profile_detils_1screen.dart` (621), `edit_personal_details_screen.dart` (589), `resume_screen.dart` (564), `certificates.dart` (537), `pre_production_screen.dart` (502), `utility/Utils.dart` (487), `auth/login/login.dart` (464), `auth/resetpassword/reset_password_screen.dart` (428), `auth/forgotpassword/forgot_password_otp_screen.dart` (403), `auth/forgotpassword/forgot_password_screen.dart` (401). **Reason in every case:** the screen owns its own data layer, state, layout tree, modal sheets, file pickers, and navigation calls.

### E2. Feature-based vs layer-based 🟠 [MEDIUM]

Top-level `lib/` is **feature-based** (`home/`, `shoots/`, `auth/`, `Profile/`, `file_manager/`, `manageavailability/`, `messages/`, `splash/`, `onboding/`, `upcomingshootviewdetils/`) but **each feature has no internal layering** — a "feature" is a folder of screens, nothing else. The cross-cutting `service/`, `utility/`, `widgets/`, `model_class/`, `app/`, `config/` are layer-shaped, but the features cannot consume them through abstractions.

Feature-first is the right *shape*; it is just empty inside.

### E3. Circular dependencies 🟢

Spot-check did not surface cyclic Dart imports (the analyzer would surface them as errors). `lib/auth/login/login.dart:7` imports `../../main_screen.dart`, but `main_screen.dart` does not import any auth file — no cycle. **Not applicable — no cycles detected.** Recommend adding `dependency_validator` to CI to lock this in.

### E4. Cross-feature imports & casing inconsistency 🔴 [HIGH]

The `auth/` feature reaches directly into the shell:
```dart
// lib/auth/login/login.dart:7
import '../../main_screen.dart';
```
`Login` only references `Mainscreen` in a commented-out `Navigator.pushAndRemoveUntil` block (`:115-119`). The import remains and pulls the entire shell graph into the auth feature's compile unit.

**Folder casing is inconsistent and case-mismatched imports rely on macOS being case-insensitive** (map § Naming convention). The folder on disk is `lib/model_class/`; imports say `Model_Class/`:
```dart
// lib/main_screen.dart:17
import 'Model_Class/myprofile_model.dart';
```
```dart
// lib/home/home_screen.dart:13-21
import '../model_class/create_dashboard_details_model.dart';
import '../Model_Class/crewstatus_model.dart';
import '../Model_Class/dashboard_count_model.dart';
import '../Model_Class/shoot_status_model.dart';
import '../Model_Class/upcoming_shoots_model.dart';
import '../Model_Class/create_dashboard_details_model.dart' as dashboard;
import '../Model_Class/myprofile_model.dart' as profile;
import '../Model_Class/myprofile_model.dart';   // duplicate, unaliased
```
And in the same file `shoots/shoots_screen.dart` mixes both forms in adjacent lines:
```dart
// lib/shoots/shoots_screen.dart:9-11
import '../model_class/shoot_count_model.dart';
import '../Model_Class/shoots_model.dart';
import '../UpcomingShootViewdetils/upcoming_shoot_view_detils.dart';
```
The third import references `UpcomingShootViewdetils/` (capital U+S+V) — actual folder is `upcomingshootviewdetils/` (all lowercase). All three forms compile only on macOS/APFS (case-insensitive). **Linux CI will not build this** (map § Pre-audit flag #16).

Top-level mixed casing — `Profile/` (PascalCase) vs `auth/`, `home/`, `shoots/` (lowercase) — is the same hazard at a coarser grain.

### E5. Duplicate imports & filename anomalies 🟡 [LOW]

`home_screen.dart:18-21` imports the same physical file twice (once aliased, once not). `dart analyze`'s `duplicate_import` lint is being ignored. Filename anomalies catalogued in `docs/AUDIT_MAP.md § Pre-audit flag #17` include:
- `lib/auth/view_details_screen .dart` — **literal space in filename before `.dart`**.
- `lib/Profile/profile_new_passwrod_screen.dart` — "passwrod".
- `lib/widgets/Topmessgae.dart` — "messgae" + PascalCase file.
- `lib/widgets/app_loder.dart` — "loder".
- `lib/widgets/commonFileViewer.dart`, `lib/widgets/commonImagePicker.dart`, `lib/widgets/new_Textfield.dart` — non-snake_case.
- `lib/onboding/`, `lib/upcomingshootviewdetils/`, `lib/Profile/profiledetils/profile_detils_1screen.dart` — repeated misspellings.

These do not break behaviour today; they break **search**, **CI**, and **onboarding** tomorrow.

---

## F. Cross-platform Integrity

### F1. Declared targets

`android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` — **6 platform scaffolds** (map § Project metadata).

### F2. Plugins that do not support all declared platforms 🟠 [MEDIUM]

Sampled direct deps against pub.dev platform tables:

| Plugin | Android | iOS | Web | macOS | Linux | Windows |
|--------|---------|-----|-----|-------|-------|---------|
| `flutter_stripe` 12.6.0 | ✅ | ✅ | ⚠️ partial | ❌ | ❌ | ❌ |
| `google_maps_flutter` 2.12.3 | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `geolocator` 11.1.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `image_picker` 1.2.0 | ✅ | ✅ | ✅ | ❌ (interface only) | ❌ | ❌ |
| `image_cropper` 10.0.0+1 | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `file_picker` 8.3.7 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `path_provider` 2.1.5 | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |

`flutter_stripe`, `google_maps_flutter`, `image_picker`, `image_cropper` do **not** support desktop targets. The `linux/` and `windows/` scaffolds will fail at build or first plugin call. No `if (Platform.isAndroid || Platform.isIOS)` guards exist around payment/map/picker call sites (spot-checked).

### F3. Platform-specific code without guards 🟠 [MEDIUM]

```dart
// lib/service/api_service.dart:3
import 'dart:io';
```
Used unguarded for `File` parameters in `postMultipart*` methods. `signup3_screen.dart`, `Profile/featured_work_list.dart`, and `Profile/myprofile.dart` likewise use `dart:io File` directly. **`dart:io` is unavailable on the web target** — these files will not compile under `flutter build web`. The web scaffold is therefore vestigial; either drop it or move file APIs behind a `XFile`/`cross_file` abstraction (`cross_file` is already pulled transitively per `pubspec.lock:92-99`).

### F4. Hard-coded secrets & insecure transport (map § Pre-audit flags #9, #10) 🔴 [HIGH]

```xml
<!-- android/app/src/main/AndroidManifest.xml:22-24 -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc"/>
```
The Google Maps Android API key is checked into VCS as cleartext, and the same key is shared between dev and prod flavors. Combined with:
```xml
<!-- android/app/src/main/AndroidManifest.xml:10-14 -->
<application
    android:label="BEIGECP"
    android:name="${applicationName}"
    android:icon="@mipmap/cp_app_icon"
    android:usesCleartextTraffic="true">
```
`usesCleartextTraffic="true"` is set globally in the production manifest. Both findings predate this audit's scope but are surfaced because they intersect with the architecture problem: there is **no place** in the current architecture to inject a build-time-different key. A future fix requires the missing build/DI seams.

Additionally:
```dart
// lib/config/env.dart:20
stripePublishableKey = 'PLACE_HOLDER_LIVE_STRIPE_KEY';
```
Prod ships with a placeholder Stripe key. Calling any Stripe API in prod will throw.

### F5. Test surface broken (map § Test surface) 🟠 [MEDIUM]

```dart
// test/widget_test.dart:14-29
testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('0'), findsOneWidget);
  ...
  await tester.tap(find.byIcon(Icons.add));
  ...
  expect(find.text('1'), findsOneWidget);
});
```
This is the **unmodified Flutter counter-app template**. The live `MyApp` requires `isLoggedIn: bool` (`lib/main.dart:30-33`) and renders no counter — the test will not compile, let alone pass. CI cannot rely on `flutter test`.

---

## Recommended folder structure for THIS project

Target a feature-first layered Clean-lite layout. Three layers per feature, plus a shared `core/`. Riverpod (already a paid-for dep) is the DI/state tool — actually wire it up.

```
lib/
├── main.dart                       # bootstrap: Env.init → ProviderScope → runApp
├── main_dev.dart
├── main_prod.dart
├── app/
│   ├── app.dart                    # MaterialApp.router (live, not commented out)
│   ├── router.dart                 # GoRouter only
│   ├── route_names.dart
│   └── theme/
│       ├── color_tokens.dart       # broken out from ColorCode mega-file
│       ├── typography.dart
│       └── app_theme.dart
├── core/
│   ├── env/env.dart
│   ├── network/
│   │   ├── api_client.dart         # the ONLY file that knows http/dio
│   │   ├── api_endpoints.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── logging_interceptor.dart
│   ├── storage/
│   │   └── secure_session_store.dart   # replaces SharedService static
│   ├── error/
│   │   ├── failure.dart            # sealed class
│   │   └── exceptions.dart
│   ├── validation/                  # pure Dart, dart-testable
│   │   ├── email.dart
│   │   └── password.dart
│   ├── format/
│   │   └── date_format.dart        # replaces inline DateFormat across screens
│   ├── result.dart                 # sealed Result<T> for repo returns
│   └── di/
│       └── providers.dart          # Riverpod provider definitions
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── dtos/login_response_dto.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart
│   │   │   ├── auth_repository.dart           # abstract
│   │   │   └── use_cases/login_use_case.dart
│   │   └── presentation/
│   │       ├── controllers/login_controller.dart
│   │       ├── screens/login_screen.dart
│   │       └── widgets/login_form.dart
│   ├── home/                                  # split home_screen.dart into ~8 widgets
│   ├── profile/
│   ├── shoots/
│   ├── file_manager/
│   ├── messages/
│   ├── availability/
│   └── onboarding/                            # rename from "onboding"
└── shared/
    ├── widgets/                   # genuinely cross-feature only
    │   ├── app_loader.dart        # rename from "app_loder"
    │   ├── top_message.dart       # rename from "Topmessgae"
    │   ├── custom_text_field.dart
    │   └── ...
    └── extensions/
```

Hard rules:

- **No widget file imports `core/network/` directly.** Only `*_repository_impl.dart` does.
- **No `presentation/` file imports `data/` directly.** `presentation/` and `domain/` depend on each other; `domain/` depends on nothing.
- **`features/<x>/` must not import `features/<y>/`.** Cross-feature data flows via `core/` or a shared `domain/` contract.
- **DTOs stay in `data/`** with `fromJson`. **Entities in `domain/`** with no JSON awareness. Mappers connect them.
- **Casing:** every folder + file `snake_case`. Run `dart fix` + an import-sorter after rename.
- **Tests:** delete `test/widget_test.dart` template. Replace with `dart test` on `core/` first, then widget tests on shared widgets.

Migration plan (one dev, ~12 weeks):

| Week | Work |
|------|------|
| 1 | Stand up `core/network/ApiClient` with Dio interceptors; abstract `Repository` base; `ProviderScope` at root. Login flow only. |
| 2 | Migrate `auth/` (login + signup1–3 + forgot/reset). Delete `auth/login/login.dart` → `main_screen.dart` cross-import. |
| 3 | Migrate `home/`. Break `home_screen.dart` into ~8 sub-widgets. |
| 4–5 | Migrate `profile/` and `featured_work_list/`. Replace `prefs.clear()` with key-scoped session clear. |
| 6 | Migrate `shoots/`, `upcomingshootviewdetils/`. |
| 7 | Migrate `file_manager/`, `messages/`, `availability/`. |
| 8 | Repaginate `Utils.dart`. Rename folders to `snake_case`, fix all `Model_Class/` imports. |
| 9 | Move regex/date/role-mapping into `core/validation/` + `core/format/` + use cases. Begin `dart test` coverage. |
| 10–12 | Remove `package:http` (Dio-only). Set up Linux CI runner. Decide platform set; drop dead targets. Fix `widget_test.dart`. |

---

## Dependency flow diagram (target)

```
┌───────────────────────────────────────────────────────────────────────┐
│                              widget tree                              │
│                                                                       │
│   features/<x>/presentation/screens/   ──watches──►   Controller      │
│        (Stateless/ConsumerWidget)                  (Riverpod          │
│                                                     StateNotifier)    │
└───────────────────────────────────────────────────────────────────────┘
                              │ ref.read
                              ▼
┌───────────────────────────────────────────────────────────────────────┐
│             features/<x>/domain/use_cases/<verb>_use_case.dart        │
│                  (pure Dart, throws domain Failures)                  │
└───────────────────────────────────────────────────────────────────────┘
                              │ depends on
                              ▼
┌───────────────────────────────────────────────────────────────────────┐
│         features/<x>/domain/<x>_repository.dart   (abstract)          │
└───────────────────────────────────────────────────────────────────────┘
                              ▲                                  ▲
                       implemented by                       depends on
                              │                                  │
┌──────────────────────────────────────────┐   ┌─────────────────────────────┐
│ features/<x>/data/<x>_repository_impl    │──►│ core/network/ApiClient      │
│   ▸ DTO ─ mapper ─ Entity                │   │   ▸ Dio + Interceptors      │
│   ▸ catches exceptions ▸ throws Failure  │   │   ▸ env-aware base URL      │
└──────────────────────────────────────────┘   └─────────────────────────────┘
                                                       │
                                                       ▼
                                                core/env/Env
```

Arrows point **inward** only. `domain/` has no outbound deps. `presentation/` and `data/` both depend on `domain/`. `core/network/` is the only place `package:dio` appears. **Today this collapses to one arrow: `screens/ ─► service/api_service.dart`.**

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Introduce `ApiClient` behind a single Riverpod provider; ban `ApiService()` constructor calls from `lib/features/`.** *Effort: 1 dev-week.* *Impact:* unhooks 58 widget sites from HTTP, enables interceptor-based auth header injection, makes mocking possible for the first time. Start with auth + home — the pattern propagates.

2. 🔴 **Split the four largest screens (`signup3`, `home`, `myprofile`, `signup1` — ~11,200 lines total) into controllers + sub-widgets.** *Effort: 2 dev-weeks.* *Impact:* IDE becomes responsive, biggest test-impossibility cluster removed, dead code surfaces during the split. Target: no file in `presentation/screens/` over 300 lines.

3. 🔴 **Normalise folder + import casing to `snake_case` and rename all `Model_Class/` import sites.** *Effort: 1 dev-day.* *Impact:* unblocks Linux CI (currently a no-go), fixes 8+ case-mismatched imports including the three-form mix in `shoots_screen.dart:9-11`, removes the `home_screen.dart:18-21` duplicate-import warnings. Hard-fail CI on case mismatch via a Linux runner.

4. 🔴 **Replace `SharedService.logout`'s `prefs.clear()` with key-scoped removal; move session storage behind a `SessionStore` interface.** *Effort: 1 dev-day.* *Impact:* prevents future feature prefs from being silently wiped on logout, sets up the DI seam every other refactor depends on.

5. 🟠 **Decide platform set; drop `linux/`, `windows/`, likely `web/` + `macos/` until needed; fix `test/widget_test.dart`.** *Effort: 1 hour for platforms, 30 min for the test.* *Impact:* stops claiming support that won't compile (`flutter_stripe`/`google_maps_flutter`/`image_picker` don't support desktop, `dart:io` is unguarded everywhere), restores `flutter test` as a useful CI signal. Re-add platforms per intent with matching guards.

---

*Audit refreshed against `docs/AUDIT_MAP.md` (2026-05-20). Per project rule, all `.md` artifacts live under `docs/`.*
