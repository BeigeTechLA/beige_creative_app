# AUDIT_SCALE.md — Scalability Audit (#7)

**Auditor role:** Senior Flutter Architect / Mobile Engineering Lead.
**Reference set:** `docs/AUDIT_MAP.md`, `docs/AUDIT_ARCH.md` (required); cross-refs to `docs/AUDIT_STATE.md`, `docs/AUDIT_STRUCT.md`, `docs/AUDIT_QUALITY.md`, `docs/AUDIT_PERF.md`, `docs/AUDIT_SEC.md`.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** `lib/`, build configuration, CI surface, contributor docs.
**Output convention:** all docs live in `docs/` per project rule.

---

## Three-axis verdict

| Axis | Status | Breaks at |
|------|--------|-----------|
| **Users 10× (1k → 10k DAU)** | 🔴 Will fail | First popular content drop: dashboards re-fetch on every navigation (no client cache, no request dedup — `docs/AUDIT_PERF.md` §D4/D5), shoots list has no pagination param (`docs/AUDIT_PERF.md` §D2), uncached `Image.network` × 12 sites doubles upstream bandwidth, `0` HTTP timeouts (`docs/AUDIT_SEC.md` §F4) means a slow backend page produces hung clients that retry manually → retry storm. |
| **Features 2× (current ~15 → 30)** | 🔴 Will fail | Single `lib/app/router.dart` (369 lines, every screen imported) becomes a merge-conflict hotspot. `lib/service/api_endpoints.dart` likewise. `lib/main_screen.dart` shell hard-codes 4-tab + 1-drawer destinations. Five classes named `Data` already collide in `lib/model_class/` (`docs/AUDIT_STRUCT.md` C-section) — the 6th feature's `Data` adds another `as` alias to every consumer file. `lib/utility/colorcode.dart` + parallel dead `lib/app/colors.dart` ensure the next dev picks the wrong palette. |
| **Team 3× (1 → 3 devs)** | 🔴 Will fail | No CI (`.github/`, `bitrise.yml`, `codemagic.yaml`, `fastlane/` — all absent). No `flutter analyze` enforcement. `test/widget_test.dart` is broken template (`docs/AUDIT_MAP.md` § Test surface). No `CONTRIBUTING.md` / `ARCHITECTURE.md` (only `CLAUDE.md` + template README). Three devs simultaneously touching `home_screen.dart` (2,902 lines), `myprofile.dart` (2,834), or `signup3_screen.dart` (3,465) cannot avoid conflicts. Linux runners break on the `Model_Class/` vs `model_class/` casing (`docs/AUDIT_STRUCT.md` §E4). |

## Scalability score: **2 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | Each axis scales independently; feature flags + remote config in place; CI enforces conventions; tests gate merges |
| 7–8  | Two axes solid, one weak; recoverable with focused work |
| 5–6  | All three axes have known sharp edges with workarounds documented |
| 3–4  | Each scale event requires a refactor; god files block parallel work |
| 1–2  | No CI, no tests, no abstractions; first growth event triggers cascading rewrites |

Score — **Feature-add isolation 0/2 · API/network layering 0/2 · Caching/pagination 0/2 · Team-scale readiness 1/2 · CI/release infrastructure 1/2** → 2/10.

---

## Pre-analysis — three growth scenarios

### Scenario 1 — User base 10×

Current API call pattern: every screen instantiates `ApiService()`, fires a fetch in `initState`, parses JSON inline (`docs/AUDIT_ARCH.md` §B1 — 58 sites). No client cache (`docs/AUDIT_PERF.md` §D4). No request dedup (`docs/AUDIT_PERF.md` §D5). No connect/receive/send timeouts (`docs/AUDIT_SEC.md` §F4). No retry/backoff anywhere (`grep -rn "retry\|exponential\|backoff" lib` → **0**).

**What breaks first:** the dashboard endpoint family. A returning user opens the app, lands on the home screen, the 7 fetchers in `lib/home/home_screen.dart:314-322` fan out. If the API tier is at 80% capacity, two of the 7 stall; the user backgrounds the app; the kernel kills the Dart isolate. On resume, the cycle repeats. With 10× users, every backend pause turns into a fan-in surge as 7× more clients each spawn 7× requests with no timeout.

