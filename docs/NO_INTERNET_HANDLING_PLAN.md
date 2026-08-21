# No-Internet Handling — Execution Plan

**Status:** Proposed
**Owner:** TBD (target: post Phase 6.13 / next quality sprint)
**Created:** 2026-06-07

## Goal

Restrict navigation while device is offline and surface a **platform-adaptive** "No Internet" dialog (Cupertino on iOS, Material on Android). Layer this on top of the existing `connectivityProvider` (raw stream) without disturbing the established `ExceptionHandler` → `NoInternetException` reactive path.

## Current State (Audit — biegeCPapp)

| Item | Status |
|------|--------|
| `connectivity_plus: ^7.0.0` | **Already in `pubspec.yaml`**. No dependency work needed. |
| `connectivityProvider` (`lib/core/providers/core_providers.dart:83`) | Exists as `StreamProvider<List<ConnectivityResult>>` — raw `Connectivity().onConnectivityChanged` passthrough. No debounce, no DNS reachability check, no domain enum, **no consumer**. |
| `NoInternetException` | Defined in `lib/core/network/exceptions/network_exception.dart`. Mapped from `DioException.connectionError`, `SocketException`, and unknown `DioException` carrying a `SocketException` inside `ExceptionHandler.mapDioException` (`lib/core/network/exceptions/exception_handler.dart:137`). Already returns through `Either<AppException, T>` and is consumed in notifiers (e.g. `login_notifier.dart:164`). |
| `ExceptionHandler.guardAsync` | Skips Crashlytics reporting for `NoInternetException` / `TimeoutException` / `RequestCancelledException` (lines 90-99). Keep as-is. |
| Legacy `InternetHelper` | **Does not exist** (cleaned up in earlier migration phases). No legacy delete step required. |
| GoRouter `redirect` (`lib/app/router.dart:38`) | Checks `authStateProvider` + `onboardingSeenProvider`. Reacts via `_AuthRefreshNotifier extends ChangeNotifier` bridging both providers. No connectivity gate. |
| `rootNavigatorKey` (`lib/app/navigator_key.dart`) | Singleton `GlobalKey<NavigatorState>` — already passed to `GoRouter(navigatorKey:)`. Reuse for dialog mount. |
| Platform-specific dialog | Not used anywhere — `showAdaptiveDialog` is unused in the tree. |
| Shared widgets folder | `lib/shared/widgets/` (already contains `top_message.dart`, `app_loader.dart`, etc.). Drop new widgets here. |

## Decisions

1. **Detection:** event-driven via the existing `connectivity_plus` stream. Wrap with a `ConnectivityService` that debounces and exposes a domain `ConnectivityStatus` enum. No polling timer.
2. **Reachability validation:** on transition only, run `InternetAddress.lookup('one.one.one.one')` (Cloudflare — fewer false negatives in regions where `google.com` is throttled) to defeat captive-portal "connected but offline". Debounced 300ms.
3. **Navigation gate:** GoRouter `redirect` consults connectivity. Offline + protected route → stay (`return null`). Public routes (`Routes.publicPaths`) exempt so splash/onboarding/auth flow doesn't deadlock cold-start.
4. **Dialog:** `showAdaptiveDialog` + `AlertDialog.adaptive` (Material on Android, Cupertino on iOS). Non-dismissible via barrier; **Retry** button only. Auto-dismisses when connectivity returns.
5. **Reactive fallback preserved:** existing `NoInternetException` propagation through repositories/notifiers untouched. The dialog handles *device-level* offline; the exception path still catches *request-level* races (online state but request fails).
6. **Scope:** app-wide, mounted under `ProviderScope` at `startApp()`. Active from splash onward.
7. **Existing `connectivityProvider`:** keep file location but *replace* its body with a thin alias to the new pipeline, OR delete it if no callers — `rg connectivityProvider lib/` returns zero hits (confirmed via the audit search), so safe to retire in the same patch.
8. **`AppTheme.dark()` only:** app is locked to dark theme. `AlertDialog.adaptive` already inherits theme — no extra styling work.

## Architecture

```
ConnectivityService (DI'd, event stream)
        │
        ▼
connectivityStreamProvider  (StreamProvider<ConnectivityStatus>)
        │
        ├──► connectivityStatusProvider (Provider<ConnectivityStatus>, defaults to unknown)
        │       │
        │       ├──► routerProvider redirect — gate navigation
        │       └──► ConnectivityListener widget — show / hide adaptive dialog
        │
        └──► (independent) ExceptionHandler.mapDioException still emits NoInternetException
```

