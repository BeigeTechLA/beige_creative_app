# AUDIT_TEST.md — Testing Audit (#9)

**Auditor role:** Senior Flutter Engineer — testing strategy.
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** `test/`, `integration_test/`, `pubspec.yaml` dev dependencies; testability assessment across `lib/`.
**Output convention:** all docs live in `docs/` per project rule.

---

## Coverage estimate: **0%**

Hard data:

```
test/
└── widget_test.dart      # 30 lines, unmodified Flutter counter-app template (map § Test surface)
integration_test/          # does NOT exist
```

`grep -nE "mock|mockito|mocktail|test_coverage|patrol|integration_test" pubspec.yaml pubspec.lock` → **0 dev-dependency entries**. The only test surface that ships is `flutter_test` from the SDK.

The lone file references `MyApp()` with no arguments, but the live class requires `isLoggedIn: bool` (`lib/main.dart:30-33`). **The test does not compile, let alone pass.** No line of `lib/` is exercised. Coverage = **0%**.

## Test types present

| Type | Count |
|------|-------|
| Unit | 0 |
| Widget | 0 (1 broken template) |
| Golden | 0 |
| Integration | 0 |

## Testability score: **1 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | Pure-Dart domain layer; DI everywhere; deterministic clock/random; mocks via interface |
| 7–8  | Most business logic in controllers/use-cases; minor `BuildContext` coupling |
| 5–6  | Mixed — some screens have controllers, some do not |
| 3–4  | Logic in widgets but at least one network seam mockable |
| 1–2  | Logic, network, persistence, formatting all live in widget state |

Score: **DI 0/2 · Determinism 0/2 · Business-logic isolation 0/2 · Test infra 0/2 · Existing test quality 1/2** → 1/10.

## Verdict

**Largely untestable.** The production code is structured such that **no business path can be unit-tested without spinning up the real HTTP backend, the real `SharedPreferences` platform channel, and the real device clock**. Every fix-list below depends on the refactor in `docs/AUDIT_ARCH.md` § Migration plan landing first; layering tests on top of the current shape would create flaky tests that double the maintenance burden without raising confidence.

---

## Pre-analysis — 5 most business-critical files + testability blockers

### 1. `lib/auth/login/login.dart` — login is the gate to everything

**Could a unit test land in 10 minutes? No.**

Blockers:
- `_fetchLogin` (`:50-149`) instantiates `ApiService()` inline (`:73`) — cannot mock the network.
- `SharedService.setLoginDetails` is a `static` method (`lib/service/shared_service.dart:9`) reading the global `SharedPreferences` — cannot inject a fake.
- `_fetchLogin` reads `emailController.text` / `passwordController.text` directly from `TextEditingController` fields on the state class — the *only* way to drive the function is through a full widget pump.
- `_fetchLogin` calls `context.goNamed(RouteNames.home)` (`:120`) — without a `MaterialApp.router` mounted with the real router config, `context.goNamed` throws.
- Error-string regex parsing inline (`:124-141`) — testable only via the actual exception type the network throws, which varies by environment.

To test "login fails with empty password," a tester must: provide a real router, a real `SharedPreferences` instance (`testing/SharedPreferences.setMockInitialValues`), and a fake HTTP server. **Conservative estimate: 2–3 hours per test case.**

### 2. `lib/Profile/myprofile.dart` — profile edit + photo upload

**Could a unit test land in 10 minutes? No.**

Blockers:
- 9 `ApiService()` instantiations across the file; one site uses raw `Dio()` (`:594`) constructed *inside* the function — not interceptable.
- `dart:io File` parameters (`:587-591`) — testable only with real filesystem fixtures.
- Modal-builder nested `setState`/`setModalState` (`:2603-2611`) — runs only inside a real `showModalBottomSheet` callback chain.
- Hard-coded URL string (`:598`) — bypasses `ApiEndpoints`; tests cannot stub the endpoint.
- 2 hard-coded `TextEditingController()` fields (`:834-835`) + N modal-scoped ones — `dispose()` is missing (`docs/AUDIT_STATE.md` §C4), so tests leak controllers.

