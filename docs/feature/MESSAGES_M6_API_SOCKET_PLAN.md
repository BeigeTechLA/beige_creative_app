# Messages Module — M6 API + Socket.IO Integration Plan

**Status:** Planning
**Owner:** Mobile (crew app)
**Scope:** Wire crew-side messaging UI to real REST API + socket.io transport. UI already shipped in M1–M5; this phase only swaps the repository implementation behind the existing `MessagesRepository` contract.
**Prerequisite reading:**
- `docs/feature/MESSAGES_UI_PLAN.md` (UI complete, contract locked)
- `docs/feature/external-chat-api-reference.md` (REST surface)
- `docs/feature/web-chat-socket-reference.md` (Socket.IO event reference)

---

## 0. Guiding Principles

1. **Contract is frozen.** `MessagesRepository` (lib/features/messages/domain/repositories/messages_repository.dart) stays as-is. UI does not change. M6 only fills source bodies and flips one flag.
2. **REST for mutations, Socket.IO for realtime updates.** Matches web reference. Send/edit/delete go through REST; backend re-emits via socket; local UI applies socket events to state.
3. **Single seam = `useDummyMessagesProvider`.** Default flips `true → false`. Dummy source stays compiled (used by widget tests + goldens).
4. **Socket lifecycle = app session.** Connect on login (after token available), disconnect on logout. Join chat-room scoped to thread screen via `ref.onDispose`. Join notification-room on connect.
5. **No widget/notifier ever imports `socket_io_client` or `dio`.** Always behind sources.

---

## 1. Task Ledger

