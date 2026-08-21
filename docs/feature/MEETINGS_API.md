# Meetings API

API reference for the **Meetings** feature (`external-meetings`).

> 📘 **Client integration plan:** [`MEETINGS_MT8_API_PLAN.md`](MEETINGS_MT8_API_PLAN.md) maps each endpoint below to the crew-app `MeetingsRepository`, DTOs, enum mappers, and 2-step create flow. Read alongside this reference when wiring the Flutter client.

---

## Conventions

| Variable | Description |
|----------|-------------|
| `{{URL}}` | Base API URL: `https://mobile.beige.app/api/` — keep the trailing slash; paths below append directly (e.g. `https://mobile.beige.app/api/external-meetings`). |
| `{{CP_TOKEN}}` | Auth token passed in the `Authorization` header. |

**Common headers** (all endpoints):

```
Content-Type: application/json
Authorization: {{CP_TOKEN}}
```

> ⚠️ **Auth scheme unconfirmed.** The token is sent raw in `Authorization` with no `Bearer` prefix in the source. Confirm whether the server expects `Bearer {{CP_TOKEN}}`.

---

## Endpoints

| # | Action | Method | Path |
|---|--------|--------|------|
| 1 | List meetings | `GET` | `external-meetings` |
| 2 | View meeting | `GET` | `external-meetings/{id}` |
| 3 | Create meeting | `POST` | `external-meetings` |
| 4 | Add participants | `POST` | `external-meetings/{id}/participants` |
| 5 | Edit meeting | `PATCH` | `external-meetings/{id}` |
| 6 | Delete meeting | `DELETE` | `external-meetings/{id}` |

---

### 1. List meetings

```http
GET {{URL}}external-meetings?limit=100&page=1&sortBy=meeting_date_time:desc
```

**Query parameters**

| Param | Type | Example | Notes |
|-------|------|---------|-------|
| `limit` | integer | `100` | Page size. |
| `page` | integer | `1` | 1-based page index. |
| `sortBy` | string | `meeting_date_time:desc` | Format `field:direction` (`asc` \| `desc`). Other sortable fields unconfirmed. |

