# Migration Log — Beige Creative App (Crew)

> Decisions, judgment calls, and deviations from `MIGRATION_PLAN.md` / `MIGRATION_RULES.md` are logged here during migration.
> Format: date (ISO), section header. Each entry lists **Changes**, **Decisions** (with rationale), and **Constraints Maintained** (what was preserved — e.g., zero visual drift, `flutter analyze` zero errors).
>
> See also: [`MIGRATION_PLAN.md`](MIGRATION_PLAN.md) · [`MIGRATION_RULES.md`](MIGRATION_RULES.md) · [`docs/migration/`](docs/migration/) (phase plans).

---

### 2026-05-28: Phase 3 Task 3.20 — Shared design-system widgets

- **Changes**:
  - Built 6 shared widgets under `lib/shared/widgets/`:
    - `app_button.dart` — `AppButton` with 5 variants (`primary/secondary/outline/text/destructive`) × 3 sizes (`sm/md/lg`) + `isLoading`, `icon`, `fullWidth` flags. Inline `_ButtonColors` record for per-variant palette.
    - `app_card.dart` — `AppCard` with 3 variants (`flat/outlined/elevated`) + optional `onTap` (wraps in `Material > InkWell`) + customizable `padding`/`backgroundColor`.
    - `app_text_field.dart` — `AppTextField` wrapping `TextFormField`. Supports `controller`/`initialValue`, label, hint, error, prefix icon, suffix slot, formatters, validator, max-lines/length, focus node, autovalidate mode.
    - `app_avatar.dart` — `AppAvatar` with `xs/sm/md/lg/xl` sizes; renders `CachedNetworkImage` when `imageUrl` is set, falls back to initials (`Bob Marley` → "BM", `Cher` → "C", empty → "?").
    - `app_loading.dart` — `AppLoading` centered spinner + optional caption.
    - `app_empty_state.dart` — `AppEmptyState` icon + title + optional description + optional CTA (consumes `AppButton`).
  - Built 6 smoke tests under `test/shared/widgets/` — 11 cases total, all passing. Covers render correctness, tap dispatch, loading-state blocking, initials fallback, optional-prop omission.

- **Decisions**:
  - **Used direct `AppColors.*` over `Theme.of(context)`** — `AppTheme.dark()` already maps `AppColors` onto Material's `TextTheme` and color scheme. Adding `Theme.of(context).colorScheme.surface` here would just look up `AppColors.background` via two extra dereferences for no behavioral gain (dark mode only). Spec listed this as a "use" recommendation, not a hard rule. Light-mode work in a later phase can lift colors onto `Theme.of(context)` then.
  - **Used `withValues(alpha: 0.5)` for disabled-button background** — Material 3 API; works under Flutter 3.10+ which the project targets.
  - **`AppButton` `isLoading` does NOT swap the variant** — same surface, just replaces label with a spinner. Avoids size-jitter when transitioning into/out of loading.
  - **`AppCard.onTap == null` skips the `Material > InkWell` wrap** — tap-less cards render as a plain `DecoratedBox`, avoiding the ripple-affordance cue that says "tappable."
  - **`AppTextField` always renders the label outside the field** (rather than as `InputDecoration.labelText`) — gives a stable, non-floating label that matches the project's visual language.
  - **`AppAvatar` initials parser handles single-word names** ("Cher" → "C") and empty input ("?") explicitly — first-character + last-character fallback would otherwise repeat the same letter.
  - **Deferred guide §6.7 widgets** (`AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog`) per spec — Phase 4 features add them incrementally as needed. Avoids speculative widgets that don't have a consumer.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/shared/widgets/` → No issues found. Full analyze → 301 (baseline).
  - `flutter test test/shared/widgets/` → 11/11 passing. Full suite → 25/25 passing.
  - Zero raw `Color(0xFF…)` or inline `TextStyle(...)` in the six widget files (verified by reading).
  - No production caller touched — widgets exist but no Phase 4 consumer yet.

---

### 2026-05-28: Phase 3 Task 3.19 — `FirebaseService.initialize` stub

- **Changes**:
  - Created `lib/core/firebase/firebase_service.dart` — static `FirebaseService.initialize(Environment env) → Future<bool>` and `FirebaseService.isInitialized` getter.
  - Body: `try { await Firebase.initializeApp(); _initialized = true; CrashlyticsService.registerErrorHandlers(); await CrashlyticsService.setCustomKey(flavor, env.name); return true; } catch (e, st) { AppLogger.w(...); return false; }`.
  - Idempotent — `_initialized` short-circuits second invocation.
  - Updated `lib/main.dart` — `await FirebaseService.initialize(environment);` runs right after `WidgetsFlutterBinding.ensureInitialized()` and before `PrefsService.init()`. Failure is benign (telemetry stays in stub-log mode from Task 3.18).

