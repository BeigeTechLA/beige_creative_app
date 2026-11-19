# Notification Feature — Working Reference

How notifications work end-to-end in `beige_creative_app` (BEIGE, crew client).
Reflects current code after the 2026-11-19 push audit fixes. Pairs with
`docs/audit/PUSH_NOTIFICATION_AUDIT_2026-11-19.md` (findings/history) and
`docs/PUSH_NOTIFICATION_ARCHITECTURE_SPEC.md` (API contracts).

The feature has two halves:

- **Push** (device-level FCM) — `lib/core/notifications/`
- **In-app notification center** (REST list/counts) — `lib/features/notification/`

Both share one routing engine and one `session_id`.

---

## 1. Stack

| Package | Version | Role |
|---------|---------|------|
| `firebase_core` | 5.0.0 | Firebase init |
| `firebase_messaging` | 17.0.0 | FCM token + remote messages |
| `flutter_local_notifications` | ^22.3.0 | Local notification display + channels |

Firebase config is flavored (dev/prod) per platform:
`android/app/src/{dev,prod}/google-services.json`,
`ios/config/{dev,prod}/GoogleService-Info.plist`. `Firebase.initializeApp()` is
called without options and reads the native per-flavor config. Pins are locked
for CocoaPods compatibility — see pubspec comments before bumping.

---

## 2. Boot sequence

`lib/main_{dev,prod}.dart` → `startApp()` (`lib/main.dart`):

1. `FirebaseService.initialize()` — tolerant; push is skipped if config missing.
2. If initialized, `PushNotificationService.instance.initialize()`:
   - registers the background message handler,
   - sets up `flutter_local_notifications` and creates the 4 Android channels,
   - starts token fetch + refresh listeners,
   - captures a terminated-launch notification tap into `_pendingPayload`.
   - **Does NOT request the OS permission here** (moved to post-login, §3).
3. `App` (`lib/app/app.dart`) watches `pushTokenSyncProvider`, which keeps the
   auth-gated token registration + permission prompt alive.

---

## 3. Token lifecycle

```
cold start → initialize() → _setupTokenManagement()   (fetch pre-login; may be null)
     │
login (or returning user) → pushTokenSyncProvider authenticated branch
     │   requestPermissions()  →  ensureToken()  →  onTokenRefreshed(token)
     │                                                 │
     │                                getAppSessionId() + rememberSession()
     │                                POST /push-notifications/tokens
     │                                     { fcm_token, session_id }
     │
token rotates → FirebaseMessaging.onTokenRefresh → onTokenRefreshed → re-POST
     │
logout → AuthStateNotifier._endSession → _removeFcmToken(deleteToken: true)
     │     DELETE /push-notifications/tokens { session_id }
     │          ↑ runs BEFORE clearSession() so the Bearer token is still live
     │     resetToken(deleteFromFirebase: true) → deleteToken() + clear _fcmToken
     │
clearSession() wipes bearer / user / prefs
```

Key rules:

- **`session_id`** is a random UUID v4 per `(install, user)`, stored in prefs
  under `app_session_id_<userId>` (`PrefsSessionStore.getAppSessionId()`). It is
  **not** `user.id`; the per-install id keeps multi-device mapping distinct. It
  is also cached in memory by `PushNotificationService.rememberSession()` so
  logout removal still has the correct id after prefs are cleared.
- **iOS token fetch** gates on the APNS token: `fetchToken()` polls
  `getAPNSToken()` up to 5× (1s each) before calling `getToken()`, avoiding a
  null-token cold-start race.
- **Registration is auth-gated**: `onTokenRefreshed` no-ops unless
  `authStateProvider` is true. Pre-login token fetches are re-pushed after the
  callback is wired.
- **Logout rotates the token** (`deleteToken()`); a transient session expiry
  (`expireSession()`) keeps the token to avoid churn. Both run through
  `_endSession`, so both deregister the backend row.
- **Removal ordering is load-bearing**: the `DELETE` must run before
  `clearSession()`, otherwise `AuthInterceptor` has no token to attach and the
  backend rejects the removal (the original audit HIGH finding).

---

## 4. Android notification channels

Four dedicated channels, created at init (and recreated in the background
isolate):

| Channel id | Name | Importance | Used for |
|------------|------|-----------|----------|
| `beige_chat_channel` | Chat Messages | max | messages / chat |
| `beige_booking_channel` | Booking Updates | high | shoot bookings |
| `beige_meeting_channel` | Meeting Reminders | high | meetings |
| `beige_general_channel` | General Updates | default | everything else (manifest default) |

Small icon is `@drawable/ic_notification` (monochrome, all five density buckets)
across every path — manifest default, local-notif init, foreground, background.
`largeIcon` stays the colorful `@mipmap/ic_launcher`.

Android 13+ `POST_NOTIFICATIONS` is declared and requested at runtime.

---

## 5. iOS specifics

- Entitlements: `aps-environment` = `development` (Runner) / `production`
  (RunnerProd).
- `Info.plist` `UIBackgroundModes` includes `remote-notification` and `fetch`.
- Foreground presentation options are turned **off** so iOS does not auto-show;
  `flutter_local_notifications` renders foreground banners instead (no dup).
- App icon badge is zeroed natively in
  `AppDelegate.applicationDidBecomeActive` (`setBadgeCount(0)` on iOS 16+,
  `applicationIconBadgeNumber = 0` fallback).

---

## 6. Message handling by app state