**Response** `200 OK` — paginated wrapper of [Meeting objects](#meeting-object).

```json
{
  "results": [ /* Meeting object[] — see schema below */ ],
  "page": 1,
  "limit": 100,
  "totalPages": 1,
  "totalResults": 30
}
```

**Wrapper fields**

| Field | Type | Notes |
|-------|------|-------|
| `results` | Meeting[] | Array of meeting objects (see [Meeting object](#meeting-object)). |
| `page` | integer | Current page (echoes `page` query param). |
| `limit` | integer | Page size (echoes `limit` query param). |
| `totalPages` | integer | Total pages for the current `limit`. |
| `totalResults` | integer | Total meetings across all pages. |

---

### 2. View meeting

```http
GET {{URL}}external-meetings/{id}
```

**Path parameters**

| Param | Type | Notes |
|-------|------|-------|
| `id` | integer | Meeting ID (example used `10`). |

**Response** `200 OK` — a single [Meeting object](#meeting-object), returned directly (no wrapper). ✅ Confirmed: identical shape to each entry in List's `results[]`.

---

### 3. Create meeting

```http
POST {{URL}}external-meetings
```

**Request body**

```json
{
  "order_id": 1031,
  "meeting_date_time": "2026-05-11T14:30:00.000Z",
  "meeting_end_time": "2026-05-11T15:30:00.000Z",
  "meeting_status": "pending",
  "meeting_type": "post_production",
  "meeting_title": "MUSIC VIDEOS Shoot - Harsh Catch-up",
  "description": "test",
  "meetLink": "https://meet.google.com/wot-zhyg-run",
  "cp_ids": [],
  "admin_id": 248,
  "created_by_id": 248,
  "participants": [4],
  "send_notification": true
}
```

**Field reference**

| Field | Type | Required? | Notes |
|-------|------|-----------|-------|
| `order_id` | integer | ? | Linked order. |
| `meeting_date_time` | string (ISO 8601 UTC) | yes | Start time. |
| `meeting_end_time` | string (ISO 8601 UTC) | ? | End time. |
| `meeting_status` | string (enum) | ? | See [enums](#enums). |
| `meeting_type` | string (enum) | ? | See [enums](#enums). |
| `meeting_title` | string | yes | |
| `description` | string | no | |
| `meetLink` | string (URL) | no | ⚠️ camelCase, inconsistent with snake_case elsewhere. |
| `cp_ids` | integer[] | no | Purpose vs `participants` unclear. |
| `admin_id` | integer | ? | |
| `created_by_id` | integer | ? | |
| `participants` | integer[] | no | ❗ **Has no effect on create** (confirmed — see response note below). Add participants via the separate endpoint instead. |
| `send_notification` | boolean | no | Triggers notification on create. |

**Response** `201 Created` (confirm code) — the full [Meeting object](#meeting-object) with the new `id`. ✅ Same shape as reads.

```json
{
  "id": 36,
  "meeting_status": "pending",
  "meeting_title": "MUSIC VIDEOS Shoot - Harsh Catch-up",
  "duration": 60,
  "order": { "id": 1031, "name": "corporate Shoot - harsh" },
  "client": null,
  "admin": null,
  "cps": [],
  "participants": [],
  "created_by": { "id": 248, "name": "have had", "email": "ho21@gmail.com", "role": "creative" },
  "participant_responses": [],
  "change_request": null
}
```
_(Trimmed — identical structure to the [Meeting object](#meeting-object); full field list there.)_

> ⚠️ **Request fields not reflected in the create response — verify before relying on them:**
> - Sent `participants: [4]` → response `participants: []`. ❗ **Confirmed dead path:** user `4` is a real, existing user (later added successfully via [Add participants](#4-add-participants)), yet create ignored it. The create-body `participants` field does **not** attach participants. Use [Add participants](#4-add-participants) after creating.
> - Sent `admin_id: 248` → response `admin: null` (while `created_by` resolved to user 248). `admin_id` either isn't applied or doesn't map to the `admin` field. Confirm what `admin_id` actually does.
> - `client` derives from the `order`, not the request body — it was `null` here despite a valid `order_id`.

---

### 4. Add participants

```http
POST {{URL}}external-meetings/{id}/participants
```

**Path parameters**

| Param | Type | Notes |
|-------|------|-------|
| `id` | integer | Meeting ID (example used `6`). |

**Request body**

```json
{
  "role": "manager",
  "user_ids": ["4"]
}
```

| Field | Type | Notes |
|-------|------|-------|
| `role` | string | ❗ **Appears to have no effect on the result.** Sent `"manager"`, but the added user came back in `participants[]` with `role: "participant"`. Either ignored, overridden, or stored elsewhere — don't rely on it to set a participant's role. |
| `user_ids` | string[] | ⚠️ **Strings** here vs integer `participants` in create. |

**Response** `200 OK` (confirm code) — the full **updated** [Meeting object](#meeting-object), with the new user(s) merged into `participants[]`.

```json
{
  "id": 34,
  "participants": [
    { "id": 258, "name": "Beige Sales", "email": "sales@beigecorporation.io", "role": "participant" },
    { "id": 4,   "name": "Punya Shetty", "email": "punyashree1@yopmail.com",   "role": "participant" }
  ]
  /* ...rest identical to Meeting object */
}
```

> ✅ **This call is how participants actually get attached.** User `4` (a real, existing user) was added successfully here — the *same* ID that create silently dropped. So [create-body `participants` is a dead path](#3-create-meeting); use this endpoint instead. Added users get `role: "participant"` regardless of the requested `role`.

---

### 5. Edit meeting

```http
PATCH {{URL}}external-meetings/{id}
```

Partial update — send only fields to change.

**Path parameters**

| Param | Type | Notes |
|-------|------|-------|
| `id` | integer | Meeting ID (example used `12`). |

**Request body (example)**

```json
{
  "meeting_title": "COMMERCIAL Shoot - Neha Catch-up",
  "meeting_type": "post_production",
  "description": "To discuss quotes functionality",
  "meeting_date_time": "2026-06-14T05:30:00.000Z",
  "meeting_end_time": "2026-06-14T06:30:00.000Z",
  "meeting_status": "rescheduled"
}
```

Same field semantics as [Create](#3-create-meeting).

**Response** `200 OK` (confirm code) — the full **updated** [Meeting object](#meeting-object).

> ✅ **Confirmed: true partial update.** Only the fields in the body change; everything omitted is preserved. In the sample, `meeting_title` / `description` / times / status were updated, while `participants` (incl. previously-added user `4`), `cps`, `order`, `client`, `admin`, and `meetLink` were **left intact**. Send only what changed.
>
> ✅ **`duration` recomputes** from the new start/end (the edited times yielded `60`). Never send it.
>
> ❓ **Still unverified:** whether relational fields (`participants`, `cp_ids`, `order_id`) can be *changed* via PATCH — the sample body only touched scalars.

---

### 6. Delete meeting

```http
DELETE {{URL}}external-meetings/{id}
```

**Path parameters**

| Param | Type | Notes |
|-------|------|-------|
| `id` | integer | Meeting ID (example used `6`). |

**Response:** _Not documented._ Confirm soft vs hard delete and success status code.

---

## Meeting object

Returned by **List** (inside `results[]`) and by **View** (directly, unwrapped) — ✅ confirmed identical across both. Note the **request/response asymmetry**: on write you send scalar IDs (`order_id`, `cp_ids`, `participants`), but reads return fully expanded nested objects.

```json
{
  "id": 34,
  "meeting_status": "rescheduled",
  "meeting_date_time": "2026-06-11T13:30:00.000Z",
  "meeting_end_time": "2026-06-11T14:30:00.000Z",
  "meeting_type": "post_production",
  "meeting_title": "BRAND_PRODUCT Shoot - Punyashree Catch-up",
  "description": null,
  "meetLink": "https://meet.google.com/azi-kwdf-tuo",
  "duration": 60,
  "order": { "id": 4434, "name": "STUDIO Shoot - Rach Studio" },
  "client":  { "id": 198, "name": "Arpit S", "email": "arpits85@gmail.com", "role": "admin" },
  "admin":   { "id": 258, "name": "Beige Sales", "email": "sales@beigecorporation.io", "role": "sales_rep" },
  "cps": [
    { "id": 290, "name": "Punyashree Shetty", "email": "punyashree.s@yopmail.com", "role": "cp" }
  ],
  "participants": [
    { "id": 258, "name": "Beige Sales", "email": "sales@beigecorporation.io", "role": "participant" }
  ],
  "created_by": { "id": 198, "name": "Arpit S", "email": "arpits85@gmail.com", "role": "admin" },
  "participant_responses": [
    {
      "user_id": "538",
      "user_email": "pranav+rpclientdev1@revurge.com",
      "participant_ids": ["422"],
      "response": "declined",
      "responded_at": "2026-04-11T11:28:27.296Z"
    }
  ],
  "change_request": null
}
```

**Top-level fields**

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Meeting ID. |
| `meeting_status` | string (enum) | See [enums](#enums). |
| `meeting_date_time` | string (ISO 8601 UTC) | Start. |
| `meeting_end_time` | string (ISO 8601 UTC) | End. |
| `meeting_type` | string (enum) | See [enums](#enums). |
| `meeting_title` | string | |
| `description` | string \| null | Nullable; multi-line strings observed. |
| `meetLink` | string (URL) | Google Meet link. camelCase. |
| `duration` | integer | **Server-computed** minutes (end − start). Do not send on write. |
| `order` | object \| null | `{ id, name }`. Expanded from `order_id`. |
| `client` | [User](#user-sub-object) \| null | The order's client. |
| `admin` | [User](#user-sub-object) \| null | Assigned admin/sales rep. **Can be `null`.** |
| `cps` | [User](#user-sub-object)[] | Expanded from `cp_ids`. May be empty. |
| `participants` | [User](#user-sub-object)[] | Expanded from `participants` IDs. May be empty. |
| `created_by` | [User](#user-sub-object) \| null | Creator. |
| `participant_responses` | object[] | RSVP records. See below. Empty array when no responses. |
| `change_request` | object \| null | Always `null` in sample — **structure unknown, confirm with backend.** |

### User sub-object

Used by `client`, `admin`, `created_by`, and each entry of `cps` / `participants`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | User ID. |
| `name` | string | |
| `email` | string | |
| `role` | string (enum) | Observed: `admin`, `sales_rep`, `sales_admin`, `cp`, `client`, `participant`, `pm`, `creative`. ⚠️ **Open enum** — `creative` only surfaced in a create response, not in 30 list records. Do not seal this enum client-side; parse with a fallback. Mixes account roles (`admin`, `client`, `cp`…) with meeting-context roles (`participant`, `pm`) in the same field. |

### participant_responses entry

| Field | Type | Notes |
|-------|------|-------|
| `user_id` | string | Responding user ID (string, not int). |
| `user_email` | string | Lowercased email of responder. |
| `participant_ids` | string[] | Linked participant IDs; often `[]`, sometimes populated (e.g. `["422"]`). ⚠️ Semantics unclear — confirm. |
| `response` | string (enum) | Observed: `accepted`, `declined`. |
| `responded_at` | string (ISO 8601 UTC) | |

---

## Enums

> ⚠️ **Partial / observation-based.** Values below are only those seen in live data. Get the authoritative allowed sets from the backend before validating client-side.

**`meeting_status`** — confirmed in data: `pending`, `rescheduled`, `cancelled`
_(`completed` plausible but never observed — do not assume.)_

**`meeting_type`** — only `post_production` observed across all 30 records. **Full set unconfirmed** — treat as effectively unknown; the field being an enum doesn't mean other values are valid.

**`participant_responses[].response`** — observed: `accepted`, `declined`
_(`pending`/`tentative` plausible — unconfirmed.)_

**User `role`** — observed: `admin`, `sales_rep`, `sales_admin`, `cp`, `client`, `participant`, `pm`, `creative` ⚠️ **open enum** (`creative` only appeared in a create response) — do not seal.

**`role`** (add-participants request body) — observed: `manager` (note: not seen in any read response above — confirm it's the same vocabulary).

---

## Open questions for the backend team

_Updated after the List response was captured. ✅ = resolved by live data, ❓ = still open._

1. ✅ ~~List pagination wrapper~~ — confirmed `{ results, page, limit, totalPages, totalResults }`.
2. ❓ Response schema for **Delete** — List, View, Create, Add-participants, **and Edit** all confirmed to return the full [Meeting object](#meeting-object). Only Delete remains uncaptured.
3. ✅ ~~Create-body `participants`~~ — **confirmed dead.** Participants attach only via [Add participants](#4-add-participants). Two-call flow (create → add participants) is required.
4. ❗ **`admin_id` has no visible effect** — sent `248`, response `admin: null`. Confirm what `admin_id` is for (vs `created_by_id`, which did resolve).
5. ❗ **Add-participants `role` has no visible effect** — sent `"manager"`, added user came back as `role: "participant"`. Confirm whether participant roles are settable at all via this endpoint.
6. ❓ `client` is derived from the order, not the request — confirm when it populates (was `null` despite valid `order_id`).
7. ❓ `meeting_type` allowed values — only `post_production` ever seen. Effectively unknown.
8. ❓ `change_request` object structure — always `null` in samples.
9. ❓ `participant_responses[].participant_ids` semantics — when/why populated.
10. ❓ User `role` is an **open enum** (`creative` appeared late) — get the authoritative full set; account role or per-meeting role?
11. ❓ Which fields are genuinely required on create vs optional.
12. ❓ Can PATCH change relational fields (`participants`, `cp_ids`, `order_id`)? Sample only edited scalars.
12. ❓ Auth header format (`Bearer` prefix or raw token).
13. ❓ Error response shape and status codes (validation, 401, 404, etc.).
14. ❓ `meetLink` camelCase — intentional or should it be `meet_link`?
15. ❓ Exact success status codes (Create `201`?, Add-participants `200`?, Delete `200`/`204`?).