- **Decisions**:
  - **Bare `Firebase.initializeApp()` (no `options:`)** — relies on the platform-side `google-services.json` / `GoogleService-Info.plist` discovery. Passing explicit `options` would require generating `firebase_options.dart` via `flutterfire configure`, which the spec defers to a pre-prod ticket. Bare call gracefully throws when native config is missing → caught + logged.
  - **`runZonedGuarded` deferred** — adding it requires wrapping every entry-point (`main_dev.dart`, `main_prod.dart`) in `runZonedGuarded(() async { await startApp(...); }, (e, s) => CrashlyticsService.recordError(e, s, fatal: true))`. The spec's task scope is "max 2 files"; adding it now would force a 4-file edit and risk silently swallowing async errors that the framework handler would otherwise surface. The `registerErrorHandlers()` Flutter+Platform pair catches the dominant crash paths.
  - **Initialize Firebase *before* `PrefsService.init`** — `PrefsService` reads `flutter_secure_storage`, which can throw on first run; if it does, having Crashlytics handlers already wired ensures the crash gets captured.
  - **`bool` return value, not `void`** — lets a future feature branch on `FirebaseService.isInitialized` if it needs to avoid no-op behavior for telemetry-critical flows.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/firebase/ lib/main.dart` → No issues found. Full analyze → 301 (baseline).
  - `flutter test` → 14/14 passing. The test environment has no Firebase config — `initialize` returns false there, telemetry stays in stub-log mode (visible in widget-test output as `Crashlytics(stubbed): ...`).

---

### 2026-05-28: Phase 3 Task 3.18 — `AnalyticsService` + `CrashlyticsService`

- **Changes**:
  - Created `lib/core/firebase/analytics_events.dart` — 14 `lowercase_snake_case` event-name constants grouped by domain (auth, shoots, profile, availability, navigation).
  - Created `lib/core/firebase/crashlytics_keys.dart` — 5 custom-key constants (`flavor`, `user_id`, `user_role`, `last_route`, `feature_area`).
  - Created `lib/core/firebase/analytics_service.dart` — static wrapper around `FirebaseAnalytics.instance` with `logEvent`, `logLogin`, `logScreenView`, `setUserId`. `_isFirebaseAvailable` guard short-circuits when `Firebase.apps.isEmpty` so dev builds work pre-`flutterfire configure`. `buildObserver()` exposes a `FirebaseAnalyticsObserver` if config is present.
  - Created `lib/core/firebase/crashlytics_service.dart` — static wrapper with `setCustomKey`, `setUserIdentifier`, `recordError`, `log`. `registerErrorHandlers()` wires `FlutterError.onError` + `PlatformDispatcher.instance.onError` to forward into Crashlytics. Same config-absent short-circuit as Analytics.
  - Upgraded `lib/core/firebase/app_analytics_observer.dart` from a no-op stub into a delegating `NavigatorObserver`. Forwards push/replace/pop into the live `FirebaseAnalyticsObserver` (when present) AND writes the current route name to the Crashlytics `last_route` custom key on every nav event.

- **Decisions**:
  - **`Firebase.apps.isEmpty` guard, not a separate "isConfigured" flag** — single source of truth (the SDK itself). Wrapping in `try { … } catch (_) { false }` defends against the case where `Firebase` symbol resolves but the platform channel isn't initialized.
  - **All methods on `AnalyticsService` / `CrashlyticsService` are static** — matches the existing `AppLogger` pattern and avoids forcing Riverpod for trivial fire-and-forget telemetry. If we ever want test-time injection, we can swap to providers without changing call sites (move to a singleton + `late final _instance` overrideable in test).
  - **Did not wire `screen_view` events explicitly** — the Firebase `NavigatorObserver` already emits `screen_view` events on push/replace; double-emitting from our observer would inflate counts. Our observer adds the `last_route` Crashlytics breadcrumb on top.
  - **`crashlyticsKeys.flavor` set later** — `FirebaseService.initialize` (Task 3.19) is the right home for it. Setting from this task would require either coupling the wrapper to `Env` (already imported transitively, would work) or pre-init logic in `startApp`. Cleaner to do it in 3.19's bootstrap.
  - **Native auto-tracking disable deferred** — `firebase_analytics_collection_enabled` manifest/plist toggle belongs to the pre-prod `flutterfire configure` task. Adding it now without the corresponding native config files would be inert.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/firebase/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline.
  - `flutter test` → 14/14 passing. Widget-test console output (`Crashlytics(stubbed): setCustomKey last_route=splash`) confirms the observer is wired into the router and the stub path is exercised correctly.

---

### 2026-05-28: Phase 3 Task 3.17 — GoRouter auth redirect + observer

- **Changes**:
  - Created `lib/core/providers/auth_state_provider.dart` — `authStateProvider = StateProvider<bool>((_) => false)`. Single source of truth for "logged in" at the routing layer.
  - Created `lib/core/firebase/app_analytics_observer.dart` — `class AppAnalyticsObserver extends NavigatorObserver` no-op stub. Task 3.18 fills the body with the real `FirebaseAnalyticsObserver` delegate.
  - Rewrote `lib/app/router.dart`:
    - Added `routerProvider = Provider<GoRouter>((ref) { … })` reading `authStateProvider`.
    - `_AuthRefreshNotifier extends ChangeNotifier` adapter listens to auth state via `ref.listen(...)` and notifies the router's `refreshListenable` so redirect re-evaluates on token writes/clears.
    - Public-route allowlist (`_publicRoutes` const set) covers splash, onboarding, login, sign-up steps, forgot/reset password.
    - `redirect:` enforces: unauthed user on protected route → `/login`; authed user on auth-flow route (`/login`, `/signup-*`, `/forgot-*`, `/reset-password`) → `/home`.
    - `observers: [AppAnalyticsObserver()]` wired in (stub for now).
    - Route list extracted to a private `_routes` `List<GoRoute>` so both `routerProvider` and the legacy top-level `appRouter` constant share one definition. Legacy const left in place for any not-yet-migrated importer.
  - Updated `lib/app/app.dart` — `App.build` now does `ref.watch(routerProvider)` instead of importing the bare `appRouter` constant.
  - Updated `lib/main.dart` — added `authStateProvider.overrideWith((_) => PrefsService.isLoggedIn)` to the `ProviderScope` overrides. Re-imports `auth_state_provider`.

- **Decisions**:
  - **`StateProvider<bool>` over `FutureProvider<bool>` / `AsyncNotifier`** — the redirect path must be synchronous to avoid a frame of flicker. Cold-boot value is computed synchronously in `startApp` via `PrefsService.isLoggedIn` (which reads the in-memory secure-token cache primed during `PrefsService.init()`). Mutation surface (login success, logout, 401) is just `ref.read(authStateProvider.notifier).state = …`.
  - **`_AuthRefreshNotifier` ChangeNotifier adapter** — go_router's `refreshListenable` wants a `Listenable`; Riverpod state lives in `ProviderListenable`. The adapter is the minimal idiomatic bridge — listens with `ref.listen`, fires `notifyListeners()`. Disposed via `ref.onDispose(notifier.dispose)`.
  - **Kept the top-level `final GoRouter appRouter` constant** — couldn't find a not-yet-migrated importer, but the test harness already runs `pumpProviderApp` and `App` smoke; preserving the symbol avoids a surprise breakage if any external (e.g. screen module) reaches for the constant. Phase 5.01 can delete it.
  - **`AppAnalyticsObserver` non-`const` constructor** — `NavigatorObserver` super has no const constructor, so the subclass can't be const either. Acceptable: observers list is built once per router and the cost of two object allocations is invisible.
  - **Did not add unit tests for redirect logic** — go_router's `redirect` is awkward to test in pure Dart (needs a full `MaterialApp` + navigator); pumping the auth flow is a Phase 4 widget-test target (auth feature migration). The redirect is a 12-line pure function and is reviewed by inspection.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/app/ lib/main.dart lib/core/providers/ lib/core/firebase/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline.
  - `flutter test` → 14/14 passing.

---

### 2026-05-28: Phase 3 Task 3.16 — `pumpProviderApp` test helper

- **Changes**:
  - Created `test/helpers/pump_app.dart` — `PumpProviderApp` extension on `WidgetTester` with `pumpProviderApp(Widget, {List<Override> overrides, ThemeData? theme})`. Wraps in `ProviderScope > MaterialApp(home: Directionality(child: widget))`.
  - Created `test/helpers/pump_app_test.dart` — smoke test that overrides `dioClientProvider` with `DioClient.withDio(Dio(BaseOptions(baseUrl: 'https://override.example/')))` and asserts the consumer reads the overridden baseUrl. Passing.

- **Decisions**:
  - **Extension method on `WidgetTester`** rather than top-level function — composes with the existing `await tester.pumpWidget(...)` pattern and feels native at call sites (`await tester.pumpProviderApp(...)`).
  - **`Directionality(textDirection: TextDirection.ltr)` wrap** around the home widget — leaf widget tests sometimes read `Directionality.of(context)` without a containing `MaterialApp` ancestor. The `MaterialApp` already provides this, so the inner wrap is belt-and-suspenders for tests that pump a child of `home`. Negligible cost.
  - **Optional `ThemeData? theme` param** — lets tests opt into `AppTheme.dark()` if they need theme-aware widgets to render correctly. Default `null` keeps the helper minimal.
  - **Helper is dependency-free** — no `mocks.dart` / `test_data.dart` imports. Those land in Phase 6.01. Today's helper is the smallest surface needed to widget-test the splash + onboarding pilot.
  - **Routing-aware widgets pump their own `MaterialApp.router`** — the helper deliberately uses `MaterialApp(home: ...)` because the auto-tester smoke for the whole `App` (in `test/widget_test.dart`) already covers the router path. Mixing `home:` and `router:` in one helper would force callers to pick a mode anyway.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze test/helpers/` → No issues found.
  - `flutter test` → 14/14 passing.

---

### 2026-05-28: Phase 3 Task 3.15 — Resurrect `lib/app/app.dart` + `ProviderScope`

- **Changes**:
  - Uncommented + finished `lib/app/app.dart` — `App extends ConsumerWidget` builds `MaterialApp.router` with `appRouter` + `AppTheme.dark()`. Removed the global `scaffoldMessengerKey` stub (unused; can return if a feature needs it later).
  - Rewrote `lib/main.dart` to mount `ProviderScope` and call `const App()` instead of `MyApp(isLoggedIn:)`. `MyApp` class deleted.
  - `ProviderScope` overrides:
    - `sharedPreferencesProvider.overrideWith((_) async => prefs)` — pre-resolved `SharedPreferences` from `getInstance()`.
    - `sessionStoreProvider.overrideWithValue(session)` — live `CompositeSessionStore` from the wiring done in Task 3.14.
  - Rewrote `test/widget_test.dart` — pumps `ProviderScope(...App())` with mock prefs (`SharedPreferences.setMockInitialValues({})`) and an in-test `SecureSessionBackend` fake. Smoke test confirms `MaterialApp` builds.