### Status enum

```dart
enum ConnectivityStatus { online, offline, unknown }
```

`unknown` covers the first frame before the stream emits so splash isn't falsely flagged offline and the redirect doesn't bounce.

## File Plan

### New files

| Path | Purpose |
|------|---------|
| `lib/core/connectivity/connectivity_status.dart` | `ConnectivityStatus` enum. |
| `lib/core/connectivity/connectivity_service.dart` | Wraps `Connectivity().onConnectivityChanged`. Debounces 300ms. On transition to `online`, runs `InternetAddress.lookup` reachability probe; if probe fails, demotes to `offline`. Exposes `Stream<ConnectivityStatus> watch()` and `Future<ConnectivityStatus> current()`. Constructor takes optional `Connectivity` for test injection. |
| `lib/core/connectivity/connectivity_providers.dart` | `connectivityServiceProvider`, `connectivityStreamProvider` (StreamProvider), `connectivityStatusProvider` (Provider derived from stream, defaults to `unknown`). |
| `lib/shared/widgets/no_internet_dialog.dart` | `showNoInternetDialog(BuildContext)` using `showAdaptiveDialog` + `AlertDialog.adaptive`. Single **Retry** action. `adaptiveAction` helper returns `CupertinoDialogAction` on iOS, `TextButton` on Android. |
| `lib/shared/widgets/connectivity_listener.dart` | `ConsumerStatefulWidget` wrapping the router. Listens to `connectivityStatusProvider`; shows dialog on `online → offline`, pops dialog on `offline → online`. Holds `_isDialogShowing` flag to prevent stacking. |

### Modified files

| Path | Change |
|------|--------|
| `lib/core/providers/core_providers.dart` | Remove now-redundant `connectivityProvider` (zero consumers, replaced by new pipeline). Drop the unused `connectivity_plus` import here. |
| `lib/app/app.dart` | Wrap `MaterialApp.router` output (or its `builder:`) with `ConnectivityListener(child: ...)` so the listener lives above the `Navigator` and survives route changes. |
| `lib/app/router.dart` | Extend `_AuthRefreshNotifier` to also subscribe to `connectivityStatusProvider`. Inside `redirect`: if `connectivityStatusProvider == offline` and `loc` not in `Routes.publicPaths`, return `null` (stay on current route, dialog will block UI). |

### Deleted files

None — no `internet_helper.dart` legacy exists.

## Detailed Implementation Steps

### Step 1 — Dependency
Already satisfied. `connectivity_plus: ^7.0.0` present in `pubspec.yaml`. Skip.

### Step 2 — Status enum
`lib/core/connectivity/connectivity_status.dart`:

```dart
enum ConnectivityStatus { online, offline, unknown }
```

### Step 3 — Service
`lib/core/connectivity/connectivity_service.dart`:

- Constructor: `ConnectivityService({Connectivity? connectivity})` — defaults to `Connectivity()`; override path for tests.
- Map `List<ConnectivityResult>` → `ConnectivityStatus`: any element not `ConnectivityResult.none` → `online`. All-none → `offline`.
- On every emission, run through a 300ms debounce (using `dart:async` `Timer` or a `StreamTransformer`) to collapse `wifi → none → wifi` flaps.
- On debounced `online` emission: attempt `InternetAddress.lookup('one.one.one.one')` with 2s timeout. If lookup throws `SocketException` or times out → emit `offline` instead. Captive-portal mitigation.
- Public surface:
  - `Stream<ConnectivityStatus> watch()` — broadcast stream.
  - `Future<ConnectivityStatus> current()` — one-shot snapshot (uses `checkConnectivity()` + same reachability probe).

### Step 4 — Providers
`lib/core/connectivity/connectivity_providers.dart`:

```dart
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityServiceProvider).watch();
});

final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityStreamProvider).maybeWhen(
    data: (s) => s,
    orElse: () => ConnectivityStatus.unknown,
  );
});
```

Not `.autoDispose` — these are app-wide singletons per `MIGRATION_RULES.md` §3.10.

### Step 5 — Adaptive dialog
`lib/shared/widgets/no_internet_dialog.dart`:

```dart
Future<void> showNoInternetDialog(BuildContext context) {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog.adaptive(
      title: const Text('No Internet'),
      content: const Text(
        'You are offline. Please check your connection and try again.',
      ),
      actions: [
        adaptiveAction(
          context: ctx,
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

- `adaptiveAction` lives in the same file; `Platform.isIOS` switch.
- Retry pops the dialog; `ConnectivityListener` re-evaluates the current status — if still `offline`, re-shows.
- Copy strings stay literal English for now (no i18n layer in the app yet — confirmed via `rg AppLocalizations lib/` returning zero hits).

### Step 6 — Connectivity listener widget
`lib/shared/widgets/connectivity_listener.dart`:

- `ConsumerStatefulWidget`. State holds `bool _isDialogShowing = false`.
- In `build`, call `ref.listen<ConnectivityStatus>(connectivityStatusProvider, _onStatusChanged)`.
- `_onStatusChanged(prev, next)`:
  - `next == offline` and `!_isDialogShowing` → schedule `WidgetsBinding.instance.addPostFrameCallback((_) { ... })` to guard against null `rootNavigatorKey.currentContext` during early frames; set flag; call `showNoInternetDialog(rootNavigatorKey.currentContext!)`; clear flag in the dialog future's `.whenComplete`.
  - `next == online` and `_isDialogShowing` → `Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop()`. Flag cleared by the `.whenComplete` above.
  - `next == unknown` → no-op.
- Returns `widget.child` unchanged.

### Step 7 — Router gate
In `lib/app/router.dart`:

- Extend `_AuthRefreshNotifier` constructor to add a third `_ref.listen` against `connectivityStatusProvider` that calls `notifyListeners()` on change. Close the subscription in `dispose()`.
- In the `redirect` closure, add (after the existing `isAuth` / `hasSeenOnboarding` reads):

  ```dart
  final connStatus = ref.read(connectivityStatusProvider);
  if (connStatus == ConnectivityStatus.offline && !isPublic) {
    return null; // Stay on current route; dialog blocks UI.
  }
  ```

  Place the check **before** the existing auth/onboarding redirects so an offline user mid-session isn't bounced to `/login` just because the auth check fails to refresh.
- Net effect: programmatic `context.goNamed(...)` to a protected route while offline is a no-op; user sees the modal dialog over the current screen. Public routes (splash, onboarding, all auth screens) remain reachable so cold-start with no network still resolves to a usable surface.

### Step 8 — Wire into app shell
`lib/app/app.dart`:

- Wrap router output with `ConnectivityListener`. Two options:
  - **Preferred:** use the `MaterialApp.router.builder:` callback so the listener wraps every routed page but sits *under* `Overlay`/`Navigator`:

    ```dart
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) => ConnectivityListener(child: child!),
    );
    ```
  - This places the listener inside the `MaterialApp` tree so `showAdaptiveDialog` finds the right `MaterialLocalizations` / `CupertinoLocalizations`.

### Step 9 — Cleanup
- Remove `connectivityProvider` + its `connectivity_plus` import from `lib/core/providers/core_providers.dart` (no consumers — verified). New consumers go through `connectivity_providers.dart`.
- `rg connectivity_plus lib/` should now show **only** `lib/core/connectivity/connectivity_service.dart`.

### Step 10 — Tests

Follow Phase 6 test conventions (mocktail, no real network, golden parity not required for dialog).

- `test/core/connectivity/connectivity_service_test.dart`
  - Happy: source emits `[ConnectivityResult.wifi]` → service emits `online` (with reachability probe stubbed to succeed).
  - Edge: source emits `[wifi]` then `[none]` then `[wifi]` within 300ms → service emits exactly one event (debounce collapses flap).
  - Error: source emits `[none]` → service emits `offline`.
  - Captive portal: source emits `[wifi]`, reachability probe throws `SocketException` → service emits `offline`.
- `test/shared/widgets/connectivity_listener_test.dart` (widget test)
  - Provider transitions `online → offline` → adaptive dialog appears within one frame.
  - Provider transitions `offline → online` → dialog dismisses.
  - Provider stays `unknown` → no dialog appears.
- `test/app/router_connectivity_test.dart`
  - Offline + `context.goNamed(Routes.shoots.name)` → matched location unchanged.
  - Offline + nav to a `Routes.publicPaths` member (e.g. `/login`) → nav succeeds.
  - `unknown` + nav to protected route → nav succeeds (no false-positive block on cold start).

Run gating: `flutter analyze` clean; `flutter test test/core/connectivity/ test/shared/widgets/connectivity_listener_test.dart test/app/router_connectivity_test.dart` clean.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Cold-start race: app launches offline, splash redirect runs before stream emits → wrong gate decision. | `ConnectivityStatus.unknown` treated as "do nothing" in redirect (only `offline` blocks). First real `offline` emission arrives after splash → triggers dialog cleanly. |
| Captive Wi-Fi: device shows `wifi` but no real internet. | `InternetAddress.lookup('one.one.one.one')` probe on every transition to `online`. |
| Dialog stacking if listener re-fires before previous future resolves. | `_isDialogShowing` flag in `ConnectivityListener`, cleared in `.whenComplete`. |
| `rootNavigatorKey.currentContext` null during early frames. | Guard with null check; defer dialog show to `WidgetsBinding.instance.addPostFrameCallback`. |
| Reachability probe blocks dialog on slow DNS. | 2s timeout on `InternetAddress.lookup`; on timeout → emit `offline` (fail-safe: user sees dialog rather than a stale "online" UI). |
| iOS-only Cupertino quirk: `barrierDismissible: false` still allows drag-to-dismiss on some sheet types. | Using `AlertDialog.adaptive` (not sheet) — both platforms honor the barrier flag. |
| Router gate fires before `_AuthRefreshNotifier` re-subscribes during hot reload. | `ref.listen` is set up in the notifier constructor, which runs on every `routerProvider` rebuild. Same pattern as existing auth/onboarding subscriptions — verified working. |

## Acceptance Criteria

- [ ] `lib/core/connectivity/*` and `lib/shared/widgets/no_internet_dialog.dart` + `connectivity_listener.dart` added.
- [ ] `connectivityProvider` removed from `core_providers.dart`; no dangling imports.
- [ ] `flutter analyze` clean (no new warnings).
- [ ] Manual: airplane mode toggled on Android → adaptive Material dialog appears within ~1s; toggled off → dialog dismisses.
- [ ] Manual: airplane mode toggled on iOS → Cupertino-styled dialog appears; toggled off → dialog dismisses.
- [ ] Manual: while offline, tapping any bottom-tab nav or pushing a protected route does not change visible screen.
- [ ] Manual: cold-start with airplane mode on → splash → onboarding/login reachable (not deadlocked); dialog shows only once `unknown → offline` resolves.
- [ ] Manual: captive-portal sim (block DNS to `one.one.one.one` via local hosts file or Charles) → dialog still appears even though `connectivity_plus` reports `wifi`.
- [ ] Unit + widget + router tests per Step 10 pass.
- [ ] `MIGRATION_LOG.md` entry added per `AGENTS.md` handoff discipline.

## Out of Scope

- Persistent offline banner (top-of-screen) — can layer on later if UX wants it.
- Per-request retry queue / offline-first caching.
- "Open Settings" deep link (would need `app_settings` package).
- Onboarding-time connectivity messaging (splash path stays untouched).
- i18n of dialog copy — no `AppLocalizations` layer exists yet; revisit when localization phase lands.

## Rollout Order

1. Step 2 (enum) → 3 (service) → 4 (providers) — backend layer in isolation; no UI impact.
2. Step 5 (dialog) → 6 (listener) → 8 (mount in `app.dart`) — UI surfaces dialog without router changes. Verify manually before moving on.
3. Step 7 (router gate) — adds nav restriction once dialog already works.
4. Step 9 (delete old `connectivityProvider`) → 10 (tests).

Each step independently committable. Suggested commit prefix: `feat(connectivity): ...` per existing `MIGRATION_LOG.md` style.

## References

- Companion plan in sibling repo: `biegeapp/docs/NO_INTERNET_HANDLING_PLAN.md` (consumer app — same architecture, different package versions and slightly different router shape).
- `connectivity_plus` v7 changelog: `List<ConnectivityResult>` shape unchanged from v6, so the mapping in Step 3 transfers cleanly.
- `MIGRATION_RULES.md` §3.10 (provider lifecycle), §5.4 (interceptor order — unaffected here).