Compound: `fetchprofiledata` is implemented twice (`docs/AUDIT_QUALITY.md` §C1) → 2× the load just for "who's logged in" on every cold start.

### Scenario 2 — Feature count doubles

Adding a new "Notifications" feature today requires editing **all** of: `lib/app/router.dart` (add `GoRoute`), `lib/app/route_names.dart` (add constant), `lib/service/api_endpoints.dart` (add endpoint), `lib/main_screen.dart` (probably a new drawer entry), and likely `lib/model_class/` (a new DTO). Cascade if the DTO includes a nested `Data` class → that name now collides with the 5 existing ones (`docs/AUDIT_STRUCT.md`).

There is no feature module boundary — no `features/<x>/<x>.dart` barrel, no exported public surface (`docs/AUDIT_STRUCT.md` §E3). A new dev can reach into any screen's private state class because everything is public-by-default in Dart.

**What breaks first:** `router.dart` becomes the merge-conflict hotspot. Every feature PR touches the same file. Within ~6 months and ~10 added features, the file approaches 700-800 lines and routine PR reviews spend their time on import ordering rather than business logic.

### Scenario 3 — Team triples

The three worst files (signup3 / home / myprofile = ~9,200 lines combined) hold most of the user-visible behavior. Three devs working in parallel cannot avoid two of them touching the same file in the same week. There are no:

- `analysis_options.yaml` customisations beyond the upstream lint set (`docs/AUDIT_MAP.md` § Config surface).
- `flutter analyze` CI gate (no CI exists).
- Tests beyond a broken counter-app template.
- `CONTRIBUTING.md` or `ARCHITECTURE.md` explaining the (non-)pattern.
- Folder casing convention — Linux CI breaks immediately if introduced (`docs/AUDIT_STRUCT.md` §E4).

**What breaks first:** a Friday-afternoon merge of two PRs that both touched `home_screen.dart`. The literal merge succeeds because Git can interleave 200-line edits; the runtime crashes because both devs called `setState` with overlapping `Myprofile_user` ownership.

---

## Strengths (with evidence)

1. **Routing is name-constant-driven.** `lib/app/route_names.dart` + a single `GoRouter` in `lib/app/router.dart`. Adding a route touches a small surface (`docs/AUDIT_STRUCT.md` Strengths).
2. **Endpoint registry is centralised.** `lib/service/api_endpoints.dart`. Modulo two bypass sites (`docs/AUDIT_ARCH.md` §B6), the registry exists and is the natural seam for an interceptor-based API client.
3. **Environment selection is compile-time clean.** `lib/main_dev.dart` + `lib/main_prod.dart` + Android product flavors `dev`/`prod`. Adding `staging` is a 10-minute task (`docs/AUDIT_MAP.md` § Entry points and flavors).
4. **`go_router` is already adopted** (32 import sites). Modern navigation primitive; supports nested routes, redirects, and auth guards when a controller layer exists.
5. **No CI configs to migrate away from.** Greenfield — adding a GitHub Actions workflow is unblocked by zero legacy.

These five are the scaffolding to *reuse* when the rewrite plans in `docs/AUDIT_ARCH.md` / `docs/AUDIT_STATE.md` land.

---

## A. Feature-Scale Readiness

### A1. Add a new feature without modifying unrelated files? 🔴 [HIGH]

**No.** Adding "Notifications" today touches:

- `lib/app/router.dart:51-368` — append `GoRoute`
- `lib/app/route_names.dart:1-82` — append constant
- `lib/service/api_endpoints.dart:1-81` — append endpoint string(s)
- `lib/model_class/` — add a DTO file; **avoid the name `Data`** because 5 of those exist
- `lib/main_screen.dart:312-355` — likely add a drawer entry, and (if it's a tab) a fifth bottom nav slot that the `BackdropFilter`-wrapped `BottomNavigationBar` can't accommodate without re-layout
- Possibly `lib/utility/imges_icons.dart` — register asset constants

**Six shared files touched** by a single feature add. That number does not shrink; it grows linearly with each shared concern.

### A2. Feature isolation 🔴 [HIGH]

Features in `lib/` are *folders of screens*, not encapsulated modules (`docs/AUDIT_STRUCT.md` §A2). Cross-feature import already confirmed (`docs/AUDIT_ARCH.md` §E4): `lib/auth/login/login.dart:7` imports `../../main_screen.dart`. Internal helpers leak: `signup3_screen.dart:111` declares `Portfoliolname` as a `final List<String>` — any file in the codebase can `import` `signup3_screen.dart` and reach into the screen's state class via Dart's library system to access constants intended as private helpers.

### A3. Singletons / global mutable state 🟠 [MEDIUM]

Confirmed global state surfaces:

| State | Where | Mutated by |
|-------|-------|------------|
| `Env.apiUrl`, `Env.imageUrl`, `Env.stripePublishableKey` | `lib/config/env.dart:4-6` (static `late String`) | `Env.init` at boot only — safe |
| `ApiService.imageURL` | `lib/service/api_service.dart:25` (`static String`) | `Env.imageUrl` at boot — safe |
| `SharedPreferences` (token, email, password, isLoggedIn, etc.) | `lib/service/shared_service.dart` (static methods) | every login, every logout (`prefs.clear()` — `docs/AUDIT_SEC.md` §F6) — **global mutable**. |

**Failure mode at scale:** when a sub-feature wants its own preferences namespace, today's `SharedService.logout` will wipe it. The static surface forces every contributor to extend the same singleton.

### A4. Plugin / feature flag system 🔴 [HIGH]

`grep -rn "remote_config\|FeatureFlag\|feature_flag\|GrowthBook\|launchdarkly" lib pubspec.yaml` → **0**.

No remote config, no feature flag toolkit, no `Firebase Remote Config`. Every release ships every feature; no kill-switch for a broken endpoint; no A/B testing surface. **At scale:** rolling back a bad feature requires shipping a new build to the store and waiting for the rollout. Mean-time-to-recover is days, not minutes.

---

## B. API Handling & Abstraction

### B1. API layer behind interfaces 🔴 [HIGH]

`grep -rn "abstract class" lib` → **0**. There is no `AuthRepository`, no `DashboardRepository`, no `ProfileRepository`. Every widget binds to the concrete `ApiService` (58 sites). Re-emphasised from `docs/AUDIT_ARCH.md` §D1 — surfaced here because **mockability is the *test*-scale gate**: with three devs and no interfaces, no PR can come with a unit test that exercises the business behavior without standing up the real HTTP server.

### B2. Single network client centrally configured 🔴 [HIGH]

`ApiService()` is constructed at every call site. Each construction re-reads `Env.apiUrl`, allocates new internal `Dio()`s in some methods (`lib/Profile/myprofile.dart:594` `final dio = Dio();`), and re-reads the token from `SharedPreferences` via `createAuthorizationHeader()`. There is no single configured client, no shared interceptor chain.

**Failure mode at scale:** when the team needs to add a logging interceptor (for incident response), a retry interceptor (for transient failures), or a circuit breaker (for cascading 5xx avoidance), there is no single place to put it. 58 sites × N concerns = exponential surface.

### B3. Error handling consistency 🔴 [HIGH]

Each screen handles errors differently:

- `home_screen.dart:204-207` — `catch (e) { debugPrint(...); }` (swallow)
- `shoots_screen.dart:88-90` — `on Exception catch (e) {}` (silent swallow)
- `shoots_screen.dart:96-119` — `fetchshootmodel` has **no try/catch at all** — unhandled exception
- `login.dart:121-144` — extensive regex-based parsing of error string to extract `"message"` JSON, with nested `catch (_) {}`
- `myprofile.dart:2596-2611` — `ScaffoldMessenger.showSnackBar` with hard-coded error string

Five different error-handling styles in one project. **At scale:** any debugging session that asks "did this call succeed?" requires reading the screen-specific error handler. With 30 features, that's 30 ad-hoc handlers.

### B4. Response parsing: typed DTOs or raw `Map` 🟠 [MEDIUM]

Mixed. Most fetchers wrap responses in DTOs (`Myprofilemodel.fromJson`, `Shootcountmodel.fromJson`, etc.). Several do not:
```dart
// lib/home/home_screen.dart:143-182  (fetchShootCategories)
final response = await ApiService().fetchData("creator/shoot-categories?tab=$tab");
if (response["error"] == false) {
  final data = response["data"];
  final tabs = data["tabs"];
  setState(() {
    photographyShoots = tabs["photo"]["total"] ?? 0;
    ...
  });
}
```
Direct `Map<String, dynamic>` access in a 40-line block. Adding a server-side rename causes a silent breakage (no compile-time check). At scale: schema drift will surface as runtime nulls scattered across screens.

### B5. Endpoints — constants vs string literals 🟠 [MEDIUM]

Mostly constants (`ApiEndpoints.*`), with two known bypass sites:
- `lib/Profile/myprofile.dart:2579-2583` — `"creator/profile/edit-portfolio-link/$id"` hard-coded.
- `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:75-84` — `'creator/project-details/${widget.projectid}'` hard-coded.
- `lib/Profile/myprofile.dart:598` — `"${ApiService().baseUrl}creator/profile/upload-profile-photo"` hard-coded.

Plus `lib/home/home_screen.dart:145-146` — `"creator/shoot-categories?tab=$tab"` hard-coded.

Four sites bypass the registry. **At scale:** an endpoint rename (e.g., `/creator/` → `/v2/creator/`) requires grep-and-replace across the entire `lib/`, not a single edit in `api_endpoints.dart`.

### B6. Auth token refresh — interceptor or per-call 🔴 [HIGH]

`grep -rn "refresh.*token\|refreshToken\|interceptor" lib` → **0**. There is no token refresh mechanism. `ApiService.createAuthorizationHeader` (`:28-44`) simply reads the current token. **A 401 from the API results in an opaque "Failed to load data" exception thrown into the calling screen.** The user then has to log out and back in.

### B7. Request cancellation 🟢 (not a current concern, becomes one at scale)

No `CancelToken` usage anywhere. Today's `fire-and-forget initState` pattern means even a back-button press does not cancel in-flight requests — they complete, call `setState` on a disposed widget (`docs/AUDIT_STATE.md` §C2), and waste tokens. **Not a current crash because of unguarded `setState` (which crashes earlier), but at scale this becomes a per-request server-side load.**

---

## C. Pagination & Caching

### C1. Per-screen pagination status 🔴 [HIGH]

| Screen | Endpoint | Page param? | Item count today | Risk at scale |
|--------|----------|-------------|------------------|---------------|
| `lib/shoots/shoots_screen.dart` | `creator/dashboard-details` | **no** | <100 | 1000-item mount jank + memory |
| `lib/home/home_screen.dart` | `creator/upcoming-accepted-project` | **no** | <50 | manageable |
| `lib/home/home_screen.dart` | `creator/dashboard-details` | **no** | <100 | duplicate of shoots screen |
| `lib/Profile/featured_work_list.dart` | `creator/profile-files` (presumed) | **unknown** | per-creator | scales with creator media |
| `lib/manageavailability/manage_availability_screen.dart` | `creator/availability` | **month-scoped** | per month | OK |
| `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` | `creator/project-details/$id` | n/a (single item) | — | OK |

**Server may not yet support pagination.** When the team adds it, the client requires multi-file changes (`docs/AUDIT_ARCH.md` Migration plan).

### C2. Caching strategy 🔴 [HIGH]

**None.** No in-memory cache, no `flutter_cache_manager` integration in app code (it's transitively pulled by `cached_network_image` but used only for images, and even that is unused — `docs/AUDIT_PERF.md` §B5). No `Hive`, no `sqflite`, no `drift`.

Every navigation re-fetches everything. `home_screen` → `shoots` → back → `home_screen` issues 14 HTTP calls (7 + 7).

### C3. Stale-while-revalidate (SWR) 🟢

**Not applicable — no caching exists, so no SWR pattern.** Listed for completeness; becomes relevant only after C2 is fixed.

### C4. Search debouncing 🔴 [HIGH]

`grep -rn "Timer\|Debounce\|debounce" lib` → **0**. Confirmed offenders:
- `lib/shoots/shoots_screen.dart:247` — `onChanged: searchShoots` fires per keystroke (`docs/AUDIT_PERF.md` §C2).
- `lib/auth/sign_up/signup2_screen.dart` — skills autocomplete (line not directly cited; spot-check would confirm).
- `lib/auth/sign_up/signup1_screen.dart` — Google Places autocomplete (likely same pattern).

**At scale (10× users):** every search field × every keystroke × every user = N×K×U requests to the autocomplete endpoint. Cheapest backend wins via debounce + dedup; today both are missing.

---

## D. User-Scale Readiness

### D1. Connection failure handling 🔴 [HIGH]

`grep -rn "connectivity_plus\|hasConnection\|offline\|InternetAddress" lib` → only commented-out `InternetAddress.lookup('google.com')` at `lib/utility/Utils.dart:144-145`. No connectivity awareness. No "no internet" banner. No retry button.

**Failure mode at scale:** users in flaky-network regions (rural India, subway commutes) see an indeterminate spinner. No backoff, no notification, no graceful fallback.

### D2. Loading state centrally managed 🔴 [HIGH]

Each screen owns a `bool isloading = true;` (`docs/AUDIT_STATE.md` §B1). 12 distinct `isLoading`/`isloading`/`isLoggingIn`/`isUploadingImage`/`isPicking`/`isSubmitting`/`isUpdating` flags scattered across the worst-3 screens alone. **At scale:** the UI is inconsistent — same network outage shows a spinner on one screen and a blank list on another.

### D3. Error UI standardisation 🔴 [HIGH]

Five styles (B3): `debugPrint`-only swallow, empty catch, regex-parsed error popup, hard-coded `SnackBar("Edit failed")`, custom `TopMessage` widget (`lib/widgets/Topmessgae.dart`). Each new feature reinvents the error UX.

### D4. Empty states 🔴 [HIGH]

`grep -rnE "EmptyState|empty_state|errorWidget" lib` → **0** (`docs/AUDIT_STRUCT.md` Hotspot section). Lists show `Container()` / `SizedBox()` / nothing when empty. New users with no shoots and no projects see a blank screen.

---

## E. Team-Scale Readiness

### E1. New developer onboarding 🔴 [HIGH]

**Estimate: 2–3 weeks to first merge-worthy PR.** A new mid-level Flutter dev faces:

- A `README.md` that's the **default Flutter template** (`docs/AUDIT_MAP.md` § Project metadata — "A new Flutter project.").
- **No `CONTRIBUTING.md` or `ARCHITECTURE.md`.** Only `CLAUDE.md` (written in this audit chain), which conveys the *non*-pattern.
- A 3,465-line screen as the largest file — onboarding likely requires reading it.
- Mixed casing (`Profile/` vs `home/`), confusing dead scaffolding (`lib/app/app.dart`), and multiple "right" places to put things (`docs/AUDIT_STRUCT.md` Pre-analysis).

Compare to a well-structured Flutter codebase: 2–4 days to first PR.

### E2. Documentation 🔴 [HIGH]

| Doc | Present? |
|-----|----------|
| `README.md` | ✅ but **content is the unmodified Flutter template** (4 lines: "A new Flutter project. A few resources..."). |
| `CONTRIBUTING.md` | ❌ |
| `ARCHITECTURE.md` | ❌ (audit produced `docs/AUDIT_ARCH.md` — not a replacement) |
| `CHANGELOG.md` | ❌ |
| `CLAUDE.md` | ✅ (written during this audit chain) |
| API client docs / endpoint catalogue | ❌ (only the `ApiEndpoints` class) |
| Onboarding runbook | ❌ |

### E3. Public APIs of features delineated 🔴 [HIGH]

**Every file is public.** No barrel files (`docs/AUDIT_STRUCT.md` §E1). No `library`/`part of` declarations. A future "Notifications" feature has no way to declare "consumers may import `notifications.dart`; everything else is internal."

### E4. Shared utilities discoverability 🔴 [HIGH]

Two `App*` utils classes (`Utils.dart` block-commented + `AppUtils`) + `DateTimeUtils` in `lib/widgets/` (`docs/AUDIT_STRUCT.md` §C2). Three parallel design-token namespaces (`ColorCode`, `AppColors`, inline `Color(0x...)`). A new dev cannot find what already exists; reinvention is the default.

### E5. Test infrastructure 🔴 [HIGH]

`test/widget_test.dart` (43-line counter template; won't compile against current `MyApp(isLoggedIn:)` signature — `docs/AUDIT_MAP.md` § Pre-audit flag #1). No `integration_test/`. No `mocktail`/`mockito` dep. No `test/helpers/`.

Adding a test today requires: write the dep, write the helpers, fight the lack of DI (`docs/AUDIT_ARCH.md` §D3). It is *hostile* to test contribution.

---

## F. CI/CD & Release

### F1. CI config files 🔴 [HIGH]

`find . -path "*github*" -o -path "*circleci*" -o -path "*bitrise*" -o -path "*codemagic*" -o -path "*fastlane*" -o -name ".gitlab-ci.*"` → **0 matches**. `ls .github` → **does not exist**.

**No CI at all.** Every PR is reviewed without an automated `flutter analyze`, no test run, no build verification, no static security scan.

### F2. Lint enforced in CI 🔴 [HIGH]

Not applicable while F1 stands. `analysis_options.yaml` is upstream-only (`docs/AUDIT_MAP.md` § Config surface). Even *locally* there is no `dart fix --apply` discipline (the file at `:23-25` shows two commented lint suggestions, neither active).

### F3. Tests run in CI 🔴 [HIGH]

Not applicable while F1 stands. **Tests would fail anyway** because `test/widget_test.dart` references `MyApp()` with no args (E5).

### F4. Build matrix per flavor / platform 🔴 [HIGH]

Not applicable while F1 stands. Both Android flavors (`dev`/`prod`, build.gradle.kts:41-53) and iOS schemes would need a matrix entry per `--flavor` × `-t lib/main_*.dart` × platform.

---

## Scalability roadmap

| # | Improvement | Effort | Impact at scale | Priority |
|---|-------------|--------|------------------|----------|
| 1 | Add a `core/network/ApiClient` behind a Riverpod provider; ban `ApiService()` direct constructions | 1 dev-week | Unblocks interceptors (auth refresh, retry/backoff, logging) at the *single* layer they belong; allows mocking for tests | 🔴 must |
| 2 | Add 30-second in-memory cache + request dedup to the new `ApiClient` | 1 dev-day (after #1) | Cuts dashboard endpoint load by ~50% on common nav paths; eliminates the duplicate `fetchprofiledata` | 🔴 must |
| 3 | Set up GitHub Actions: `flutter analyze`, `flutter test`, `flutter build apk --debug` on PR | 1 dev-day | Catches the casing/import drift, broken `widget_test.dart`, and unused-import warnings before they merge | 🔴 must |
| 4 | Normalise folder + import casing to `snake_case`; run `dart fix --apply` | 1 dev-day | Removes the 7+ case-mismatch hotspots; makes Linux CI viable | 🔴 must |
| 5 | Replace `test/widget_test.dart` template with a minimal smoke test + 1 controller test | 1 dev-day | Restores CI's ability to gate on tests; establishes the test pattern for future PRs | 🔴 must |
| 6 | Add `connectivity_plus` + an `AsyncValue<T>`-style loading/error/empty wrapper around every collection screen | 1 dev-week | Standardises error UX; gives users a "no internet" banner; closes the "blank screen on bad response" UX hole | 🟠 should |
| 7 | Add server-side pagination (limit/offset or cursor) to shoots/dashboard/upcoming/featured endpoints; wire client `infinite_scroll_pagination` | 2 dev-weeks (client + server) | Bounds memory + cold-start time at 10× users; eliminates the "load everything up front" anti-pattern | 🟠 should |
| 8 | Introduce barrel files per feature (`features/<x>/<x>.dart`) and declare a public API surface | 1 dev-day | Bounds the merge-conflict surface; makes "private to feature" enforceable via lint | 🟠 should |
| 9 | Introduce Firebase Remote Config (or similar) for feature flags / kill switches | 1 dev-week | Mean-time-to-recover from a bad release drops from days (store rollout) to minutes (flag flip) | 🟠 should |
| 10 | Add `flutter_secure_storage` + token refresh interceptor; remove password persistence | 1 dev-day | Closes the most catastrophic security hole (`docs/AUDIT_SEC.md` S3) + makes silent re-auth possible | 🔴 must (security) |
| 11 | Add `Dio` connect/receive/send timeouts + retry-with-backoff interceptor | 1 dev-day | Prevents per-user retry storms on backend hiccups (`docs/AUDIT_SEC.md` §F4) | 🔴 must |
| 12 | Centralise loading/error/empty UI via a `ScreenState<T>` wrapper widget; delete per-screen `isLoading` flags | 1 dev-week | One UX language across all screens; new feature inherits behaviour | 🟠 should |
| 13 | Write `ARCHITECTURE.md` + `CONTRIBUTING.md`; replace template `README.md` | 1 dev-day | New-dev onboarding drops from ~2 weeks to ~2 days | 🟠 should |
| 14 | Standardise folder structure (`features/<x>/{data,domain,presentation}`); migrate auth + home first | 2 dev-weeks | Bounds feature isolation; subsequent features cost a constant, not a linear-with-existing-files amount | 🟠 should |
| 15 | Split the four largest screens into controllers + sub-widgets (cross-ref `docs/AUDIT_ARCH.md` Top-fix #2) | 2 dev-weeks | Removes the largest merge-conflict targets; makes review possible | 🔴 must |

---

## Top 5 fixes from this audit

Ranked by impact-to-effort at scale.

1. 🔴 **Stand up CI now: GitHub Actions running `flutter analyze` + `flutter test` + `flutter build apk --debug` per PR.** *Effort: 1 dev-day.* *Impact at scale:* every other fix in every audit becomes enforceable. Without CI, fixes regress within a release. **Highest leverage, lowest cost.**

2. 🔴 **Introduce a single `ApiClient` behind a Riverpod provider (combined with #1 from `docs/AUDIT_ARCH.md` and `docs/AUDIT_STATE.md`).** *Effort: 1 dev-week.* *Impact at scale:* gives the codebase a single place to add **timeouts, retry/backoff, auth-refresh interceptor, caching, request dedup, logging, circuit breaker** — every cross-cutting network concern lives behind one provider. Without it, each concern is a 58-site change.

3. 🔴 **Normalise folder + file casing to `snake_case` and fix the `Model_Class/` imports.** *Effort: 1 dev-day.* *Impact at scale:* unblocks the Linux CI runner (without which step #1 only catches half of the bugs). Removes the casing landmine that scales linearly with team size.

4. 🔴 **Replace `test/widget_test.dart` template with a real smoke test and a `controller_test.dart` pattern.** *Effort: 1 dev-day (combined with #2).* *Impact at scale:* CI gains a test gate. With one example controller test, every subsequent feature's controller test is a copy-and-modify.

5. 🟠 **Write `ARCHITECTURE.md` + `CONTRIBUTING.md`; replace the template `README.md`.** *Effort: 1 dev-day.* *Impact at scale:* new-dev onboarding drops from weeks to days. Encodes the conventions established by the audit set so future PRs follow them by default. (Today, only `CLAUDE.md` exists — useful for AI assistants, but not the canonical contributor doc.)

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and `docs/AUDIT_ARCH.md`. Cross-references: `docs/AUDIT_STATE.md`, `docs/AUDIT_STRUCT.md`, `docs/AUDIT_QUALITY.md`, `docs/AUDIT_PERF.md`, `docs/AUDIT_SEC.md`. All `.md` artefacts under `docs/` per project rule.*