- **Decisions**:
  - **Dropped `isLoggedIn` constructor plumbing** — it was only ever read by `MyApp` to choose a boot path, but the router's `initialLocation` was already `/splash` regardless. Auth branching belongs to the router redirect (Task 3.17 wires the redirect; this task just removes the dead wiring).
  - **Override `sharedPreferencesProvider` with a pre-resolved future** rather than re-running `SharedPreferences.getInstance()` inside the provider body. The instance is already paid for during `startApp`; re-fetching would duplicate work and could race with the `SessionMigration.runOnce` pass.
  - **No global `scaffoldMessengerKey`** — the old commented-out scaffold included one "for pre-GoRouter screens that show snackbars outside of a widget context". Phase 1/2 migration removed those screens; carrying the key forward would be dead infrastructure. Easy to reintroduce if a feature needs it.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/app/app.dart lib/main.dart test/widget_test.dart` → No issues found. Full analyze → 301 (baseline + 2 expected deprecation infos from Task 3.14).
  - `flutter test` → 13/13 passing.
  - No commented-out blocks in `lib/app/app.dart` (per `MIGRATION_RULES.md` §10).
  - `main_dev.dart` / `main_prod.dart` untouched — they still call `startApp(Environment.x)` unchanged.

---

### 2026-05-28: Phase 3 Task 3.14 — Token migration + `SharedService` shim + scoped `logout()`

- **Changes**:
  - Created `lib/core/session/session_migration.dart` with `SessionMigration.runOnce({prefs, session})`. Guards with sentinel `session_migration_v1_done`. If `prefs['token']` non-empty and `session.readToken()` empty, copies token across, deletes prefs key, sets sentinel. Idempotent — exits early on subsequent boots.
  - Rewrote `lib/service/shared_service.dart` as a `@Deprecated`-annotated shim. Static API preserved (`setLoginDetails`, `logout`); both delegate to a bound `SessionStore`. `bind(SessionStore)` is the wiring entry point. Lazy fallback (`_session()`) builds a `CompositeSessionStore` on-demand if `bind` was skipped — defensive coverage for migration-window edge cases.
  - `setLoginDetails` now extracts both token AND user snapshot from `response.data.user` (best-effort `UserSnapshot.fromJson`, never blocks login on parse error) AND records `lastLoginAt` as UTC `DateTime.now()`. Closes the gap where login flow lost the user snapshot.
  - `logout` now calls `session.clearSession()` — deletes token + refresh + user + lastLoginAt by key. `prefs.clear()` is no longer reachable via `SharedService`. Closes AUDIT_SEC finding on blanket-wipe-on-logout.
  - `lib/main.dart` wires the startup sequence: `Env.init` → `PrefsService.init` → `SharedPreferences.getInstance` → build `CompositeSessionStore(SecureSessionStore(), PrefsSessionStore(prefs))` → `SessionMigration.runOnce` → `SharedService.bind(session)` → resolve `isLoggedIn` → `runApp`. All before any network call.

- **Decisions**:
  - **Sentinel suffix `_v1`** — future schema changes (e.g. moving refresh token, adding a key) can bump to `_v2` to re-trigger one-shot migration without re-writing the helper.
  - **Secure-store wins when both have a token** — migration only writes legacy → secure if secure is empty. Avoids overwriting a freshly-acquired token if a previous session managed to write secure but failed to clear prefs.
  - **Class-level `@Deprecated`, not per-method** — single emission point per call site. The two existing call sites (`auth/login/login.dart`, `profile/myprofile.dart`) now surface as `deprecated_member_use_from_same_package` info-level lints, which act as the migration radar for Phase 4.
  - **`SharedService.bind()` is non-deprecated** — it is the migration plumbing itself, not a legacy API. The class's `@Deprecated` decoration trips a sigil on the call site in `main.dart`; suppressed with `// ignore: deprecated_member_use_from_same_package` because that's the wiring layer, not a feature consumer.
  - **Capturing user snapshot during `setLoginDetails`** — previously the user data from login response was unused; identity fields were re-fetched from `/profile`. Now `SessionStore.writeUser` persists it so the dashboard can render fields immediately. Drops one round trip on the cold-boot path.
  - **No `@Deprecated` on `SharedService.bind()`** — wiring layer, not a feature consumer.
  - **`PrefsService.init` still called** — it sets up the legacy in-memory token cache + first-launch-wipe sentinel. Removing it would break the 50+ call sites that read `PrefsService.token` directly. Phase 4 migrates those incrementally; Phase 5.01 deletes `PrefsService`.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/main.dart lib/service/shared_service.dart lib/core/session/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline + 2 expected `deprecated_member_use_from_same_package` info lints on `SharedService` call sites (migration radar).
  - `flutter test` → 13/13 passing.
  - Public surface of `SharedService` unchanged — both existing call sites compile + execute without edits.

---

### 2026-05-28: Phase 3 Task 3.13 — `SessionStore` interface + impls

- **Changes**:
  - Expanded `lib/core/session/session_store.dart` from a 3-method stub (left over from Task 3.11) into the full composite interface: token + refresh CRUD, user snapshot CRUD, `readLastLoginAt`/`writeLastLoginAt`, `isLoggedIn`, `clearSession`. Added `UserSnapshot` value type (id, name, email, role, userType, profileImageUrl) with `fromJson`/`toJson`/equality.
  - Added concrete `CompositeSessionStore implements SessionStore` (in the same file) wiring two backends via public structural contracts `SecureSessionBackend` + `PrefsSessionBackend`.
  - Created `lib/core/session/secure_session_store.dart` — `SecureSessionStore implements SecureSessionBackend`. Token + refresh stored in `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences-backed Keystore on Android). Constructor takes optional `FlutterSecureStorage` for test injection.
  - Created `lib/core/session/prefs_session_store.dart` — `PrefsSessionStore implements PrefsSessionBackend`. User snapshot serialized to JSON in `SharedPreferences` under `session_user_snapshot`; `lastLoginAt` stored as ISO-8601 string under `session_last_login_at`.
  - Round-trip unit tests added at `test/core/session/session_store_test.dart` — 6 cases, all passing. Uses an in-memory `SecureSessionBackend` fake + `SharedPreferences.setMockInitialValues({})` so it never touches the real Keychain.

- **Decisions**:
  - **Public structural contracts (`SecureSessionBackend`, `PrefsSessionBackend`)** rather than typing the composite against `SecureSessionStore`/`PrefsSessionStore` concretes — lets test fakes implement the surface they need without mocking the entire concrete class. Cleaner than `mocktail` for this layer.
  - **Composite class in the same file as the interface** to stay within the spec's "max 3 files" budget. Backends are in their own files; composite is a small wiring class so co-locating with the interface is fine.
  - **`isLoggedIn()` derived from secure-token presence**, not from a separate prefs flag. Matches the existing `SharedService`/`PrefsService` invariant ("token presence is the single source of truth for 'logged in'") and avoids a desync between prefs flag and actual token.
  - **`UserSnapshot` kept narrow** — id, name, email, role, userType, profileImageUrl. Full profile data still belongs to the profile feature; the snapshot exists just to bootstrap the UI before the profile fetch resolves.
  - **No call-site migration in this task** — task spec is explicit: "No call sites touched yet — this lands the primitive only." Legacy `SharedService` / `PrefsService` / `SecureStorageService` are untouched. Task 3.14 migrates them via shim.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/session/ lib/core/providers/` → No issues found.
  - `flutter analyze` (full) → 299 issues (within baseline ±).
  - `flutter test` → 13/13 passing (6 exception-handler + 6 session round-trip + 1 widget smoke).