| Task | Status | Output |
|---|---|---|
| M6.01 — Env + pubspec | ✅ (2026-06-15; corrected 2026-06-16) | `socket_io_client: ^2.0.3+1` added; `Env.socketUrl` field, dev corrected to `https://api2.dev.beige.app` after live probes showed `api.dev.beige.app/socket.io` returns 404 while `api2.dev.beige.app/socket.io` returns Engine.IO 200/101; prod = `https://api.prod.beige.app` (provisional TODO); `CHAT_SOCKET_URL` dart-define override supported; `flutter analyze` clean |
| M6.02 — Response DTOs | ✅ (2026-06-15) | `pagination_envelope.dart`, `participant_dto.dart`, `shared_file_dto.dart` new; `MessageDto.fromRestJson` + `fromSocketJson`, `ConversationDto.fromRestJson`, `ChatDetailsDto.fromRestJson` added (dummy `fromJson` retained). Analyze + messages tests green. |
| M6.03 — `MessagesRemoteSource` impl | ✅ (2026-06-15) | 9 methods (sendAudio/sendAttachment block on Q3); endpoints added to `ApiEndpoints`; `editMessage`/`deleteMessage` contract widened to take `conversationId`; `DioException` funnel via `ExceptionHandler.mapDioException`; `MessagesRemoteSource(DioClient, SessionStore)` ctor wired in provider; impl + dummy + test fake updated; analyze + tests green. |
| M6.04 — `MessagesSocketSource` impl | ✅ (2026-06-15) | Singleton owner; `io.io(Env.socketUrl, ...)` w/ websocket+polling, `setAuth({token,userId,userRole})` + `Authorization` header, auto-reconnect 2–15s backoff; binds 11 server events (`message`, `messageEdited`, `messageDeleted`, `updateChatRoom`, `participantAdded/Removed`, `chatRoomStatusChanged`, `notification:new`, `userTyping`, `stopTyping`, `socketError`) → sealed `ChatSocketEvent` via `_fan` (per-room + global); `emitTyping/StopTyping`; own-typing echo suppressed; `disconnect` closes all controllers; `ref.onDispose` hook in provider. |
| M6.05 — Repository wiring | ✅ (2026-06-15) | Provider wiring (dioClient + sessionStore) landed in M6.03/M6.04; this task widens `MessagesRepository` with `globalEvents`, `joinConversation`, `leaveConversation`, `notifyTyping`, `notifyStopTyping` and impl delegates to socket (dummy no-ops); test fake updated; analyze + tests green. |
| M6.06 — Lifecycle + auth | ✅ (2026-06-15) | `chatSocketLifecycleProvider` watches `authStateProvider` + `useDummyMessagesProvider` → fires `socket.connect()` only when authed AND on real backend, else `disconnect()`. Mounted in `App.build` via `ref.watch` so it stays alive for session. Analyze + messages tests green; 2 unrelated `shoots_repository_impl_test.dart` failures pre-existing. |
| M6.07 — Notifier adjustments | ✅ (2026-06-15) | Thread notifier: `joinConversation` on hydrate, `leaveConversation` on dispose, `MessageReceived` dedupes by id (bumps status), `MessageEdited`/`MessageDeleted` already wired in M3. List notifier: subscribes to `repo.globalEvents()`, throttled (500ms) refresh on `MessageReceived` / `MessageEdited` / `MessageDeleted` / `RoomPreviewUpdated` / `ParticipantsChanged` / `RoomStatusChanged` / `NotificationReceived`. Analyze + tests green. |
| M6.08 — Typing + presence | ✅ (2026-06-15) | `ChatComposer` typing state machine (`kComposerTypingIdle = 3s`): fires `onTypingPulse` once per session, `onTypingStop` on idle/clear/submit/dispose. Notifier wraps `repo.notifyTyping/notifyStopTyping` → screen wires `notifier.notifyTyping`/`notifier.notifyStopTyping` to composer callbacks. `ChatAppBar.isTyping` already consumes `state.peerTyping` (M3) — no change needed. **Presence**: backend has no documented event (plan §11 Q5 still open); skipped. |
| M6.09 — Mark-read trigger | ✅ (2026-06-15) | `ChatThreadNotifier.markRead()` fires after hydrate (when messages exist), after each genuine inbound `MessageReceived` (own-echo dedupe branch skipped), and on `AppLifecycleState.resumed` (screen observes via `WidgetsBindingObserver`). Errors swallowed (best-effort). Backend `mark-read` ignores `upTo` today — value forwarded for future. |
| Tabs removed | ✅ (2026-06-15) | All / Shoots / Admin tab bar deleted. `messages_tab_bar.dart` removed, `ConversationTab` enum + `Conversation.tab` field + `_parseTab` + `_tabFromRoomType` stripped. `listConversations({String? query})` no longer takes `tab`. List notifier no longer tracks `tab`/`selectTab`. Tests updated; analyze + tests green. |
| M6.10 — Error + reconnect UX | ✅ (2026-06-15) | Socket source: `_emitSocketError()` coalesces `SocketErrored` to ≤1 per 30s during reconnect storms; gate reopens on next successful `onConnect`. Thread notifier consumes `SocketErrored` → `errorMessage = "Connection lost. Reconnecting…"` → existing M3 snackbar wire surfaces banner. Auto-reconnect retains 2–15s backoff from M6.04. **Room rejoin patch**: `_activeRoomIds` set tracks current joins; `onConnect` replays `joinRoom` for every id (socket.io v4 does not auto-rejoin rooms). Offline send-queue / tap-to-retry deferred (out of M6 scope per §8). |
| M6.11 — Flag flip + dummy retention | ✅ (2026-06-15) | `useDummyMessagesProvider` default flipped `true → false`. Production traffic now hits real REST + socket.io via `chatSocketLifecycleProvider` (post-login). Dummy source + fixtures retained — widget tests override `messagesRepositoryProvider` wholesale (not the dummy flag), so they remain untouched. Analyze + messages tests + goldens green; 2 pre-existing unrelated `shoots_repository_impl_test.dart` failures persist. |
| M6.12 — Integration tests | ✅ (2026-06-15) | 23 new tests across 3 files. **Remote source** (12): `listConversations` payload mapping + `search` param + `ServerException` on 500; `fetchThread` reverses to chronological asc; `sendText` body `{message,replyTo}`; `editMessage` body `{content,roomId}` (key divergence); `deleteMessage` body `{roomId}`; `markRead` PATCH no body; `fetchDetails` map; `UnauthorizedException` on missing session; `sendAudio`/`sendAttachment` UnimplementedError. **Thread notifier** (7): `MessageEdited`/`MessageDeleted` patch state; `MessageReceived` dedupe vs append; markRead skip on own echo; typing flips; `SocketErrored` banner; cross-room filter. **List notifier** (4): initial fetch; `RoomPreviewUpdated` throttled refetch; burst coalescing; non-list events ignored. Socket source omitted (no easy `io.Socket` test double; covered by smoke). Analyze clean. |
| M6.13 — Analyze + smoke | ✅ (2026-06-15; socket host corrected 2026-06-16) | Static: `flutter analyze` clean; full `flutter test` = 512 pass / 2 fail (both pre-existing in `shoots_repository_impl_test.dart`, unrelated to M6 — `crew_accept` vs `status` body-key drift). Manual smoke runbook documented in §12 below; dev backend socket host now verified as `wss://api2.dev.beige.app/socket.io/?EIO=4&transport=websocket`. |

