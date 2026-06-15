# External Chat — Message API Reference

> **Scope of this document.** This is a faithful transcription of the supplied API
> specification. It documents the REST surface only. Response bodies, error
> formats, pagination metadata, and any real-time (Socket.IO/WebSocket) transport
> are **not** part of the source document and are **not** invented here. See
> [Known Gaps](#known-gaps) before treating this as a complete implementation guide.

---

## Overview

| Item | Details |
| --- | --- |
| Base Path | `/external-chat` |
| Authentication | Required for **all** endpoints |
| Authorization Header | `Authorization: <token>` |
| Content-Type | `application/json` |
| Sender identity | Sender/user details are taken automatically from the logged-in token. Sender info in request bodies is optional. |

### Common Headers

| Header | Value |
| --- | --- |
| `Content-Type` | `application/json` |
| `Authorization` | `<TOKEN>` |

---

## Endpoint Summary

| # | Name | Method | Path |
| --- | --- | --- | --- |
| 1 | Get Rooms | GET | `/external-chat/rooms` |
| 2 | Get Messages | GET | `/external-chat/messages/:roomId` |
| 3 | Get Participants | GET | `/external-chat/participants/:roomId` |
| 4 | Mark Room Read | PATCH | `/external-chat/room/:roomId/mark-read` |
| 5 | Send Message | POST | `/external-chat/messages/:roomId` |
| 6 | Reply Message | POST | `/external-chat/messages/:roomId` |
| 7 | React To Message | POST | `/external-chat/messages/:messageId/reaction` |
| 8 | Create Room (Admin) | POST | `/external-chat/room` |
| 9 | Get Room Details | GET | `/external-chat/room/:roomId/details` |
| 10 | Add Participants (Admin) | POST | `/external-chat/room/:roomId/participants` |
| 11 | Remove Participant (Admin) | DELETE | `/external-chat/room/:roomId/participants/:userId` |
| 12 | Get Directory | GET | `/external-chat/directory` |
| 13 | Get Room By Booking | GET | `/external-chat/room/:bookingId` |
| 14 | Edit Message | POST | `/external-chat/messages/:messageId/edit` |
| 15 | Delete Message | POST | `/external-chat/messages/:messageId/delete` |

> **Routing note (flagged, not in source):** Endpoints 5/6 and endpoint 13 both
> resolve under `/external-chat/room...` / `/external-chat/messages/:roomId`
> patterns. #13 (`/room/:bookingId`) and #9 (`/room/:roomId/details`) share the
> `/room/:id` prefix — confirm with backend that `:bookingId` and `:roomId` are
> disambiguated by route, not collided.

---

## Endpoints

### 1. Get Rooms

Gets the chat room list for the logged-in user.

- **Method:** `GET`
- **Path:** `/external-chat/rooms`
- **Query params:** `page`, `limit`, `sortBy`, `search` *(search optional)*
- **Body:** none

---

### 2. Get Messages

Gets the message list of the selected chat room.

- **Method:** `GET`
- **Path:** `/external-chat/messages/:roomId`
- **Path param:** `roomId`
- **Query params:** `page`, `limit`, `sortBy`
- **Body:** none

---

### 3. Get Participants

Gets participants/members of the selected chat room.

- **Method:** `GET`
- **Path:** `/external-chat/participants/:roomId`
- **Path param:** `roomId`
- **Body:** none

---

### 4. Mark Room Read

Marks the selected room as read for the logged-in user.

- **Method:** `PATCH`
- **Path:** `/external-chat/room/:roomId/mark-read`
- **Path param:** `roomId`
- **Body:** none

---

### 5. Send Message

Sends a new message in the selected room.

- **Method:** `POST`
- **Path:** `/external-chat/messages/:roomId`
- **Path param:** `roomId`
- **Body fields:** `message`, `replyTo`

```json
{
  "message": "hello",
  "replyTo": null
}
```

---

### 6. Reply Message

Same endpoint as Send Message. To reply, pass the target message ID in `replyTo`.

- **Method:** `POST`
- **Path:** `/external-chat/messages/:roomId`
- **Path param:** `roomId`
- **Body fields:** `message`, `replyTo`

```json
{
  "message": "hello",
  "replyTo": "6a2297aa6c97de3766f0a3d8"
}
```

---

### 7. React To Message

Adds or updates an emoji reaction on a message.

- **Method:** `POST`
- **Path:** `/external-chat/messages/:messageId/reaction`
- **Path param:** `messageId`
- **Body fields:** `emoji`, `roomId`

```json
{
  "emoji": "👍",
  "roomId": "6a01d803559441ddaa24bd48"
}
```

> **Flagged:** `messageId` is in the path **and** `roomId` is required in the body.
> Both are needed for this call.

---

### 8. Create Room (Admin only)

Creates a direct or project chat room.

- **Method:** `POST`
- **Path:** `/external-chat/room`
- **Body fields:** `roomType`, `client`, `participants`, `roomName`
  *(optional: `bookingId`, `orderId`, `externalId`, `selectedCpIds`, `externalRef`)*

**Direct room example (from source):**

```json
{
  "roomType": "direct",
  "client": {
    "id": "1",
    "name": "Gandhi Ronak",
    "email": "ronak84745@gmail.com",
    "role": "client"
  },
  "participants": [],
  "roomName": "Direct_Gandhi"
}
```

---

### 9. Get Room Details

Gets room details, participants, and linked metadata.

- **Method:** `GET`
- **Path:** `/external-chat/room/:roomId/details`
- **Path param:** `roomId`
- **Body:** none

---

### 10. Add Participants (Admin)

Adds one or more participants to a room.

- **Method:** `POST`
- **Path:** `/external-chat/room/:roomId/participants`
- **Path param:** `roomId`
- **Body fields:** `participants` *(optional: `role`)*

```json
{
  "participants": [
    {
      "id": "2120",
      "name": "Devine Craft",
      "email": "craftdivine780@gmail.com",
      "role": "cp",
      "subtitle": "[\"1\",\"2\",\"3\"]",
      "profileImage": "profile_photo_5_1776920358523.jpg",
      "source": "cp",
      "alreadyAdded": false
    }
  ]
}
```

---

### 11. Remove Participant (Admin)

Removes the selected participant from a room.

- **Method:** `DELETE`
- **Path:** `/external-chat/room/:roomId/participants/:userId`
- **Path params:** `roomId`, `userId`
- **Body fields:** `role`

```json
{
  "role": "cp"
}
```

> **Flagged:** A `DELETE` request carrying a JSON body is unusual and some HTTP
> clients drop the body on DELETE. Confirm the client library (and any proxy)
> forwards the body, or confirm with backend whether `role` can move to a query param.

---

### 12. Get Directory

Gets the members dropdown list.

- **Method:** `GET`
- **Path:** `/external-chat/directory`
- **Query param:** `search` *(optional)*
- **Body:** none

---

### 13. Get Room By Booking

Gets the chat room linked with a booking/project ID.

- **Method:** `GET`
- **Path:** `/external-chat/room/:bookingId`
- **Path param:** `bookingId`
- **Body:** none

---

### 14. Edit Message

Updates existing message content.

- **Method:** `POST`
- **Path:** `/external-chat/messages/:messageId/edit`
- **Path param:** `messageId`
- **Body fields:** `content`, `roomId`

```json
{
  "content": "updated message",
  "roomId": "6a01d803559441ddaa24bd48"
}
```

> **Flagged — field name inconsistency:** Send/Reply (#5, #6) use the key
> `message` for body text. Edit uses `content`. Same conceptual field, two
> different keys. Do not assume they are interchangeable — use exactly the key
> shown per endpoint.

---

### 15. Delete Message

Deletes or soft-deletes a message.

- **Method:** `POST`
- **Path:** `/external-chat/messages/:messageId/delete`
- **Path param:** `messageId`
- **Body fields:** `roomId`

```json
{
  "roomId": "6a01d803559441ddaa24bd48"
}
```

---

## Known Gaps

The source specification does **not** define the following. These must be
obtained from the backend team before or during implementation — do not assume:

1. **Response bodies.** No success response shape is documented for any endpoint.
   The shape of a room, message, participant, or reaction object is unknown.
2. **Error format.** No error envelope, status codes, or error-code list.
3. **Pagination metadata.** `page`/`limit`/`sortBy` are accepted as inputs, but
   the response-side pagination fields (total count, hasMore, next cursor, etc.)
   are undocumented.
4. **`sortBy` allowed values.** Field names and direction syntax are unspecified.
5. **Real-time transport.** No WebSocket/Socket.IO events are described. A chat
   experience needs live message delivery; the REST surface alone implies polling,
   which is almost certainly not the intended design. Confirm the real-time layer
   separately — it is out of scope for this document by request.
6. **Auth token lifecycle.** Token format, expiry, and refresh flow are undocumented.
7. **Field-name inconsistency.** `message` (send/reply) vs `content` (edit) — see #14.
8. **DELETE-with-body** behavior — see #11.

---

*Generated from `Messages_API_document.docx`. Faithful transcription; gaps flagged, nothing fabricated.*