---

### 2026-05-28: Phase 3 Task 3.12 — Swap `api_service.dart` internals to `DioClient`

- **Changes**:
  - Rewrote `lib/service/api_service.dart` end-to-end. Public surface preserved verbatim — 68 call sites compile without edits.
  - Internals now route through a static lazy `DioClient` (`_ensureClient()` builds once, caches instance) with the canonical interceptor chain: `Auth → Retry → Error → Logging` (logging gated by `kDebugMode`).
  - `AuthInterceptor` reads token via `PrefsService.token`. Per-call `createAuthorizationHeader()` removed.
  - `postMultipartStep3` no longer bypasses auth — runs through the shared client. Closes the AUDIT_SEC finding that Step 3 was unauthenticated.
  - All `http.{get,post,put,delete}` calls + `http.MultipartRequest` replaced with `_dio.{get,post,put,delete}<dynamic>` + `Dio.FormData`. Zero `package:http` imports remain in `lib/service/`.
  - Cleaned up `lib/profile/myprofile.dart:_uploadImage` — the one remaining caller of `createAuthorizationHeader()`. Now uses the canonical `ApiService().postMultipart(...)` path, eliminating a parallel raw `Dio()` instance + hand-built Bearer header.

- **Decisions**:
  - **Static lazy `_client` field** (rather than per-instance) — 68 call sites share the same Dio. Avoids 68 redundant Dio instances + interceptor chains. Per-instance was correct but wasteful.
  - **Tried-and-true `try/catch DioException → throw Exception('Failed to ...')`** preserved for the legacy facade — keeps return-contract compatibility for callers that still do bare `try/catch`. Typed `AppException` flow lives on the new repository pattern (Phase 4 migration target).
  - **`postMultipart` content-type left to Dio** — `FormData` auto-sets `multipart/form-data; boundary=...`. The legacy code's explicit `Content-Type: multipart/form-data` actually broke boundaries on some servers; dropping it is the right move.
  - **`http` package kept in `pubspec.yaml`** — task notes say Phase 5.02 removes it. Leaving it avoids a surprise import-not-found if any feature edge case still references `package:http` indirectly.
  - **`_uploadImage` fixed in this task, not deferred to Phase 4** — it was a direct compile-break from `createAuthorizationHeader()` removal. The replacement is a 1:1 functional swap (same endpoint path, same `crew_member_id` + `profile_photo` payload).
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/service/api_service.dart` → No issues found.
  - `flutter analyze` (full) → 298 issues (3 fewer than baseline; old api_service had type-inference lints).
  - `flutter test` → 7/7 passing (6 exception-handler + 1 widget smoke).
  - Zero `package:http` imports in `lib/service/`.
  - Public signatures of all 10 `ApiService` methods unchanged.

---

### 2026-05-28: Phase 3 Task 3.11 — `core_providers.dart`

- **Changes**:
  - Created `lib/core/providers/core_providers.dart` with 4 singleton providers (no `.autoDispose` per `MIGRATION_RULES.md` §3.10):
    - `sharedPreferencesProvider` — `FutureProvider<SharedPreferences>`. Body throws `UnimplementedError`; overridden in `startApp` (after `SharedPreferences.getInstance()`) and in `pumpProviderApp` (Task 3.16).
    - `sessionStoreProvider` — `Provider<SessionStore>`. Body throws until overridden — concrete impl arrives in Task 3.13.
    - `dioClientProvider` — `Provider<DioClient>`. Reads `sessionStoreProvider`, builds a fresh `DioClient`, and attaches the canonical interceptor chain `Auth → Retry → Error → Logging` (Logging is `kDebugMode`-gated by inclusion-time `if`).
    - `connectivityProvider` — `StreamProvider<List<ConnectivityResult>>` (matches `connectivity_plus ^6.x` API).
  - Created `lib/core/session/session_store.dart` — minimal abstract `SessionStore` interface stub with `readToken / writeToken / clearSession`. Task 3.13 expands it (user snapshot, refresh token, etc.) and adds the concrete `Secure` / `Prefs` implementations.

- **Decisions**:
  - **Throwing `UnimplementedError` in provider bodies** instead of returning a noop/null default — forces test harnesses and `startApp` to override explicitly. Silent default impls hide misconfiguration until the first network call.
  - **Stub `SessionStore` abstract interface added here, not deferred to 3.13** — providers need a real type to expose; an abstract three-method interface is a small, stable surface and Task 3.13 can extend it backward-compatibly.
  - **Interceptor chain assembled inside the provider, not on `DioClient` itself** — keeps `DioClient` free of Riverpod/`SessionStore` deps. Tests can override `dioClientProvider` to inject a `DioClient.withDio(mockDio)`.
  - **`kDebugMode`-gated `LoggingInterceptor` via `if (kDebugMode) ...` in a list literal** — Dart tree-shakes both the import and the instantiation in release builds when the const expression is `false`.
  - **`connectivityProvider` typed as `List<ConnectivityResult>`** — `connectivity_plus ^6.x` switched from single result to list (multi-transport devices). Wrong type would have wedged consumers downstream.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/providers/ lib/core/session/` → No issues found.
  - Provider graph: `dioClient → session`; `prefs`, `connectivity` independent. No cycles.
  - Nothing wired into `runApp` yet — `ProviderScope` lands in Task 3.15.

---

### 2026-05-28: Phase 3 Task 3.10 — Interceptors (Auth + Retry + Error + Logging)

- **Changes**:
  - Created `lib/core/network/interceptors/` with 4 files:
    - `auth_interceptor.dart` — `AuthInterceptor extends QueuedInterceptor`. Constructor takes `tokenReader: Future<String?> Function()` + optional `onUnauthorized: Future<void> Function()`. `onRequest` injects `Authorization: Bearer <token>` when token non-empty. `onError` awaits `onUnauthorized?.call()` on HTTP 401 then forwards.
    - `retry_interceptor.dart` — `RetryInterceptor extends Interceptor`. 3 attempts, exponential backoff `[250ms, 500ms, 1000ms]`. Retries 5xx + transient transport (`connectionError`, `connectionTimeout`, `receiveTimeout`). Never retries 4xx or `DioExceptionType.cancel`. Attempt counter in `RequestOptions.extra['__retry_attempt__']`.
    - `error_interceptor.dart` — `ErrorInterceptor extends Interceptor`. Delegates to `ExceptionHandler.mapDioException(err, st)` and wraps the typed exception into `DioException.error` via `copyWith`. Repositories using `guardAsync` already get typed errors; this exists for non-guarded consumers (and for future logging hooks).
    - `logging_interceptor.dart` — `LoggingInterceptor extends Interceptor`. Gated by `kDebugMode`. Logs via `AppLogger.{d,w}`. Redacts header values for `authorization`, `cookie`, `x-api-key` to `<redacted>` before logging.
  - Refactored `lib/core/network/exceptions/exception_handler.dart`: renamed private `_mapDioException` → public `mapDioException` so the handler and `ErrorInterceptor` share one mapping function (single source of truth for Dio → AppException rules).

