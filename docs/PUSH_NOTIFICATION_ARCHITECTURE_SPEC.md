# Push Notification Architecture & Implementation Specification
**App Name**: Beige Creative (Flutter Mobile App)  
**Target Surface**: Creative / Crew Mobile Application (Android & iOS)  
**Date**: August 4, 2026  
**Document Version**: 1.0.0  

---

## 1. Executive Summary & Architecture Overview

This specification details the end-to-end architecture, API contracts, session management, payload routing, and Flutter code structure for **Push Notification Integration** in the Beige Creative Mobile Application.

### System Architecture Diagram

```
┌───────────────────────────┐         ┌───────────────────────────┐         ┌───────────────────────────┐
│   Beige Flutter App       │         │   Beige App Backend       │         │   Third-Party Push Engine │
│   (Android & iOS)         │         │   (API Gateway)           │         │   (Firebase / FCM)        │
└─────────────┬─────────────┘         └─────────────┬─────────────┘         └─────────────┬─────────────┘
              │                                     │                                     │
              │  1. Login Success                   │                                     │
              ├────────────────────────────────────►│                                     │
              │                                     │                                     │
              │  2. Get FCM Token from Firebase     │                                     │
              │───┐                                 │                                     │
              │   │ FirebaseMessaging.getToken()    │                                     │
              │◄──┘                                 │                                     │
              │                                     │                                     │
              │  3. POST /push-notifications/tokens │                                     │
              ├────────────────────────────────────►│  Forward Token & Preferences        │
              │   Headers: device_type=android/iOS  ├────────────────────────────────────►│
              │   Body: fcm_token, session_id       │                                     │
              │                                     │                                     │
              │  4. PATCH /push-notifications/prefs │                                     │
              ├────────────────────────────────────►│  Update Session Preferences         │
              │   Body: session_id, topics          ├────────────────────────────────────►│
              │                                     │                                     │
              │                                     │  5. Event Trigger (Shoot/Msg/etc.) │
              │                                     │◄────────────────────────────────────┤
              │                                     │                                     │
              │  6. Deliver Push Notification       │  Check session preference           │
              │◄────────────────────────────────────┴─────────────────────────────────────┤
              │                                     │                                     │
              │  7. User Taps Push Notification     │                                     │
              │───┐                                 │                                     │
              │   │ handlePushTap(payload)          │                                     │
              │   │ GoRouter Deep-Link Navigation   │                                     │
              │◄──┘                                 │                                     │
```

---

## 2. Automatic Header Stamping (`device_type`)

In the Beige Flutter codebase, every HTTP request sent via `DioClient` is automatically intercepted and stamped with device metadata by `AppHeadersInterceptor` (`lib/core/network/interceptors/app_headers_interceptor.dart`).

### Automatic Headers Sent on Every Request:
| Header Key | Header Value | Description |
| :--- | :--- | :--- |
| `device_type` | `"android"` or `"iOS"` | Resolved at app startup via `Platform.isIOS ? 'iOS' : 'android'` |
| `user_type_name` | `"creative"` | Surface identifier for Creative/Crew app |
| `user_type` | `"2"` | Numeric role code (`2` = Creative, `3` = Client) |

> **Backend Note**: Per API documentation §2.1, `device_type` is accepted in request headers. Because `AppHeadersInterceptor` automatically attaches this header to all API requests, manual inclusion in JSON bodies is optional and handled automatically by Dio.

---

## 3. Session & FCM Token Lifecycle

### 3.1 Session Identifier (`session_id`)
- `session_id` is derived from the active user's persistent session state in `SessionStore` (`lib/core/session/session_store.dart`).
- When a user logs in, `SessionStore` stores the `UserSnapshot` containing `user.id`.
- The `user.id` (or auth session token) serves as the stable `session_id` for device token mapping.

---

### 3.2 Token Registration API Contract

#### `POST /push-notifications/tokens`
- **When Called**: Immediately after successful user login, and whenever Firebase refreshes the FCM Token (`FirebaseMessaging.instance.onTokenRefresh`).
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  device_type: android  (or iOS - injected automatically by AppHeadersInterceptor)
  Content-Type: application/json
  ```
- **Request Body**:
  ```json
  {
    "fcm_token": "eK3x9L...fcm_token_string",
    "session_id": "USER_SESSION_ID"
  }
  ```

---

### 3.3 Token Removal API Contract (Logout)

#### `DELETE /push-notifications/tokens`
- **When Called**: Triggered when the user explicitly logs out or when an unauthenticated 401 response occurs.
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  ```
- **Request Body**:
  ```json
  {
    "session_id": "USER_SESSION_ID"
  }
  ```

