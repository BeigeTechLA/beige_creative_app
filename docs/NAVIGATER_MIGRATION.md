# Navigator Migration — Centralised Routing & Tracking

Status: **Done (2026-06-01)** — A0 + A + B + C + D + F complete. B6 + F8 device-smoke deferred. E remains future work.
Owner: TBD.
Related docs: `docs/NAVIGATION_MAP.md` (current state snapshot), `CLAUDE.md`, `MIGRATION_RULES.md`.

### Phase progress

| Phase | State | Commit | Notes |
|---|---|---|---|
| A0 — Regenerate navigation map | ✅ Done | `9befd0d` | NAVIGATION_MAP.md rewritten; P15/P16/P18 evidence updated; P21+P22 added; audit cross-walk in §11. |
| A — Centralisation | ✅ Done | `98b2196` | `lib/app/routes.dart` + `navigator_key.dart`; auth → NotifierProvider; refreshListenable merged; 36-file `RouteNames` sweep; 9/9 route tests pass; 160/160 full suite green. |
| B — Restoration + DraftStore | ✅ Done | `3b2120b` | 6 restoration files + `prefsProvider`. Persist on every route change, restore on splash, logout wipes. `kRestorationEnabled = false`; flip after device smoke (B6 deferred). 19 new tests; 179/179 green. |
| C — Typed args | ✅ Done | `3e4b08e` | 3 args files + 3 test files. 9 args classes; null-safe `fromExtra`. P15 resolved (no non-null casts). 21 new tests; 200/200 green. |
| D — Cleanup | ✅ Done | `70979ee` | Last 2 raw `Navigator.push` killed. `RouteNames` shim + `ShootRequestAccepted` orphan deleted. `view_details_screen.dart` renamed `file_viewer_screen.dart` (class `FileViewerScreen`); new `Routes.fileViewer` route. `AppShell` bottom bar hides on branch 4. CI guard `tool/check_no_navigator_push.sh`. `MIGRATION_RULES.md` §6.1-§6.4 refreshed. |
| F — Centralised screen-view analytics | ✅ Done | `93d2310` | `RouteSpec.trackScreenView` + `_trackedNameOf` extractor. 4 opt-outs (splash + 3 success surfaces). AppShell logs branch switches explicitly. SCREEN_CATALOG.md generated. 5 new tests; 205/205 green. F8 device smoke deferred. |
| E — Future | — | — | Out of scope this migration. |

## 1. Goal

Make the router the single source of truth for paths, names, gating, and analytics — and survive process death for multi-step flows. Pattern is drawn from the `biegeapp` (client-side) router, which already solves most of these problems.

Outcomes:

1. One file lists every route's `path`, `name`, `isPublic`, and `args` shape.
2. Auth + onboarding + (future) connectivity gates are reactive — no stale redirects.
3. Interceptors / non-widget code can navigate without `BuildContext`.
4. Multi-step `state.extra` payloads survive cold start.
5. Zero `Navigator.push` / `MaterialPageRoute` in `lib/`.
6. Bottom-bar selected index never lies about the active branch.
7. Crashlytics breadcrumbs already work — keep them, plus add a redirect breadcrumb.
8. Every screen logs a stable `screen_view` to Firebase Analytics via `FirebaseAnalyticsObserver`, keyed off `RouteSettings.name` (= `Routes.x.name`, snake_case). No ad-hoc `logScreenView` per screen.

## 2. Problems being fixed

Drawn from the current code + `NAVIGATION_MAP.md`. Each item maps to a Phase task below.

| # | Problem | Evidence |
|---|---|---|
| P1 | Path strings duplicated between `_publicRoutes` set and per-feature `path:` literals. | `lib/app/router.dart:24-34` vs `auth_routes.dart:19,24,28…` |
| P2 | `RouteNames` holds only names, not paths — no `name → path` map. | `lib/app/route_names.dart` |
| P3 | `authStateProvider` is `StateProvider<bool>` — mutated from outside via `.notifier.state = …`. Leaks state ownership. | `lib/core/providers/auth_state_provider.dart:12` |
| P4 | `onboardingSeenProvider` is read in `redirect:` but NOT in `refreshListenable`. Flips don't re-run redirect. | `lib/app/router.dart:49`, `_AuthRefreshNotifier:77-92` |
| P5 | No `rootNavigatorKey`. 401 interceptor cannot bounce to `/login` without context. | absent |
| P6 | No route restoration. Cold start always lands `/splash`; multi-step signup loses extras. | absent |
| P7 | No draft store. `state.extra as Map<String, dynamic>` is in-memory only — process death = data loss. | `auth_routes.dart:31-66` (signup-step-2/3 extras), `profile_routes.dart` |
| P8 | Two leftover `Navigator.push` + `MaterialPageRoute`. | `pre_production_screen.dart:223`, `common_file_viewer.dart:23` |
| P9 | `AppShell` bottom bar clamps `currentIndex > 3 ? 0`. Branch 4 (Manage Availability) shows Dashboard active. | `app_shell.dart:46` |
| P10 | Kebab-case route names (`"signup-step-1"`). `biegeapp` uses snake_case — analytics splits across apps. | `route_names.dart` |
| P11 | Untyped extras — every screen redoes `data['key'] ?? ''` casts; no compile-time guard. | `auth_routes.dart:31-66`, `profile_routes.dart:78-99` |
| P12 | Two `view_details_screen.dart` files (auth/ + file_manager/). Import collisions waiting. | `lib/features/auth/presentation/screens/view_details_screen.dart`, `lib/features/file_manager/presentation/screens/view_details_screen.dart` |
| P13 | Adding a public auth route requires editing 3 files (`route_names.dart` + `auth_routes.dart` + `_publicRoutes` set). | structural |
| P14 | No test enforces every `GoRoute` has a `name`. Analytics observer silently drops un-named pushes. | `app_analytics_observer.dart:39` (`if (name == null || name.isEmpty) return`) |
| P15 | Three GoRoutes do non-null cast `state.extra as Map<String,dynamic>` (no `?? {}`) — crash if any caller forgets `extra:`. All current callers pass extras (verified A0.1/A0.2), so this is a latent footgun, not active crash. Sites: `shoots_routes.dart:15` (`upcomingShootDetails`), `shoots_routes.dart:23` (`cancelShoot`), `profile_routes.dart:53` (`featuredWorkDetails`). Plus `profile_routes.dart:79` casts to bare `String`. Original 767-line crash site is gone — Phase 4 god-widget split shrank `manage_availability_screen.dart` to 324 lines. | re-scoped via A0.1 sweep |
| P16 | ~~Duplicate routes to `CancelScreen` (`/cancel-shoot` vs `/shoot-Cancel`).~~ **OBSOLETED by Phase 1-5 feature restructure** — only `/cancel-shoot` exists today. Confirmed in A0.1 sweep. | audit F-06 → resolved |
| P17 | `RouteNames.shootCancelotties` constant value is `"shoot-cancellooties"` (double-o typo) while path is `/shoot-cancelotties`. Name=value drift; safe today (both sides agree on constant), trap for anyone typing literal value. | `route_names.dart`, audit F-08. |
| P18 | Single `PopScope` site in `lib/` (`featuredwork_details_screen.dart:69`); zero `WillPopScope` / `SystemNavigator.pop`. Android hardware-back drops signup-step-2/3 form state silently; no "discard form?" guard on multi-step flows. | audit F-13 (was "0 hits"; updated A0.5). Scope question: in this migration or follow-up? Listed in §9. |
| P19 | Logout `goNamed(login)` does not clear go_router stack. Back-gesture from `/login` may resurrect authed tree → API calls with cleared token. | audit F-05. Mitigated partially by `redirect` (added post-audit) bouncing unauth to `/login`, but worth verifying in A0 against current `AuthStateNotifier.logout()` path. |
| P20 | `screen_view` analytics rides on `RouteSettings.name`. Today's kebab names (`signup-step-1`) ship to Firebase as the screen_name; snake_case rename in Phase A changes the analytics key. No test asserts every route is observed, no `screenClass` is set, and modal sheets / dialogs are invisible to the observer. | `app_analytics_observer.dart:38-42`, `analytics_service.dart:29-33`, P10/P14. |
| P21 | Dead constants in `route_names.dart`: `signup` (line 9, value `"signup"`) and `viewShootDetails` (lines 83-84, value `"view-shoot-details"`). Both defined, no matching `GoRoute`, zero references in `lib/`. Confirmed A0.3. | audit F-07, A0.3 sweep. |
| P22 | `lib/features/shoots/presentation/screens/shoot_request_accepted_screen.dart` (`ShootRequestAccepted`) is defined but has **zero** call sites. Was previously raw-`Navigator.push`-only per audit F-11; the push has since been removed without removing the widget. Candidate for deletion in Phase D. | audit F-11, A0.6 sweep. |