- **Decisions**:
  - **Token sourced via callback, not a `SessionStore` reference** — Task 3.13 introduces `SessionStore`; this task lands ahead. The `tokenReader: Future<String?> Function()` signature lets the eventual `SessionStore` plug in cleanly (`tokenReader: () => sessionStore.token`) without `AuthInterceptor` ever importing the future class. Tests inject a sync callback returning a fake token.
  - **`onUnauthorized` is a callback, not a router push** — keeps interceptor framework-agnostic (no `BuildContext`/`GoRouter` import). Provider in Task 3.11 wires it to "clear session + push login" once Task 3.17 router redirect lands.
  - **Refresh-token flow is a stub** — current backend has no refresh endpoint per `AUDIT_SEC.md`. 401 = session over. `QueuedInterceptor` base class still chosen so concurrent in-flight requests serialise through one token-read lane when refresh becomes available.
  - **`ErrorInterceptor` attaches via `copyWith(error: appException)`** — preserves the original `DioException` envelope (status, headers, request options) for any consumer that wants forensic data, while making the typed `AppException` immediately accessible at `dioException.error as AppException`.
  - **`LoggingInterceptor` uses `AppLogger`, not `print`** — consistent with the project convention in `CLAUDE.md`.
  - **Public mapper rename**: `ExceptionHandler._mapDioException` → `ExceptionHandler.mapDioException`. Re-ran `exception_handler_test.dart` (6/6 passing) to confirm no regression.
  - **Interceptor registration order** documented but not yet executed — happens in Task 3.11 (`dioClientProvider`): `Auth → Retry → Error → Logging`. Matches `MIGRATION_RULES.md` §5.4.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/{interceptors,exceptions}/` → No issues found.
  - `flutter test test/core/network/exception_handler_test.dart` → 6/6 passing after public-rename refactor.
  - No production code consumes interceptors yet; provider in Task 3.11 wires them.

---

### 2026-05-28: Phase 3 Task 3.09 — `DioClient` singleton

- **Changes**:
  - Created `lib/core/network/dio_client.dart` with `DioClient` class.
  - `BaseOptions`: `baseUrl: Env.apiUrl`, 15s connect/receive/send timeouts (Risk #20 — slow-loris path closed), `Accept: application/json` default header, `responseType: ResponseType.json`.
  - Default constructor instantiates a fresh `Dio` with the options above.
  - `DioClient.withDio(Dio)` named constructor — test seam for injecting a pre-configured Dio with mock adapter.
  - `attachInterceptors(List<Interceptor>)` extension point — Task 3.10 will use this to wire `AuthInterceptor`, `RetryInterceptor`, `ErrorInterceptor`, `LoggingInterceptor` without re-touching the class.

- **Decisions**:
  - **No constructor dependencies** — task spec mentions "takes dependencies for future interceptors", but flowing `SessionStore` through `DioClient` couples the holder to the auth concern. Cleaner: interceptors get their deps in their own constructors; `DioClient.attachInterceptors` just receives the pre-built list. Provider (Task 3.11) does the assembly.
  - **`Env.apiUrl` read once at construction** — Env must be initialized via `Env.init(...)` in `startApp` before the first `DioClient()` instance is built. Already the case in `lib/main.dart`.
  - **No global state / no singleton pattern** — provider owns the lifecycle. `DioClient()` is a plain class; tests can construct fresh instances or use `.withDio(...)`.
  - **`responseType: json` set explicitly** — defensive against future endpoints that return non-JSON. Repositories can override per-request.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/dio_client.dart` → No issues found.
  - No production code consumes `DioClient` yet — first wiring happens in Task 3.11 (provider) + Phase 4 (feature data sources).

---

### 2026-05-28: Phase 3 Task 3.08 — `ApiResponse<T>` wrapper

- **Changes**:
  - Created `lib/core/network/api_response.dart` with generic `ApiResponse<T>` class.
  - Fields: `final bool error`, `final String? message`, `final T? data`.
  - `factory ApiResponse.fromJson(Map<String, dynamic>, T Function(dynamic))` — defensively parses `error` (defaults to false on non-bool), reads `message` as nullable String, skips `dataParser` when `data` is null.
  - `void assertNoError()` — throws `ServerException(message: message ?? 'API returned error=true')` when `error == true`. Designed to be called inside a `guardAsync` block; the exception is caught and converted to `Either.Left`.

- **Decisions**:
  - **Made `assertNoError()` public** (not `_assertNoError`) — repositories call it directly. The task spec used the private name but the helper is the integration point with `guardAsync`; keeping it private would force repositories to either reach into private members (impossible across libraries) or duplicate the check.
  - **Threw `ServerException` rather than a new typed envelope error** — keeps the exception hierarchy lean. `error: true` from the backend doesn't carry HTTP semantics; treating it as a server-side application error is the cleanest fit.
  - **No `toJson()` / serialization back to map** — `ApiResponse` is read-only at the boundary. Outgoing payloads use DTO `toJson` directly.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/api_response.dart` → No issues found.
  - No production code consumes the wrapper yet — repositories will adopt it in Phase 4 feature work.

---

### 2026-05-28: Phase 3 Task 3.07 — Sealed `AppException` + `ExceptionHandler`

- **Changes**:
  - Created `lib/core/network/exceptions/` module with 6 files:
    - `app_exception.dart` — sealed base class + library declaration + `part` directives.
    - `network_exception.dart` (part) — `NoInternetException`, `TimeoutException`, `RequestCancelledException`.
    - `server_exception.dart` (part) — `ServerException` (with `statusCode`), `ServiceUnavailableException`.
    - `client_exception.dart` (part) — `UnauthorizedException` (401), `ForbiddenException` (403), `NotFoundException` (404), `ValidationException` (422 with `fieldErrors: Map<String, List<String>>`), `TooManyRequestsException` (429 with optional `retryAfter`).
    - `exception_handler.dart` — `ExceptionHandler.guardAsync<T>(Future<T> Function())` → `Either<AppException, T>` via `dartz`. Maps `DioException` by `DioExceptionType` + status code, `SocketException`, `dart:async.TimeoutException`, re-wrapped `AppException`, and fallback to `ServerException`.
    - `exceptions.dart` — barrel exports.
  - Added smoke test at `test/core/network/exception_handler_test.dart` — 6 cases (happy / 401 / 422+fieldErrors / 500 / connectionTimeout / AppException passthrough). All passing.

- **Decisions**:
  - **Used Dart `part` / `part of`** to split the sealed hierarchy across files. Dart prohibits extending a sealed class outside its declaring library, so the four subclass files are `part of 'app_exception.dart'`. The barrel exports only the library file + handler (parts aren't independently exportable). Consumers import the barrel and get the whole API.
  - **Class names match `MIGRATION_RULES.md` §5.3 verbatim** including `TimeoutException` (collides with `dart:async.TimeoutException` — handler uses `import 'dart:async' as dart_async;` to disambiguate). Library consumers can do the same if they need both types.
  - **Server message parsing**: handler checks `data['message']`, `data['error']`, and `data['detail']` in priority order. Field errors checked under `errors` or `field_errors` keys; list-or-string values both normalized to `List<String>`. `Retry-After` header parsed as integer seconds (HTTP-date variant not implemented; can extend in Phase 4 when an endpoint demands it).
  - **`ExceptionHandler` is non-instantiable** (private constructor) — pure static utility.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze` shows 301 issues (= baseline); module itself is "No issues found".
  - `flutter test test/core/network/exception_handler_test.dart` → 6/6 passing.
  - No production code touched outside the new `core/network/exceptions/` module — repositories will adopt `guardAsync` in Phase 4 feature work.

---

### 2026-05-28: Phase 3 Task 3.06 — Move `ApiEndpoints` to `lib/core/network/`

- **Changes**:
  - Created `lib/core/network/api_endpoints.dart` as new canonical location for `ApiEndpoints` class.
  - **Bug fix**: `add_availability` had a leading `/` ("/creator/add-availability") that would yield a double-slash when joined with `Env.apiUrl` (which already terminates in `api/`). Stripped the leading slash → now `"creator/add-availability"`, consistent with all 30 other endpoint constants.
  - Replaced `lib/service/api_endpoints.dart` with a single-line `export 'package:beige_creative_app/core/network/api_endpoints.dart';` shim so all 25 importing files continue to resolve without edits.
  - `docs/phase3/task_06_api_endpoints_move.md` updated: status → ✅ Completed, checkboxes marked.