---

## 2. Env + Dependencies

### 2.1 `pubspec.yaml`
Add:
```yaml
socket_io_client: ^2.0.3+1
```
No new dev deps. `dio` + `flutter_secure_storage` already present.

### 2.2 Env keys
Existing `Env` (`lib/config/env.dart`) hardcodes URLs per `Environment` in `init()` switch — does **not** read from `env/*.json` (those carry only `GOOGLE_MAPS_KEY` via `--dart-define-from-file`). Match that pattern.

Added to `lib/config/env.dart`:
- `static late String socketUrl;`
- `Environment.dev`  → `https://api2.dev.beige.app` *(verified live 2026-06-16; sibling `biegeapp` uses same host)*
- `Environment.prod` → `https://api.prod.beige.app` *(TODO — provisional, mirrors dev pattern; backend to confirm)*
- `CHAT_SOCKET_URL` dart-define can override either value for backend smoke tests.

#### Confirmed dev backend socket URL

Full handshake URL provided by backend:

```
wss://api2.dev.beige.app/socket.io/?EIO=4&transport=websocket
```

- Scheme `wss://` → encrypted WebSocket transport
- Path `/socket.io/` → Engine.IO mount point (default for `socket_io_client`)
- Query `EIO=4` → Engine.IO protocol v4 (matches backend `socket.io` v4.7.5)
- Query `transport=websocket` → skips polling upgrade

`socket_io_client` accepts the bare host (`https://api2.dev.beige.app`); mobile sets `.setPath('/socket.io')` and `.setTransports(['websocket'])`, so do not put the `/socket.io/?EIO=4…` suffix in `socketUrl`.

2026-06-16 probe results:
- `https://api.dev.beige.app/socket.io/?EIO=4&transport=websocket` → HTTP 404 `Route not found`.
- `https://api2.dev.beige.app/socket.io/?EIO=4&transport=polling` → Engine.IO 200 open packet.
- `https://api2.dev.beige.app/socket.io/?EIO=4&transport=websocket` with upgrade headers → HTTP 101 Switching Protocols.

Q7 resolved → strike from §11 open questions.

### 2.3 Dummy fixtures
Keep `assets/dummy/messages/*.json` + pubspec asset entry. Tests still use them. Do **not** delete the entry in M6.

---

## 3. Response Shapes (assumptions + verification gates)

