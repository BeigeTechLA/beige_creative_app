# Push Notification Audit — 2026-11-19

Audit of FCM push notification setup (Android + iOS), token fetch/refresh, and
logout token removal for `beige_creative_app` (BEIGE CP).

**Branch:** `feature_notification`
**Reviewer:** Claude Code
**Scope:** `lib/core/notifications/*`, notification feature data layer, auth /
session flow, native config (Android manifest, iOS entitlements/Info.plist,
flavored Firebase config), and `docs/PUSH_NOTIFICATION_ARCHITECTURE_SPEC.md`.

## Files reviewed

- `lib/core/notifications/push_notification_service.dart`
- `lib/core/notifications/push_token_sync_provider.dart`
- `lib/features/notification/data/sources/notification_remote_source.dart`
- `lib/features/notification/data/repositories/notification_repository_impl.dart`
- `lib/core/providers/auth_state_provider.dart`
- `lib/core/network/interceptors/auth_interceptor.dart`
- `lib/core/network/dio_client.dart`
- `lib/core/session/session_store.dart`, `prefs_session_store.dart`
- `lib/main.dart`, `lib/app/app.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`, `Runner.entitlements`, `RunnerProd.entitlements`
- Flavored Firebase config (dev/prod, both platforms)

---

## Verdict

Setup is solid overall — multi-channel local notifications, flavored Firebase
config, APNS-aware iOS token fetch, background handler, and deep-link routing
are all present and mostly correct.

**However, one HIGH-severity bug: logout token removal races the session clear
and most often fires the `DELETE` without a Bearer token → backend keeps the
row → the logged-out device keeps receiving push notifications.** A handful of
medium and low issues are listed below.

---

## What is correct

- **Flavored native config** present on both platforms:
  `android/app/src/{dev,prod}/google-services.json`,
  `ios/config/{dev,prod}/GoogleService-Info.plist`.
- **iOS entitlements** correct: `aps-environment` = `development` (Runner) /
  `production` (RunnerProd). `UIBackgroundModes` includes `remote-notification`
  and `fetch`.
- **Android 13+** `POST_NOTIFICATIONS` declared and requested at runtime via
  `requestNotificationsPermission()`.
- **iOS APNS gate**: `fetchToken()` polls `getAPNSToken()` up to 5× before
  calling `getToken()`, avoiding the null-token cold-start race.
- **4 dedicated channels** (chat / booking / meeting / general) with correct
  importance tiers; created at init and recreated in the background isolate.
- **Background handler** is `@pragma('vm:entry-point')`, re-inits Firebase, and
  shows a local notification only for data-only messages (no duplicate with the
  system tray).
- **Token sync** gated on `authStateProvider`, re-pushes a cached pre-login
  token after the callback is wired. Login `POST` carries the Bearer header
  (session is written before the auth-state flip).
- **session_id survives logout**: held in memory via `rememberSession()`, so the
  removal call still has the correct id after prefs are cleared.
- **Firebase init tolerant** (`isInitialized` guard); push init is skipped when
  Firebase config is absent.

---

## Findings

| # | Severity | Area | Issue |
|---|----------|------|-------|
| 1 | **HIGH** | Logout removal | `DELETE` token races session clear → sent without Bearer → 401 → token orphaned on backend |
| 2 | MEDIUM | Android icon | FCM `default_notification_icon` = `@mipmap/ic_launcher`, not the monochrome `ic_notification` → white square in tray |
| 3 | MEDIUM | Spec drift | `session_id` is a random per-(install,user) UUID, spec says `user.id`; checklist §210/211 stale |
| 4 | LOW | Cleanup | No `FirebaseMessaging.deleteToken()` / in-memory `_fcmToken` clear on logout |
| 5 | LOW | Dead code | `clearAppSessionId()` removes the wrong key; `deviceType` repo param dropped |
| 6 | LOW | UX | Permission prompt fires at cold start (pre-login), not at a contextual moment |
| 7 | LOW | Misc | iOS badge never reset; `expireSession()` 401-path `DELETE` also fails silently |

---

### Finding 1 — HIGH: logout `DELETE` fires unauthenticated (token not removed)

Two decoupled reactions to `authState → false` with **no ordering guarantee**:

- `AuthStateNotifier._endSession` (`auth_state_provider.dart:45`): sets
  `state = false`, then `await clearSession()` which calls `_secure.clearToken()`
  (wipes the Bearer token).
- `pushTokenSyncProvider` listener (`push_token_sync_provider.dart:51`): on
  `!next && previous == true`, calls
  `await removeFcmToken(sessionId: lastSession)` → `DELETE` through
  `AuthInterceptor`.

Timing trace:

1. `state = false` schedules the Riverpod listener flush (a microtask).
2. Synchronous code continues into `clearSession()` → hits
   `await _secure.clearToken()` first → the token wipe is kicked off and
   `_endSession` suspends.
3. The scheduled microtask runs the listener → `DELETE` →
   `AuthInterceptor.onRequest` → `await tokenReader()` → **the token is already
   cleared → `null` → no `Authorization` header is attached.**

Spec §3.3 explicitly requires `Authorization: Bearer <AUTH_TOKEN>` on the
`DELETE`. So the request returns 401 and the backend keeps the token row.

**Impact:** the device keeps receiving push notifications after logout until the
FCM token naturally rotates — a privacy/security regression (an ex-user, or the
next user on a shared device, receives notifications intended for the previous
session). Non-deterministic: it may succeed on some runs and fail on others.
Both `logout()` and `expireSession()` are affected (the expire path's token is
already dead, so lower impact there).

**Fix direction:** deregister the token *before* clearing the session, so the
`DELETE` is guaranteed to carry a valid Bearer token. Either await the removal
inside `_endSession` ahead of the `clearSession` cleanup (matches the spec's
"inside `clearSession()`" intent), or snapshot the Bearer token and attach it
explicitly so interceptor ordering no longer matters.

### Finding 2 — MEDIUM: wrong Android default notification icon

`AndroidManifest.xml:51` sets `default_notification_icon` to
`@mipmap/ic_launcher` (full-color). For system-tray FCM `notification` messages
(background/terminated delivery), Android masks non-alpha icons → a white/gray
square. The monochrome `ic_notification.png` already exists in every density
bucket but is unused for the default. The local-notification path already uses
`@drawable/ic_notification` correctly — so the two paths are inconsistent.

**Fix:** point the manifest default to `@drawable/ic_notification`.

**Implemented (2026-11-19):**
- `AndroidManifest.xml` `default_notification_icon` → `@drawable/ic_notification`.
- Also aligned the background-isolate data-only path in
  `push_notification_service.dart`: its `AndroidInitializationSettings` and
  `AndroidNotificationDetails.icon` were still `@mipmap/ic_launcher` → now
  `@drawable/ic_notification`. The colorful `largeIcon` (`@mipmap/ic_launcher`)
  and the app launcher icon (`android:icon`) are intentionally unchanged.
- Result: every small-icon path (manifest default, local-notif init,
  foreground, background) uses the monochrome drawable, which exists in all five
  density buckets. `flutter analyze` clean. On-device tray-render check (Test
  Summary row 1) pending.

### Finding 3 — MEDIUM: `session_id` semantics drift from spec