- **Decisions**:
  - **Shim left at old path** — 25 importers across `auth/`, `home/`, `profile/`, `shoots/`, `manage_availability/`, `main_screen.dart` would otherwise need parallel edits. Per-feature migration to the new path can happen in Phase 4 alongside other feature work. Phase 5 retires the shim.
  - **Used `Write` instead of `git mv`** — equivalent effect with the shim re-export. The old path keeps the same identifier set via re-export, so consumer imports stay valid.
  - **No `// ignore_for_file: constant_identifier_names`** added — preserving baseline lint noise rather than introducing a new ignore directive. The snake_case constants will likely be renamed in Phase 4 feature work alongside per-feature data-source migration.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze` shows 301 issues — exactly the baseline; zero new lints introduced.
  - All 25 importing files still compile via the shim.
  - Endpoint string set unchanged except for the targeted `add_availability` slash fix.

---

### 2026-05-28: Phase 3 Task 3.05 — Legacy shims (⛔ Obsolete)

- **Changes**:
  - No code edits. Task marked ⛔ Obsolete — N/A.
  - `docs/phase3/task_05_design_tokens_shims.md` updated: status → ⛔ Obsolete, rationale documented.

- **Findings**:
  - `lib/utility/colorcode.dart` does not exist (deleted in commit `c416cb6`).
  - `lib/utility/imges_icons.dart` does not exist (deleted in prior Phase 1/2 work).
  - Zero `ColorCode.*` and zero `AppImages.*` references in `lib/`. All consumers migrated.
  - Task 3.05 was designed as a deprecation-shim layer for surfacing the migration to consumers. With zero consumers and zero source files, there is nothing to shim.

- **Decisions**:
  - **Skip Task 3.05 entirely** — the migration radar this task provides is moot. Creating empty deprecated classes for non-existent identifiers would add noise without benefit.
  - **Phase 5.01 cross-reference** — when Phase 5.01 ("delete shims") is reached, log it as "completed by Phase 1/2 cleanup" rather than re-doing the work.

- **Constraints Maintained**:
  - No source files touched.
  - `flutter analyze` baseline unchanged.

---

### 2026-05-28: Phase 3 Task 3.04 — Asset tokens audit

- **Changes**:
  - No code edits — audit-only. `AppAssets` already canonical, `AppImages` already retired.
  - `docs/phase3/task_04_design_tokens_assets.md` updated: status → ✅ Completed, checkboxes + audit notes.

- **Findings**:
  - `lib/utility/imges_icons.dart` no longer exists (removed in prior Phase 1/2 work — not just shimmed).
  - `lib/app/assets.dart` (189 LOC) holds the canonical `AppAssets` class with directory base constants (`_svg`, `_images`, `_lottie`, `_active`, `_inactive`, `_home`, `_shootSvg`, `_onboarding`) plus path constants grouped by category (active/inactive nav icons, home/common images, shoot SVGs, onboarding images, lottie animations, fonts).
  - Zero `AppImages.*` references in `lib/`.
  - 43 `AppAssets.*` call sites across `lib/`.
  - Zero hardcoded `'assets/...'` literal strings in widgets outside `lib/app/assets.dart`.
  - `flutter analyze lib/app/assets.dart`: 26 pre-existing info-level `constant_identifier_names` lints (legacy snake_case names retained for backward compat — `group_logo`, `clock_icon`, `photo_icon`, etc.); zero errors.

- **Decisions**:
  - **Snake_case constant names retained** — renaming would cascade to all 43 call sites for zero functional benefit. Flagged as optional Phase 4 cleanup if desired.
  - **Task 3.05 shim obsolete for assets** — `imges_icons.dart` is gone, not present. Task 3.05 may still cover `ColorCode` shim if requested, but no `AppImages` shim is needed.
  - **Stayed on `improvments-phase1` branch** — consistent with Tasks 3.01–3.03 directive.

- **Constraints Maintained**:
  - `flutter analyze lib/app/assets.dart` zero errors.
  - No source files touched — audit-only confirmation that prior phases already met Task 3.04 acceptance.

---

### 2026-05-28: Phase 3 Task 3.03 — Design tokens audit (spacing + radii + shadows + durations)

- **Changes**:
  - No code edits — audit-only task. All four token files already present and filled from prior Phase 1/2 sweeps.
  - `docs/phase3/task_03_design_tokens_spacing_radii.md` updated: status → ✅ Completed, checkboxes + audit notes.

- **Findings**:
  - `lib/app/spacing.dart` (214 LOC) — 4-px grid (`hairline/fine/xxxs..xxxl/huge/massive/jumbo/max`), off-grid component constants (`tabInnerPad`, `editProfileBtnH`, `folderCardInset`, `profileCardTop`, `avatarOverlapTop`), screen padding (`screenH/screenHWide/screenHAuth/screenV`), component-specific (`cardPadding`, `inputVertical`, `chipPaddingH/V`, `bottomNavHeight`), responsive factors (calendar event factors), convenience `EdgeInsets`, `SizedBox` gap helpers.
  - `lib/app/radii.dart` (215 LOC) — `none/xs/sm/md/mld/lg/statsInner/xl/xxl/xxxl/huge/portfolioCompact/authCard/massive/portfolio/header/round/sheet/roundLg/pillSm/pill/enormous/full`, outliers (`nano`, `eventLabel`, `signupChip`, `compactCard`, `clientContact`), convenience `BorderRadius` getters, top-only/bottom-only sheet roundings, standalone `Radius` constants.
  - `lib/app/shadows.dart` (164 LOC) — `none/sm/md/lg/xl` standard elevation + harvested `activeNavGlow`, `ctaDark`, `heroOverlay`, `goldCta`, `card/cardSubtle/cardBlack12/cardHeavy`, `viewerSheet`.
  - `lib/app/durations.dart` (34 LOC) — `instant (100ms)`, `fast (200)`, `fast250`, `normal (300)`, `pageTransition (350)`, `slow (500)`, `splash (800)`, `long (1000)`, `autoDismiss (2000)`.
  - Widget consumption: 44 (`AppSpacing`) + 41 (`AppRadii`) + 9 (`AppShadows`) + 2 (`AppDurations`) = 96 total reference sites in `lib/`.
  - `flutter analyze` on the 4 files: No issues found.

- **Decisions**:
  - **Theme-component wiring deferred** — `AppTheme.dark()` does not yet consume `AppSpacing/AppRadii/AppShadows/AppDurations`. `lib/app/theme.dart:107-124` keeps `inputDecorationTheme`, `cardTheme`, `bottomSheetTheme`, `dialogTheme`, `snackBarTheme`, `chipTheme`, etc. commented behind a "enable individually with screenshot diff" gate. Enabling them risks shifting widgets that don't pass explicit `shape:` or `padding:` — violates zero-visual-drift rule.
  - **Strict-match fidelity** — every harvested constant retains its original literal value verbatim. Off-grid values (e.g., `7.79` for calendar event labels, `11.5` for nested stats interior radius, `0.6` for fine inset) preserved by name, not snapped to grid.
  - **Stayed on `improvments-phase1` branch** — consistent with Tasks 3.01–3.02 directive.

- **Constraints Maintained**:
  - `flutter analyze` zero issues on `lib/app/{spacing,radii,shadows,durations}.dart`.
  - No source files touched — audit-only confirmation that prior phases already filled the Task 3.03 scaffolds.
  - Zero visual drift preserved by not edits.

---

### 2026-05-28: Phase 3 Task 3.02 — Design tokens audit (colors + text styles)

- **Changes**:
  - No code edits — audit-only task. Verified scaffolds against spec.
  - `docs/phase3/task_02_design_tokens_colors_text.md` updated: status → ✅ Completed, checkboxes marked with audit findings.

- **Findings**:
  - `lib/utility/colorcode.dart` no longer exists; `ColorCode` retired in commit `c416cb6` ("Centralize design tokens; migrate widgets to AppColors and retire ColorCode"). Zero `ColorCode.*` references remain in `lib/`.
  - `lib/app/colors.dart` (463 LOC) holds 200+ tokens grouped: brand, background/surface, text, semantic, border/divider, opacity variants, gradient, functional, status, map, and extended Phase 1 additions.
  - `lib/app/text_styles.dart` (573 LOC) defines all 13 §4.4 semantic styles (`displayLarge/Medium/Small`, `titleLarge/Medium/Small`, `bodyLarge/Medium/Small`, `labelLarge/Medium/Small`, `caption`) plus ~50 harvested extended exemplars (Phase 2 Batches 4–11) and an inherit/legacy bucket.
  - `lib/app/theme.dart` `AppTheme.dark()` maps `AppTextStyles.*` onto all 13 Material `TextTheme` slots and references only `AppColors.*`. Wired at `lib/main.dart:45`.
  - Zero inline `Color(0x…)` literals outside `colors.dart`. ~97 inline `TextStyle(` sites remain in feature widgets — Phase 4 per-feature replacement scope.

- **Decisions**:
  - **Not in scope:** widget-level inline `TextStyle(` replacement. Phase 3 covers token-scaffold creation; per-feature replacement is Phase 4.
  - **Kept `textfieldBorderLegacy = Color(0xFFE8D1AB80)`** (40-bit legacy value, info-level lint `use_full_hex_values_for_flutter_colors`) — intentional for zero visual drift. Documented in code comment.
  - **Stayed on `improvments-phase1` branch** — consistent with Task 3.01 directive.

- **Constraints Maintained**:
  - `flutter analyze lib/app/{colors,text_styles,theme}.dart lib/main.dart` → 1 pre-existing intentional info-level lint, zero errors/warnings.
  - No source files touched — audit-only confirmation that prior phases already met Task 3.02 acceptance.

---

### 2026-05-28: Phase 3 Task 3.01 — Add target packages

- **Changes**:
  - `pubspec.yaml`: added runtime deps `dartz ^0.10.1`, `freezed_annotation ^3.1.0`, `json_annotation ^4.9.0`, `connectivity_plus ^6.0.5`, `firebase_core ^3.6.0`, `firebase_analytics ^11.3.3`, `firebase_crashlytics ^4.1.3`.
  - `pubspec.yaml`: added dev deps `freezed ^3.2.3`, `json_serializable ^6.8.0`, `build_runner ^2.4.13`, `mocktail ^1.0.4`.
  - `flutter pub get` resolved (46 changed dependencies).
  - `flutter analyze` shows 301 pre-existing info/warnings; **zero errors** introduced.

- **Decisions**:
  - **Either/`Either` lib: chose `dartz`** over `fpdart` — smaller surface, matches `MIGRATION_PLAN.md` recommendation. Locks in for the project.
  - **`freezed_annotation ^3.1.0` (not `^2.4.4`)** — pinned up because `flutter_stripe ^12.1.1` → `stripe_platform_interface ^12.6.0` transitively requires `freezed_annotation ^3.1.0`. Bumped matching dev-dep `freezed` to `^3.2.3` for codegen compatibility with the 3.x annotation API.
  - **Stayed on `improvments-phase1` branch** instead of cutting `migration/phase3/deps` — user directive; sequential phase work continues on this branch.

- **Constraints Maintained**:
  - `flutter analyze` zero errors (only pre-existing info/warnings remain).
  - No source files touched — pubspec-only change.
  - Both `main_dev.dart` and `main_prod.dart` entrypoints unaffected; flavor configs untouched.

---

### 2026-05-27: Execution and validation of Phase 2 (Tasks 2.01–2.09)

- **Changes**:
  - Fully executed and closed all 9 tasks in Phase 2.
  - Typo and folder renames finalized: `onboding` → `onboarding`, `manageavailability` → `manage_availability`, `upcomingshootviewdetils` → `upcoming_shoot_view_details`, drop literal spaces in filenames, and convert all uppercase files/directories to `lowercase_snake_case`.
  - Import casings completely corrected inside `lib/` and `test/` to align with case-sensitive OS file paths.
  - Masked and sanitized Bearer token leakage in both `api_service.dart` and `myprofile.dart` logs.
  - Disabled cleartext traffic (`usesCleartextTraffic="false"`) inside `AndroidManifest.xml`.
  - Implemented prime target folder scaffold with empty directory `.gitkeep` anchors under `lib/core/`, `lib/shared/`, `lib/features/`, and `lib/dummy/`.
  - Introduced local env properties loader inside Kotlin Gradle DSL `build.gradle.kts` linking back-to-back build definitions dynamically into `AndroidManifest` configurations via `manifestPlaceholders`.
  - Transitioned Google Maps API and Stripe publishable keys out of source tree into environment definitions in `lib/config/env.dart` utilizing `String.fromEnvironment`. Committed template JSON environment variables to `env/`.
  - Pruned deprecated `flutter_dotenv` package from `pubspec.yaml` and cleaned non-existent assets directories.
  - Restored `IndexedStack` inside `main_screen.dart` tab bar to conserve visual session state during tab transitions.
  - Consolidated `/shoot-Cancel` duplicate route down to `/cancel-shoot`.
  - Configured robust continuous integration workflow file `ci.yml` run triggers for analyze, test, and dev flavor compilation check validation.
  - Updated conventions, environment variables, commands, and target folder layout specifications inside `CLAUDE.md`.
  - Staged and committed all changes into working branch `improvments-phase1`.

- **Decisions**:
  - **Dynamic Gradle Placeholder Decoder** — Used dynamic splitting and base64 parsing directly inside Kotlin Gradle script to extract keys from base64 dart-defines, keeping native builds entirely decoupling-friendly and dynamic.
  - **Secure Storage Retained** — Verified password persistence and did not regress keychain encryption security as secure storage wrapper was already standard in login.
  - **Consolidated Casing Enforcement** — Renamed and corrected all casing properties, ensuring zero compilation errors on strict environments.

- **Constraints Maintained**:
  - `flutter analyze` fully clean of compiler errors.
  - All test suites successfully green (`flutter test` passes 100%).
  - Branch shippability maintained.

### 2026-05-27: Guides cross-check patch — shared widgets, font note, models/utils tests

- **Changes**:
  - Cross-checked `MIGRATION_PLAN.md` + per-phase tasks against `docs/guides/FLUTTER_BASE_GUIDELINES.md`, `FLUTTER_DESIGN_SYSTEM.md`, `FLUTTER_TESTING_GUIDELINES.md`.
  - **New Phase 3 Task 3.20** — `docs/phase3/task_20_shared_widgets.md`: build `AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState` in `lib/shared/widgets/`. 6h estimate. Phase 3 total 19 → 20 tasks, 8 → 8.75 effort-days.
  - **New Phase 6 Task 6.14** — `docs/phase6/task_14_models_utils_tests.md`: unit tests for freezed DTOs, validators, formatters, extensions. 1d estimate. Phase 6 total 13 → 14 tasks, 16 → 17 effort-days.
  - **Task 3.02 font note** — appended explicit guard against guide's `Inter` example; preserve `Unbounded` + `Outfit` per current `pubspec.yaml`.
  - `MIGRATION_PLAN.md` Phase 3 + Phase 6 budget rows updated; TOTAL 93.5 → 95.25 effort-days.

- **Decisions**:
  - **Shared widgets at end of Phase 3, not split across Phase 4** — every Phase 4 feature consumes them, so build once before features migrate. Avoids per-feature reinvention and keeps Phase 4 acceptance ("zero magic numbers") enforceable.
  - **Limited to 6 widgets, not full §6.7 checklist** — `AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog` deferred until a Phase 4 feature needs them. Guide explicitly recommends incremental construction.
  - **Font preservation made explicit** — guides use `Inter` in examples but project ships `Unbounded` + `Outfit`. Without the note, Task 3.02 could silently re-introduce `Inter` and break visual parity. Zero visual drift is non-negotiable per `MIGRATION_RULES.md`.
  - **Models/utils tests folded into Phase 6, not Phase 4** — keeps Phase 4 PRs focused on feature migration; defers cheap coverage wins to the dedicated test phase.
  - **Gaps NOT patched (already covered)** — `CancelToken` ban for search/pagination already in `MIGRATION_RULES.md` §5.2 line 535 and in Task 4.14 step list. Connectivity pre-check ban already in `MIGRATION_RULES.md` §5.2 line 533. Verified before adding.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - File numbering preserved; new files append at end of each phase folder (no renames).

---

### 2026-05-27: Sprint-board restructure (`docs/phase<N>/` per phase, task-level chunks)

- **Changes**:
  - Created `docs/phase1/` … `docs/phase6/` — one folder per phase.
  - Each phase has a `README.md` (sprint board: task table + acceptance + dependencies) and one task file per chunk (`task_NN_<slug>.md`).
  - Total chunks: 73 task files across 6 phases + 6 phase READMEs = 79 new files.
    - Phase 1: 0 task files (read-only post-audit) — README only.
    - Phase 2: 9 tasks (folder renames, security hotfixes, secrets, CI, scaffold).
    - Phase 3: 19 tasks (deps, design tokens, network stack, session store, ProviderScope, router redirect, Firebase wrappers).
    - Phase 4: 23 tasks (feature migration — one per migration unit; god widgets split into preceding `.a` decomposition tasks).
    - Phase 5: 8 tasks (shim deletion, dep prune, cached images, comment hygiene, lint upgrade, naming polish, router final).
    - Phase 6: 13 tasks (test helpers, repo + Notifier + widget tests, goldens, integration tests, CI coverage gate).
  - Deleted single-file phase plans: `docs/migration/phase1_audit.md` … `phase6_testing.md` (702 LOC total). Replaced by chunked task files.
  - Kept under `docs/migration/`: `README.md` (legacy index), `flavor_bundle_id_plan.md` (companion). Both retain root link to `MIGRATION_PLAN.md`.
  - Appendix in `MIGRATION_PLAN.md` updated to point at new sprint boards.
  - Task file template: status header (🔴 / 🟡 / 🟢 / ⏭️) · owner / dates / PR / branch table · goal · references · files-in-scope (max 5–10 per task) · steps · acceptance · notes.

- **Decisions**:
  - **Sprint-planning granularity** — each task ≤10 files = ≤1 PR. Mirrors `MIGRATION_RULES.md` §1.1 ("if a step touches more than 8–10 files, break it into smaller steps").
  - **God-widget split-then-migrate as separate tasks** — `.a` (decompose, zero behavior change) + `.b` (migrate). Tracked separately so the split can be reviewed without Notifier noise.
  - **Phase 4 = 23 tasks not 22 migration units** — `signup1`, `signup3`, `myprofile`, `home_screen`, `featured_work_list` each get a `.a` decomposition predecessor.
  - **Phase 6 = 13 tasks not 5–7** — repository / Notifier / widget tests split into manageable batches so each task is ≤1.5 effort-days.
  - **Status emoji per user preference** — 🔴 Not Started · 🟡 In Progress · 🟢 Completed. Same legend on every README + task file.
  - **Path scheme** — phase folders sit directly under `docs/` (not under `docs/migration/`). Rationale: contributors expect `docs/phaseN/` to be the actionable sprint board; `docs/migration/` is legacy + companion docs.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - Old single-file phase plans deleted only after the new chunked structure was fully populated.

---

### 2026-05-27: Plan refresh + relocation to repo root

- **Changes**:
  - Moved `docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` (repo root) to match the sibling `biegeapp` layout (`MIGRATION_PLAN.md` + `MIGRATION_RULES.md` + `MIGRATION_LOG.md` co-located at root).
  - Created this file (`MIGRATION_LOG.md`) at the root.
  - Verified current LOC / file counts against `lib/` and updated plan tables:
    - Top god widgets re-measured: `signup3_screen.dart` 3,465 → 3,569; `home_screen.dart` 2,902 → 2,860; `myprofile.dart` 2,834 → 2,836; `featured_work_list.dart` 1,703 → 1,685; `signup1_screen.dart` 1,959 → 1,836; `signup2_screen.dart` 1,328 → 1,331; `upcoming_shoot_view_detils.dart` 1,396 → 1,184.
    - Several screens shrank: `login.dart` 464 → 382; `reset_password_screen.dart` 428 → 332; `forgot_password_screen.dart` 401 → 362; `file_manager_screen.dart` 661 → 604; `pre_production_screen.dart` 502 → 434.
    - One screen grew: `edit_personal_details_screen.dart` 589 → 666.
    - Total Dart LOC across `lib/`: 34,162 across 87 files (was ~30k across 38 screens; codebase grew).
  - 3 new profile screens folded into Group C: `change_password_screen.dart` (274 LOC), `profile_otp_screen.dart` (343 LOC), `featuredwork_details_screen.dart` (177 LOC).
  - Foundations checklist row 7 (`AppTheme.dark()`) flipped ⚠️ → ✅ — wired at `lib/main.dart:45`.
  - Foundations checklist note: `flutter_secure_storage ^9.2.2` already declared in `pubspec.yaml`.
  - Risk register #10 (Linux CI casing) downgraded H/H → H/M — `Home`, `Profile`, `Shoots` already lowercased; only `onboding`, `manageavailability`, `upcomingshootviewdetils` and the file with a literal space remain.
  - Hard blocker #1 (folder casing) marked partially done; Hard blocker #2 (target packages) updated to acknowledge `flutter_secure_storage` already present.
  - Phase 2.A budget trimmed 1.5 → 1 day; Phase 2.B trimmed 1 → 0.75 day; Phase 3.A trimmed 1.5 → 1 day. Total ~94.75 → ~93.5 effort-days.
  - Appendix paths fixed (file now sits at root; relative links retargeted).
  - Back-references in `docs/migration/flavor_bundle_id_plan.md` updated (`docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` at repo root).

- **Decisions**:
  - **Plan at repo root, not under `docs/`** — matches `biegeapp` layout for cross-project muscle memory. CLAUDE.md states "all new .md files belong under `docs/`" with exceptions for `CLAUDE.md` and `README.md`. Adding `MIGRATION_PLAN.md` + `MIGRATION_LOG.md` to that exception set as the canonical migration-control docs, given they sit alongside `MIGRATION_RULES.md` (already at root). Reason: discoverability — a contributor opening the repo sees plan, rules, log together; the alternative buries plan two levels deep while rules sit at root.
  - **Refresh vs rewrite** — kept the 2026-05-21 analysis verbatim and applied targeted edits. The audit-driven judgment calls (pilot choice, group order, decomposition strategy) are still correct; only the underlying numbers moved.
  - **Drift in the wrong direction** (`ApiService()` 58 → 68, `setState` 266 → 291, `print/debugPrint` 242 → 283, `StatefulWidget` 41 → 44) noted but not treated as a blocker — the migration roadmap absorbs new screens via the same per-feature template; new screens just lengthen Group C by 0.5 day and Phase 5 cleanup by a few `print()` strips.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged (no lib/ touches).
  - No commits made; user controls when to stage and commit.

---