### 3. `lib/home/home_screen.dart` — dashboard with 7 fetchers

**Could a unit test land in 10 minutes? No.**

Blockers:
- 8 `ApiService()` instantiations (`:90`, `:127`, `:145-148`, `:187-188`, `:212`, `:232`, `:255`, `:275`) — none injectable.
- `initState` fires 7 fetchers in parallel (`:314-322`); no way to await them all, and they `setState` on a disposed widget if the test pumps too fast.
- `AnimationController(vsync: this, ...)` at `:323` — requires a `TickerProvider`, runs in real time; tests would need `tester.pumpAndSettle()` repeatedly to drain.
- `prepareAvailabilityEvents` parses `Map<String,dynamic>` from a network response and writes to `events` — pure logic mixed with the network result.

### 4. `lib/auth/sign_up/signup3_screen.dart` — multipart registration

**Could a unit test land in 10 minutes? No.**

Blockers (all those of #2 + #3, plus):
- `ApiService().postMultipartStep3(...)` (`:240-253`) takes an *absolute URL* built via `ApiService().baseUrl + ApiEndpoints.register_step3` — tests cannot pin the URL.
- `postMultipartStep3` itself bypasses the auth header (per `CLAUDE.md`) — even if mocked, the production code path differs from the test path.
- 65-line `_submit` (`:148-269`) combines payload assembly, multipart construction, navigation, and snackbar dispatch — granular testing of "did payload include featured_work" requires the entire function to run end-to-end.

### 5. `lib/service/api_service.dart` — the central HTTP god class

**Could a unit test land in 10 minutes? No.**

Blockers:
- No interface — `ApiService` is a concrete class (`docs/AUDIT_ARCH.md` §D1, `D2`).
- `createAuthorizationHeader` (`:28-44`) reads `SharedPreferences` directly — cannot inject token.
- `_baseUrl = Env.apiUrl` is read once at construction; `Env.init` must run first; `Env` is a static-field class.
- Three multipart variants (`postMultipart`, `postMultipartData`, `postMultipartStep3`) each instantiate their own `Dio()` — no shared interceptor seam.
- `imageFile.lengthSync()` (`:350`) — blocks main thread synchronously; tests would need real files.

The class has no abstract surface, no constructor parameters, and no dependency seam.

---

## Untestable code hotspots (worst blocking classes)

Ranked by leverage — fixing the testability of these classes unlocks the rest.

1. **`lib/service/api_service.dart`** — central HTTP. Until this is behind `abstract class ApiClient`, every screen that calls it is untestable.
2. **`lib/service/shared_service.dart`** — static `SharedPreferences` mediator. Static methods are unmockable in Dart without surface refactor.
3. **`lib/config/env.dart`** — static `Env.apiUrl` etc. Tests cannot stub a "test backend URL" without calling `Env.init`, which has global side effects.
4. **`lib/main_screen.dart`** — bottom-nav shell. Reaches into `ApiService` from `fetchprofiledata()` (`:50-87`). Until the shell consumes a `currentUserProvider`, the shell cannot be widget-tested.
5. **`lib/home/home_screen.dart` / `signup3_screen.dart` / `myprofile.dart`** — the god screens. Their `State<T>` classes are simultaneously view + controller + repository + persistence; unit tests need them dismembered first.

---

## A. Coverage & Types

### A1. `test/` and `integration_test/` 🔴 [HIGH]

- `test/` exists. **1 file**: `test/widget_test.dart`.
- `integration_test/` **does not exist**.
- `test/_helpers/`, `test/fixtures/`, `test/builders/` **do not exist** (`find test -type d` → only `test`).

### A2. Test types 🔴 [HIGH]

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

The unmodified template — looks for a counter `'0'` / `'1'` that does not exist anywhere in this app's `MyApp`. Calls `MyApp()` without the `required this.isLoggedIn` argument (`lib/main.dart:30-33`). **Will not compile.** `flutter test` returns:

> `Error: The named parameter 'isLoggedIn' is required, but there's no corresponding argument.`

### A3. Estimated coverage 🔴 [HIGH]

**0%.** Not approximate — exact. The single test file does not compile; therefore no line of `lib/` is reached.

### A4. Layer coverage 🔴 [HIGH]

| Layer | Coverage |
|-------|----------|
| Presentation (screens) | 0% — no widget tests |
| Domain (use cases / entities) | n/a — **no domain layer exists** (`docs/AUDIT_ARCH.md` §B2) |
| Data (DTO `fromJson`, repository) | 0% — no DTO tests despite 10 hand-written `fromJson` factories |
| Core (validation, format, network) | 0% — no `core/` layer exists |

### A5. Critical untested paths 🔴 [HIGH]

| Path | Test status |
|------|-------------|
| Login → home navigation | untested |
| Sign-up step 1/2/3 (multipart upload) | untested |
| Forgot password → OTP → reset | untested |
| Profile photo upload (raw Dio path) | untested |
| Stripe payment | untested + prod key is placeholder (`docs/AUDIT_SEC.md` S2) — would throw |
| Logout (`prefs.clear()`) | untested |
| Auth-token expiry handling | n/a — no refresh logic exists (`docs/AUDIT_SCALE.md` §B6) |
| Network failure recovery | untested; ~87% of `setState` after `await` lack `mounted` guards (`docs/AUDIT_STATE.md` §C2) |

---

## B. Test Quality

### B1. Tests with trivially passing assertions 🔴 [HIGH]

The single test would test counter `'0'`/`'1'`. If forced to compile (by changing `MyApp()` to `MyApp(isLoggedIn: false)`), every assertion fails — there is no counter. The test is **not even trivially passing**; it is structurally wrong for this app.

### B2. Tests testing implementation details 🟢

**Not applicable — no tests exist beyond the broken template.**

### B3. Brittle tests 🟢

**Not applicable — no tests exist.** But the *production code* has 11 direct `DateTime.now()` / `Random()` references (`grep -rnE "DateTime\.now\(\)|Random\(\)|new Random" lib | wc -l` → 11). Any future test of date-dependent logic (calendar events, "this week"/"this month" filters at `home_screen.dart:68-76`, `prepareAvailabilityEvents` at `:290-302`) will be brittle unless these become injectable `Clock`/`Random` dependencies.

### B4. Missing edge cases 🟢

**Not applicable — no tests exist.** But each of the 9 hand-written `fromJson` factories in `lib/model_class/` should be tested for: null fields, missing fields, type mismatches, empty arrays, malformed dates.

### B5. Arrange/act/assert structure 🟢

**Not applicable.**

### B6. Flaky-prone async tests 🟢

**Not applicable.**

### B7. Mocking — mockito / mocktail / hand-rolled 🔴 [HIGH]

`pubspec.yaml` `dev_dependencies`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

`grep -nE "mock|mockito|mocktail" pubspec.yaml` → **0**. No mocking library is declared. Today, every test would need to either:
- (a) hand-roll a fake `ApiService` (impossible — `ApiService` is final + non-abstract; subclassing is allowed but the static `imageURL` field interferes),
- (b) inject the real network and assert against a real backend (integration test territory).

Recommend `mocktail` (Dart-3 friendly, null-safety-aware, no code-gen). Add to `dev_dependencies`.

### B8. Widget tests using `pumpWidget` correctly 🟢

**Not applicable — no widget tests yet.** When introduced, every widget that uses `context.goNamed` requires `MaterialApp.router(routerConfig: appRouter)` as an ancestor. Pre-build a helper:

```dart
// test/helpers/pump_app.dart
Future<void> pumpApp(WidgetTester tester, Widget under) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...],
      child: MaterialApp(home: under),
    ),
  );
}
```

---

## C. Testability of Production Code

### C1. Hardcoded `new`-instantiated dependencies 🔴 [HIGH]

| Offender | Count |
|---------|-------|
| `ApiService()` instantiations in widget state classes | **58** (`docs/AUDIT_ARCH.md` §B1) |
| `Dio()` instantiated inside method bodies | 2 (`lib/Profile/myprofile.dart:594`, `lib/service/api_service.dart:220, 334`) |
| `SharedPreferences.getInstance()` called directly from widgets | 6 (`docs/AUDIT_MAP.md` § Detected patterns) |
| `TextEditingController()` constructed in widget state | **58** (`docs/AUDIT_STATE.md` §C4) |
| `Timer(...)` | 0 (none — but means no debounce, see `docs/AUDIT_PERF.md` §C2) |
| `DateTime.now()` / `Random()` | 11 |
| `File(...)` constructor calls in `lib/` | 13 |

### C2. No DI 🔴 [HIGH]

Re-emphasised from `docs/AUDIT_ARCH.md` §D3. **No DI container. No constructor injection. No service locator. No Riverpod providers live.**

Classes that should be injectable but are not:
- `ApiService` (network)
- `SharedService` (session storage)
- `Env` (configuration — static-only)
- the eventual `LoginUseCase`, `DashboardController`, `ProfileRepository`, etc. (don't exist yet)

### C3. Static methods used for injectable logic 🔴 [HIGH]

```dart
// lib/service/shared_service.dart:7-49
class SharedService {
  static Future<void> setLoginDetails(Map<String, dynamic> response) async { ... }
  static Future<void> logout() async { ... }
}
```
Static. Cannot be overridden in tests. **The biggest single testability blocker after `ApiService`.**

```dart
// lib/config/env.dart:1-23
class Env {
  static late Environment current;
  static late String apiUrl;
  ...
}
```
Same pattern. `Env.init(...)` mutates global state.

### C4. Singletons that cannot be replaced in tests 🟠 [MEDIUM]

Paradoxically, `ApiService` is **not** a singleton — it is constructed at every call site. This creates an *allocation* problem (`docs/AUDIT_PERF.md`) without giving any testability benefit. Replacing each `ApiService()` with `ref.read(apiClientProvider)` simultaneously fixes both.

### C5. Business logic mixed into widgets 🔴 [HIGH]

`docs/AUDIT_ARCH.md` §C1, `docs/AUDIT_STATE.md` §B1, `docs/AUDIT_QUALITY.md` §B1. The same finding under the testing lens: until logic moves out of `State<T>` classes, every "test the business behaviour" attempt becomes a widget test.

### C6. `BuildContext`-coupled logic 🔴 [HIGH]

`docs/AUDIT_STATE.md` §E3. `_showSnack(message)` and other helpers reach into `ScaffoldMessenger.of(context)` from non-build code paths. `context.goNamed(RouteNames.home)` lives inside `_fetchLogin` (`login.dart:120`). Until controllers emit events that the widget translates, business code cannot be tested without a `MaterialApp` mounted.

### C7. `DateTime.now()` / `Random()` direct use 🟠 [MEDIUM]

11 sites. Today they cause no test failures because there are no tests. The moment a test for `prepareAvailabilityEvents` or `getFilterValue` lands, the test must inject a clock.

**Fix:** introduce `core/time/clock.dart`:
```dart
abstract class Clock {
  DateTime now();
}
class SystemClock implements Clock { @override DateTime now() => DateTime.now(); }
class FixedClock implements Clock {
  FixedClock(this._t);
  final DateTime _t;
  @override DateTime now() => _t;
}
```
Provide via Riverpod; default to `SystemClock`; override to `FixedClock` in tests.

---

## D. Critical Coverage Gaps

### D1. BLoC/Cubit coverage 🟢

**Not applicable — no BLoC, no Cubit.** Every state transition lives in `setState` calls, which cannot be tested in isolation.

### D2. Repository coverage 🔴 [HIGH]

**Not applicable — no repositories exist (`docs/AUDIT_ARCH.md` §D1).** All network access goes through the concrete `ApiService`.

When repositories land (per `docs/AUDIT_ARCH.md` Migration plan), each one needs:
- success case test
- error case test (server 500, network failure, malformed JSON)
- empty / null case test
- timeout case test (post-`docs/AUDIT_SEC.md` §F4 fix)

### D3. Use case coverage 🔴 [HIGH]

**Not applicable — no use cases exist.** Use cases are pure-Dart, the *easiest* code to test. After the migration lands, this will be the first layer to reach 80%+ coverage.

### D4. Form validation 🔴 [HIGH]

Validation lives inline in widget state:

```dart
// lib/auth/login/login.dart:151-156
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}
```
```dart
// lib/auth/sign_up/signup1_screen.dart:63
return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
```
```dart
// lib/Profile/profiledetils/edit_personal_details_screen.dart:35
return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
```

Three regexes copy-pasted, each on a state class private method. Untestable without pumping the widget. **The trivial fix** — extract to `lib/core/validation/{email,plus_code}.dart` (`docs/AUDIT_QUALITY.md` §C3) — makes all three testable in 5 minutes.

### D5. Navigation tests 🟢

**Not applicable — no tests.** When introduced, `lib/app/router.dart` is one of the most-changed files (every feature adds a route) and a `routerTest` would protect against breakages.

### D6. Error mapping 🔴 [HIGH]

Each screen handles errors differently (`docs/AUDIT_SCALE.md` §B3): five styles in one project. There is no central server-error-to-user-error mapping, so there is nothing to test.

---

## E. Infrastructure

### E1. Test helpers / fixtures / builders 🔴 [HIGH]

`test/_helpers/`, `test/fixtures/`, `test/builders/` — **none exist**.

Standard tooling missing:
- A `pumpApp` helper that mounts `ProviderScope` + `MaterialApp.router`.
- A `mockHttpClient()` helper using `mocktail`.
- DTO fixture JSON files (e.g., `test/fixtures/auth_login_success.json`) for `fromJson` round-trip tests.
- A `FakeSharedPreferences` builder.

### E2. CI runs tests 🔴 [HIGH]

`docs/AUDIT_SCALE.md` §F1, F3 — **no CI at all**. Even if the test surface improved, nothing enforces it on PRs.

### E3. Coverage reports 🔴 [HIGH]

No `coverage/` directory, no `lcov.info`, no `genhtml` invocation, no codecov / coveralls config. Coverage is invisible.

`flutter test --coverage` would emit `coverage/lcov.info`; nothing in the repo plumbs that into a tracker.

---

## Findings (severity order)

🔴 HIGH

- 0% measured coverage; lone test does not compile (A1–A3, B1).
- Zero test infrastructure: no mocking lib, no helpers, no fixtures, no CI (E1, E2, E3).
- Production code is structurally untestable: 58 concrete `ApiService()` constructions; `SharedService` static; `Env` static; no abstractions (C1, C2, C3).
- All business logic lives in `State<T>` classes (C5).
- All routing decisions live inside async `BuildContext`-coupled methods (C6).
- 9 hand-written `fromJson` factories with no round-trip tests; schema drift will surface as runtime nulls (D2).
- Three duplicated regexes (D4), three duplicated date formatters (`docs/AUDIT_QUALITY.md` §C1) — pure-Dart code that *could* be tested today, but lives inside widget files.

🟠 MEDIUM

- 11 direct `DateTime.now()` / `Random()` sites — non-deterministic, no `Clock` abstraction (C7).
- 13 `File(...)` constructor calls inside widget code; tests need real filesystem (C1 row).
- No request-side mocking seam — even when a test wants to stub a single HTTP call, the `Dio()` instances are constructed inside method bodies (C1 `Dio()` row).
- Hard-coded URL strings bypass `ApiEndpoints` in 4 sites (`docs/AUDIT_ARCH.md` §B5, B6) — tests cannot pin URLs.

🟡 LOW

- `pubspec.yaml` declares `flutter_lints: ^6.0.0` but no `prefer_const_constructors`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print` overrides (`docs/AUDIT_QUALITY.md` Top-fix #5). Some of these would surface test-hostile patterns at lint time.

---

## Priority test plan

Layer-ordered. Each row sequenced after its blocker resolves.

| # | Test | Type | Why critical | Effort | Blocker (must precede) |
|---|------|------|--------------|--------|-------------------------|
| 1 | `core/validation/email_test.dart` — valid, invalid, empty, edge (`a@b.co`, `a@b`, unicode) | unit | Login + sign-up gate; trivially testable | 30 min | Extract `isValidEmail` to `core/validation/` |
| 2 | `core/validation/plus_code_test.dart` — Google plus-code regex | unit | Signup1 + profile-edit forms; same regex copied twice | 20 min | Extract to `core/validation/` |
| 3 | `core/format/date_format_test.dart` — `formatDate`, `formatTime`, `formatDateTime` | unit | Three duplicated helpers; format strings differ silently | 30 min | Consolidate `DateTimeUtils` + inline helpers (`docs/AUDIT_QUALITY.md` Top-fix #4) |
| 4 | `data/auth/login_response_dto_test.dart` — happy path, missing `user`, null `token`, server `error:true` | unit | `Myprofilemodel.fromJson` etc. crash on malformed responses today | 30 min | Move DTOs into `data/`; introduce sealed `Result<T>` |
| 5 | All `lib/model_class/*.dart` `fromJson` round-trip tests | unit | 9 DTOs; null + empty + missing-field cases | 1 day | DTOs migrated to `data/`; fixture files committed under `test/fixtures/` |
| 6 | `core/network/api_client_test.dart` — interceptor adds Bearer, retries on 503, fails on timeout | unit | Single place network behaviour is observable post-refactor | 1 day | `ApiClient` abstraction lands (`docs/AUDIT_ARCH.md` Top-fix #1) |
| 7 | `features/auth/domain/login_use_case_test.dart` — success returns session, 401 returns `AuthFailure`, 500 surfaces `Failure.server` | unit | Login is the critical path; use case is pure Dart | 1 day | Use cases exist |
| 8 | `features/auth/presentation/login_controller_test.dart` — submit transitions loading → data, loading → error | unit | StateNotifier transitions guarded by AsyncValue | 0.5 day | Controllers exist |
| 9 | `features/home/domain/dashboard_use_case_test.dart` | unit | 7 fetchers → one aggregate use case | 1 day | Home controller exists |
| 10 | `features/profile/data/profile_repository_impl_test.dart` — photo upload, portfolio link CRUD | unit | Currently 9 ApiService sites in one screen | 1 day | Repository abstraction lands |
| 11 | `widget/login_screen_test.dart` — empty form disables button, valid form enables, network error shows snack | widget | Smoke for the gateway screen | 0.5 day | Controllers exist; `pumpApp` helper exists |
| 12 | `widget/dashboard_screen_test.dart` — loading shows skeleton, data shows counters, error shows retry button | widget | Replaces the "blank screen" failure mode | 0.5 day | Dashboard controller exists |
| 13 | `integration/login_to_home_test.dart` — full E2E with mocked backend | integration | Catches navigation + auth-state hand-off | 1 day | Integration_test/ scaffold |
| 14 | `golden/login_screen_golden_test.dart` — light/dark, locale variations | golden | Catches Theme drift after the dual-token system collapses (`docs/AUDIT_STRUCT.md` Top-fix #2) | 0.5 day | Single theme namespace lands |
| 15 | `widget/router_test.dart` — guard: unauthenticated user redirected from `/home` to `/login` | widget | The codebase has no router redirect today (`/splash` handles it) | 0.5 day | Router redirect lands |

**Realistic schedule:** ~3 weeks of focused work yields rows 1–10 (~70% coverage of new `core/` + `domain/` layers; ~30% of `data/`).

---

## Refactoring required to enable testing

This list is the strict ordered prerequisite for the test plan above.

1. **Introduce `core/network/ApiClient` (abstract) + Riverpod provider.** Replaces direct `ApiService()` constructions. (`docs/AUDIT_ARCH.md` Top-fix #1.)
2. **Introduce `core/storage/SessionStore` (abstract) + Riverpod provider.** Replaces static `SharedService`. (`docs/AUDIT_SEC.md` Top-fix #1.)
3. **Introduce `core/time/Clock` (abstract) + Riverpod provider.** Replaces direct `DateTime.now()`.
4. **Wire `ProviderScope` at app root.** Uncomment `lib/app/app.dart`. Without this, no provider override works.
5. **Extract validation, formatting, and role-mapping helpers from widgets into `core/`.**
6. **Migrate auth + home features to `features/<x>/{data,domain,presentation}` per `docs/AUDIT_ARCH.md` Migration plan.**
7. **Replace inline JSON DTOs with named DTO classes per feature; add fixture files under `test/fixtures/`.**
8. **Add `mocktail`, `network_image_mock`, optionally `golden_toolkit` to `dev_dependencies`.**
9. **Add `test/_helpers/pump_app.dart` and `test/_helpers/test_fakes.dart`.**
10. **Add GitHub Actions running `flutter test --coverage` per PR.** (`docs/AUDIT_SCALE.md` Top-fix #1.)

Until steps 1–4 land, *no* unit test of the existing widgets can be written without mounting the real network and real platform channels.

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Replace `test/widget_test.dart` template with a minimal compiling smoke test today.** *Effort: 15 minutes.* *Impact:* gets `flutter test` to green; sets the precedent for what a test in this repo looks like. Even pumping `const SizedBox()` is better than the broken counter template — at least CI (once stood up) reports a number.

2. 🔴 **Add `mocktail` + a `pump_app` helper + one validation test (`core/validation/email_test.dart`).** *Effort: 1 hour.* *Impact:* establishes the entire testing surface: a mocking lib, a helper, a fixture-free test, a first green example. Subsequent tests are copy-and-modify.

3. 🔴 **Extract regex/format/role-mapping helpers from widgets into `core/validation/` and `core/format/`** (`docs/AUDIT_QUALITY.md` Top-fix #4). *Effort: 1 dev-day.* *Impact:* turns three currently-untestable widget methods into ten pure-Dart functions covered in an hour. Single biggest near-term coverage win.

4. 🔴 **Stand up the `ApiClient`/`SessionStore`/`Clock` abstractions per `docs/AUDIT_ARCH.md` Top-fix #1 and `docs/AUDIT_SEC.md` Top-fix #1.** *Effort: ~1 dev-week (combined).* *Impact:* unblocks every controller / use case / repository test. Without this, every other testing investment plateaus at validation/formatting helpers.

5. 🟠 **Add CI that runs `flutter analyze` + `flutter test --coverage` per PR; upload `lcov.info` to a coverage tracker.** *Effort: 1 dev-day.* *Impact:* makes coverage visible; trends become reviewable in PR comments; regressions surface immediately. Combined with `docs/AUDIT_SCALE.md` Top-fix #1.

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and the audit set `docs/AUDIT_ARCH.md` / `docs/AUDIT_STATE.md` / `docs/AUDIT_STRUCT.md` / `docs/AUDIT_QUALITY.md` / `docs/AUDIT_PERF.md` / `docs/AUDIT_SEC.md` / `docs/AUDIT_SCALE.md` / `docs/AUDIT_FLAVOR.md`. All `.md` artefacts under `docs/` per project rule.*