## 3. Non-goals

- Deep-link / Universal-link support. (Out of scope; possible follow-up once typed args + path constants land.)
- Replacing `StatefulShellRoute.indexedStack`. Shell stays as-is.
- Migrating screens to Riverpod where they aren't already (Phase 4 work).
- Building a generic event taxonomy (login, signup_completed, shoot_accepted, …). Phase F only centralises **screen-view** tracking via `FirebaseAnalyticsObserver` + `RouteSettings.name`. Custom event taxonomy stays a follow-up.

## 4. Target architecture

### 4.1 `RouteSpec` — single source of truth

`lib/app/routes.dart` (new):

```dart
import 'package:flutter/foundation.dart';

@immutable
class RouteSpec {
  const RouteSpec({
    required this.name,
    required this.path,
    this.isPublic = false,
  });

  final String name;   // analytics-safe, snake_case
  final String path;   // GoRouter path
  final bool isPublic; // reachable while unauthenticated
}

abstract class Routes {
  // Entry
  static const splash = RouteSpec(name: 'splash', path: '/splash', isPublic: true);
  static const onboarding = RouteSpec(name: 'onboarding', path: '/onboarding', isPublic: true);

  // Auth
  static const login = RouteSpec(name: 'login', path: '/login', isPublic: true);
  static const signupStep1 = RouteSpec(name: 'signup_step_1', path: '/signup-step-1', isPublic: true);
  static const signupStep2 = RouteSpec(name: 'signup_step_2', path: '/signup-step-2', isPublic: true);
  static const signupStep3 = RouteSpec(name: 'signup_step_3', path: '/signup-step-3', isPublic: true);
  static const forgotPassword = RouteSpec(name: 'forgot_password', path: '/forgot-password', isPublic: true);
  static const forgotOtp = RouteSpec(name: 'forgot_otp', path: '/forgot-otp', isPublic: true);
  static const resetPassword = RouteSpec(name: 'reset_password', path: '/reset-password', isPublic: true);

  // Shell tabs
  static const home = RouteSpec(name: 'home', path: '/home');
  static const shoots = RouteSpec(name: 'shoots', path: '/shoots');
  static const files = RouteSpec(name: 'files', path: '/files');
  static const messages = RouteSpec(name: 'messages', path: '/messages');
  static const manageAvailability = RouteSpec(name: 'manage_availability', path: '/manage-availability');

  // … (profile, shoots, file_manager — port from RouteNames)

  /// Flat list — used to derive [publicPaths] and by the route-completeness test.
  static const all = <RouteSpec>[
    splash, onboarding,
    login, signupStep1, signupStep2, signupStep3,
    forgotPassword, forgotOtp, resetPassword,
    home, shoots, files, messages, manageAvailability,
    // …
  ];

  static final Set<String> publicPaths = {
    for (final r in all) if (r.isPublic) r.path,
  };
}
```

`lib/app/route_names.dart` becomes a thin shim that re-exports `Routes.x.name` for the migration window, then is deleted in step 7.6.

### 4.2 Per-feature route fragments — keep, but cleaner

Each `*_routes.dart` switches from string literals to `Routes.x`:

```dart
GoRoute(
  path: Routes.login.path,
  name: Routes.login.name,
  builder: (context, state) => const LoginScreen(),
),
```

Add typed-args parsing co-located with the feature (see 4.5).

### 4.3 Auth provider — `Notifier<bool>` with mutator

Replace `lib/core/providers/auth_state_provider.dart`:

```dart
class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(sessionStoreProvider).hasToken;

  Future<void> login() async { /* delegated by login flow */ state = true; }
  Future<void> logout() async {
    await ref.read(sessionStoreProvider).clear();
    await ref.read(routeRestorationServiceProvider).clearAll();
    await ref.read(draftStoreProvider).clearAll();
    state = false;
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(AuthStateNotifier.new);
```