---

### 3.4 Preference Sync API Contract

#### `PATCH /push-notifications/preferences`
- **When Called**: Whenever the user updates settings in `NotificationSettingsScreen` or taps "Save" in `NotificationCategorySheet`.
- **Request Body**:
  ```json
  {
    "session_id": "USER_SESSION_ID",
    "notification_preferences": {
      "push_enabled": true,
      "topics": {
        "shoots": true,
        "payments": false,
        "messages": true,
        "meetings": true,
        "proposals": false,
        "files": true,
        "system": true
      }
    }
  }
  ```

---

## 4. Topic Routing & Tap Handling (`handlePushTap`)

When a push notification is tapped by the user, the `PushNotificationService` extracts the data payload and routes the user using `GoRouter`.

### 4.1 Routing Table Matrix

| Topic | Event Type (`type`) | Payload Parameters | Target Screen / Route Name | Navigation Action |
| :--- | :--- | :--- | :--- | :--- |
| `shoots` | `booking_confirmed` | `booking_id` | `Routes.upcomingShootDetails` | Opens Shoot Details screen for `booking_id` |
| `messages` | `direct_message`<br>`messaging_initiated`<br>`mention` | `chat_room_id` / `room_id`<br>`booking_id` | `Routes.chatDetails` / `Routes.chat` | Opens Chat Thread screen for `chat_room_id` |
| `meetings` | `meeting_scheduled`<br>`meeting_participant_added`<br>`meeting_updated`<br>`meeting_rescheduled`<br>`meeting_cancelled` | `meeting_id`<br>`booking_id` | `Routes.meetings` | Opens Meetings calendar/list view |
| `files` | `raw_files_uploaded`<br>`edited_files_delivered`<br>`new_version_uploaded`<br>`files_selected_for_editing`<br>`revision_requested_on_edit`<br>`revision_comment_added`<br>`final_files_approved` | `booking_id`<br>`project_id`<br>`filepath` | `Routes.files` / `Routes.filesFolder` | Opens File Manager or specific folder |
| *Fallback* | Any unmapped topic | None | `Routes.notifications` | Opens Notification Center Screen |

---

### 4.2 Standard Tap Handler Implementation Logic

```dart
void handlePushTap(Map<String, dynamic> data, BuildContext context) {
  final topic = data['topic']?.toString() ?? '';
  final type = data['type']?.toString() ?? '';
  
  switch (topic) {
    case 'shoots':
      final bookingId = data['booking_id']?.toString();
      if (bookingId != null && bookingId.isNotEmpty) {
        context.pushNamed(Routes.upcomingShootDetails.name, extra: {'booking_id': bookingId});
      } else {
        context.pushNamed(Routes.shoots.name);
      }
      break;

    case 'messages':
      final roomId = data['chat_room_id']?.toString() ?? data['room_id']?.toString();
      if (roomId != null && roomId.isNotEmpty) {
        context.pushNamed(Routes.chatDetails.name, extra: {'chat_room_id': roomId});
      } else {
        context.pushNamed(Routes.messages.name);
      }
      break;

    case 'meetings':
      final meetingId = data['meeting_id']?.toString();
      context.pushNamed(Routes.meetings.name, extra: {'meeting_id': meetingId});
      break;

    case 'files':
      final bookingId = data['booking_id']?.toString();
      final filePath = data['filepath']?.toString();
      if (bookingId != null) {
        context.pushNamed(Routes.filesFolder.name, pathParameters: {'id': bookingId});
      } else {
        context.pushNamed(Routes.files.name);
      }
      break;

    default:
      context.pushNamed(Routes.notifications.name);
      break;
  }
}
```

---

## 5. Developer Implementation Checklist

- [x] **Header Stamping**: Verified `AppHeadersInterceptor` automatically stamps `device_type` header.
- [ ] **FCM Service Initialization**: Implement `PushNotificationService` in `lib/core/services/push_notification_service.dart`.
- [ ] **Login Hook**: Trigger `POST /push-notifications/tokens` inside `AuthNotifier` post-login.
- [ ] **Logout Hook**: Trigger `DELETE /push-notifications/tokens` inside `AuthNotifier` / `SessionStore.clearSession()`.
- [ ] **Preference Sync Hook**: Connect `NotificationSettingsNotifier` to call `PATCH /push-notifications/preferences`.
- [ ] **Tap Routing Unit Tests**: Add unit test for `handlePushTap` in `test/core/services/push_notification_service_test.dart`.

---

*Document prepared for team review and backend synchronization.*