| App state | Path |
|-----------|------|
| **Foreground** | `onMessage` → `_showForegroundNotification` → local notif on the type's channel |
| **Background + `notification` payload** | OS tray shows automatically (manifest default icon/channel) |
| **Background + data-only** | `_firebaseMessagingBackgroundHandler` (`@pragma('vm:entry-point')`) re-inits Firebase, recreates the channel, shows a local notif |
| **Terminated, launched by tap** | `getInitialMessage()` → `_pendingPayload` → flushed by `app_shell.processPendingNotification` once the router is ready |
| **Background, resumed by tap** | `onMessageOpenedApp` → route immediately |

---

## 7. Payload parsing + deep-link routing

`NotificationPayload.fromMap` resolves one of **8 types** — `chat`, `booking`,
`meeting`, `files`, `profile`, `deeplink`, `unknown` — using a 3-tier strategy:

1. **Topic** (`topic` / `category`): e.g. `shoots`→booking, `messages`→chat.
2. **Type / event string** (`type` / `notification_type` / `event`): substring
   match (`booking*`, `*message*`, `*meeting*`, `*file*`, `*profile*`, …).
3. **Key heuristics**: presence of `chat_room_id`, `file_id`, `meeting_id`,
   `booking_id`, `targetRoute`, etc.

It reads both the flat `data` map and a nested `payload` map, with many
snake/camel aliases per field.

`_executeRouting` (GoRouter via `rootNavigatorKey`) performs the navigation.
Guards: if the context is null or the current route is splash, the payload is
re-queued into `_pendingPayload`.

| Type | Destination |
|------|-------------|
| chat | `chat` (conversationId) → else `messages` |
| booking | `upcomingShootDetails` (projectId) → else `shoots` |
| meeting | `meetings` tab (`?meetingId`) |
| files | `filesFolder` (id) → else `files` |
| profile | `myProfile` |
| deeplink / unknown | `targetRoute` → else `notificationList` |

The same `handleNotificationClick(payload)` entry point is reused by in-app
notification list taps, so push and in-app share one routing engine.

---

## 8. In-app notification center

Layered with the standard Phase-4 pattern:
`NotificationRemoteSource` → `NotificationRepositoryImpl` → providers → screens.

Endpoints (`app-notifications`):

- `GET /app-notifications` — paginated list; `status` / `search` / `category` filters
- `GET /app-notifications/counts` — unread badge count
- `GET /app-notifications/{id}` — detail
- `PATCH /app-notifications/{id}/read` · `/unread` · `/read-all`
- `DELETE /app-notifications/{id}`

Providers (`presentation/providers/notification_list_providers.dart`):

- `notificationCountProvider` — `FutureProvider.autoDispose<NotificationCounts>`.
- `notificationListProvider` —
  `NotifierProvider.autoDispose<NotificationListNotifier, NotificationListState>`;
  paginated, with `markAsRead` / `markAsUnread` / `markAllAsRead` / `delete` /
  bulk-read commands. Each mutation invalidates `notificationCountProvider`.

Screens: `notification_screen`, `notification_section_screen`, plus
`notification_stacked_cards`, `notification_item_card`,
`notification_filter_bottom_sheet`, `empty_notification_widget`.

---

## 9. Wiring map

```
main.dart / startApp
  └─ PushNotificationService.initialize()        (channels, listeners, bg handler)

app.dart (App)
  └─ watch pushTokenSyncProvider                 (auth-gated permission + token register)

pushTokenSyncProvider
  ├─ onTokenRefreshed  → POST /push-notifications/tokens   (register / refresh)
  └─ login transition  → requestPermissions() + ensureToken()

AuthStateNotifier._endSession
  └─ _removeFcmToken → DELETE /push-notifications/tokens → resetToken   (logout teardown)

AuthInterceptor        → Bearer on POST/DELETE token calls
app_shell              → processPendingNotification()                   (flush queued tap)
rootNavigatorKey       → GoRouter deep-link routing
```

Invariants:

- **One routing engine** handles push taps, terminated-launch, and in-app list taps.
- **One `session_id`** ties the device token to its backend row.
- **Token register/remove is gated on `authStateProvider`**; removal is ordered
  before session clear so it stays authenticated.

---

## 10. Key files

| Concern | File |
|---------|------|
| Push service (init, channels, token, routing) | `lib/core/notifications/push_notification_service.dart` |
| Payload model + type resolution | `lib/core/notifications/notification_payload.dart` |
| Auth-gated token register + permission | `lib/core/notifications/push_token_sync_provider.dart` |
| Logout teardown ordering | `lib/core/providers/auth_state_provider.dart` |
| Token REST source | `lib/features/notification/data/sources/notification_remote_source.dart` |
| In-app list/counts providers | `lib/features/notification/presentation/providers/notification_list_providers.dart` |
| session_id generation | `lib/core/session/prefs_session_store.dart` |
| iOS badge reset | `ios/Runner/AppDelegate.swift` |
| Android channels / default icon | `android/app/src/main/AndroidManifest.xml` |

---

## 11. Known pending (device-only verification)

Covered in code, not yet confirmed on a physical device:

- Logout `DELETE` carries auth + returns 2xx; rotated token stops receiving (both platforms).
- Android tray renders the monochrome glyph (no white square).
- iOS badge clears on open; post-auth permission prompt fires for login and returning users; APNS still registers.

See `docs/audit/PUSH_NOTIFICATION_AUDIT_2026-11-19.md` for the full test matrix.