All `ref.read(authStateProvider.notifier).state = …` call sites become `.login()` / `.logout()`.

### 4.4 Refresh listenable — merge auth + onboarding

`router.dart`:

```dart
final auth = ValueNotifier<bool>(ref.read(authStateProvider));
final onb  = ValueNotifier<bool>(ref.read(onboardingSeenProvider));
ref.listen(authStateProvider, (_, v) => auth.value = v);
ref.listen(onboardingSeenProvider, (_, v) => onb.value = v);

return GoRouter(
  navigatorKey: rootNavigatorKey,
  refreshListenable: Listenable.merge([auth, onb]),
  …
);
```

Same shape as `biegeapp/lib/app/router.dart:108-109`. Lets us add a `connectivity` notifier later without re-plumbing.

### 4.5 Typed args

Per multi-step flow, create an args class beside the feature:

```dart
// lib/features/auth/presentation/routes/signup_args.dart
@immutable
class SignUpStep2Args {
  const SignUpStep2Args({required this.crewMemberId, required this.email, …});

  final int crewMemberId;
  final String email;
  // …

  Map<String, dynamic> toExtra() => { 'crewMemberId': crewMemberId, 'email': email, … };

  factory SignUpStep2Args.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return SignUpStep2Args(
      crewMemberId: m['crewMemberId'] as int,
      email: m['email'] as String? ?? '',
      // …
    );
  }
}
```

Route builder shrinks to:

```dart
builder: (context, state) {
  final args = SignUpStep2Args.fromExtra(state.extra);
  return SignUp2Screen(args: args);
},
```

Call site:

```dart
context.pushNamed(Routes.signupStep2.name, extra: args.toExtra());
```

### 4.6 `rootNavigatorKey`

`lib/app/navigator_key.dart` (new, copied from biegeapp):

```dart
import 'package:flutter/material.dart';
final rootNavigatorKey = GlobalKey<NavigatorState>();
```

Passed to `GoRouter(navigatorKey: rootNavigatorKey)`. Auth interceptor (`lib/core/network/interceptors/…`) can do:

```dart
rootNavigatorKey.currentContext?.goNamed(Routes.login.name);
```

### 4.7 Restoration + DraftStore (Phase B — optional but recommended)

Port both files from biegeapp with minor edits:

- `lib/core/restoration/route_restoration_service.dart` — persist `matchedLocation` + params, TTL, schema migration.
- `lib/core/restoration/draft_store.dart` — JSON drafts for signup flow (only flow with cross-step extras in this app).
- `lib/core/restoration/restoration_providers.dart` — wire to `sessionStoreProvider`'s prefs.
- `lib/core/restoration/restoration_keys.dart` — prefs keys + feature flag `kRestorationEnabled` (default `false` — flip when ready).
- `lib/core/restoration/app_lifecycle_observer.dart` — stamps `lastActiveTs` on `paused`.
- `lib/core/restoration/splash_restorer.dart` — pure helper called from `SplashScreen` to decide restore vs `goNamed(home)`.

Attach via `router.routerDelegate.addListener(persistOnChange)` in `routerProvider`. Skip list copied from biegeapp + `'/signup-step-*'` if we choose not to restore mid-signup (lighter to start there).

Defer Phase B until Phase A lands and stabilises.

### 4.8 `AppShell` bottom bar fix

Replace `currentIndex: shell.currentIndex > 3 ? 0 : shell.currentIndex` with `selectedItemColor` overrides so nothing is highlighted on branch 4, OR hide the bottom bar on branch 4:

```dart
bottomNavigationBar: shell.currentIndex >= 4
    ? null
    : _AppShellBottomBar(currentIndex: shell.currentIndex, onTap: _goBranch),
```

