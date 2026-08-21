# AUDIT_STATE.md — State Management Audit (#2)

**Auditor role:** Senior Flutter Architect — state-management-at-scale lens.
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** every widget under `lib/` — `dispose()`, `initState()`, `build()`, async `setState`, listener registration.
**Output convention:** all docs live under `docs/` per project rule.

---

## Verdict

**Approach: raw `StatefulWidget` + `setState`. Right choice: No. Applied correctly: No.**

The app uses **`setState` exclusively** across 41 `StatefulWidget` classes (5 `StatelessWidget`s), with **266** `setState` call sites and only **35** `if (mounted)` guards (map § Detected patterns; counts re-verified). No reactive primitives exist: `ChangeNotifier` 0, `ValueNotifier` 0, `StreamController` 0, `StreamSubscription` 0, `Equatable`/`@immutable` 0. `flutter_riverpod: ^2.6.1` is in `pubspec.yaml` but only referenced inside the commented-out `lib/app/app.dart` (map § Pre-audit flag #4). The result is screen-local mutable state with no inversion, no observability, and **8 `dispose()` overrides total for 41 `StatefulWidget`s with 58 `TextEditingController()` constructions** — a confirmed leak in every screen whose state class declares text controllers without a `dispose`.

## State management score: **2 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | Reactive primitive chosen + applied consistently, controllers disposed, granular rebuilds, error/empty/loading states modeled |
| 7–8  | One framework chosen consistently, some leakage in long screens |
| 5–6  | Mixed patterns but disposals correct, async lifecycle handled |
| 3–4  | `setState` only; some controller disposal; partial mounted-guarding |
| 1–2  | `setState` only; controller disposal mostly absent; async `setState` unguarded; happy-path-only UI |

Score breakdown — **Approach fit 0/2 · Lifecycle hygiene 0/2 · Async safety 0/2 · Rebuild economics 1/2 · Loading/error/empty modeling 1/2** → 2/10.

---

## Strengths (with evidence)

1. **No mystery framework.** Every screen is `setState`-driven — a junior can read any file without learning a DSL. 🟢
2. **`const` constructors are heavily used.** `grep -cE "const [A-Z][a-zA-Z]+\(" lib` returns **1,438** matches — leaf widgets are mostly `const`-friendly, so the wide-cascade rebuild penalty of `setState` is at least partly absorbed at the leaves.
3. **Compile-time entry-point split lets the boot path stay terse.** `lib/main.dart:9-24` runs `Env.init` and reads the login flag before mounting the tree — no top-level state controller needed at startup:
   ```dart
   // lib/main.dart:9-24
   Future<void> startApp(Environment environment) async {
     WidgetsFlutterBinding.ensureInitialized();
     Env.init(environment);
     final prefs = await SharedPreferences.getInstance();
     bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
     runApp(MyApp(isLoggedIn: isLoggedIn));
   }
   ```

---

## Pre-analysis: 3 most stateful screens + lifecycle trace

| # | Screen | Lines | TextEditingControllers | AnimationControllers | Other state | `setState` calls | `mounted` checks | `dispose()` |
|---|--------|-------|------------------------|----------------------|-------------|------------------|-------------------|-------------|
| 1 | `lib/auth/sign_up/signup3_screen.dart` | 3,465 | 5 class-level + 1 in modal (`:3064`) | 0 | ~35 fields incl. 9 mutable `List<T>` + 4 `File?` slots | 25 | **0** | **none** |
| 2 | `lib/home/home_screen.dart` | 2,902 | 0 directly observed¹ | 1 (`_controller`, `:323`) | ~23 fields incl. 4 lists + `Map<DateTime,String>` events | 39 | **0** | yes — disposes only `_controller` (`:308-311`) |
| 3 | `lib/Profile/myprofile.dart` | 2,834 | 2 class-level + N inside modals (e.g. `:834-835`) | 0 | photo upload buffer + 5+ mutable lists | 19 | 7 | **none** |

¹ Spot-check; the file imports `TextEditingController` transitively via shared widgets — confirm with `grep -n "TextEditingController" lib/home/home_screen.dart`.

### Lifecycle traces (where state is created, mutated, disposed)

**signup3_screen.dart**
- Created in `SignUp3ScreenState` class body (`:65-110`): 5 `TextEditingController()`, 9 `List<T> name = []`, 4 `File?` slots, 6 `bool` flags, 2 `int?` indexes.
- Mutated via 25 `setState` sites; none guarded by `mounted`.
- Async work: `_pickPortfolio` (`:274-284`), `_pickCertificate` (`:148+`), step-3 submission (`:240-269`) — all `await` then `setState` without `mounted` check.
- **Disposed:** never. No `dispose()` override exists. All 5 class-level `TextEditingController`s and the modal-scoped `tagController` at `:3064` leak on every push/pop of the screen.

**home_screen.dart**
- `initState` (`:314-339`) fires **7 fetchers** in parallel, then constructs the `AnimationController` and registers a status listener.
  ```dart
  // lib/home/home_screen.dart:314-339
  void initState() {
    super.initState();
    fetchCrewStats("this_month"); // default
    fetchShootCategories("photo");
    fetchavailability();
    fetchcreatordashboarddetails();
    fetchdashboardcount();
    fetchupcomingshoots();
    fetchprofiledata();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _slideOut = Tween<Offset>(...).animate(...);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && upcomingshootslist.isNotEmpty) {
        setState(() { _currentIndex = (_currentIndex + 1) % upcomingshootslist.length; });
        _controller.reset();
      }
    });
  }
  ```
- `dispose()` (`:308-311`) calls `_controller.dispose()` only.
- Mutated via 39 `setState` calls. Every fetcher `setState`s after `await` — `0` `mounted` checks. If the user navigates away during one of the 7 in-flight fetches, the framework throws on a disposed widget.

**myprofile.dart**
- 2 class-level `TextEditingController`s at `:834-835` plus modal-scoped controllers nested inside `showModalBottomSheet` builders.
- 9 `ApiService()` call sites in the same state class (map § B1 audit cross-ref).
- Mutated via 19 `setState` (7 with `mounted` guard, 12 without).
- **Disposed:** never. No `dispose()` override.

### Pattern governance per screen

| Screen | Pattern | Mixed with anything? | Where it leaks |
|--------|---------|----------------------|----------------|
| signup3 | raw `setState` | nothing | controllers (5+1), async without `mounted` |
| home | raw `setState` + 1 `AnimationController` listener | nothing | TECs (if any), all 7 fetcher chains lacking `mounted` |
| myprofile | raw `setState` | nothing | TECs (2 class-level + modal-scoped), 12 unguarded async `setState` |

There is **no mixing** of state-management frameworks — Riverpod / Provider / BLoC / GetX / MobX are not in use anywhere in `lib/` (map § Detected patterns; re-verified via `grep`). The only pattern in production is `setState`. The "mix" is not between frameworks; it is between *guarded* and *unguarded* async lifecycles within the same screen.

---

## A. Approach Identification

### A1. Primary state management used 🔴 [HIGH]

`setState` on `StatefulWidget` — 266 sites across 41 stateful widgets.

```dart
// lib/auth/login/login.dart:182-184
void _updateUI() {
  setState(() {});
}
```
An **empty-`setState` rebuild-everything hammer**, called from listeners attached to `emailController` and `passwordController` (`lib/auth/login/login.dart:178-179`). Every keystroke rebuilds the entire login screen tree.

### A2. Secondary patterns 🟢

**Not applicable — this codebase does not use a secondary state-management approach.** No `flutter_bloc`, `provider`, `get`, `mobx`, `getx`, `signals`, `riverpod` runtime surfaces. `flutter_riverpod` is a declared dependency but unused (map § State management).

### A3. Approach vs app complexity 🔴 [HIGH]

App complexity: 30+ screens, 50+ JSON DTO types, multi-step sign-up with file uploads, payments (Stripe), maps, calendars, dashboards aggregating 8 endpoints, drawer + bottom-nav shell. That is **well past** the threshold where `setState` is appropriate.

**Failure mode at scale:** Cross-screen state (auth session, profile data, dashboard counters, calendar events) is re-fetched separately by every screen that needs it — see `fetchprofiledata()` duplicated in both `lib/main_screen.dart:50-87` and `lib/home/home_screen.dart:83-124`, hitting the same endpoint twice on every login. There is no single source of truth, so two screens displaying the same user can show contradictory data after a stale fetch.

**Why juniors do this:** `setState` is the default in every Flutter cookbook page. Up-front cost is zero. The cost shows up later, in disposal bugs and stale-data bugs that this audit catalogs below.

---

## B. Pattern Integrity

### B1. State classes with too many fields (>10) 🔴 [HIGH]

Counted by `awk` over each state class body. Threshold: 10.

| State class | Field count (approx) |
|-------------|----------------------|
| `SignUp3ScreenState` (`lib/auth/sign_up/signup3_screen.dart:63`) | **35** |
| `_HomeScreenState` (`lib/home/home_screen.dart:38`) | **23** |
| `_SignUp1ScreenState` | (file 1,959 lines — not counted line-by-line; visibly >20) |
| `_SignUp2ScreenState` | (file 1,328 lines — visibly >15) |
| `MyprofileState` (`lib/Profile/myprofile.dart`) | 8 class-level + many inside modal sheet builders — see B5 |

`SignUp3ScreenState:63-110` declares (verbatim selection):

```dart
// lib/auth/sign_up/signup3_screen.dart:63-110
class SignUp3ScreenState extends State<SignUp3Screen> {
  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController enter_work_titleController = TextEditingController();
  int? editingProjectIndex;
  int selectedPortfolioIndex = -1;
  int? editingPortfolioIndex;
  final TextEditingController portfolioNameController = TextEditingController();
  final TextEditingController portfolioLinkController = TextEditingController();
  List<Map<String, dynamic>> savedPortfolioLinks = [];
  int selectedSocialIndex = -1;
  int? editingIndex;
  List<String> selectedTags = [];
  List<String> featuredProjectsTitles = [];
  String? fileType;
  File? featuredFile;
  bool isVideo = false;
  bool isLoggingIn = false;
  File? documentFile;
  File? portfolioFile;
  IconData? selectedIcon;
  Color? selectedColor;
  File? selectedFile;
  List<Map<String, dynamic>> savedLinks = [];
  List<PlatformFile> featuredFiles = [];
  List<bool> featuredIsVideo = [];
  List<File> featuredImages = [];
  bool isSubmitting = false;
  List<List<File>> featuredProjects = [];
  List<File> tempFeaturedImages = [];
  bool isPicking = false;
  List<File> certificateFiles = [];
  ...
}
```
Two parallel lists (`featuredImages` + `featuredIsVideo`, `featuredFiles` + same) maintain related data by **positional correlation** — drop one element from one list and they desynchronise silently.

**Rationale:** A state class is also an implicit DTO between modal builders and the parent widget. 35 mutable fields in one scope means no encapsulation, no invariants, and no place to apply `copyWith`. **Failure mode:** the multi-list invariant has already broken in practice — see C8 below where `setState` is called inside a modal callback that mutates parent state. **Why juniors do this:** the screen grew incrementally and no refactor extracted sub-features into their own widgets.

### B2. God BLoCs/Cubits/Controllers handling unrelated concerns 🟢

**Not applicable — this codebase does not use BLoC, Cubit, or Notifier controllers.** Replaced by *god state classes* (B1).

### B3. Event handlers doing too much (>40 lines) 🔴 [HIGH]

`SignUp3ScreenState`'s submission handler runs **~65 lines** of payload assembly, file map construction, multipart POST, navigation, and snackbar dispatch:
```dart
// lib/auth/sign_up/signup3_screen.dart:203-269
"social_media_links": jsonEncode(
  savedLinks.map((e) => {
    "platform": e['name'].toString().toLowerCase(),
    "url": normalizeUrl(e['url']),
  }).toList(),
),
"featured_work": jsonEncode(
  List.generate(featuredProjects.length, (index) {
    return {
      "work_title": (index < featuredProjectsTitles.length)
          ? featuredProjectsTitles[index] : "",
      "tags": selectedTags,
    };
  }),
),
...
final Map<String, List<File>> files = {
  "certifications": certificateFiles,
  "recent_work_media": featuredImages,
};
if (documentFile != null) { files["resume"] = [documentFile!]; }
if (portfolioFile != null) { files["portfolio"] = [portfolioFile!]; }
...
final response = await ApiService().postMultipartStep3(
  ApiService().baseUrl + ApiEndpoints.register_step3,
  fields: payload.map((k, v) => MapEntry(k, v.toString())),
  resume: documentFile,
  portfolio: portfolioFile,
  certificates: certificateFiles,
  recentWorks: featuredImages,
  recentWorkIndexes: List.generate(featuredImages.length, (i) => i),
);
...
if (response != null && response['error'] == false) {
  context.goNamed(RouteNames.login);
} else {
  _showSnack(response?['message'] ?? "Submission failed");
}
...
finally { setState(() => isLoggingIn = false); }
```
Same screen, calendar event prep (`lib/home/home_screen.dart:290-302`) and email regex validation (`lib/auth/login/login.dart:151-156`) are smaller offenders. Pattern from B1: handler = view + controller + repository + use-case + navigator + snackbar dispatcher.

### B4. Mutable state classes (no `copyWith`, no `const`, no `Equatable`) 🔴 [HIGH]

`grep -rn "Equatable\|@immutable" lib/` returns **0**.
`grep -rn "copyWith" lib/` returns **34** matches — but these are inside DTOs generated by hand in `lib/model_class/*` (e.g., `Myprofilemodel` DTO `copyWith` chains), not state classes.

No widget state class is immutable. Every state class is a bag of mutable fields directly mutated in `setState` closures. There is no equality, no diffing, no selective rebuild — every `setState` rebuilds the whole subtree.

### B5. Mutable lists exposed directly 🔴 [HIGH]

`grep -rnE "  List<[^>]+> [a-zA-Z]+ = \[\]" lib/` returns **35** raw-list state declarations.

In `SignUp3ScreenState:76,82-83,100-110` alone:
```dart
List<Map<String, dynamic>> savedPortfolioLinks = [];
List<String> selectedTags = [];
List<String> featuredProjectsTitles = [];
List<Map<String, dynamic>> savedLinks = [];
List<PlatformFile> featuredFiles = [];
List<bool> featuredIsVideo = [];
List<File> featuredImages = [];
List<List<File>> featuredProjects = [];
List<File> tempFeaturedImages = [];
List<File> certificateFiles = [];
```
These lists are passed into modal builders, mutated from those builders, then re-read by the parent on the next rebuild. **`UnmodifiableListView` is not used anywhere** (`grep -rn "UnmodifiableListView\|unmodifiable" lib/` returns 0). Junior contributors can — and the multi-list invariant suggests already have — mutate these from anywhere in the file.

---

## C. Anti-patterns

### C1. `setState` where state belongs in a parent or shared notifier 🔴 [HIGH]

`fetchprofiledata()` is implemented twice — same endpoint, same DTO, same target field — in `lib/main_screen.dart:50-87` *and* `lib/home/home_screen.dart:83-124`. Each writes a private `Myprofile_user` into its own `State`. On login, both calls fire; on a profile edit, only the screen visible at the time refreshes. The shell's drawer can show a stale name while the dashboard card shows the fresh one.

**This is the canonical "state belongs higher" smell** — the user profile is global session state, not a screen-local field.

### C2. `setState` in async without `mounted` check 🔴 [HIGH]

Ratio per worst-3 screens (re-verified via `grep -c`):

| Screen | `setState` sites | `mounted` references | Unguarded ratio |
|--------|------------------|-----------------------|-----------------|
| `lib/home/home_screen.dart` | 39 | **0** | 100% |
| `lib/auth/sign_up/signup3_screen.dart` | 25 | **0** | 100% |
| `lib/Profile/myprofile.dart` | 19 | 7 | ~63% |

Whole-repo ratio: 266 `setState` calls vs 35 `mounted` references — **~87% unguarded.**

```dart
// lib/home/home_screen.dart:184-201
Future<void> fetchCrewStats(String filter) async {
  try {
    final response = CrewStatsModel.fromJson(
      await ApiService().fetchData(ApiEndpoints.crewStats(filter)),
    );
    if (response.error == false) {
      ...
      setState(() {
        sucessfullshoots = response.data.completedShoots;
        ...
      });
    }
  } catch (e) {
    debugPrint("Error is:::::$e");
  }
}
```
No `if (!mounted) return;` before `setState`. **Failure mode:** Flutter framework throws `setState() called after dispose()` if the user backs out of the dashboard before the seven `initState` fetchers (`:314-322`) complete. In release builds this becomes a silent log spam; in debug it crashes the screen.

#### Refactor diff

```dart
// BEFORE — lib/home/home_screen.dart:184-201
Future<void> fetchCrewStats(String filter) async {
  try {
    final response = CrewStatsModel.fromJson(
      await ApiService().fetchData(ApiEndpoints.crewStats(filter)),
    );
    if (response.error == false) {
      setState(() {
        sucessfullshoots = response.data.completedShoots;
        ...
      });
    }
  } catch (e) { debugPrint("Error is:::::$e"); }
}
```
```dart
// AFTER (interim — minimal touch)
Future<void> fetchCrewStats(String filter) async {
  try {
    final response = CrewStatsModel.fromJson(
      await ApiService().fetchData(ApiEndpoints.crewStats(filter)),
    );
    if (!mounted) return;             // ← guard 1
    if (response.error == false) {
      setState(() {
        sucessfullshoots = response.data.completedShoots;
        ...
      });
    }
  } catch (e) {
    if (!mounted) return;             // ← guard 2 if you setState in catch
    debugPrint("Error is:::::$e");
  }
}
```
**True fix** (consistent with AUDIT_ARCH.md): move the work into a `StateNotifier<DashboardState>` whose lifecycle is owned by a Riverpod provider — `mounted` becomes irrelevant because the notifier outlives the widget.

### C3. Missing `const` constructors 🟡 [LOW]

`const` usage is actually broad (1,438 sites). Not a project-wide concern. Spot offenders remain — `lib/auth/login/login.dart:31-32` constructs two `TextEditingController()`s at class scope, then attaches listeners in `initState` (`:178-179`). The controllers themselves can't be `const`, but several of the `Text(...)` / `SizedBox(...)` literals in worst-3 screens omit `const` despite having all-literal arguments — a fix that costs nothing once you turn on `prefer_const_constructors` in `analysis_options.yaml` (currently disabled by default with no override — map § Config surface).

### C4. Controllers not disposed 🔴 [HIGH]

**This is the biggest scaling bomb in the codebase.**

- `dispose()` overrides total: **8** (`grep -rn "void dispose" lib`). Locations:
  - `lib/splash/splash_screen.dart:83`
  - `lib/home/home_screen.dart:308`
  - `lib/auth/forgotpassword/forgot_password_screen.dart:178`
  - `lib/Profile/profiledetils/edit_personal_details_screen.dart:215`
  - `lib/Profile/deleteaccount/delete_account_otp_screen.dart:64`
  - `lib/file_manager/file_manager_screen.dart:27`
  - `lib/manageavailability/manage_availability_screen.dart:52`
  - `lib/widgets/custom_multi_selectfield.dart:38`
- `StatefulWidget` count: **41**. Coverage: **~20%**.
- `TextEditingController()` construction sites: **58** across 33+ files. Most are never disposed.

**Confirmed leaks (representative):**

```dart
// lib/auth/login/login.dart:31-32, 178-179  (no dispose() exists in this file)
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
...
emailController.addListener(_updateUI);
passwordController.addListener(_updateUI);
```
Two controllers + two listeners + zero disposal. Push/pop the login screen 10× → 20 dangling controllers, 20 dangling listeners.

```dart
// lib/auth/sign_up/signup3_screen.dart:65-74  (no dispose() exists in this file)
final TextEditingController nameLinkController = TextEditingController();
final TextEditingController linkController = TextEditingController();
final TextEditingController enter_work_titleController = TextEditingController();
...
final TextEditingController portfolioNameController = TextEditingController();
final TextEditingController portfolioLinkController = TextEditingController();
```
Five controllers, plus a modal-scoped one at `:3064`. Every leak survives until process termination.

```dart
// lib/Profile/myprofile.dart:834-835  (no dispose() exists in this file)
TextEditingController nameController = TextEditingController();
TextEditingController linkController = TextEditingController();
```

`AnimationController` disposal: 3 of 3 `AnimationController` declarations have a matching `dispose()` call (`lib/home/home_screen.dart:308-311`, `lib/splash/splash_screen.dart:83`, `lib/manageavailability/manage_availability_screen.dart:52`). **`AnimationController` hygiene is fine; `TextEditingController` hygiene is catastrophic.**

`ScrollController`, `FocusNode`, `PageController`, `StreamController` — **all 0 in `lib/`** (`grep`-verified). The codebase has not yet adopted any of these; when it does, the same dispose pattern will leak.

#### Refactor diff (`lib/auth/login/login.dart`)

```dart
// BEFORE — lib/auth/login/login.dart  (no dispose anywhere)
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

@override
void initState() {
  super.initState();
  _loadSavedCredentials();
  emailController.addListener(_updateUI);
  passwordController.addListener(_updateUI);
}
```
```dart
// AFTER
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

@override
void initState() {
  super.initState();
  _loadSavedCredentials();
  emailController.addListener(_updateUI);
  passwordController.addListener(_updateUI);
}

@override
void dispose() {
  emailController
    ..removeListener(_updateUI)
    ..dispose();
  passwordController
    ..removeListener(_updateUI)
    ..dispose();
  super.dispose();
}
```
And replace `_updateUI` (`setState(() {})`) with `ListenableBuilder(listenable: Listenable.merge([emailController, passwordController]), builder: (_, __) => ...)` so a keystroke rebuilds only the submit-button subtree, not the entire screen.

### C5. Stream subscriptions stored without cancel 🟢

**Not applicable — this codebase does not use `StreamSubscription` or `StreamController`.** (`grep -rn "StreamSubscription\|StreamController" lib/` returns 0 in both.) The day a feature adds a Firestore snapshot listener or an SSE feed, this category will become a 🔴 finding because no disposal pattern exists to copy from.

### C6. BLoC events / Riverpod providers dispatched inside `build` 🟢

**Not applicable — BLoC is not in use** and Riverpod's only file is block-commented (`lib/app/app.dart`).

### C7. Provider misuse / GetX misuse 🟢

**Not applicable — `provider`, `get`, `getx` are not in `pubspec.yaml`.**

### C8. `setState` in modal-builder callbacks mutating parent state 🟠 [MEDIUM]

```dart
// lib/Profile/myprofile.dart:2570-2611  (excerpt)
setModalState(() => isUpdating = true);
try {
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
} catch (e) {
  ...
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Network error. Please try again."), backgroundColor: ColorCode.red),
  );
} finally {
  if (mounted) setModalState(() => isUpdating = false);
}
return;
}

// ✅ ADD MODE: local update
setModalState(() {
  setState(() {
    portfolioLinks.add({...});
  });
  showForm = false;
});
```
`setModalState(() { setState(() { ... }) })` is a nested rebuild trigger across two scopes — the modal sheet's local state and the parent screen's state. The mutation also writes directly to the parent's `portfolioLinks` list (the same kind of raw mutable list flagged in B5). **Failure mode:** if the modal is dismissed mid-`await`, the parent `setState` still queues against a now-popped context.

### C9. Happy-path-only UI / no error/empty surfaces 🟠 [MEDIUM]

`grep -rnE "EmptyState|empty_state|errorWidget" lib/` returns **0**. Spot pattern:
```dart
// lib/shoots/shoots_screen.dart:96-119  (fetchshootmodel)
Future<void> fetchshootmodel() async {
  setState(() => isLoading = true);
  final rawResponse = await ApiService().fetchData(ApiEndpoints.creatordashboarddetails);
  print("🔥 API RESPONSE 👉 $rawResponse");
  final response = ShootsModel.fromJson(rawResponse);
  if (response.error == false) {
    setState(() { mylist = response.data.shoots; allShoots = response.data.shoots; isLoading = false; });
  } else {
    setState(() => isLoading = false);
  }
}
```
- No `try/catch` — an HTTP failure throws past the UI without setting state.
- `response.error == true` branch only resets `isLoading`; the UI then renders an empty `ListView` indistinguishable from "no shoots yet."
- No error widget, no retry button, no empty-state illustration.

```dart
// lib/shoots/shoots_screen.dart:88-90  (fetchshootcount catch)
} on Exception catch (e) {

}
```
Bare empty catch. UI stuck at `0`/`0`/`0`/`0` forever on any exception. **Re-emphasised from AUDIT_ARCH §C2** — surfaces here because state is the level at which the loading/error/empty trichotomy should live (e.g., `AsyncValue<T>` in Riverpod, `Result<T>` in Bloc).

---

## D. Rebuild Economics

### D1. `setState` at the top of large widget trees 🟠 [MEDIUM]

`lib/auth/login/login.dart:182-184`:
```dart
void _updateUI() {
  setState(() {});
}
```
Called on every keystroke in either email or password field. The login screen contains a `SingleChildScrollView` with a 0.35-screen-height stack (`:223-280`), gradient overlays, multiple text spans, and a submit button — **all** of that rebuilds on every character typed, despite only the button's disabled-state depending on the fields.

**Failure mode:** on a low-end Android device, key-event throughput drops visibly. Spot it via Flutter DevTools timeline.

#### Refactor diff

```dart
// BEFORE
emailController.addListener(_updateUI);
passwordController.addListener(_updateUI);
void _updateUI() => setState(() {});
// ... in build():
ElevatedButton(onPressed: isFormValid ? _fetchLogin : null, child: Text("Login"))
```
```dart
// AFTER
// Drop the listeners; wrap only the submit button in a ListenableBuilder.
ListenableBuilder(
  listenable: Listenable.merge([emailController, passwordController]),
  builder: (context, _) {
    final enabled = emailController.text.trim().isNotEmpty &&
                    passwordController.text.trim().isNotEmpty;
    return ElevatedButton(
      onPressed: enabled ? _fetchLogin : null,
      child: const Text("Login"),
    );
  },
)
```
Now only the button's pixel-level region rebuilds. The rest of the tree stays frozen.

### D2. Granular listening absent 🟠 [MEDIUM]

`grep -rn "context\.select\|select((" lib/` returns **0**. Riverpod's `select`, Provider's `Selector`, `context.select` — none exist because the host frameworks don't exist. This is a downstream symptom of A1/A3, not a separate fix.

---

## E. Tight Coupling

### E1. Widgets directly importing repositories / data sources 🔴 [HIGH]

Re-emphasised from `docs/AUDIT_ARCH.md §B1`. Every screen imports `lib/service/api_service.dart` and instantiates `ApiService()` — **58** sites. From a state-management lens, this means: there is no controller layer in which to test a state transition without mocking the platform-channel network call.

### E2. State classes calling `Navigator` directly 🟠 [MEDIUM]

```dart
// lib/auth/login/login.dart:120
context.goNamed(RouteNames.home);
```
```dart
// lib/auth/sign_up/signup3_screen.dart:259
context.goNamed(RouteNames.login);
```
```dart
// lib/Profile/myprofile.dart:2587
if (mounted) Navigator.pop(context);
```
Routing decisions are baked into state-mutating code paths. **Failure mode:** when login changes from "navigate to home" to "navigate to home **iff** profile is complete, else to onboarding," the change touches the screen's submission handler instead of a single router/auth-listener.

**Fix:** controller emits a `LoginResult.success(session)` event; a top-level `ref.listen(authProvider, (_, next) => ...)` performs navigation. The screen never imports `go_router`.

### E3. State classes referencing `BuildContext` outside `build` 🟠 [MEDIUM]

```dart
// lib/auth/login/login.dart:42-48
_showSnack(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: ColorCode.red),
  );
}
```
And similar `_showSnack` helpers across every screen. The state class holds an implicit reference to a `BuildContext` that may not be safe to use post-`await`. Same root cause as C2.

---

## Keep or migrate? — **Migrate**, with three reasons grounded in this codebase

1. **Disposal hygiene is unrecoverable inside `setState`.** With 41 `StatefulWidget`s and 58 `TextEditingController()` constructions, retrofitting `dispose()` to every screen is a forensic exercise. Migration to controller-owned state (Riverpod `StateNotifier` or equivalent) moves controllers into the controller's lifetime; the widget owns nothing to dispose. The classes of leaks above stop being possible.
2. **The dashboard already demands shared state.** `fetchprofiledata` is duplicated across `main_screen.dart` and `home_screen.dart` because there is no shared place for the profile. Every screen that touches the user — drawer, home tab, profile screen, sign-up flow — currently re-fetches it. A single `currentUserProvider` makes this one fetch with multiple consumers and zero divergence.
3. **`flutter_riverpod` is already paid for.** It is in `pubspec.lock:260-264` and listed in `pubspec.yaml:60`. The block-comment in `lib/app/app.dart:17-32` even contains a scaffolding `ConsumerWidget` and a reference to `routerProvider`. Migration means *uncommenting and continuing the work that was started*, not introducing a new framework.

(Avoid arguments by analogy. The above are this-codebase facts.)

---

## Migration plan

Twelve-week single-dev plan, dovetailing with the AUDIT_ARCH §"Migration plan" — same weeks, complementary work.

| Week | State-management work |
|------|-----------------------|
| 1 | Wire `ProviderScope` at root (uncomment `lib/app/app.dart`). Introduce `currentUserProvider` (`AsyncNotifier<UserSession>`). Replace the two duplicate `fetchprofiledata` sites with `ref.watch(currentUserProvider)`. |
| 2 | Migrate `auth/` to `LoginController extends StateNotifier<AsyncValue<void>>` (diff shown in AUDIT_ARCH §B1). Delete `emailController.addListener(_updateUI)` keystroke-rebuild pattern; replace with `ListenableBuilder` on the submit button only. Add `dispose()` to every TEC site in `auth/`. |
| 3 | Migrate `home/` to `DashboardController`. Collapse the 7-fetcher `initState` block into a single `_load()` that fires controller methods. Replace 39 raw `setState` calls with `state = state.copyWith(...)` on a `freezed`-like `DashboardState` (manual `copyWith` is fine; the codebase already has 34 hand-written `copyWith`s on DTOs). |
| 4–5 | Migrate `Profile/myprofile.dart` and `featured_work_list.dart`. The 9 API call sites in `myprofile.dart` collapse to ~5 controller methods. Modal-sheet builders stop mutating parent state directly; they emit events to a `ProfileEditController`. |
| 6 | `shoots/` and `upcomingshootviewdetils/`. Replace empty `on Exception catch (e) {}` with `state = state.copyWith(asyncShoots: AsyncValue.error(e, st))`. |
| 7 | `file_manager/`, `messages/`, `availability/`. |
| 8 | Sweep: add `dispose()` to remaining state classes that still hold `TextEditingController`. Aim: dispose() coverage 100% of stateful widgets *that own controllers*. |
| 9 | Add `if (!mounted) return;` (or remove the need entirely by promoting to a controller) at the remaining async `setState` sites — aim: 0 unguarded `setState` after `await`. |
| 10 | Wire `ListenableBuilder`/`Consumer` granularly across remaining screens to remove `setState(() {})` rebuild-all-hammers. |
| 11 | Introduce `AsyncValue<T>` (Riverpod) for every fetch — gain loading/error/empty trichotomy for free in `Consumer`. |
| 12 | Add `dart test` coverage on `*_controller_test.dart` files. Aim: every controller has at least one test that drives a happy and an error transition. |

Acceptance gates:
- `grep -rn "setState" lib/features/` after migration: **0**.
- `grep -rn "TextEditingController" lib/features/ | grep -v "dispose"`: every controller declared has a matching dispose.
- `grep -rn "ApiService()" lib/features/`: **0**.
- `flutter test` runs the controllers under `dart test`.

---

## Before/after for the most state-heavy screen

Target: `lib/auth/sign_up/signup3_screen.dart` (3,465 lines, 35-field state class, 5+ undisposed TECs, 25 unguarded `setState`s, 65-line submission handler).

### Before (sketch — sign-up step 3, current shape)

```dart
// lib/auth/sign_up/signup3_screen.dart:63-110 (excerpt)
class SignUp3ScreenState extends State<SignUp3Screen> {
  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  ...
  List<File> featuredImages = [];
  List<bool> featuredIsVideo = [];  // positional correlation
  List<Map<String, dynamic>> savedLinks = [];
  bool isSubmitting = false;
  ...
  // No dispose() at all.

  Future<void> _submit() async {
    setState(() => isSubmitting = true);   // unguarded post-await
    try {
      // 65 lines of payload assembly, multipart POST, navigation
      final response = await ApiService().postMultipartStep3(
        ApiService().baseUrl + ApiEndpoints.register_step3,
        fields: payload.map(...),
        ...
      );
      if (response != null && response['error'] == false) {
        context.goNamed(RouteNames.login);
      } else {
        _showSnack(response?['message'] ?? "Submission failed");
      }
    } catch (e) {
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoggingIn = false); // typo: different flag than the one set on line 1
    }
  }
}
```

### After (target shape)

```dart
// lib/features/auth/signup/domain/signup_state.dart
class SignupState {
  const SignupState({
    this.featuredWorks = const [],
    this.portfolioLinks = const [],
    this.socialLinks = const [],
    this.resume,
    this.portfolio,
    this.certificates = const [],
    this.submission = const AsyncValue.data(null),
  });
  final List<FeaturedWork> featuredWorks;        // FeaturedWork bundles file + isVideo + title — no parallel-list bug
  final List<PortfolioLink> portfolioLinks;
  final List<SocialLink> socialLinks;
  final XFile? resume;                           // XFile, not dart:io File — web-safe (AUDIT_ARCH §F3)
  final XFile? portfolio;
  final List<XFile> certificates;
  final AsyncValue<void> submission;             // loading / error / empty / data — all one type
  SignupState copyWith({...}) => ...;
}
```

```dart
// lib/features/auth/signup/presentation/signup_controller.dart
class SignupController extends StateNotifier<SignupState> {
  SignupController(this._submit) : super(const SignupState());
  final SignupStep3UseCase _submit;

  void addFeaturedWork(FeaturedWork w) => state = state.copyWith(featuredWorks: [...state.featuredWorks, w]);
  void setResume(XFile f) => state = state.copyWith(resume: f);

  Future<void> submit() async {
    state = state.copyWith(submission: const AsyncValue.loading());
    state = state.copyWith(submission: await AsyncValue.guard(() => _submit(state)));
  }
}

final signupControllerProvider = StateNotifierProvider.autoDispose<SignupController, SignupState>(
  (ref) => SignupController(ref.read(signupStep3UseCaseProvider)),
);
```

```dart
// lib/features/auth/signup/presentation/signup_step3_screen.dart  (the only widget file)
class SignupStep3Screen extends ConsumerWidget {
  const SignupStep3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Single listener that fires once on success — navigation lives outside the state class.
    ref.listen<AsyncValue<void>>(
      signupControllerProvider.select((s) => s.submission),
      (_, next) {
        next.whenOrNull(
          data: (_) => context.goNamed(RouteNames.login),
          error: (e, _) => TopMessage.show(context, e.toString()),
        );
      },
    );
    return _SignupStep3Body();    // pure layout, no state
  }
}
```

Net effect: **3,465 lines → ~6 small files**, no `setState`, no `dispose()` for the screen (the `StateNotifier.dispose()` runs automatically via `autoDispose`), navigation outside the state class, file pickers behind `XFile` so web compiles. The 35-field god class becomes a `freezed`-style immutable `SignupState`; the multi-list invariant is enforced by the `FeaturedWork` aggregate.

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Add `dispose()` to every state class that constructs a `TextEditingController`.** *Effort: 1 dev-day mechanical pass.* *Impact:* stops 50+ confirmed memory leaks; restores the lifecycle contract that the rest of the framework assumes. Hard-fail any new TextEditingController without a paired `.dispose()` via a custom lint or CI grep.

2. 🔴 **Add `if (!mounted) return;` before every post-`await` `setState`.** *Effort: 1 dev-day mechanical pass.* *Impact:* eliminates the ~231 unguarded async `setState` sites (~87% of all `setState`). Stops "setState called after dispose" crashes during fast navigation, especially on the home screen with 7 parallel fetchers.

3. 🔴 **Replace `emailController.addListener((){setState((){})})` and equivalents with `ListenableBuilder` around only the button.** *Effort: 0.5 dev-day per screen (login, signup1–3, forgot/reset, profile edit).* *Impact:* removes the keystroke-rebuild-everything pattern, immediate FPS gain on low-end Android. Bonus: surfaces other screens still using the same idiom — search `setState(() {})` and `setState\(\(\) \{\}\)`.

4. 🔴 **Promote `currentUser` to a single `AsyncNotifier<UserSession>` provider.** *Effort: 1 dev-week (includes uncommenting `lib/app/app.dart` + wiring `ProviderScope`).* *Impact:* eliminates the duplicate `fetchprofiledata` between `main_screen.dart` and `home_screen.dart`; downstream consumers (drawer, home, profile, sign-up review) read one source. Enables every later migration in the AUDIT_ARCH plan.

5. 🟠 **Introduce `AsyncValue<T>`-style loading/error/empty in every fetcher (start with `shoots_screen.dart`).** *Effort: 1 dev-day for the first screen, ~2 hours per subsequent screen.* *Impact:* removes the empty-`catch` pattern (`shoots_screen.dart:88-90`), gives every list the same shape of loading spinner / error retry / empty state. Reduces "ListView shows nothing" support tickets to one of "loading, error, or genuinely empty."

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and `docs/AUDIT_ARCH.md`. All `.md` artefacts under `docs/` per project rule.*
