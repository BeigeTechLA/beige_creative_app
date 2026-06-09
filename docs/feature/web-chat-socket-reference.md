# Web Chat Socket Reference

> Simple technical knowledge base for the current web chat/messaging implementation.
> Prepared for implementation and handoff reference.

---

## Overview

| Area | Details |
|---|---|
| Implementation type | Web chat / messaging |
| Realtime protocol | Socket.IO (not raw WebSocket) |
| Message mutations | Handled mainly through REST APIs |
| Realtime updates | Received through Socket.IO room events |
| Heartbeat | Handled internally by Socket.IO |

---

## Packages

| Layer | Package | Version / Note |
|---|---|---|
| Frontend | `socket.io-client` | v4.8.3 |
| Backend | `socket.io` | v4.7.5 |
| Protocol | Socket.IO | Not raw WebSocket |

---

## Main Files

| Purpose | File Path |
|---|---|
| Web socket usage | `beige-web-mobile-front/components/chat/ExternalChatView.tsx` |
| Web REST chat helper | `beige-web-mobile-front/lib/externalChatApi.ts` |
| Backend socket service | `beige-tech-mobile-web-api-2/src/services/socket.service.js` |
| Backend external chat route | `beige-tech-mobile-web-api-2/src/routes/v1/externalChat.route.js` |
| Backend message model | `beige-tech-mobile-web-api-2/src/models/chatMessage.model.js` |

---

## Connection Configuration

The web app creates a Socket.IO connection when a valid `userId` is available.

```js
const socket = io(socketServerUrl, {
  transports: ["websocket", "polling"],
});
```

| Config Item | Value |
|---|---|
| Preferred socket URL | env variable `NEXT_PUBLIC_CHAT_SOCKET_URL` |
| Fallback URL | API base URL |
| Transports | `websocket`, `polling` |
| Heartbeat | Socket.IO internal heartbeat |

---

## Connection Flow

1. Create a Socket.IO connection.
2. On `connect`, emit `joinNotificationRoom` for the current user.
3. On `connect`, emit `joinRoom` for the selected chat room (if one is active).
4. Listen for realtime events and update local UI state.
5. On component cleanup, remove listeners and disconnect.

---

## Socket Events

| Event | Direction | Purpose |
|---|---|---|
| `joinNotificationRoom` | Web → Backend | Join user-specific notification room |
| `joinRoom` | Web → Backend | Join the selected chat room |
| `message` | Backend → Web | Deliver new message payload to a room |
| `updateChatRoom` | Backend → Web | Update room preview and timestamp |
| `messageEdited` | Backend → Web | Notify room that a message was edited |
| `messageDeleted` | Backend → Web | Notify room that a message was soft-deleted |
| `participantAdded` | Backend → Web | Trigger room refresh |
| `participantRemoved` | Backend → Web | Trigger room refresh |
| `chatRoomStatusChanged` | Backend → Web | Trigger room refresh |
| `notification:new` | Backend → Web (user room) | Update unread count when relevant |
| `socketError` | Backend → Web | General socket-level error |
| `userTyping` | Web ↔ Backend (broadcast) | Typing status support |
| `stopTyping` | Web ↔ Backend (broadcast) | Stop typing status support |

---

## Joining Rooms

### Notification Room

Emit `joinNotificationRoom` on connect.

```json
{
  "userId": "USER_ID",
  "userRole": "admin"
}
```

- Backend room format: `user_${userId}`
- Used for realtime `notification:new` events

### Chat Room

Emit `joinRoom` when a chat room is selected.

```json
{
  "roomId": "CHAT_ROOM_ID",
  "userId": "USER_ID",
  "userName": "User Name"
}
```

- Backend validates `userId`, `userName`, and `roomId`
- Backend confirms the chat room exists
- Backend calls `socket.join(roomId)` and emits `roomJoined` to the room

---

## Message Send Flow

Messages are sent via **REST**, not directly through socket.

```
POST external-chat/messages/:roomId
```

