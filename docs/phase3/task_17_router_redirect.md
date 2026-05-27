# Task 3.17 — GoRouter auth redirect + observer

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 3h

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
- [ ] Add `authStateProvider` (bool); update on token write/clear
- [ ] In `routerProvider`, read auth state and apply `redirect:` per `MIGRATION_RULES.md` §3.2
- [ ] Prune dead `RouteNames` flagged by `NAVIGATION_AUDIT.md` (already partly handled in 2.07)
- [ ] Smoke: cold start logged-out → `/login`; cold start logged-in → `/home`; 401 → `/login`

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Cold start respects auth state
- [ ] `AppAnalyticsObserver` fires (verify by tapping into the observer in dev)

## Notes
The actual `AppAnalyticsObserver` class lands in [Task 3.18](task_18_analytics_crashlytics.md). This task wires it in once it exists.
