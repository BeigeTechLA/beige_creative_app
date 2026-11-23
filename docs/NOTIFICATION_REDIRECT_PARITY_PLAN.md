# Notification Redirect Parity Plan (biegeCPapp)

**Created:** 2026-11-23
**Status:** Phases 1–4 code-complete (2026-11-23); device QA outstanding

## Problem

Developer report: app killed, notification sits in tray a while, then tapped → redirection does not work.

### Root cause (verified)

"Time in tray" = proxy for **process reclaimed by OS**. Warm tap → `onMessageOpenedApp` (works). Tap after process death → **cold start** path → broken.

CP app compiles but uses the old fragile pattern. Two cold-start defects:

1. **Data-only terminated taps are permanently dropped.**
   - Backend sends data-only pushes; bg handler `_firebaseMessagingBackgroundHandler` (`push_notification_service.dart`) shows a local notification for `message.notification == null`.
   - On cold start `getInitialMessage()` returns null for a *local* notification tap.
   - `getNotificationAppLaunchDetails()` is never called.
   - bg-handler local-notif plugin (`push_notification_service.dart:44`) sets no `onDidReceiveNotificationResponse` / `onDidReceiveBackgroundNotificationResponse`.
   - → nothing captures the tap → `_pendingPayload` stays null → no redirect.

2. **Notification-type terminated taps captured but race-prone.**
   - `getInitialMessage()` sets `_pendingPayload`, but the only drain is a single-shot `AppShell.initState` postFrame (`shared/layouts/app_shell.dart:58`) → `processPendingNotification`.
   - No retry; readiness gate only `context != null && path != splash`. On cold boot (splash→login→shell) the drain can fire before the authenticated router exists → `pushNamed` swallowed, payload consumed, lost.

Foreground + warm-background work fine.

## Decision

Full router parity with biegeapp: extract a CP `NotificationTapRouter` mirroring biegeapp's design, adapted to CP `Routes` (`RouteSpec`), `ChatArgs`, `UpcomingShootDetailsArgs`, `ShootsArgs`. Matches the sibling-app mirror convention.

## Gate inputs available in CP (verified)

- `authStateProvider` (bool), `AccountStatus` (`.active`), `connectivityStatusProvider` (`ConnectivityStatus`), `guestModeProvider`.
- `_AuthRefreshNotifier` (merged `Listenable`) already serves as `refreshListenable` → reuse to drive `tapRouter.retry`.
- Payload exposes `type, title, chatId, bookingId, meetingId, folderId, filePath, targetRoute, rawMap`.
- Args: `messages_args.dart` (`ChatArgs`), `shoots_args.dart` (`UpcomingShootDetailsArgs`, `ShootsArgs`).

## Plan

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | **Cold-start capture.** In `initialize()`: added `getNotificationAppLaunchDetails()` fallback when `getInitialMessage()` null. Set `onDidReceiveBackgroundNotificationResponse` on BOTH plugin instances (main setup + bg-handler); background isolate persists tapped payload to `SharedPreferences` via top-level `_onDidReceiveBackgroundNotificationResponse`; `_drainPersistedTap()` adopts it on next launch (only if launch capture didn't already). | `lib/core/notifications/push_notification_service.dart` | Killed + data-only tap yields a pending payload on cold start | ✅ Completed |
| 2 | **Port `NotificationTapRouter`.** New class mirroring biegeapp verbatim (control logic), `_destination` adapted to CP `Routes` + `ChatArgs`/`UpcomingShootDetailsArgs`, `router.namedLocation`. Service now funnels all tap sources through `tapRouter.enqueue`; `_executeRouting`/`handleNotificationClick(BuildContext)` removed. | `lib/core/notifications/notification_tap_router.dart` (new, 290 lines), `push_notification_service.dart` | Service enqueues taps into router; no direct `_executeRouting` | ✅ Completed |
| 3 | **Wire router + retract fragile drain.** `attach(router, canNavigate, blockedReason)` in `routerProvider` (gate = `authStateProvider` + `accountStatusProvider==active` + `connectivityStatusProvider!=offline` + `!Routes.publicPaths`); `notifier.addListener(tapRouter.retry)`; `detach` on dispose. Removed single-shot `AppShell.initState` drain (+ its unused import). Added resume→`processPendingNotification()` in `app_lifecycle_observer.dart`. | `lib/app/router.dart`, `lib/shared/layouts/app_shell.dart`, `lib/core/restoration/app_lifecycle_observer.dart`, `push_notification_service.dart` | Tap lands on correct screen on cold start regardless of boot route sequence | ✅ Completed |
| 4 | **Tests + gate.** Ported router unit test (12 cases: cold-start/splash gate, survive-login, dedup, reject-retain, offline, meeting query, files folder, profile, internal/external deeplink, already-open ack, dispatch-failure onError, inactive-account blockedReason). | `test/core/notifications/notification_tap_router_test.dart` (new) | analyze clean · router test 12/12 ✅ · full suite **784 pass / 2 fail (both pre-existing, see notes)** · iOS/Android build NOT run | ✅ Completed (device/build QA pending) |

## Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Kill app → notification+data push → wait 2+ min → tap | Routes to correct screen (chat/booking/meeting/file) | logged-out → after login; offline; guest mode |
| 2 | Kill app → data-only push → wait 2+ min → tap | Routes to correct screen (currently broken) | boot on splash when tapped |
| 3 | Background (warm) → tap | Routes to correct screen | — |
| 4 | Foreground → push arrives → tap | Local banner shown, routes | — |
| 5 | Repeat 1–4 on Android + iOS | Identical behavior | iOS APNs warmup; Android 13 POST_NOTIFICATIONS denied; account not active → gated then routes once active |

## Execution Notes (2026-11-23)

- `flutter analyze`: notification files + router + app_shell + lifecycle observer = 0 issues. Project-wide analyze shows 3 pre-existing `override_on_non_overriding_member` warnings in unrelated test files (`login_notifier_test`, `comments_notifier_test`, `conversation_list_notifier_test`) — not touched.
- Full `flutter test`: **784 pass / 2 fail**. Both failures confirmed **pre-existing** (fail identically with this work git-stashed out):
  1. `test/widget_test.dart` — "App smoke test" (App build hits a provider-in-error-state; `PushNotificationService.instance`/`pushTokenSyncProvider` needs Firebase, which the smoke test does not stub).
  2. `test/app/route_page_coverage_test.dart` — a notification-area route page builder is null in the static coverage check (unrelated to tap routing).
- iOS/Android release builds + on-device QA still outstanding.

## Notes

- Sibling app `biegeapp` restores its own (previously deleted) `NotificationTapRouter` — see `docs/NOTIFICATION_REDIRECT_FIX_PLAN.md` there. Both routers are behaviorally identical (same control logic; only `_destination` differs for app-specific routes/args).