`getAppSessionId()` (`prefs_session_store.dart:96`) returns a random
`Uuid().v4()` keyed per user (`app_session_id_<userId>`), not `user.id` as spec
§3.1 states. The implementation is arguably *better* (distinct per install →
multi-device safe), but the spec and its checklist (§210/211, "inside
`AuthNotifier`") are stale versus the real `pushTokenSyncProvider` wiring.

**Fix:** update `docs/PUSH_NOTIFICATION_ARCHITECTURE_SPEC.md` to match the
implementation and check off the delivered items.

**Implemented (2026-11-19):** rewrote spec §3.1 to describe the per-(install,user)
UUID (keyed `app_session_id_<userId>`, cached in memory for logout) with a note
that it deliberately diverges from the old `user.id` wording. Updated §3.3 "When
Called" to document the before-`clearSession()` ordering. Checked off §209–211
(FCM init, login hook, logout hook) with their real file locations and corrected
the stale `lib/core/services/...` paths to `lib/core/notifications/...`. Left
§212 (preference sync) and §213 (tap-routing tests) unchecked — not covered by
this token-lifecycle audit; §213's test path corrected.

### Findings 4–7 — LOW

- **4** — No `FirebaseMessaging.instance.deleteToken()` nor `_fcmToken = null`
  on logout. The device token lingers (re-registered on next login — acceptable,
  but an incomplete teardown).
- **5** — `clearAppSessionId()` removes the bare `app_session_id` key, never the
  `_<userId>` variant it actually writes → dead/buggy (not called during logout,
  so latent). `deviceType` is accepted by the repo impl then dropped (the remote
  source recomputes it from `Platform`).
- **6** — Permission is requested unconditionally in `initialize()` at cold
  start; iOS best practice favors a contextual prompt after the user sees value.
  The token is also fetched/synced even when permission is denied (harmless but
  wasteful).
- **7** — iOS app badge is never cleared on open; `expireSession()`'s `DELETE`
  fails silently (the server session is already dead — low impact).

**Implemented (2026-11-19):**

- **4** — Added `PushNotificationService.resetToken({required deleteFromFirebase})`:
  clears the in-memory `_fcmToken` and remembered session id, and on explicit
  logout also calls `FirebaseMessaging.deleteToken()` so the device token
  rotates. `_removeFcmToken` now takes `deleteToken` = `emitLogoutEvent`, so an
  explicit logout fully tears down while a transient `expireSession()` keeps the
  token (no churn). Guarded.
- **5** — `clearAppSessionId()` now removes every key prefixed `app_session_id`
  (both the bare key and the `_<userId>` variants). Dropped the unused
  `deviceType` param from `NotificationRepository.saveFcmToken` and its impl (the
  remote source + `AppHeadersInterceptor` already stamp `device_type`).
- **6** — Removed the cold-start `requestPermissions()` from
  `PushNotificationService.initialize()`; it is now requested from
  `pushTokenSyncProvider` on the authenticated transition (and for returning
  logged-in users on cold start via `fireImmediately`), before `ensureToken()`
  so iOS APNS registration still proceeds. Channels/listeners still set up at
  cold start.
- **7** — iOS badge is now zeroed natively in `AppDelegate.applicationDidBecomeActive`
  (`setBadgeCount(0)` on iOS 16+, `applicationIconBadgeNumber = 0` fallback). The
  `expireSession()` silent-`DELETE` note (7b) is left as-is — intentional, the
  server session is already dead and the call is guarded.

**Verification:** `flutter analyze` on all touched Dart files — no issues
(full-project analyze shows only 3 pre-existing `clearAppSessionId` override
warnings in Phase-6 test fakes, unrelated to this work). Focused suites
(`test/core/providers/`, `login_notifier_test.dart`,
`notification_category_sheet_test.dart`) pass 48/48. iOS badge + permission-flow
checks pending on device.

---

## Fixes Plan

Scope: Finding 1 (must-fix) and Finding 2 (visible quality). Finding 3 is a doc
update bundled in. Findings 4–7 were initially deferred and then implemented on
2026-11-19 (see per-finding "Implemented" notes above and the Phase 5 row below).

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Fix logout token-removal race so `DELETE` always carries a valid Bearer token | `lib/core/providers/auth_state_provider.dart`, `lib/core/notifications/push_token_sync_provider.dart` | Token removal awaited *before* `clearSession()`; `DELETE` observed with `Authorization` header; logout still completes even if removal fails | Completed |
| 2 | Point Android FCM default icon at the monochrome drawable | `android/app/src/main/AndroidManifest.xml`, `lib/core/notifications/push_notification_service.dart` | `default_notification_icon` = `@drawable/ic_notification`; tray icon renders as a clean monochrome glyph | Completed |
| 3 | Reconcile spec doc with implementation | `docs/PUSH_NOTIFICATION_ARCHITECTURE_SPEC.md` | §3.1 describes the per-(install,user) UUID; §210/211 checklist items marked done with the real wiring location | Completed |
| 4 | Verify + log | `MIGRATION_LOG.md`, this file | `flutter analyze` clean for touched files; focused tests green; findings table statuses updated | Completed |
| 5 | Findings 4–7 (token teardown, dead code, permission timing, iOS badge) | `push_notification_service.dart`, `auth_state_provider.dart`, `push_token_sync_provider.dart`, `prefs_session_store.dart`, `notification_repository.dart(+impl)`, `ios/Runner/AppDelegate.swift` | `deleteToken()` on explicit logout; `clearAppSessionId` removes all keys; `deviceType` param gone; permission requested post-auth; iOS badge zeroed on active | Completed |

### Phase 1 — design detail

The cleanest fix keeps the two concerns together and ordered. Preferred option:

- Move the logout-time `removeFcmToken` out of the fire-and-forget
  `pushTokenSyncProvider` listener and into an explicit step in `_endSession`
  that runs **before** the `clearSession` cleanup, wrapped in the same
  `_cleanUp` guard (so a removal failure never strands logout):

  ```
  Future<void> _endSession({required bool emitLogoutEvent}) async {
    state = false;                       // revoke access immediately
    ...existing invalidations...
    await _cleanUp('fcm token', _removeFcmToken);   // NEW — before clearSession
    await _cleanUp('session', () => clearSession());
    ...rest unchanged...
  }
  ```

  `_removeFcmToken` reads `PushNotificationService.instance.lastSessionId` and
  calls `notificationRepositoryProvider.removeFcmToken(...)`, then
  `clearSession()`. The `DELETE` now runs while the Bearer token is still
  present. Keep the listener's logout branch only as a no-op/fallback or remove
  it to avoid a double `DELETE`.

- Alternative (less invasive): keep the listener but snapshot the Bearer token
  before `state = false` and attach it to the `DELETE` via a request option,
  bypassing the interceptor's live `tokenReader`. Rejected as primary because it
  duplicates token-attachment logic.

Open question for the user: on `expireSession()` (401 path), the token is
already server-side-invalid — keep attempting the `DELETE` (harmless, fails
silently) or skip it for the expiry path? Default: keep it, guarded, no behavior
change.

**Implemented (2026-11-19):** chose the preferred option.

- `AuthStateNotifier._endSession` now calls `await _cleanUp('fcm token',
  _removeFcmToken)` **before** the `session` cleanup. The new `_removeFcmToken`
  reads `PushNotificationService.instance.lastSessionId`, calls
  `notificationRepositoryProvider.removeFcmToken(...)`, then
  `pushService.clearSession()`. It is wrapped in `_cleanUp`, so a removal
  failure logs and still lets the session teardown + router redirect proceed.
- The singleton access is guarded with try/catch: in test environments without
  Firebase, `PushNotificationService.instance` constructs `FirebaseMessaging`
  and throws — treated as "nothing registered → no-op".
- The redundant logout branch was removed from `pushTokenSyncProvider`; it only
  handles login now. A comment records that logout removal is owned by
  `_endSession` to preserve ordering and avoid a double `DELETE`.
- `expireSession()` shares `_endSession`, so it now also attempts removal
  (guarded, kept per default).

**Verification:** `flutter analyze` on both touched files — no issues.
`test/core/providers/session_expiry_test.dart` (incl. `logout` / expiry cases)
and `test/features/auth/presentation/login_notifier_test.dart` pass (44 tests).
Manual network-log verification (Test Summary rows 2–3) still pending on device.

### Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Log in (dev flavor), background the app, send a test push | Notification arrives; tray icon is the monochrome glyph, not a white square | Android 13 fresh install (permission prompt), Android 12 and below |
| 2 | While logged in, explicit Logout; capture network log | `DELETE /push-notifications/tokens` carries `Authorization: Bearer <token>` and returns 2xx; token row removed | Slow secure-storage device; airplane mode (removal fails, logout still completes) |
| 3 | After logout in step 2, send a test push to the old token | No notification delivered (token deregistered) | Token already rotated server-side |
| 4 | Trigger session expiry (invalidate token server-side), make an authed call | Router returns to Login; no crash; expiry-path `DELETE` behaves per chosen option | Repeated 401s share one cleanup |
| 5 | Log in on two devices, log out of one | Only the logged-out device's token row is removed; the other keeps receiving push | Same user, two installs |
| 6 | Foreground push while app open | Single local notification on the correct channel (no duplicate) | iOS foreground presentation options off |

---

## Recommended priority

1. **Finding 1** (logout auth ordering) — functional + privacy. Must-fix.
2. **Finding 2** (notification icon) — visible quality.
3. **Finding 3** (spec reconciliation).
4. Findings 4–7 — optional cleanup, track for a later pass.
