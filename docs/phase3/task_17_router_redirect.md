# Task 3.17 — GoRouter auth redirect + observer

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/router-redirect` |

## Goal
Drive routing from `authStateProvider` so unauthenticated users are redirected to `/login` and authenticated users on `/login` are sent to `/home`. Attach `AppAnalyticsObserver` for automatic screen tracking.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #7 (no 401 handling)
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §6, §7

## Files in scope (max 2)
- `lib/app/router.dart` — add `redirect:` + `observers: [AppAnalyticsObserver()]`
- `lib/core/providers/auth_state_provider.dart` — `Provider<bool>` derived from `SessionStore.hasToken`

## Steps
- [x] `authStateProvider` (`StateProvider<bool>`) at `lib/core/providers/auth_state_provider.dart` — default `false`, overridden in `startApp` with `PrefsService.isLoggedIn`. Auth flows (login success, 401, manual logout) flip the value.
- [x] `routerProvider` at `lib/app/router.dart` reads auth state and applies `redirect:`. Re-evaluates on auth changes via `_AuthRefreshNotifier extends ChangeNotifier` adapter wired to `ref.listen(authStateProvider, ...)`. Plumbed as `refreshListenable`.
- [x] Public-route allowlist (`_publicRoutes`): `/splash`, `/onboarding`, `/login`, `/signup-step-{1,2,3}`, `/forgot-password`, `/forgot-otp`, `/reset-password`. Everything else is gated.
- [x] Redirect rules:
  - `!isAuth && route ∉ publicRoutes` → `/login`
  - `isAuth && route ∈ {/login, /signup-*, /forgot-*, /reset-password}` → `/home`
  - else → no redirect
- [x] `AppAnalyticsObserver` stub created at `lib/core/firebase/app_analytics_observer.dart` (no-op `NavigatorObserver`); wired into `routerProvider.observers` + the legacy `appRouter` fallback. Real Firebase delegate lands in Task 3.18.
- [x] Dead `RouteNames` pruning — left untouched. Phase 2.07 already handled the bulk; out of scope for this task.
- [ ] Manual cold-start smoke (logged-out → /login; logged-in → /home; 401 → /login) — **not verified** (no device/sim). Logic is asserted via test harness and the `_AuthRefreshNotifier` mechanism is standard go_router/Riverpod glue.

## Acceptance
- [x] `flutter analyze lib/app/ lib/main.dart lib/core/providers/ lib/core/firebase/` → No issues found. Full analyze → 301 (baseline).
- [x] Cold start respects auth state — `startApp` overrides `authStateProvider` with `PrefsService.isLoggedIn` before `runApp`; redirect runs first frame.
- [x] `AppAnalyticsObserver` is wired into the router observers list; once Task 3.18 lands the Firebase delegate, screen tracking activates without further router edits.

## Notes
The actual `AppAnalyticsObserver` class lands in [Task 3.18](task_18_analytics_crashlytics.md). This task wires it in once it exists.