```json
{
  "message": "Hello team",
  "sender": {
    "id": "USER_ID",
    "name": "User Name",
    "email": "user@example.com",
    "role": "admin"
  },
  "replyTo": null
}
```

- REST helper: `externalChatApi.sendMessage(roomId, message, { sender, replyTo })`
- Backend saves to MongoDB
- Backend emits realtime `message` event to the socket room

---

## Realtime Message Event

After save, backend emits to the room:

```js
io.to(String(roomId)).emit("message", payload);
```

```json
{
  "roomId": "CHAT_ROOM_ID",
  "senderId": "USER_ID",
  "senderName": "User Name",
  "messageId": "MESSAGE_ID",
  "message": "Hello team",
  "fileUrl": null,
  "fileName": null,
  "fileType": null,
  "message_type": "text",
  "createdAt": "2026-06-04T10:00:00.000Z",
  "updatedAt": "2026-06-04T10:00:00.000Z",
  "replyTo": null,
  "success": true
}
```

**Frontend handling:**
- Active room → append message to the list
- Other room → increment local unread count
- Always update room last message preview

---

## Edit and Delete Message Flow

| Action | REST Endpoint | Realtime Event | Frontend Update |
|---|---|---|---|
| Edit message | `POST external-chat/messages/:messageId/edit` | `messageEdited` | Find by `messageId`, replace `message` with new content, mark `is_edited: true` |
| Delete message | `POST external-chat/messages/:messageId/delete` | `messageDeleted` | Find by `messageId`, set `is_deleted: true`, display *"This message was deleted"* |

---

## Other Event Details

| Topic | Details |
|---|---|
| `updateChatRoom` | Updates room list preview and timestamp — usually fires after a new message is saved |
| `participantAdded` / `participantRemoved` / `chatRoomStatusChanged` | All schedule a room refresh |
| `notification:new` | Increments unread count if the notification belongs to a room and was not sent by the current user |
| `socketError` | Carries general socket-level errors such as unauthorized access |
| `userTyping` / `stopTyping` | Supported by backend but not actively used in the current main web flow |

---

## Direct Socket Events Supported by Backend

The backend socket service also supports these direct socket events (currently underused by the web client):

- `message`
- `editMessage`
- `deleteMessage`
- `replyMessage`
- `receivedMessage`
- `userTyping`
- `stopTyping`

> Current web implementation uses **REST for mutations** and **Socket.IO for receiving updates**.

---

## Message Persistence

Messages are stored in MongoDB using the `ChatMessage` model.

```json
{
  "chat_room_id": "CHAT_ROOM_ID",
  "message": "Hello team",
  "sent_by": "USER_ID",
  "message_type": "text",
  "file_url": null,
  "file_name": null,
  "file_type": null,
  "reply_to": null,
  "is_edited": false,
  "is_deleted": false
}
```

**Supported `message_type` values:**

| Type |
|---|
| `text` |
| `image` |
| `file` |
| `system` |

---

## REST API Reference

| Method | Path |
|---|---|
| `GET` | `external-chat/rooms` |
| `GET` | `external-chat/room/:bookingId` |
| `POST` | `external-chat/room` |
| `GET` | `external-chat/messages/:roomId` |
| `POST` | `external-chat/messages/:roomId` |
| `POST` | `external-chat/messages/:messageId/edit` |
| `POST` | `external-chat/messages/:messageId/delete` |
| `PATCH` | `external-chat/room/:roomId/mark-read` |
| `GET` | `external-chat/participants/:roomId` |
| `POST` | `external-chat/room/:roomId/participants` |
| `DELETE` | `external-chat/room/:roomId/participants/:userId` |
| `GET` | `external-chat/directory` |

---

## TL;DR

- Chat is **web-based**, realtime layer is **Socket.IO**
- **Message mutations** (send, edit, delete) → REST
- **Realtime updates** (new messages, edits, deletes, room changes) → Socket.IO events
- Messages persist in **MongoDB**