Source REST doc explicitly flags response bodies as undocumented (`external-chat-api-reference.md` § Known Gaps #1). Treat shapes below as **proposed** — verify with backend before coding sources. Add a confirmation pass before M6.03.

### 3.1 Conversation / Room

```json
{
  "_id": "6a01d803559441ddaa24bd48",
  "room_name": "Direct_Gandhi",
  "room_type": "direct",
  "avatar_url": null,
  "is_online": true,
  "linked_booking_id": null,
  "participants": ["uid_1", "uid_2"],
  "unread_count": 3,
  "last_message": {
    "message": "see you there",
    "sent_at": "2026-06-14T10:00:00.000Z",
    "sent_by": "uid_1"
  },
  "updated_at": "2026-06-14T10:00:00.000Z"
}
```

**Mapping → `Conversation`:**
- `_id` → `id`
- `room_name` → `title`
- `room_type` → drives `tab`: `direct → all`, `project|booking → shoots`, `admin|broadcast → admin`. **Backend must confirm tab taxonomy.**
- `last_message.sent_by == currentUserId` → `lastMessage.fromMe`
- `unread_count` → `unreadCount`

### 3.2 Message (REST list + socket payload)

REST list (`GET /external-chat/messages/:roomId`):
```json
{
  "_id": "msg_1",
  "chat_room_id": "6a01d803559441ddaa24bd48",
  "sent_by": "uid_1",
  "sender_name": "Ronak",
  "message": "Hello team",
  "message_type": "text",
  "file_url": null,
  "file_name": null,
  "file_type": null,
  "reply_to": null,
  "is_edited": false,
  "is_deleted": false,
  "createdAt": "2026-06-14T10:00:00.000Z",
  "read_by": ["uid_1", "uid_2"]
}
```

Socket payload (per web reference §"Realtime Message Event"):
```json
{
  "roomId": "...", "senderId": "...", "senderName": "...",
  "messageId": "...", "message": "...",
  "fileUrl": null, "fileName": null, "fileType": null,
  "message_type": "text",
  "createdAt": "...", "updatedAt": "...",
  "replyTo": null, "success": true
}
```

**Field name divergence is real** — REST uses `snake_case`, socket uses `camelCase`. DTO layer must normalize. Build two mappers: `MessageDto.fromRestJson` and `MessageDto.fromSocketJson`. Keep existing `MessageDto.fromJson` for dummy fixtures (rename to `fromDummyJson` if needed, or keep as the canonical dummy shape).

**`message_type` mapping to existing enum:**
- `text` → `MessageType.text`
- `image` → `MessageType.image`
- `file` (with `file_type` startsWith `audio/`) → `MessageType.file` + `MessageFile.durationMs` populated (audio bubble decides on `mimeType`)
- `file` (other) → `MessageType.file`
- `system` → `MessageType.system`

`DeliveryStatus` is not in REST/socket payloads. Derive client-side:
- Optimistic local → `sending`
- Socket `message` echo (own message) → `sent` → `delivered`
- `notification:new` from other participant for this room → bump to `read` when their `readReceipt`-equivalent arrives.

> **Open question:** backend does not appear to emit explicit `messageRead` events per web reference. Confirm with backend whether `notification:new` or a dedicated event signals read receipts. If not available, keep status at `delivered` and document.

### 3.3 Room Details (`GET /external-chat/room/:roomId/details`)

Assumed shape — confirm:
```json
{
  "_id": "...",
  "room_name": "...",
  "avatar_url": null,
  "contact_email": "...",
  "contact_phone": "...",
  "participants": [ { "id": "...", "name": "...", "role": "cp", "profile_image": "..." } ],
  "linked_shoot": { "id": "...", "title": "..." },
  "shared_files": [ { "id": "...", "name": "...", "url": "...", "size_bytes": 1024, "uploaded_at": "...", "mime_type": "image/png" } ],
  "notes": "..."
}
```

Build `ParticipantDto`, `SharedFileDto`, `ChatDetailsDto.fromJson` accordingly.

### 3.4 Pagination

REST accepts `page`, `limit`, `sortBy`. Response envelope unknown. Two viable strategies:
- **Wrapped:** `{ data: [...], page, limit, total, hasMore }`
- **Bare list + headers**

Wait for backend; default DTO loader handles both via `_unwrap(json)` helper that tolerates `{data: [...]}` or `[...]`. Use `hasMore` (or `data.length == limit`) as cursor signal. Map to existing `ChatThread.hasMore` if present (verify).

---

## 4. `MessagesRemoteSource` Implementation

Replace `UnimplementedError` stubs. Inject `DioClient` via constructor.

### 4.1 Wiring
```dart
class MessagesRemoteSource {
  MessagesRemoteSource(this._client);
  final DioClient _client;
  Dio get _dio => _client.dio;
}
```

Provider update (M6.05):
```dart
final _remoteMessagesSourceProvider = Provider<MessagesRemoteSource>(
  (ref) => MessagesRemoteSource(ref.watch(dioClientProvider)),
);
```

### 4.2 Method-by-method

| Contract method | HTTP call | Notes |
|---|---|---|
| `listConversations({tab, query})` | `GET /external-chat/rooms?page=1&limit=50&search={query}` | `tab` is client-side filter (no `tab` query in API). Apply existing `_filter()` on `ConversationDto.fromRestJson` results. |
| `fetchThread(id, {cursor})` | `GET /external-chat/messages/{id}?page={cursor or 1}&limit=30&sortBy=-createdAt` | Convert to chronological asc before returning. `cursor` is page number stringified. |
| `sendText(id, body, {replyToId})` | `POST /external-chat/messages/{id}` body `{message, replyTo}` | Backend re-emits via socket. Return mapped Message; UI dedupes by `id` on socket echo. |
| `sendAudio(id, path, dur)` | `POST /external-chat/messages/{id}` multipart **TBD** | Source doc has no upload endpoint. **Flag to backend.** Stub with `UnimplementedError('audio upload not yet supported by backend')` until clarified. |
| `sendAttachment(id, ...)` | Same upload uncertainty. **Flag.** Stub for now. |
| `editMessage(id, body)` | `POST /external-chat/messages/{id}/edit` body `{content, roomId}` | Note key is `content`, not `message`. `roomId` required in body — notifier must pass it. **Repository signature needs `roomId` or remote must look it up.** See §6. |
| `deleteMessage(id)` | `POST /external-chat/messages/{id}/delete` body `{roomId}` | Same roomId requirement. |
| `markRead(id, upTo)` | `PATCH /external-chat/room/{id}/mark-read` (no body) | API spec has no `upTo` field. Either ignore `upTo` or pass via body if backend confirms. |
| `fetchDetails(id)` | `GET /external-chat/room/{id}/details` | Map via `ChatDetailsDto.fromRestJson`. |

### 4.3 Error handling
Wrap each call:
```dart
try { ... }
on DioException catch (e) { throw MessagesNetworkException(_extractMessage(e)); }
```
Define `MessagesNetworkException` in `domain/exceptions/`. Notifier catches and surfaces via existing snackbar pattern.

---

## 5. `MessagesSocketSource` Implementation

Owns single socket connection. Multiplexes events into per-room `StreamController` subscriptions.

### 5.0 Singleton Lifecycle

`MessagesSocketSource` is a **process-wide singleton**. One instance, one `io.Socket`, one notification-room join — for the entire authenticated app session.

**Why singleton (not per-screen, not per-room):**
- Socket.IO connection is expensive: TCP + upgrade handshake + auth + `joinNotificationRoom`. Re-doing this on every thread screen mount kills UX.
- Notification room (`user_${userId}`) must stay joined while the app is foregrounded, even when no thread screen is open — drives unread counts on `MessagesScreen` list.
- Multiple thread screens (back stack, deep links) cannot each own a connection — backend would see N sockets per user, ack storms, duplicate `message` echoes.
- Mirrors web reference (`ExternalChatView.tsx` holds one `socket = io(...)` for the page session).

**Singleton enforcement layers:**

| Layer | Mechanism | Guarantee |
|---|---|---|
| Riverpod | `Provider<MessagesSocketSource>` (plain, **not** `autoDispose`) | Single instance per `ProviderContainer`. `ProviderContainer` itself is one-per-app via root `ProviderScope` in `App`. |
| Constructor | No `factory`, no static cache — Riverpod is the single owner | Cannot accidentally `MessagesSocketSource()` elsewhere; provider is the only construction site. |
| Internal field | `io.Socket? _socket;` (nullable, lazy) | First `connect()` builds it; subsequent calls early-return on `_socket?.connected == true`. |
| Connect guard | `if (_socket?.connected == true) return;` at top of `connect()` | Re-entrant safe. Multiple lifecycle triggers (auth flip, hot reload, foreground) collapse to one socket. |

**Lifecycle anchors:**

```
App boot
  ↓ startApp() → ProviderScope mounts
  ↓ App.build() reads chatSocketLifecycleProvider (keeps it alive)
User logs in
  ↓ sessionStateProvider.isAuthenticated = true
  ↓ chatSocketLifecycleProvider → socket.connect()
     ↓ builds _socket, emits joinNotificationRoom
[N thread screens open/close — each calls socket.joinRoom / leaveRoom only]
User logs out
  ↓ sessionStateProvider.isAuthenticated = false
  ↓ chatSocketLifecycleProvider → socket.disconnect()
     ↓ closes all per-room StreamControllers, nulls _socket
App backgrounded / killed
  ↓ ProviderContainer torn down → socket.disconnect() via dispose hook (defensive)
```

**Explicit non-singletons (intentional):**
- Per-room `StreamController<ChatSocketEvent>` instances in `_controllers` map — created lazily on first `events(roomId)` call, closed in `leaveRoom`. These are **per-room**, not per-screen; if two providers ever subscribe to the same room (shouldn't happen but defensive), `.broadcast()` allows it.

**Forbidden patterns** (call out in code review):
- `MessagesSocketSource()` direct construction outside provider.
- `autoDispose` on `_socketMessagesSourceProvider` — would tear down socket whenever no listener exists, defeating notification-room persistence.
- Holding a local `io.Socket` reference inside a notifier or widget — must go through source.

**Hot reload note:** Dart VM hot reload preserves provider container, so `_socket` survives. Hot restart rebuilds container — `connect()` runs again, old `_socket` is GC'd unreferenced (add `disconnect()` in a `ref.onDispose` on the provider for clean teardown).

### 5.1 Connection
```dart
class MessagesSocketSource {
  MessagesSocketSource({required SessionStore session}) : _session = session;
  final SessionStore _session;
  io.Socket? _socket;
  final _controllers = <String, StreamController<ChatSocketEvent>>{};
  final _globalCtrl = StreamController<ChatSocketEvent>.broadcast();
}
```

Connect logic:
```dart
Future<void> connect() async {
  if (_socket?.connected == true) return;
  final user = await _session.readUser();
  final token = await _session.readToken();
  _socket = io.io(
    Env.socketUrl.isEmpty ? Env.apiUrl : Env.socketUrl,
    io.OptionBuilder()
      .setTransports(['websocket', 'polling'])
      .setExtraHeaders({'Authorization': token ?? ''})
      .enableAutoConnect()
      .enableReconnection()
      .build(),
  );
  _socket!.onConnect((_) {
    _socket!.emit('joinNotificationRoom', {
      'userId': user.id,
      'userRole': user.role,
    });
  });
  _bindEvents();
}
```

### 5.2 Room join/leave
```dart
Future<void> joinRoom(String roomId) async {
  final user = await _session.readUser();
  _socket?.emit('joinRoom', {
    'roomId': roomId,
    'userId': user.id,
    'userName': user.name,
  });
}
Future<void> leaveRoom(String roomId) async {
  _socket?.emit('leaveRoom', {'roomId': roomId}); // verify backend handler
  _controllers.remove(roomId)?.close();
}
```

### 5.3 Event binding → sealed `ChatSocketEvent`

| Socket event | Payload key inputs | Emit |
|---|---|---|
| `message` | `roomId`, `messageId`, `message`, `senderId`, `senderName`, `message_type`, `createdAt`, `fileUrl/Name/Type`, `replyTo` | `MessageReceived(roomId, Message.fromSocket(...))` |
| `messageEdited` | `messageId`, `roomId`, `message`/`content` | `MessageEdited(roomId, messageId, newBody)` |
| `messageDeleted` | `messageId`, `roomId` | `MessageDeleted(roomId, messageId)` |
| `updateChatRoom` | `roomId` | `RoomPreviewUpdated(roomId)` |
| `participantAdded` / `participantRemoved` | `roomId` | `ParticipantsChanged(roomId)` |
| `chatRoomStatusChanged` | `roomId`, `status` | `RoomStatusChanged(roomId, status)` |
| `notification:new` | `roomId?`, `body` | `NotificationReceived(body, conversationId: roomId)` |
| `userTyping` | `roomId`, `userId`, `userName` | `TypingStarted(roomId, userId, userName)` |
| `stopTyping` | `roomId`, `userId` | `TypingStopped(roomId, userId)` |
| `socketError` | `message` | `SocketErrored(message)` (broadcast to all room controllers + global) |

`PresenceChanged` + `ReadReceiptUpdated` — **no matching backend event in reference**. Emit synthetically when:
- `PresenceChanged`: skip in M6 (not supported by backend); flag to backend.
- `ReadReceiptUpdated`: skip until backend clarifies; status display stops at `delivered`.

### 5.4 Multi-room stream routing
`events(roomId)` returns:
```dart
Stream<ChatSocketEvent> events(String roomId) {
  return (_controllers[roomId] ??= StreamController<ChatSocketEvent>.broadcast()).stream;
}
```
On each socket event, route by `roomId` to that controller + global controller for room-list invalidation.

### 5.5 Lifecycle
`disconnect()` clears `_socket`, closes all controllers. Called from `chatSocketLifecycleProvider` on logout.

---

## 6. Repository Contract Adjustments

The current `MessagesRepository.editMessage(String messageId, String newBody)` and `deleteMessage(String messageId)` do **not** carry `roomId`, but the REST contract requires it in the body.

**Options:**
1. **Widen signatures** (cleanest):
   ```dart
   Future<void> editMessage(String conversationId, String messageId, String newBody);
   Future<void> deleteMessage(String conversationId, String messageId);
   ```
   Update notifier call sites (`chat_thread_providers.dart`) — they already have `conversationId` in scope.
2. **Lookup roomId in repository** via local cache — adds state to source, hides the requirement.

**Decision:** Option 1. Update contract + notifier + dummy source. Single sweep, no hidden state.

Same applies if upload endpoints (M6.02) need additional metadata — revisit signatures during backend handshake.

---

## 7. Notifier + Lifecycle Wiring

### 7.1 `chatSocketLifecycleProvider`
New provider, app-scoped (not auto-dispose). Watches auth state:
```dart
final chatSocketLifecycleProvider = Provider<void>((ref) {
  final session = ref.watch(sessionStateProvider);
  final socket = ref.watch(_socketMessagesSourceProvider);
  if (session.isAuthenticated) {
    socket.connect();
  } else {
    socket.disconnect();
  }
});
```
Read once in `App.build` to keep alive.

### 7.2 `chatThreadProvider` (existing)
- On build: call `socket.joinRoom(conversationId)` + subscribe to `repo.events(id)`.
- On `ref.onDispose`: `socket.leaveRoom(conversationId)` + cancel subscription.
- Extend switch on sealed events:
  - `MessageEdited` → patch message body in state, set `isEdited: true`.
  - `MessageDeleted` → patch `isDeleted: true`, clear `body`.
  - `RoomPreviewUpdated` → no-op here (list notifier handles).
  - `ReadReceiptUpdated` (if/when added) → bump matching message statuses.

### 7.3 `conversationListProvider` (existing)
- Subscribe to a global event channel (`socket.globalEvents` or filter `RoomPreviewUpdated`/`NotificationReceived`).
- On `RoomPreviewUpdated`/`MessageReceived` for any room: refetch list (or patch the matching tile + bump unread).
- Throttle refetches (250–500ms) to avoid storms on bursty backends.

### 7.4 Typing
`ChatComposer` already owns text controller. On text change with debounce 1500ms:
- non-empty + not previously typing → `socket.emitTyping(roomId)`
- empty or 3s idle → `socket.emitStopTyping(roomId)`

Add to `MessagesSocketSource`:
```dart
void emitTyping(String roomId)    => _socket?.emit('userTyping', {'roomId': roomId, ...userPayload});
void emitStopTyping(String roomId) => _socket?.emit('stopTyping', {'roomId': roomId, ...userPayload});
```

Expose via repository:
```dart
void typing(String roomId);
void stopTyping(String roomId);
```

Subtitle in `ChatAppBar`: thread notifier exposes `Set<String> typingUserIds` derived from `TypingStarted`/`TypingStopped`. Render "typing…" when non-empty.

### 7.5 Mark-read
In `ChatThreadScreen`:
- On `didChangeAppLifecycleState` resume + on first frame with messages: `repo.markRead(roomId, lastIncomingMsgId)`.
- On new `MessageReceived` while screen is focused (`ModalRoute.of(context)?.isCurrent == true`): immediately mark read.

---

## 8. Error + Reconnect UX

- `socket_io_client` handles reconnection (`enableReconnection: true`). Wire `onReconnect`, `onReconnectAttempt`, `onError` to emit `SocketErrored` once per attempt cycle (don't spam).
- Thread screen `ref.listen<ChatThreadState>(...)` catches `error` field → snackbar (already wired in M3).
- **Offline send queue** (best-effort, not blocking M6 ship):
  - On `sendText` failure (DioException network), keep optimistic message with `DeliveryStatus.failed`.
  - Tap-to-retry tile (out of M6 scope; track as M6.10b followup).

---

## 9. Flag Flip + Dummy Retention

- `useDummyMessagesProvider` default → `false`.
- Override to `true` in:
  - `test/...messages_screen_test.dart` (already overrides)
  - `test/golden/messages_test.dart` (component-only, no provider needed)
  - Any future widget tests.
- Dummy source + fixtures remain bundled. No prod-only build flag — code splitting adds friction with negligible bundle saving.

---

## 10. Test Plan (M6.12)

| Layer | What | Tooling |
|---|---|---|
| Remote source | Each REST method maps payloads correctly, throws `MessagesNetworkException` on Dio errors | `http_mock_adapter` |
| Socket source | Event bind dispatches correct `ChatSocketEvent` subtype with right roomId, multi-room routing | Fake `io.Socket` via test double / `FakeSocket` |
| Thread notifier | Edit/delete socket events patch state; typing events drive `typingUserIds` | Provider container + manual event injection |
| List notifier | `RoomPreviewUpdated` triggers debounced refetch | Same |
| Lifecycle | Connect on auth, disconnect on logout, room join/leave on screen mount/dispose | Provider container + fake sources |
| Smoke | Real dev backend: send/receive/edit/delete/typing roundtrip on two devices | Manual |

---

## 11. Open Questions for Backend (resolve before M6.03)

1. **Response envelope shape** for each endpoint (REST source doc lists this as unknown).
2. **`sortBy` allowed values** + pagination response fields.
3. **File upload endpoint** for audio + attachments — not in source doc.
4. **Read-receipt event** — does backend emit anything, or is "delivered" the terminal status?
5. **Presence events** — does backend emit user-online/offline, or is `is_online` only on room payload?
6. **Tab taxonomy** — how does `room_type` map to `all|shoots|admin`?
7. ~~**Socket URL** — same origin as REST, or dedicated?~~ **RESOLVED 2026-06-15, corrected 2026-06-16** — dedicated host: dev = `wss://api2.dev.beige.app/socket.io/?EIO=4&transport=websocket`. Prod still TBD.
8. **Auth handshake on socket** — `Authorization` header sufficient, or also `auth: { token }` in `io()` options?
9. **DELETE-with-body** for participant removal — confirm Dio passes body (flagged in REST ref §11).
10. **`leaveRoom` socket event** — does backend handle it, or does disconnect suffice?
11. **Edit body key** — `content` vs `message` (flagged in REST ref §14). Confirm.

---

## 12. Out of Scope (M6)

- Push notifications (FCM/APNs).
- Group room creation flow (POST `/external-chat/room`).
- Reactions UI (REST endpoint exists; no UI in M1–M5).
- Reply-to UI surface (repo accepts `replyToId`; composer has no quote affordance yet).
- Add/remove participant admin UI.
- Search-in-conversation server-side wiring (stays local-only filter).
- Failed-send retry tap UX (track separately).
- Encryption / E2EE.

---

## 13. Sequence: Send Message (end-to-end)

```
User taps send
  ↓ ChatComposer → ChatThreadNotifier.send(text)
  ↓ optimistic append (status: sending)
  ↓ repo.sendText(roomId, text)
     ↓ MessagesRemoteSource.sendText → POST /external-chat/messages/:roomId
     ↓ 200 → returns Message
  ↓ notifier patches optimistic with real id, status: sent
Backend persists + emits socket "message" to room
  ↓ MessagesSocketSource decodes → MessageReceived(roomId, msg)
  ↓ ChatThreadNotifier.onEvent: dedupe by id (already present from sendText return)
     → skip append, bump status: delivered
ConversationListNotifier sees RoomPreviewUpdated → debounced refetch
```

## 14. Sequence: Receive Message (other user sends)

```
Backend emits "message" to room
  ↓ MessagesSocketSource → MessageReceived(roomId, msg)
  ↓ ChatThreadNotifier.onEvent: append to state
  ↓ if screen focused: repo.markRead(roomId, msg.id)
ConversationListNotifier:
  ↓ if roomId != active room: bump unreadCount + update preview
  ↓ else: update preview only
```

---

## 15. Manual Smoke Runbook (M6.13)

Run on a real device against dev backend.

```bash
flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart
```

Watch console for `[MessagesSocketSource]` debug lines (printed on disconnect).

| # | Action | Expected | What it verifies |
|---|---|---|---|
| 1 | Cold start, log in | Console: socket opens against `api2.dev.beige.app`; `joinNotificationRoom` emit visible in backend logs | `chatSocketLifecycleProvider`, auth handshake |
| 2 | Open Messages tab | List renders from `/external-chat/rooms` REST; no tab bar visible | `listConversations`, tab removal |
| 3 | Tap a conversation | Thread loads from `/external-chat/messages/:roomId`; rendered chronological asc | `fetchThread`, reverse mapping |
| 4 | Type "hello" in composer (don't send) | Other party sees "typing…" within ~1s | `userTyping` emit, typing state machine |
| 5 | Wait 3s without sending | Other party "typing…" clears | `kComposerTypingIdle = 3s` |
| 6 | Send "hello" | Optimistic bubble (clock icon) → swaps to delivered (✓✓) when socket echo lands; only ONE bubble (dedupe works) | `sendText` REST + socket echo dedupe |
| 7 | Have other party send a message | Bubble appears at bottom; auto-scrolled; markRead PATCH fires | `MessageReceived` append + `markRead` |
| 8 | Background app + foreground | markRead fires again | `didChangeAppLifecycleState(resumed)` |
| 9 | Toggle airplane mode for 10s, then off | Snackbar "Connection lost. Reconnecting…" appears once (NOT repeatedly); socket reconnects; previously-joined room continues to receive events | Error throttle + rejoin replay |
| 10 | Log out from drawer | Console: socket disconnects; subsequent backend events stop reaching this client | `chatSocketLifecycleProvider` disconnect |

### Known live limitations
- **Audio note send**: throws — backend has no upload endpoint (plan §11 Q3).
- **File attach send**: same — Q3.
- **Read receipts on sender side**: status stays at `delivered`; never advances to `read` (Q4).
- **Peer presence (online dot in AppBar)**: shows initial `is_online` from REST list; doesn't update live (Q5).
- **Prod socket URL**: placeholder `https://api.prod.beige.app` — verify with backend before prod build.

### Bug-report template (if smoke uncovers issues)

```
Step #: ___
Expected: ___
Actual: ___
Console log snippet: ___
Network tab / backend log: ___
```