Bar disappearing on Manage Availability is the honest UX (it's a Drawer-only tab).

### 4.9 Kill `Navigator.push`

| File | Replacement |
|---|---|
| `lib/features/file_manager/presentation/screens/pre_production_screen.dart:223` | Add `GoRoute('/file-viewer', name: Routes.fileViewer.name, …)` or use `showDialog`. |
| `lib/shared/widgets/common_file_viewer.dart:23` | Same. |

### 4.10 Route-completeness test

`test/app/router_test.dart` (new):

```dart
test('every GoRoute has a non-empty name', () {
  final routes = _flatten(routerProvider /* with overrides */);
  for (final r in routes.whereType<GoRoute>()) {
    expect(r.name, isNotNull);
    expect(r.name, isNotEmpty);
  }
});

test('every Routes.* entry maps to a GoRoute with same path/name', () {
  // builds a Set<(name,path)> from Routes.all and from the tree, asserts equal.
});

test('Routes.publicPaths matches isPublic flags', () { /* sanity */ });
```

Failing CI when someone adds a `GoRoute` without registering it in `Routes` is the whole point.

### 4.11 Centralised screen-view analytics

`FirebaseAnalyticsObserver` already logs `screen_view` automatically — it reads `route.settings.name` on every push/replace/pop. GoRouter copies `GoRoute.name` straight into `RouteSettings.name`, so once Phase A wires every `GoRoute(name: Routes.x.name)`, the observer is the single source of truth for screen analytics. No per-screen `logScreenView` call is needed.

Extend `AppAnalyticsObserver` minimally:

```dart
class AppAnalyticsObserver extends NavigatorObserver {
  AppAnalyticsObserver()
      : _delegate = AnalyticsService.buildObserver(
          nameExtractor: _nameOf,
          // FirebaseAnalyticsObserver also accepts routeFilter — default keeps PageRoute only.
        );

  static String? _nameOf(RouteSettings s) {
    final n = s.name;
    if (n == null || n.isEmpty) return null;
    // Defence in depth — Phase A ensures these are already snake_case.
    return n;
  }

  // … existing didPush/didReplace/didPop unchanged, still write Crashlytics breadcrumb.
}
```

`AnalyticsService.buildObserver` grows the matching parameter:

```dart
static FirebaseAnalyticsObserver? buildObserver({
  ScreenNameExtractor? nameExtractor,
}) {
  final inst = _instance;
  if (inst == null) return null;
  return FirebaseAnalyticsObserver(
    analytics: inst,
    nameExtractor: nameExtractor ?? defaultNameExtractor,
  );
}
```

For dialogs / bottom sheets (not `PageRoute`), keep an explicit `AnalyticsService.logScreenView(screenName: Routes.x.name)` at the call site — documented in `MIGRATION_RULES.md`.

Opt-out: add `RouteSpec.trackScreenView` (default `true`). Observer skips when false (used for `/splash`, OTP success momentary screens that would skew funnel metrics).

```dart
class RouteSpec {
  const RouteSpec({
    required this.name,
    required this.path,
    this.isPublic = false,
    this.trackScreenView = true,
  });
  // …
}
```

The observer resolves the spec by `settings.name` lookup against `Routes.byName` (added in A1) and short-circuits when `trackScreenView` is false.

## 5. Phased plan

Total estimate: **~3.5-6 dev days** for Phase A0 + A + C + D. Phase B (restoration) is another **1-2 days**. Phase F (centralised screen analytics) is **0.5-1 day**, parallelisable with C/D.

> **Why A0 exists:** the existing `docs/NAVIGATION_MAP.md` predates the Phase 1-5 feature/Riverpod migration. It still references `lib/main.dart`, `lib/main_screen.dart`, `lib/service/shared_service.dart`, `lib/service/api_service.dart`, `lib/auth/`, `lib/Profile/`, and claims "No Riverpod / `ProviderScope` never mounted" and "No `redirect` callback" — all false against current `lib/app/router.dart` + `lib/features/<f>/presentation/routes/*_routes.dart`. Phase A1's inventory needs a current map; A0 produces it. Without A0, A1 inherits stale paths and the route-completeness test in A8 will mis-assert.

### Phase A0 — Regenerate navigation map (0.5 day, docs only)

Read-only sweep + docs rewrite. No code changes. Blocks Phase A. **Done in commit `9befd0d`.**

| Task | Status | File(s) | Notes |
|---|---|---|---|
| A0.1 | ✅ | Sweep router + per-feature route files. | 37 GoRoutes inventoried. |
| A0.2 | ✅ | Sweep call sites. | ~90 named-nav refs across 38 files. 2 raw `Navigator.push` confirmed (P8). |
| A0.3 | ✅ | Cross-check `RouteNames` constants vs `GoRoute(name:)` registrations. | Dead: `signup`, `viewShootDetails` (P21). |
| A0.4 | ✅ | Rewrite `docs/NAVIGATION_MAP.md`. | All stale `main_screen.dart` / `service/*` refs gone. Mermaid + 37 routes documented. |
| A0.5 | ✅ | Cross-check P1-P19 evidence. | P15 re-scoped (manage_availability.dart shrank 767→324 lines, footgun not crash); P16 obsoleted; P18 evidence updated. Added P20-P22. |
| A0.6 | ✅ | Audit cross-walk F-01..F-22. | 9/22 obsoleted by Phase 1-5. See §11. |
| A0.7 | ✅ | Single docs-only commit. | `9befd0d` on `improvments-phase1`. |

Acceptance: regenerated `NAVIGATION_MAP.md` lists every current `GoRoute`, every current call site, no references to deleted files (`lib/main.dart`, `lib/main_screen.dart`, `lib/service/*`, `lib/auth/`, `lib/Profile/`). `rg -F "lib/service/" docs/NAVIGATION_MAP.md` returns 0. Mermaid renders. **Verified.**

### Phase A — Centralisation (1.5 days, no behavior change)

**Done in commit `98b2196`.** 51 files changed (+534 / −310). 9/9 router tests + 160/160 full suite green.

| Task | Status | File(s) | Notes |
|---|---|---|---|
| A1 | ✅ | `lib/app/routes.dart` | 37 `RouteSpec`s. snake_case names + kebab paths. `Routes.all` / `.publicPaths` / `.byName`. |
| A2 | ✅ | `lib/app/navigator_key.dart` | `rootNavigatorKey` wired into `GoRouter(navigatorKey:)`. |
| A3 | ✅ | `lib/app/router.dart` | `_publicRoutes` literal set deleted; derived from `Routes.publicPaths`. Inline `GoRoute`s use `Routes.x`. |
| A4 | ✅ | 5 feature `*_routes.dart` | auth / profile / shoots / availability / file_manager — all `Routes.x.path/.name`. |
| A5 | ✅ | `auth_state_provider.dart`, `login_notifier.dart`, `delete_account_providers.dart`, `profile_action_buttons.dart`, `main.dart` | `NotifierProvider<AuthStateNotifier, bool>`. `markLoggedIn()` + `logout()`. 3 mutator call sites migrated. `startApp` override passes initial seed. |
| A6 | ✅ | `lib/app/router.dart` | `_AuthRefreshNotifier` listens to `authStateProvider` AND `onboardingSeenProvider`. |
| A7 | ✅ | ~36 call sites + `route_names.dart` | `sed` sweep: `RouteNames.X` → `Routes.X.name`; `route_names.dart` import → `routes.dart`. `route_names.dart` converted to `@deprecated` forwarder shim — deleted in D4. |
| A8 | ✅ | `test/app/router_test.dart` | 9 tests: name non-empty, snake_case regex (`^[a-z][a-z0-9_]{0,39}$`), uniqueness, `publicPaths` ↔ `isPublic` flag, `byName` covers `all`, GoRoute ↔ RouteSpec consistency, every `Routes.x` registered. |

Acceptance: `flutter analyze` clean, `flutter test` green (160/160), app boots and reaches `/home` after login. **Verified.**

### Phase B — Restoration & DraftStore (1-2 days, gated by flag)

**Done in commit `3b2120b`.** 6 new restoration files + 3 test files. `kRestorationEnabled = false` (B6 device smoke deferred).

| Task | Status | File(s) | Notes |
|---|---|---|---|
| B1 | ✅ | `lib/core/restoration/{restoration_keys,route_restoration_service,app_lifecycle_observer,splash_restorer,draft_store,restoration_providers}.dart` | Ported from biegeapp. Skip list uses `Routes.publicPaths` + OTP/success surfaces. `SignUpDraft` replaces biegeapp's Booking variants. |
| B2 | ✅ | `lib/app/router.dart` | `router.routerDelegate.addListener(persistOnChange)` — every URL change calls `RouteRestorationService.persist`. No-op while flag is off. |
| B3 | ✅ | `lib/features/splash/presentation/screens/splash_screen.dart` | Tries `splashRestorerProvider.shouldRestore(...)` before `goNamed(home)`. |
| B4 | ✅ | `lib/features/auth/presentation/routes/auth_routes.dart`, `lib/core/restoration/draft_store.dart` | `SignUpDraft` model. Step-2/3 builders fall back to draft when `state.extra` is null AND flag is on. |
| B5 | ✅ | `lib/core/providers/auth_state_provider.dart` | `logout()` calls `routeRestorationService.clearAll()` + `draftStore.clearAll()` before flipping state. |
| B6 | ⏳ | manual QA + `MIGRATION_LOG.md` | Deferred until product/team confirms restoration is acceptable mid-signup (§9 Q2 still open). Auto-tests cover unit invariants; device smoke flips the flag. |

### Phase C — Typed args (0.5-1 day)

**Done in commit `3e4b08e`.** 3 args files + 3 test files. 200/200 tests green.

| Task | Status | File(s) | Notes |
|---|---|---|---|
| C1 | ✅ | `lib/features/auth/presentation/routes/signup_args.dart` | `SignUpStep2Args`, `SignUpStep3Args`, `ViewDetailsArgs`. |
| C2 | ✅ | `lib/features/profile/presentation/routes/profile_args.dart` | `FeaturedWorkDetailsArgs`, `ChangePasswordArgs` (bare-String + Map shapes), `ProfileOtpArgs`, `ProfileNewPasswordArgs`. |
| C3 | ✅ | `lib/features/shoots/presentation/routes/shoots_args.dart` | `UpcomingShootDetailsArgs`, `CancelShootArgs`. `_asInt` accepts int/num/String. |
| C4 | ✅ | 3 `*_routes.dart` builders + 10 push call sites | All `extra:` map literals replaced with `Args(...).toExtra()`; builders use `Args.fromExtra(state.extra)`. |
| C5 | ✅ | route_restoration_service + args | P15 latent footgun eliminated — `Args.fromExtra(null)` returns safe defaults. Original 767-line crash site is gone (file shrank to 324 lines post-Phase-4). |

### Phase D — Cleanup (0.5 day)

**Done in commit `70979ee`.** 12 files (155 +, 181 −). 200/200 tests still pass. Grep guard green.

| Task | Status | File(s) | Notes |
|---|---|---|---|
| D1 | ✅ | `pre_production_screen.dart`, `common_file_viewer.dart`, `file_manager_routes.dart`, `file_manager_args.dart` | `pre_production` → `pushNamed(Routes.fileViewer)` with `FileViewerArgs`. `common_file_viewer` → `showDialog` (modal, not routed). |
| D2 | ✅ | `lib/shared/layouts/app_shell.dart` | `currentIndex >= 4 ? null : bar`. Bar disappears on Manage Availability — honest UX. |
| D3 | ✅ | `lib/features/file_manager/presentation/screens/file_viewer_screen.dart` | Renamed from `view_details_screen.dart`; class `FileManagerViewDetailsScreen` → `FileViewerScreen`. P12 resolved. |
| D4 | ✅ | `lib/app/route_names.dart` (deleted), `lib/features/shoots/presentation/screens/shoot_request_accepted_screen.dart` (deleted) | Shim drained after Phase A sweep; orphan widget (P22) removed. |
| D5 | ✅ | `MIGRATION_RULES.md`, `tool/check_no_navigator_push.sh` | §6.1–§6.4 rewritten around `RouteSpec` + typed args + modal-vs-route boundary. CI grep guard executable. |
| D6 | ✅ | `docs/NAVIGATION_MAP.md` | Phase D delta note (route 37→38, deletions, AppShell change, zero raw `Navigator.push`). |

### Phase F — Centralised screen-view analytics (0.5-1 day)

**Done in commit `93d2310`.** 8 files (282 +, 31 −). 205/205 tests green.

| Task | Status | File(s) | Notes |
|---|---|---|---|
| F1 | ✅ | `lib/app/router.dart`, `lib/core/firebase/app_analytics_observer.dart`, `lib/shared/layouts/app_shell.dart` | Observer attached at root only — sees PageRoute pushes / replaces. Shell-branch switches handled via explicit `AnalyticsService.logScreenView` call in `AppShell._goBranch`. |
| F2 | ✅ | `lib/core/firebase/analytics_service.dart` | `buildObserver` accepts `ScreenNameExtractor`. Defaults to the SDK's `defaultNameExtractor` when caller passes none. |
| F3 | ✅ | `lib/app/routes.dart`, `app_analytics_observer.dart` | `RouteSpec.trackScreenView` (default `true`). `_trackedNameOf` returns `null` when `Routes.byName[name]?.trackScreenView == false`, so the Firebase observer skips `screen_view`. Crashlytics breadcrumb still records via the existing `_recordRoute`. Opt-outs: `splash`, `profile_password_success`, `delete_account_success`, `shoot_cancelotties`. |
| F4 | ⛔ no-op | `app_analytics_observer.dart` | `FirebaseAnalyticsObserver`'s default `screenClassExtractor` returns `settings.name`, matching what we want when paths are unique (they are). Custom helper deferred — only worth it if path collisions land. |
| F5 | ✅ | `MIGRATION_RULES.md` §6.5 | PageRoute auto-logged. Dialogs/sheets call `AnalyticsService.logScreenView` explicitly. Branch switches logged in AppShell. Never hard-code analytics strings. |
| F6 | ✅ | `docs/analytics/SCREEN_CATALOG.md` | 38 routes inventoried with name / path / isPublic / track. Documents kebab→snake rename impact. |
| F7 | ✅ | `test/app/routes_analytics_test.dart` | snake_case regex, ≤40 char limit, hyphen-leak guard, uniqueness, expected opt-out flags. |
| F8 | ⏳ | manual QA + `MIGRATION_LOG.md` | Deferred. Needs a post-`flutterfire configure` build; smoke walks splash → login → home → shoots → manage_availability → logout and confirms snake `screen_name` events in DebugView. Document result before flipping analytics dashboards. |

Acceptance: DebugView shows `screen_view` events with snake_case `screen_name` matching `Routes.x.name` on every `PageRoute` push/replace; shell-branch switch logs the new branch's screen; `splash` and opt-out routes are absent; CI fails if a `Routes.x.name` violates the regex or duplicates an existing name. **All static checks green; F8 awaits real device.**

### Phase E — Future (not in this plan)

- E1: Generated route map (markdown) emitted from a dev tool that walks `Routes.all`. (Subsumes Phase F's `SCREEN_CATALOG.md` once it lands.)
- E2: Deep-link support — possible once paths + typed args are centralised.
- E3: Offline gate (`visitedOnlineLocations` from biegeapp) — only if product asks for it.
- E4: Custom event taxonomy (`login_success`, `signup_completed`, `shoot_accepted`, …) layered on top of Phase F's `AnalyticsService`.

## 6. Rollout

- One PR per Phase. Phase A0 (docs-only) lands first and unblocks A1. Phase A is the only mandatory code phase; B/C/D/F are independent and shippable on their own.
- `kRestorationEnabled = false` default — flip in a follow-up PR after Phase B QA.
- Feature flag is not needed for Phase A; the change is structural and behaviour-preserving.
- Phase F ships behind no flag — `AnalyticsService.buildObserver` already no-ops when Firebase config is missing, so dev/local builds stay green pre-`flutterfire configure`.

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| snake_case rename breaks analytics dashboards. | Keep the kebab `path:` strings. Only `name:` (analytics screen key) changes. Coordinate with analytics owner; consider keeping kebab names if dashboards are heavily wired. |
| `AuthStateNotifier` API change misses a call site → silent logout fail. | `flutter analyze` + grep `authStateProvider.notifier).state` before deleting the setter. |
| Restoration restores user into a screen whose backing data 404s post-deploy. | TTL + skip list (auth/OTP/success screens already excluded in biegeapp). Start `kRestorationEnabled = false` and dogfood. |
| Typed args break existing pushers expecting `Map`. | Roll C feature-by-feature; each `Args` class accepts both keys + missing-field defaults during the migration window. |
| Removing `RouteNames` breaks something obscure. | Keep shim for one release; grep `RouteNames\.` after Phase A. |
| Phase F renames `screen_name` in Firebase (kebab → snake), orphaning existing dashboards / funnels. | Coordinate with analytics owner before merge. Option: keep kebab `path:` and only switch `RouteSpec.name` if dashboards are wired to `path` not `screen_name`. Worst case, ship a one-time mapping table in BigQuery to bridge old/new keys. |
| Phase F over-logs — modal sheets / `showDialog` start firing `screen_view` for non-screen surfaces. | `FirebaseAnalyticsObserver` default `routeFilter` keeps `PageRoute` only — leave as default. Dialogs / sheets call `logScreenView` explicitly per F5. |

## 8. Source-of-truth references

- biegeapp router: `../../biegeapp/lib/app/router.dart` (full reference impl).
- biegeapp restoration: `../../biegeapp/lib/core/restoration/*`.
- biegeapp draft store: `../../biegeapp/lib/core/restoration/draft_store.dart`.
- biegeapp navigator key: `../../biegeapp/lib/app/navigator_key.dart`.
- Current state inventory: `docs/NAVIGATION_MAP.md` (stale until Phase A0 regenerates it).
- **Pre-migration navigation audit** (historical reference): `docs/audit/NAVIGATION_AUDIT.md`. Snapshot of branch `improvments-phase1`, 2026-05-21. File paths predate Phase 1-5 feature/ restructure — do **not** use for current line:number citations. Use for: (a) finding categories that may survive (raw-Navigator inventory, dup routes, missing back-handling, dead constants), (b) deep-link gap rationale (§3 non-goal), (c) baseline counts for "did Phase 1-5 reduce raw `Navigator.push` sites?" comparison. Cross-walked in task A0.6.
- Project rules: `CLAUDE.md`, `MIGRATION_RULES.md`.

## 9. Open questions for the team

1. Are existing kebab-case route names load-bearing in any Firebase dashboard? If yes, keep them and update biegeapp instead.
2. Is restoration into mid-signup acceptable, or should signup always restart? (Drives B4 skip list.)
3. Should `manageAvailability` (branch 4) keep its bottom-bar tile (add 5th item) or stay Drawer-only (hide bar on that branch)?
4. Phase A only, or A+C bundled into one PR? Recommendation: separate, since C touches every multi-arg screen.
5. P18 — adding `PopScope` guards on signup-step-2/3 + change-password OTP flows: in this migration (Phase D candidate) or follow-up? Audit flagged it 2026-05-21; still 0 hits in `lib/` per A0.2 sweep results.
6. Phase F: which routes should opt out of `screen_view` (`trackScreenView: false`)? Candidates: `/splash` (always transient), `/forgot-otp` + `/reset-password` (funnel noise vs signal — analytics owner call), in-app file-viewer modal once it becomes a real route (D1).
7. Phase F: keep kebab `path:` strings forever (current plan), or also rename `path:` to snake_case? Dashboards keyed on `screen_name` are safe; deep links and any web analytics that scrape `firebase_screen` from the URL are not. Default: keep kebab paths.

## 10. Expected output — files added / changed

Action legend: **A** = added, **M** = modified, **R** = renamed, **D** = deleted.

Per-phase manifest. Counts are the upper bound; A4/A7/C4 sweep widths depend on the A0 inventory.

### Phase A0 — Docs regenerate

| Action | Path | Purpose |
|---|---|---|
| M | `docs/NAVIGATION_MAP.md` | Full rewrite — current router, providers, feature routes, mermaid. |
| M | `docs/NAVIGATER_MIGRATION.md` | §2 evidence line:number fixups + §5 A0.6 audit cross-walk results. |

### Phase A — Centralisation

| Action | Path | Purpose |
|---|---|---|
| A | `lib/app/routes.dart` | `RouteSpec` + `Routes.all` + `Routes.publicPaths` + (Phase F) `Routes.byName`. |
| A | `lib/app/navigator_key.dart` | `rootNavigatorKey` for context-less navigation. |
| M | `lib/app/router.dart` | Consume `Routes.publicPaths`, attach `rootNavigatorKey`, merge `auth+onboarding` into `refreshListenable`. |
| M | `lib/features/auth/presentation/routes/auth_routes.dart` | Switch literals → `Routes.x.path/.name`. |
| M | `lib/features/profile/presentation/routes/profile_routes.dart` | Same. |
| M | `lib/features/shoots/presentation/routes/shoots_routes.dart` | Same. |
| M | `lib/features/file_manager/presentation/routes/file_manager_routes.dart` | Same. |
| M | `lib/features/home/presentation/routes/home_routes.dart` | Same. |
| M | `lib/core/providers/auth_state_provider.dart` | `StateProvider<bool>` → `NotifierProvider<AuthStateNotifier, bool>` with `login()` / `logout()`. |
| M | `lib/app/route_names.dart` | Convert to forwarder shim re-exporting `Routes.x.name`. Deleted in D4. |
| M | _N call sites_ of `authStateProvider.notifier).state = …` | Switch to `.login()` / `.logout()`. Expected ≤5 hits. |
| M | _N call sites_ of `RouteNames.x` | Switch to `Routes.x.name`. Sweep via `rg "RouteNames\."`. |
| A | `test/app/router_test.dart` | Route-completeness test (4.10). |

### Phase B — Restoration & DraftStore (flagged off)

| Action | Path | Purpose |
|---|---|---|
| A | `lib/core/restoration/route_restoration_service.dart` | Persist matched location + params, TTL, schema migration. |
| A | `lib/core/restoration/draft_store.dart` | JSON drafts for cross-step flows. |
| A | `lib/core/restoration/restoration_providers.dart` | Riverpod wiring to `sessionStoreProvider` prefs. |
| A | `lib/core/restoration/restoration_keys.dart` | Prefs keys + `kRestorationEnabled` flag (`false` default). |
| A | `lib/core/restoration/app_lifecycle_observer.dart` | Stamps `lastActiveTs` on `paused`. |
| A | `lib/core/restoration/splash_restorer.dart` | Splash decision helper. |
| A | `lib/features/auth/presentation/routes/sign_up_draft.dart` | `SignUpDraft` model + serializer. |
| M | `lib/app/router.dart` | `routerDelegate.addListener(persistOnChange)`. |
| M | `lib/features/splash/presentation/screens/splash_screen.dart` | Call `splashRestorerProvider.shouldRestore(...)`. |
| M | `lib/features/auth/presentation/routes/auth_routes.dart` | Wire `SignUpDraft` into signup builders. |
| M | `lib/core/providers/auth_state_provider.dart` | `logout()` also clears restoration + drafts. |
| M | `MIGRATION_LOG.md` | B6 smoke-test result + flag flip. |

### Phase C — Typed args

| Action | Path | Purpose |
|---|---|---|
| A | `lib/features/auth/presentation/routes/signup_args.dart` | `SignUpStep2Args`, `SignUpStep3Args`, `ViewDetailsArgs`. |
| A | `lib/features/profile/presentation/routes/profile_args.dart` | `FeaturedWorkDetailsArgs`, `ChangePasswordArgs`, `ProfileOtpArgs`, `ProfileNewPasswordArgs`. |
| A | `lib/features/shoots/presentation/routes/shoots_args.dart` | `UpcomingShootDetailsArgs`, `CancelShootArgs`. |
| M | `lib/features/auth/presentation/routes/auth_routes.dart` | Builders use `Args.fromExtra(state.extra)`. |
| M | `lib/features/profile/presentation/routes/profile_routes.dart` | Same. |
| M | `lib/features/shoots/presentation/routes/shoots_routes.dart` | Same. |
| M | _N push call sites_ across `auth/`, `profile/`, `shoots/` | Switch to `args.toExtra()`. |
| M | `lib/features/shoots/presentation/screens/manage_availability_screen.dart` | Fix P15 — pass real `UpcomingShootDetailsArgs`. |

### Phase D — Cleanup

| Action | Path | Purpose |
|---|---|---|
| M | `lib/features/file_manager/presentation/screens/pre_production_screen.dart` | Replace `Navigator.push` with `pushNamed(Routes.fileViewer.name)`. |
| M | `lib/shared/widgets/common_file_viewer.dart` | Same. |
| M | `lib/features/file_manager/presentation/routes/file_manager_routes.dart` | Register `/file-viewer` `GoRoute`. |
| M | `lib/shared/layouts/app_shell.dart` | Hide bottom bar on branch 4 (4.8). |
| R | `lib/features/file_manager/presentation/screens/view_details_screen.dart` → `file_viewer_screen.dart` | Disambiguate from `auth/.../view_details_screen.dart`. |
| M | _N import sites_ of renamed file | Update path. |
| D | `lib/app/route_names.dart` | Shim retired after Phase A grace window. |
| M | `MIGRATION_RULES.md` | "No raw `Navigator.push`" rule. |
| A | `tool/check_no_navigator_push.sh` (or analyze rule) | CI grep guard. Path TBD by infra owner. |
| M | `docs/NAVIGATION_MAP.md` | Reflect final structure (or mark superseded by E1). |

### Phase F — Centralised screen-view analytics

| Action | Path | Purpose |
|---|---|---|
| M | `lib/core/firebase/analytics_service.dart` | Add `nameExtractor` param to `buildObserver`. |
| M | `lib/core/firebase/app_analytics_observer.dart` | Plug `_nameOf`, `screenClass` helper, `RouteSpec.trackScreenView` short-circuit. |
| M | `lib/app/routes.dart` | Add `RouteSpec.trackScreenView` field + `Routes.byName` map. Flag opt-outs (`splash`, OTP success). |
| M | `MIGRATION_RULES.md` | Dialog/sheet `logScreenView` contract (F5). |
| A | `docs/analytics/SCREEN_CATALOG.md` | Generated from `Routes.all`. Shared with analytics owner. |
| A | `test/app/routes_analytics_test.dart` | Snake_case regex + uniqueness + length test. |
| M | `MIGRATION_LOG.md` | F8 DebugView smoke-test result. |

### Aggregate counts (upper bound, excluding sweep-width unknowns)

| Bucket | A | M | R | D |
|---|---|---|---|---|
| Phase A0 | 0 | 2 | 0 | 0 |
| Phase A | 3 | ~9 | 0 | 0 |
| Phase B | 7 | 5 | 0 | 0 |
| Phase C | 3 | ~5 | 0 | 0 |
| Phase D | 1 | ~6 | 1 | 1 |
| Phase F | 2 | 4 | 0 | 0 |
| **Total** | **16** | **~31** | **1** | **1** |

Sweep-width unknowns (A4, A7, C4, D1 imports) settle once A0 inventory lands. Recount after A0.7 PR.

## 11. Audit cross-walk — `docs/audit/NAVIGATION_AUDIT.md` F-01..F-22

Performed in task A0.6 on 2026-06-01 against current code. Each finding is
classified **SURVIVING** (still live), **OBSOLETED** (resolved by Phase 1-5
restructure), or **VERIFY-REQUIRED** (needs runtime check). Surviving items
already mapped to Pxx rows in §2; new rows added where coverage was missing.

| Finding | Status | Notes / Pxx mapping |
|---|---|---|
| F-01 — Raw `Navigator.push` + `MaterialPageRoute` (26 + 31 sites across 19 files) | **SURVIVING (reduced)** | Phase 1-5 killed all but 2 pairs (`pre_production_screen.dart:223-225`, `common_file_viewer.dart:23-25`). Tracked as P8. |
| F-02 — Tab content rebuilt on every switch (no IndexedStack) | **OBSOLETED** | Phase 4 introduced `StatefulShellRoute.indexedStack` (router.dart:109). State preserved across branch switches. |
| F-03 — Bottom-nav index 4 unreachable from nav | **SURVIVING** | `app_shell.dart:46` `currentIndex > 3 ? 0 : …` clamp still present. Tracked as P9. |
| F-04 — Splash re-reads `isLoggedIn`; main.dart's read dead | **OBSOLETED** | `startApp` now overrides `authStateProvider` from `PrefsService.isLoggedIn`; `redirect:` enforces gating. Splash's re-read is redundant but harmless. |
| F-05 — Logout doesn't clear navigation stack | **SURVIVING (mitigated)** | Current logout: `clearSession()` + `state = false` + `goNamed(login)`. Stack not explicitly cleared, but `redirect:` (added post-audit) bounces any !isAuth nav → `/login`. Tracked as P19. |
| F-06 — Duplicate `CancelScreen` routes (`/cancel-shoot` vs `/shoot-Cancel`) | **OBSOLETED** | Only `/cancel-shoot` exists today. Phase restructure killed dup. P16 row in §2 updated to reflect. |
| F-07 — Dead constants `signup`, `viewShootDetails`, `changePassword` | **PARTIAL — dead 2/3** | `signup` + `viewShootDetails` still dead. `changePassword` is now LIVE (registered in `profile_routes.dart:77`). Tracked as new P21. |
| F-08 — `shootCancelotties` value typo (`"shoot-cancellooties"`) | **SURVIVING** | `route_names.dart:73-74` unchanged. Tracked as P17. |
| F-09 — Case-mismatch imports (`ManageAvailability/`, `Shoots/`, …) | **OBSOLETED** | All folders are lowercase under `lib/features/` post-restructure. Linux CI risk eliminated. |
| F-10 — Orphan screens (`file_manager/view_details_screen.dart`, `Profile/profile_new_passwrod_screen.dart`, `auth/view_details_screen .dart` with trailing space) | **PARTIAL** | `file_manager/view_details_screen.dart` exists but is now IMPORTED by `pre_production_screen.dart:12` (via raw push — P8). Name-collision with `auth/view_details_screen.dart` (no trailing space anymore) tracked as P12. `profile_new_password_screen.dart` (renamed, typo fixed) is live in `profile_routes.dart:92`. |
| F-11 — `ShootRequestAccepted` reachable only via raw push | **SURVIVING (worse)** | Widget exists at `shoot_request_accepted_screen.dart`. The single raw-push site that referenced it (from `upcomingshootviewdetils/upcoming_shoot_view_detils.dart`) is gone — widget is now fully orphan. Tracked as new P22. |
| F-12 — `app/app.dart` dead | **OBSOLETED** | `lib/app/app.dart` is now the live root (mounts `MaterialApp.router`, watches `routerProvider`). |
| F-13 — No back-press handling | **SURVIVING (1 hit)** | Single `PopScope` site in `featuredwork_details_screen.dart:69`. Signup/OTP/multi-step flows still unguarded. Tracked as P18 (evidence line updated). |
| F-14 — Argument typing implicit and lossy (non-null casts on `/upcoming-shoot-details`, `/cancel-shoot`) | **SURVIVING (+ added sites)** | Three non-null `Map` casts + one non-null `String` cast confirmed in A0.1. Tracked as P15 (re-scoped) + P11. |
| F-15 — Drawer mixes `Navigator.pop` and `context.pop` | **OBSOLETED** | `AppShell` has zero pop calls (drawer pop is implicit via Scaffold). Codepath rebuilt. |
| F-16 — Shared widgets reach `Navigator` directly | **SURVIVING (reduced)** | Only `common_file_viewer.dart:23-25` survives in `lib/shared/`. Tracked as P8. `lib/utility/app_utils.dart` was deleted in Phase 5. |
| F-17 — `.then((value)` pattern in `pushNamed` | **SURVIVING (low)** | Pattern still present in `home_screen.dart:118`, `home_availability_section.dart:76`, `home_pending_shoot_card.dart:242`. Low-severity, no fix planned in this migration. |
| F-18 — Login route mixes go_router + raw Navigator | **OBSOLETED** | `login_screen.dart` now uses only `context.goNamed`/`pushNamed` (3 sites, no raw). |
| F-19 — Tab navigation discards transient state | **OBSOLETED** | Resolved by F-02 fix (indexedStack). |
| F-20 — Zero deep-link config (Android/iOS/macOS/web) | **SURVIVING (out of scope)** | §3 non-goal. Possible follow-up (Phase E2). |
| F-21 — Routes pass args via non-serializable `state.extra` | **SURVIVING** | Phase C (typed args) is the structural fix. Tracked as P11. |
| F-22 — `singleTop` without intent handling | **SURVIVING (low, OOS)** | Native config unchanged. Deferred with F-20. |

### Severity tally — current

| Severity | Then | Now | Survivors |
|---|---|---|---|
| High | 4 | 2 | F-01 (P8), F-05 (P19) |
| Medium | 11 | 6 | F-03 (P9), F-11 (P22), F-13 (P18), F-14 (P11/P15), F-16 (P8), F-21 (P11) |
| Low | 7 | 5 | F-07 (P21), F-08 (P17), F-10 (P12), F-17 (—), F-20+F-22 (OOS) |

Phase 1-5 obsoleted 9 of 22 findings (F-02, F-04, F-06, F-09, F-12, F-15, F-18, F-19, partial F-10). New problems uncovered by A0.6: P21 (dead constants narrowed), P22 (orphan widget). Net: migration scope shrank, plan is well-aimed.
