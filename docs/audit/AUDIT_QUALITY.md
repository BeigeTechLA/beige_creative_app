# AUDIT_QUALITY.md — Code Quality Audit (#4)

**Auditor role:** Senior Flutter Developer / Code Reviewer — strict standards.
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** every `.dart` file under `lib/`.
**Output convention:** all docs live in `docs/` per project rule.

---

## Verdict

**Refactor required — not production-ready.**

Modern Flutter widget choices are correct (no `WillPopScope`, `RaisedButton`, `FlatButton`, `OutlineButton` anywhere; `const` heavily used; `go_router` adopted), so the codebase is **not** in "rewrite" territory. But the quality issues compound: 41 `StatefulWidget`s with only 8 `dispose()`s (`docs/AUDIT_STATE.md` §C4), 266 `setState` calls with ~87% unguarded after `await` (`docs/AUDIT_STATE.md` §C2), 242 `debugPrint`/`print` calls leaking API payloads in release (`docs/AUDIT_MAP.md` § Pre-audit flag #19), eight `.dart` files over 1,000 lines, and a single 3,465-line screen file (`signup3_screen.dart`). On top of that, ~100+ lines of commented-out code blocks remain in `home_screen.dart`, `main_screen.dart`, and `onboding_screen.dart`. **Refactor required — landing the AUDIT_ARCH/STATE/STRUCT plans simultaneously is the path; piecemeal "clean up the lint" will not fix the substantive issues.**

## Quality score: **3 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | Lint clean, ≤200-line files, no dead code, no `!`, `dynamic` only where unavoidable |
| 7–8  | Minor lint debt, occasional `!`, some long files but logic split |
| 5–6  | Mixed quality, recoverable god files, dead code under control |
| 3–4  | Many god files, dead code present, weak typing, log spam |
| 1–2  | Deprecated APIs, broken null safety, no const, no override discipline |

Score: **Modern widget API discipline 2/2 · File-size hygiene 0/2 · Dead-code hygiene 0/2 · Null/error hygiene 0/2 · Typing/logging hygiene 1/2** → 3/10.

---

## Hotspot files (3 worst)

| # | File | Lines | Why |
|---|------|-------|-----|
| 1 | `lib/auth/sign_up/signup3_screen.dart` | **3,465** | 35-field state class (`docs/AUDIT_STATE.md` §B1), 5+ undisposed `TextEditingController`s, ~65-line submission handler at `:148-269`, **0** `mounted` checks for 25 `setState`s after `await`, hard-coded endpoint string concatenation at `:240-241`, modal-scoped controllers at `:3064`. Build method starts `:320` and runs to EOF — ~3,145 lines of single widget tree. |
| 2 | `lib/home/home_screen.dart` | **2,902** | 7-fetcher `initState` (`:314-322`) with 0 `mounted` guards on 39 `setState`s, three imports of the same model file (`:18-21`) with mixed aliasing/casing (`Model_Class/` vs `model_class/`), **10+ multiline `/* ... */` commented-out widget blocks** scattered through the build tree (e.g., `:625-`, `:840-`, `:1064-`, `:1096-`, `:1407-`, `:1511-`). Build method ~2,389 lines. |
| 3 | `lib/Profile/myprofile.dart` | **2,834** | 9 `ApiService()` call sites, raw `Dio()` upload at `:594-613` bypassing the service layer, 2 hard-coded endpoint strings (`:598`, `:2579-2583`), modal-builder `setModalState(() { setState(() { ... }) })` nesting at `:2603-2611`, **no `dispose()` despite 2+ `TextEditingController`s**. Build method ~1,955 lines. |

The same three files dominate every previous audit (`docs/AUDIT_ARCH.md` §C1, `docs/AUDIT_STATE.md` Pre-analysis, `docs/AUDIT_STRUCT.md`). Fixing them is the leverage point for the whole codebase.

---

## Strengths (with evidence)

1. **Modern widget API discipline.** `grep -rn "WillPopScope\|RaisedButton\|FlatButton\|OutlineButton" lib` returns **0**. The codebase uses current APIs (`go_router`'s navigation, `ElevatedButton`/`OutlinedButton`/`TextButton`, no deprecated buttons), and pulls in modern packages (`auto_skeleton`, `cached_network_image` 3.4.1, `lottie` 3.3.1).
2. **`const` discipline is broad** — `grep -cE "const [A-Z][a-zA-Z]+\(" lib` returns **1,438** matches. Leaf widgets are mostly `const`-friendly, so the wide `setState` rebuilds at least skip leaf reconstruction (`docs/AUDIT_STATE.md` § Strengths).
3. **String interpolation is universal.** `grep -rnE '"[^"]*" \+ ' lib` returns **0** legacy `"a" + b` concatenations. No remnant Java/Kotlin-style concat.
4. **Single concrete deprecated pattern: none.** No `RaisedButton`, no `WillPopScope`, no `FloatingActionButtonLocation.endTop` legacy values. Static analyzer's deprecation lints would land cleanly.

These are the four things to preserve through the refactor.

---

## Pre-analysis — top 10 long functions / 10 long `build()`s / duplicated blocks

### Long `build()` methods (top 10)

| File | `build()` start | Approx length |
|------|-----------------|---------------|
| `lib/auth/sign_up/signup3_screen.dart` | `:320` | **~3,145 lines** |
| `lib/home/home_screen.dart` | `:513` | **~2,389 lines** |
| `lib/Profile/myprofile.dart` | `:879` | **~1,955 lines** |
| `lib/auth/sign_up/signup1_screen.dart` | (file 1,959 lines) | ~1,300 (eyeballed) |
| `lib/Profile/featured_work_list.dart` | (file 1,703) | ~1,200 |
| `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` | (file 1,396) | ~1,000 |
| `lib/auth/sign_up/signup2_screen.dart` | (file 1,328) | ~900 |
| `lib/shoots/shoots_screen.dart` | `:151` | ~900 |
| `lib/Profile/profiledetils/enter_profile_details_screen.dart` | (file 950) | ~700 |
| `lib/manageavailability/add_availability_screen.dart` | (file 915) | ~700 |

A Flutter `build()` over **60** lines is already a yellow flag (item 2 of the brief). **Every screen in this top-10 is one to three orders of magnitude over.**

### Long non-build functions (top 5)

| File | Function | Range | Lines |
|------|----------|-------|-------|
| `lib/auth/sign_up/signup3_screen.dart` | `_submit()` (multipart submission) | `~:148-269` | ~120 |
| `lib/auth/login/login.dart` | `_fetchLogin()` | `:50-149` | ~100 |
| `lib/home/home_screen.dart` | `initState()` + private `fetch*` chain | `:83-303` | 8 fetchers, 220 lines |
| `lib/Profile/myprofile.dart` | photo upload (raw Dio) | `:580-631` | ~52 |
| `lib/Profile/myprofile.dart` | modal portfolio edit (inside `build`) | `~:2560-2615` | ~55 |

### Most duplicated logic blocks

| Block | Locations |
|-------|-----------|
| `fetchprofiledata` — identical endpoint + DTO + setState | `lib/main_screen.dart:50-87` + `lib/home/home_screen.dart:83-124` |
| Email regex `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` | `lib/auth/login/login.dart:151-156` + similar copies in sign-up screens (`grep -rn "RegExp(r'\^" lib` for confirmation) |
| Plus-code regex `^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$` | `lib/auth/sign_up/signup1_screen.dart:63` + `lib/Profile/profiledetils/edit_personal_details_screen.dart:35` |
| Inline `DateFormat("MMM d, yyyy h:mm a")` / `("h:mm a")` / `('MMM dd, yyyy')` | `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:34-58` + `lib/widgets/date_time.dart:10-21` + AppUtils.formatDate (`lib/utility/app_utils.dart:38-43`) |
| `try { … await ApiService().postData(…) … } catch (e) { debugPrint(...) } finally { setState(...) }` skeleton | duplicated across **every fetcher in every screen** — quantify via `grep -nE "await ApiService\(\)\." lib | wc -l` (count of 50+ sites; pattern essentially identical) |

Same three files in every dimension.

---

## A. Readability & Structure

### A1. Functions/methods over 30 lines 🔴 [HIGH]

The top 5 above all exceed 30 lines several-fold. Spot-counts across worst-3 files (rough — line ranges between `Future`/`void`/`Widget` declarations) suggest **dozens** of methods over 30 lines, with the most extreme at ~120 (`_submit` in `signup3_screen.dart`). A 30-line function fits in a screen; a 120-line one does not.

#### Refactor diff (split `_fetchLogin`)

```dart
// BEFORE — lib/auth/login/login.dart:50-149
Future<void> _fetchLogin() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  // validation, API call, persistence, navigation, error parsing — all inline
  ...
}
```
```dart
// AFTER
Future<void> _fetchLogin() async {
  if (!_validate()) return;
  setState(() => isLoggingIn = true);
  final result = await _loginUseCase(emailController.text.trim(), passwordController.text.trim());
  if (!mounted) return;
  result.when(
    success: (_) => context.goNamed(RouteNames.home),
    failure: (msg) => TopMessage.show(context, msg),
  );
  setState(() => isLoggingIn = false);
}

bool _validate() {
  final email = emailController.text.trim();
  if (email.isEmpty)          return _showError('Please enter your email address');
  if (!isValidEmail(email))   return _showError('Please enter a valid email address');
  if (passwordController.text.trim().isEmpty) return _showError('Please enter your password');
  return true;
}
```
100 lines → 20.

### A2. Widget `build()` methods over 60 lines 🔴 [HIGH]

See the table above. Every screen file `build()` exceeds 60 lines by a wide margin. Three exceed 1,000 lines. **The 60-line rule is violated by every screen in the codebase.**

### A3. Cyclomatic complexity hotspots 🟠 [MEDIUM]

Confirmed nests:

```dart
// lib/auth/login/login.dart:124-141  (inside catch block of _fetchLogin)
String errorMessage = "Invalid email or password";
if (e is Map<String, dynamic>) {
  errorMessage = e["message"] ?? errorMessage;
} else if (e.toString().contains("{") && e.toString().contains("message")) {
  try {
    final data = e.toString();
    final match = RegExp(r'"message":"(.*?)"').firstMatch(data);
    if (match != null) {
      errorMessage = match.group(1) ?? errorMessage;
    }
  } catch (_) {}
}
```
Five branches in a `catch` parsing string content via regex to extract a JSON error message — three logically distinct error-modelling concerns smashed together. `catch (_) {}` at the inner level swallows everything (A6 cross-ref).

```dart
// lib/home/home_screen.dart:290-302
events.clear();
availability.forEach((dateString, value) {
  final date = DateTime.parse(dateString);
  final cleanDate = DateTime(date.year, date.month, date.day);
  final isAvailable = value["available"] == true;
  final isAssigned = value["projectAssigned"] == true;
  if (isAssigned) {
    events[cleanDate] = "Shoot";
  } else if (isAvailable) {
    events[cleanDate] = "Available";
  }
});
```
Three string-equality branches over magic strings; data shape inferred from a `dynamic` map. Pulled out and tested as a pure function this is a 5-line use case.

### A4. Magic strings 🟠 [MEDIUM]

Cataloguing user-facing + API strings that should be constants. Representative — not exhaustive:

| File | Line | Magic | Suggested constant |
|------|------|-------|---------------------|
| `lib/home/home_screen.dart` | 68-76 | `"Week"`, `"Month"`, `"this_week"`, `"this_month"`, `"this_year"` | `DashboardRange.values` enum + server mapper |
| `lib/home/home_screen.dart` | 296-301 | `"available"`, `"projectAssigned"`, `"Shoot"`, `"Available"` | `AvailabilityKey` enum |
| `lib/home/home_screen.dart` | 348-351 | `"All Events"`, `"Available"`, `"Shoot"` (`eventList`) | shared enum + i18n |
| `lib/home/home_screen.dart` | 156-171 | `"photo"`, `"video"`, `"acceptedShoots"`, `"rejectedShoots"`, `"shootRequests"`, `"requests"`, `"total"` | DTO field names — should live in DTO class, not widget |
| `lib/auth/login/login.dart` | 246, 258 | "Welcome Back", "Enter your details to access your account. Continue\nmanaging your bookings and profile." | `AppStrings.loginTitle`, `AppStrings.loginSubtitle` (`docs/AUDIT_STRUCT.md` §C3 — no `AppStrings` exists) |
| `lib/auth/login/login.dart` | 124 | "Invalid email or password" (default error) | `AppStrings.loginGenericError` |
| `lib/auth/login/login.dart` | 60, 65, 56 | "Please enter your email address" / "Please enter a valid email address" / "Please enter your password" | central `AppStrings.validation*` |
| `lib/Profile/myprofile.dart` | 2596 | "Edit failed", "Network error. Please try again." | central strings |
| `lib/auth/sign_up/signup3_screen.dart` | 261 | "Submission failed", "Something went wrong" | central strings |

`grep -rnE '"[A-Z][a-zA-Z][^"]{8,}"' lib | wc -l` — would surface hundreds. The codebase has no `AppStrings` file (`docs/AUDIT_STRUCT.md` §C3); every user-facing copy is an inline literal. Internationalisation today requires touching every screen.

### A5. Magic numbers 🟠 [MEDIUM]

Representative offenders:

```dart
// lib/main_screen.dart:113
drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,
```
```dart
// lib/main_screen.dart:133
filter: ImageFilter.blur(sigmaX: 80, sigmaY: 70),
```
```dart
// lib/auth/login/login.dart:223
height: MediaQuery.of(context).size.height * 0.35,
```
```dart
// lib/home/home_screen.dart:325
duration: Duration(milliseconds: 500),
```
```dart
// lib/home/home_screen.dart:329
end: const Offset(0, 1.5),
```
```dart
// lib/main_screen.dart:259
radius: 25,
```
`AppDimensions` does not exist (`docs/AUDIT_STRUCT.md` §C3). `AppDurations` exists (`lib/app/durations.dart`) but has **0** references in `lib/` (`docs/AUDIT_STRUCT.md` §C3 — dead). The `0.3`/`0.35`/`80`/`70`/`500`/`25` numbers are repeated across screens with no traceable source.

### A6. TODO / FIXME / HACK / TEMP / XXX comments 🟢

Full list (re-grep `grep -rnE "// ?(TODO|FIXME|HACK|XXX|TEMP)" lib`):

| File | Line | Text |
|------|------|------|
| `lib/app/theme.dart` | 266 | `// TODO: Implement light theme when ready for dual-mode support.` |

That's it. **One actionable TODO in the whole codebase.** (Map § Pre-audit flag #18 reported 5 TODO + 7 XXX matches; those counts came from a broader grep including string-occurrence "xxx" inside debug logs, not comment markers. Verified — only the single `// TODO` above is a real backlog marker.)

### A7. Commented-out code blocks 🔴 [HIGH]

`grep -rnE "^\s*/\*" lib` returns 60+ multiline-comment openers. Top offenders:

| File | Lines | What |
|------|-------|------|
| `lib/home/home_screen.dart` | 10+ block-comment openers at `:78`, `:380`, `:625`, `:746`, `:748`, `:840`, `:1064`, `:1096`, `:1407`, `:1511`, etc. | Dead widget subtrees, old `TableCalendar` usage, alternate card layouts |
| `lib/main_screen.dart` | 3 blocks at `:45`, `:115`, `:233` | Old drawer-opening logic, old `IndexedStack` body, old `Navigator.push` to `Myprofile` |
| `lib/onboding/onboding_screen.dart` | 2 blocks at `:23`, `:189` | Dead alternate `SafeArea` layout |
| `lib/app/app.dart` | entire file | Block-commented `ConsumerWidget` root (`docs/AUDIT_ARCH.md` §A2) |

Plus 104 single-line `// final…`/`// setState…`/`// Navigator…` etc. commented Dart lines via `grep -rnE "^\s*// *(final|var|setState|context|Navigator|return|if|for|while|class|@override|Widget|Future|void|String|int|bool)" lib`.

**Rationale:** dead code is read by every future maintainer, costs CI cache space, and creates ambiguity ("is this the new way or the old way?"). **Failure mode:** a junior copies an outdated `Navigator.push(... MaterialPageRoute(...))` from a comment and reintroduces the navigation paradigm the team is migrating away from.

---

## B. SOLID Principle Violations

### B1. Single Responsibility 🔴 [HIGH]

Every screen state class is a god class: it owns layout (`build()`), state (mutable fields), business logic (`fetch*`/`_submit*`), navigation (`context.goNamed`), persistence (`SharedPreferences.getInstance()` inline), and snackbar UX (`_showSnack`). Worst exemplar `SignUp3ScreenState` (`lib/auth/sign_up/signup3_screen.dart:63`) has 35 fields and ~120-line submission handler.

`ApiService` (`lib/service/api_service.dart`, 399 lines) is also SRP-violating: GET/POST/PUT/DELETE (`:46-114`), multipart with 3 variants (`:126-298`), URL composition (`:302-304`), token-header construction (`:28-44`), file-size logging side effects (`:350-357`). It does five jobs.

### B2. Open/Closed 🟠 [MEDIUM]

```dart
// lib/home/home_screen.dart:68-76
String getFilterValue() {
  if (selectedRange == "Week") return "this_week";
  else if (selectedRange == "Month") return "this_month";
  else return "this_year";
}
```
Adding a "Quarter" filter requires editing this method (and every comparable one in the screen). An `enum DashboardRange { week, month, year }` with a `toServerToken()` extension closes this.

### B3. Liskov 🟢

**Not applicable — this codebase has no inheritance hierarchies beyond Flutter's own (`extends StatefulWidget`, `extends State<T>`).** No `abstract class` definitions (`docs/AUDIT_ARCH.md` §D1).

### B4. Interface Segregation 🟢

**Not applicable — no fat abstract interfaces. (`docs/AUDIT_ARCH.md` §D1.)**

### B5. Dependency Inversion 🔴 [HIGH]

Cross-ref `docs/AUDIT_ARCH.md` §D1-D4. Every widget instantiates `ApiService()` directly — 58 sites. No injection seam. **Not repeated in detail here.**

---

## C. Duplication & Dead Code

### C1. Copy-pasted blocks 🔴 [HIGH]

See pre-analysis. The canonical example, in full:

```dart
// lib/main_screen.dart:50-87
Future<void> fetchprofiledata() async {
  try {
    debugPrint("🚀 API CALL STARTED");
    setState(() { isloading = true; });
    final rawResponse = await ApiService().postData(ApiEndpoints.profiledetails, {});
    debugPrint("📦 RAW RESPONSE 👉 $rawResponse");
    final response = Myprofilemodel.fromJson(rawResponse);
    if (response.error == false) {
      debugPrint("✅ API SUCCESS");
      debugPrint("👤 NAME 👉 ${response.data.user.name}");
      debugPrint("📧 EMAIL 👉 ${response.data.user.email}");
      debugPrint("🖼 IMAGE 👉 ${response.data.user.profileImageUrl}");
      setState(() { Myprofile_user = response.data; });
    } else {
      debugPrint("❌ API ERROR 👉 ${response.message}");
    }
  } catch (e) {
    debugPrint("❌ EXCEPTION 👉 $e");
  } finally {
    setState(() { isloading = false; });
    debugPrint("🏁 API CALL END");
  }
}
```
```dart
// lib/home/home_screen.dart:83-124   (same endpoint, same DTO, same target field — duplicated)
Future<void> fetchprofiledata() async {
  try {
    setState(() { isloading = true; });
    final rawResponse = await ApiService().postData(ApiEndpoints.profiledetails, {});
    debugPrint("📦 RAW API RESPONSE: $rawResponse");
    final response = Myprofilemodel.fromJson(rawResponse);
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
On every login, the user profile is fetched twice and stored on two separate widgets. Cross-ref `docs/AUDIT_STATE.md` §C1.

### C2. Unused public methods/classes 🟠 [MEDIUM]

- `lib/app/app.dart` — entire `App` class block-commented (`docs/AUDIT_ARCH.md` §A2).
- `lib/utility/Utils.dart:13` — `class Utils` entirely commented out, file kept around.
- `lib/app/durations.dart` (`AppDurations`), `lib/app/shadows.dart` (`AppShadows`) — **0** references (`docs/AUDIT_STRUCT.md` §C3).
- `lib/app/radii.dart` (`AppRadii`) — 1 reference; effectively dead.
- `lib/service/config.dart` (`AppConfig`) — legacy URL holder superseded by `Env` (`lib/config/env.dart`); spot-check shows no live consumer.

### C3. Unused imports 🟠 [MEDIUM]

Confirmed offender — `lib/home/home_screen.dart:18-21`:
```dart
import '../Model_Class/create_dashboard_details_model.dart' as dashboard;
import '../Model_Class/myprofile_model.dart' as profile;
// (blank)
import '../Model_Class/myprofile_model.dart';
```
The third import is `myprofile_model.dart` unaliased — the same file already imported aliased as `profile`. One of them is unused. Plus the duplicate `as dashboard` alias is suspect (already imported as `import '../model_class/create_dashboard_details_model.dart';` at `:13`).

`lib/auth/login/login.dart:7` — `import '../../main_screen.dart';` is only referenced inside a block-commented `Navigator.pushAndRemoveUntil` (`:115-119`). Unused in live code (`docs/AUDIT_ARCH.md` §E4).

Repo-wide unused-import detection requires `flutter analyze`. The two above are spot-confirmed.

### C4. Unreachable code, dead branches, impossible conditions 🟡 [LOW]

Spot-check did not surface obviously unreachable code (no `return; doStuff();` patterns observed in worst-3 files). **Not applicable — none observed in spot reads.** Recommend running `dart analyze --fatal-infos` once the bigger refactors land — it will surface anything missed.

---

## D. Dart / Flutter Best Practices

### D1. `dynamic` where typed alternative exists 🟠 [MEDIUM]

`grep -rnE "\bdynamic\b" lib | wc -l` → **97** references.

Most are `Map<String, dynamic>` in `fromJson` factories — unavoidable at the JSON boundary. But several occur in *consumer* code:

```dart
// lib/home/home_screen.dart:295-301
final isAvailable = value["available"] == true;
final isAssigned = value["projectAssigned"] == true;
```
`value` here is the inner of `Map<String, dynamic>`, so it's `dynamic`. Wrapping in a domain entity (`AvailabilityCell`) would eliminate the `dynamic` from screen code.

```dart
// lib/auth/login/login.dart:127-129
if (e is Map<String, dynamic>) {
  errorMessage = e["message"] ?? errorMessage;
}
```
`catch (e)` typed `Object?` (Dart default), then narrowed via `is Map<String, dynamic>`. The whole `_fetchLogin` error-parsing path is a `dynamic` smell — should be domain exceptions in `core/error/exceptions.dart`.

### D2. Forced `!` operator 🟠 [MEDIUM]

`grep -rnE "[a-zA-Z_]+!\." lib | wc -l` → **32** sites. Sampling:

```dart
// lib/auth/sign_up/signup3_screen.dart:230  (after null-check)
files["resume"] = [documentFile!];

// lib/Profile/myprofile.dart:262  (no preceding null-check in the snippet read)
NetworkImage("${ApiService.imageURL}${Myprofile_user!.profileImageUrl}"),
```
Some have preceding null-checks; some do not. The second site only guards `(Myprofile_user?.profileImageUrl ?? "").isNotEmpty` — and then re-accesses `Myprofile_user!.profileImageUrl` (the *same* nullable). If `Myprofile_user` is null, the conditional short-circuits via `?.`/`??`, but the bang on the next read trusts a re-evaluation of state that could change between frames. **A `local?.let { … }` style pattern (assign to non-nullable local) would be safer.**

### D3. Missing `@override` 🟢

Spot reads of `lib/home/home_screen.dart`, `lib/auth/login/login.dart`, `lib/Profile/myprofile.dart` show `@override` consistently applied to `build`, `initState`, `dispose`. **Not a project-wide issue.**

### D4. Missing `required` on named params 🟡 [LOW]

```dart
// lib/auth/sign_up/signup3_screen.dart:42-57
const SignUp3Screen({
  super.key,
  this.crewMemberId,
  this.profileImage,
  this.email,
  ...
  required this.step2Progress,
});
```
Only `step2Progress` is marked required, but the rest are semantically required for a successful step-3 submission (otherwise `_submit` builds an empty payload). **Not technically a violation** — the params are typed nullable — but indicates a missing precondition. A `SignupContext` value object would carry the invariant.

### D5. Mutable fields that should be `final` 🟠 [MEDIUM]

`grep -rnE "^\s+(int|bool|String|double) [a-z]+ = " lib | wc -l` → **41**. Most are state fields legitimately mutated by `setState`. A few are constants-disguised-as-fields:

```dart
// lib/auth/sign_up/signup3_screen.dart:111-115
final List<String> Portfoliolname  = [
  "Vimeo",
  "YouTube",
  "Google Drive",
];
```
`final` ✓ but should be `static const` (or, better, an enum). Same for `Portfolioicons` (`:117-125`) and `socialNames`/`socialIcons` (`:129-146`).

```dart
// lib/home/home_screen.dart:351
List<String> eventList = ["All Events", "Available", "Shoot"];
```
Missing `final`. The list never mutates.

### D6. Missing `const` constructors on stateless widgets 🟡 [LOW]

`const` is broad (1,438 sites). Spot offenders inside long `build()`s — many `Text(...)` / `SizedBox(...)` calls with all-literal arguments are not `const`. Turning on the `prefer_const_constructors` lint in `analysis_options.yaml` (currently uncustomised — map § Config surface) would surface them via `dart fix`.

### D7. String concatenation with `+` 🟢

`grep -rnE "\"[^\"]*\" \+ |' \+ [a-zA-Z]|[a-zA-Z]\) \+ \"" lib` → **0**. **Not applicable.** Project uses interpolation throughout.

### D8. Synchronous I/O on main thread 🟠 [MEDIUM]

Confirmed one site:
```dart
// lib/service/api_service.dart:350
final fileSize = imageFile.lengthSync();
```
Inside `postMultipart` (`:326+`). `.lengthSync()` blocks the platform thread. For a 5-10 MB profile photo upload, this is a sub-second blip; for larger files (recent_work uploads from `signup3`), it's perceptible jank. Replace with `await imageFile.length()`.

### D9. Outdated patterns 🟢

`grep -rn "WillPopScope" lib` → 0. `grep -rn "RaisedButton\|FlatButton\|OutlineButton" lib` → 0. **Not applicable — codebase uses current APIs.**

### D10. `await` missing before returned Future 🟡 [LOW]

Spot heuristic `grep -rnE "^\s*return [a-zA-Z_]+\([^;]+\);" lib` surfaces `return DateFormat(...).format(parsedDate);` (`upcoming_shoot_view_detils.dart:37`) and similar — these return sync values, not futures, so OK. No genuine "returned Future without await" pattern observed in spot reads.

### D11. Empty `catch {}` or `catch` only with `print` 🔴 [HIGH]

Confirmed sites of empty catches:
```dart
// lib/auth/login/login.dart:140
} catch (_) {}
```
```dart
// lib/manageavailability/add_availability_screen.dart:374
} catch (_) {}
```
```dart
// lib/shoots/shoots_screen.dart:88-90
} on Exception catch (e) {

}
```
Plus 43 `catch` blocks whose only body is `debugPrint`/`print` (heuristic count). Pattern:
```dart
// lib/home/home_screen.dart:204-207  (representative)
} catch (e) {
  debugPrint("Error is:::::$e");
}
```
**Rationale:** error swallowing makes UI silently fail (`docs/AUDIT_STATE.md` §C2/C9). **Failure mode:** the screen stays in `isLoading=true` (the `finally`-`setState`-`false` lives in some, not others) or shows initial-state zeros forever. **Why juniors do this:** Dart forces `try`/`catch` only on functions that declare `throws`, and the cookbook pattern `try{await foo}catch(e){debugPrint(e)}` is *the* idiom every newcomer copies.

---

## E. Widget Design

### E1. Widgets handling layout + business logic + state together 🔴 [HIGH]

Cross-ref `docs/AUDIT_ARCH.md` §C1, `docs/AUDIT_STATE.md` §B1. Same finding under a different rubric: SRP at the widget level. No new evidence beyond the worst-3 hotspots.

### E2. Repeated widget subtrees (>2 occurrences) not extracted 🟠 [MEDIUM]

```dart
// lib/main_screen.dart:213-307   (drawer profile section)
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFD6B98C),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: [
      CircleAvatar(radius: 25, backgroundImage: ...),
      const SizedBox(width: 12),
      Expanded(child: Column(...)),
      const Icon(Icons.arrow_forward_ios, size: 16, color: ColorCode.black),
    ],
  ),
)
```
A "profile pill" pattern. Spot-checking `lib/home/home_screen.dart` shows comparable `CircleAvatar` + `Row` + name/email + chevron subtrees in the upcoming shoots card and the team-members chip area. Extracting `ProfilePill({avatar, title, subtitle, trailing})` would eliminate 3+ inline duplicates.

The same applies to: the "stat tile" pattern (dashboard counters in `home_screen`), the "section header with arrow" (used in `myprofile.dart` + `home_screen.dart`), and the "file picker tile with dotted border" (used in `signup3_screen` + `myprofile.dart` + `featured_work_list.dart`).

`lib/widgets/` already exists (`docs/AUDIT_STRUCT.md` §C1) — these would live there.

### E3. StatefulWidget used where StatelessWidget suffices 🟠 [MEDIUM]

`grep -rn "extends StatefulWidget" lib | wc -l` → **41** vs `extends StatelessWidget` → **5**. The ratio is too lopsided to be correct; spot-check:

```dart
// lib/widgets/new_Textfield.dart:6  (CustomInputField — defined as StatefulWidget)
class CustomInputField extends StatefulWidget {
  ...
}
class _CustomInputFieldState extends State<CustomInputField> {
  ...
}
```
A custom input wrapper that exposes `controller`, `hint`, `obscureText` is **stateless** unless it owns the text controller (it usually doesn't — callers pass a `TextEditingController`). Spot-check via `lib/widgets/new_Textfield.dart:41` shows the state class likely toggles obscure-on-eye-tap — that *is* state, so `StatefulWidget` is correct here. But the broad ratio still indicates many cargo-cult `StatefulWidget`s. Run `dart analyze` with `use_key_in_widget_constructors` + `prefer_stateless_widgets` to surface the rest.

### E4. `BuildContext` after async gap without `if (!mounted) return` 🔴 [HIGH]

Same finding as `docs/AUDIT_STATE.md` §C2. Re-emphasised from a code-quality lens: the analyzer's `use_build_context_synchronously` lint is included in `flutter_lints`. It would surface every offender. The lint is silently being ignored because the only `analysis_options.yaml` rules block is empty (`docs/AUDIT_MAP.md` § Config surface).

### E5. `setState()` in async callback without `mounted` 🔴 [HIGH]

See `docs/AUDIT_STATE.md` §C2. 266 `setState` calls / 35 `mounted` references / **~87% unguarded**.

---

## Findings (severity order)

🔴 HIGH

- Eight `.dart` files over 1,000 lines (worst 3,465). `build()` methods exceeding 60 lines: *every* screen file. (A1, A2, E1)
- 60+ multiline commented-out code blocks plus 104 single-line dead-Dart-code lines, concentrated in `home_screen.dart`, `main_screen.dart`, `onboding_screen.dart`. (A7)
- Empty `catch {}` blocks (3 confirmed); 43 catch-only-print blocks; UI silently shows initial state on any failure. (D11)
- `fetchprofiledata` duplicated verbatim across `main_screen.dart:50-87` and `home_screen.dart:83-124`. (C1)
- Inline email + plus-code regex duplicated across login + sign-up + profile edit. (C1)
- 58 direct `ApiService()` instantiations from widget state classes. (B5)
- `setState` after `await` without `mounted` — ~87% of 266 sites. (E4, E5)

🟠 MEDIUM

- 60–120-line non-build functions (`_fetchLogin`, `_submit`, photo upload). (A1)
- Magic strings everywhere; no `AppStrings`; i18n impossible without rewriting widget bodies. (A4)
- Magic numbers everywhere; `AppDurations`/`AppShadows`/`AppRadii` exist but dead. (A5)
- Repeated widget subtrees not extracted (profile pill, stat tile, file picker tile). (E2)
- 32 forced `!` operator usages; some after stale null-checks. (D2)
- 97 `dynamic` references; many in consumer code where a domain entity would type-narrow. (D1)
- Cyclomatic-complex error-parsing branch in `_fetchLogin`. (A3)
- Unused imports / dead alias imports in `home_screen.dart:18-21`. (C3)
- `lengthSync()` on the platform thread before multipart upload. (D8)
- Open/Closed violation in `getFilterValue()` (`if/else if/else` over magic strings). (B2)
- `Portfoliolname`/`socialNames` declared `final` instead of `static const`. (D5)
- Lopsided `StatefulWidget:StatelessWidget` ratio (41:5). (E3)

🟡 LOW

- One legitimate `// TODO` in the entire codebase. (A6)
- A few literals that could be `const`. (D6)
- Lint `analysis_options.yaml` is upstream-only — no `prefer_const_constructors`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print` customisation. (Map § Config surface)
- `Utils.dart` and `service/config.dart` kept as legacy dead files. (C2)
- Filename anomalies and casing (covered fully in `docs/AUDIT_STRUCT.md` §B1).

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Eliminate empty / print-only catch blocks; introduce a single `try`-`catch` wrapper that surfaces `AsyncValue.error` (or sets a `_lastError` state).** *Effort: 1 dev-day for the wrapper + sweep.* *Impact:* removes the three confirmed empty-catch sites and the 43 print-only catches that today leave the UI silently broken. Cross-fix for `docs/AUDIT_STATE.md` §C9.

2. 🔴 **Delete commented-out code in bulk.** *Effort: 1 dev-hour with grep + manual review (the 10+ blocks in `home_screen.dart` alone account for hundreds of lines).* *Impact:* reduces the worst-3 hotspot files' apparent complexity, removes the "is this the new way?" confusion, and lets future audits trust `wc -l`.

3. 🔴 **Replace all 242 `debugPrint`/`print` calls with a single `AppLogger` (or `package:logger`) wrapped behind a no-op in release builds.** *Effort: 1 dev-day mechanical pass.* *Impact:* stops API payload + token leakage in production logs (`fetchprofiledata` prints `name`, `email`, `profileImageUrl`; `api_service.dart` prints `headers` including `Authorization: Bearer $token` at `:601`). Enables the `avoid_print` lint to fail CI.

4. 🟠 **Extract the `fetchprofiledata` duplicate, the inline email/plus-code regexes, and the inline `DateFormat` helpers into `core/format/` and `core/validation/` + a single `currentUserProvider`.** *Effort: 1 dev-day (combines with `docs/AUDIT_STATE.md` Top-fix #4).* *Impact:* removes 3 of the 4 most-duplicated blocks; the fourth (the `try / await ApiService() / setState / catch debugPrint / finally setState` skeleton) goes away naturally when the controller layer lands.

5. 🟠 **Turn on `prefer_const_constructors`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print`, `prefer_final_fields`, `unnecessary_const` in `analysis_options.yaml`; run `dart fix --apply`.** *Effort: 30 minutes to enable + ~half a dev-day to triage the fallout.* *Impact:* CI surfaces every existing `setState` after `await` without `mounted`, every stale `final` candidate, every `print()`, and every `Text(...)` that could be `const`. Locks in subsequent fixes.

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and the audit triad `docs/AUDIT_ARCH.md` / `docs/AUDIT_STATE.md` / `docs/AUDIT_STRUCT.md`. All `.md` artefacts under `docs/` per project rule.*
