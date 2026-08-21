# Booking Features — Mobile App Development Guideline

**Scope of this document:** Feature specification for the **"Book a Shoot"** workflow, covering **File Manager**, **Messaging**, and **Meetings**.

**Apps in scope:**
- **CP App** (Content Provider) — mobile (Flutter)
- **Client App** (User) — mobile (Flutter)

**Out of scope (handled by Web):**
- **Admin Panel** — all administrative actions (chat creation, participant add/remove/assign, meeting attendee management) live on **web**, not on mobile.

> ⚠️ Because Admin is web-only, **neither mobile app contains participant-management UI** for chat or meetings. CP and Client are participants, not managers, in those features.

---

## Role Definitions

| Role | Description | Platform |
|------|-------------|----------|
| **Admin** | Platform administrator with full control over all features | **Web only** |
| **Client** | The party booking the shoot/service | Client App (mobile) |
| **CP (Content Provider)** | The creator/service provider fulfilling the booking | CP App (mobile) |

---

## App ↔ Feature Capability Map (Mobile Only)

| Feature | CP App | Client App |
|---------|--------|------------|
| **File Manager — Pre-Production** | View + download only | Upload + view |
| **File Manager — Post-Production** | Upload + edit + delete own files + view | View + download only |
| **Messaging** | Send + view messages (participant) | Send + view messages (participant) |
| **Meetings — Create** | ❌ Cannot create | ✅ Can create *(see Open Decision #1)* |
| **Meetings — Cancel / Edit** | ❌ | ✅ Own meetings only |
| **Meetings — View / Accept / Decline** | ✅ (if invited) | ✅ |
| **Add / Remove participants (chat or meeting)** | ❌ | ❌ |

---

# 1. File Manager — Book a Shoot

## 1.1 Overview
When a CP **accepts** a booking request, an organized folder structure is **automatically created** for managing project assets. No manual folder creation is required from either mobile app.

## 1.2 Folder Structure
```
📁 [Project / Booking Name]
├── 📁 Pre-Production
│     └── (Read-only for CP)
│
└── 📁 Post-Production
      ├── 📁 [Folder 1 — e.g., Raw Footage]
      ├── 📁 [Folder 2 — e.g., Edited Content]
      └── 📁 [Folder 3 — e.g., Final Deliverables]
```

## 1.3 Permissions Matrix

| Folder | CP Upload | CP View | Client Upload | Client View |
|--------|:---------:|:-------:|:-------------:|:-----------:|
| **Pre-Production** | ❌ | ✅ | ✅ | ✅ |
| **Post-Production** | ✅ | ✅ | ❌ | ✅ |

> Note: The source uses "Admin/Client" together. On mobile, Admin actions are web-only; the column above reflects the **Client** mobile capability.

## 1.4 Pre-Production Folder
- **Purpose:** Briefs, references, mood boards, scripts, planning materials provided by Client/Admin.
- **CP access:** Read-only (view + download).
- **Upload access:** Client (mobile) and Admin (web) only.
- **Use case:** CP has all project requirements without being able to modify source materials.

## 1.5 Post-Production Folder
- **Purpose:** All deliverables and work-in-progress files from the CP.
- **CP access:** Full read/write — upload, edit, delete **their own** files.
- **Client access:** View + download only (cannot upload).
- **Structure:** 3 sub-folders for organized delivery.

**Sub-folder examples:**
1. **Raw Footage** — unedited source files
2. **Edited Content** — work-in-progress edits
3. **Final Deliverables** — approved final assets

## 1.6 Workflow
```
1. Client creates booking  →  CP accepts booking
        ↓
2. System auto-creates folder structure
        ↓
3. Client/Admin uploads to Pre-Production (briefs, references)
        ↓
4. CP reviews Pre-Production materials (read-only)
        ↓
5. CP uploads work to Post-Production folders
        ↓
6. Client/Admin reviews and provides feedback
```

## 1.7 Per-App Screen Implications

**CP App**
- Pre-Production: list + preview + download. **No upload control.**
- Post-Production: list + upload + edit/delete (own files only) per sub-folder.

**Client App**
- Pre-Production: list + upload + preview + download.
- Post-Production: list + preview + download. **No upload control.**

---

# 2. Messaging System

## 2.1 Overview
After a booking is confirmed, a chat is initiated for communication between all parties. **Chat creation and participant management are Admin (web) actions** — not available on either mobile app.

## 2.2 Chat Initialization

| Action | Who Can Perform | On Mobile? |
|--------|-----------------|:----------:|
| Initiate / Create Chat | Admin only | ❌ (web) |
| Send Messages | All assigned participants | ✅ |
| View Messages | All assigned participants | ✅ |

## 2.3 User Management

| Action | Admin | CP | Client |
|--------|:-----:|:--:|:------:|
| Add users to chat | ✅ (web) | ❌ | ❌ |
| Remove users from chat | ✅ (web) | ❌ | ❌ |
| Assign users to chat | ✅ (web) | ❌ | ❌ |
| Leave chat | ❌ | ❌ | ❌ |

> ⚠️ **Open Decision #2:** "Leave chat" is ❌ for everyone, including Admin. As written, **no app (and no web panel) exposes a leave/exit affordance.** Treat as suspected source error — confirm before finalizing the chat screen.

## 2.4 Chat Features (mobile behavior)
1. **Chat creation** — happens on web (Admin). Mobile apps only **consume** an existing chat.
2. **Participant management** — Admin (web) adds/removes. Mobile shows the current participant list as read-only.
3. **Message visibility** — all participants see the same thread; history preserved for all active participants. Removed users lose access to chat history (removal is a web action).

## 2.5 Workflow
```
1. CP accepts booking
        ↓
2. Admin creates / initiates chat (web)
        ↓
3. Admin assigns participants — CP, Client, team members (web)
        ↓
4. All participants communicate (mobile + web)
        ↓
5. Admin adds / removes users as needed (web)
```

## 2.6 Per-App Screen Implications
- Both apps: chat thread, send message, view message history, view (read-only) participant list.
- Both apps: **no** add-user, remove-user, create-chat, or leave-chat controls.

---

# 3. Meetings System

## 3.1 Overview
Meetings can be scheduled for project discussions, reviews, and coordination. **Participant management is Admin (web) only.**

## 3.2 Meeting Creation

| Action | Admin | Client | CP |
|--------|:-----:|:------:|:--:|
| Create meeting | ✅ (web) | ✅ | ❌ |
| Cancel meeting | ✅ (web) | ✅ (own) | ❌ |
| Edit meeting details | ✅ (web) | ✅ (own) | ❌ |

## 3.3 Participant Management

| Action | Admin | Client | CP |
|--------|:-----:|:------:|:--:|
| Add users to meeting | ✅ (web) | ❌ | ❌ |
| Remove users from meeting | ✅ (web) | ❌ | ❌ |
| View meeting details | ✅ | ✅ | ✅ (if invited) |
| Accept / Decline invitation | ✅ | ✅ | ✅ |

## 3.4 Meeting Features
1. **Creation** — Client can schedule meetings for their bookings; Admin for any booking; CP cannot create (participant only).
2. **Participant management** — only Admin (web) adds/removes. Participants get notified when added/removed.
3. **Meeting details** — date & time, meeting link/location, agenda/description, participant list.

## 3.5 Workflow
```
1. Client or Admin creates meeting
        ↓
2. Admin assigns / adds participants (web)
        ↓
3. Participants receive invitation notification
        ↓
4. Participants accept / decline
        ↓
5. Admin modifies attendee list at any time (web)
        ↓
6. Meeting occurs
```

## 3.6 Per-App Screen Implications

**CP App**
- Meeting list, meeting detail (if invited), accept/decline. **No create/edit/cancel, no participant management.**

**Client App**
- Meeting list, create meeting (own bookings), edit/cancel **own** meetings, detail view, accept/decline.
- **No participant management** (Admin/web only) → see Open Decision #1.

---

# 4. Summary Table

| Feature | Create | Add Users | Remove Users | Upload |
|---------|--------|-----------|--------------|--------|
| File Manager (Pre-Prod) | Auto | N/A | N/A | Client / Admin only |
| File Manager (Post-Prod) | Auto | N/A | N/A | CP only |
| Messaging | Admin (web) | Admin (web) | Admin (web) | N/A |
| Meetings | Client, Admin | Admin (web) | Admin (web) | N/A |

---

# 5. Cross-Cutting Notes (from source)
1. All folder structures are created **automatically** upon booking acceptance.
2. Chat and meeting **notifications** are sent to relevant parties.
3. **File versioning** may be implemented for Post-Production folders. *(Marked "may be" in source — scope explicitly before building.)*
4. **All actions are logged** for audit purposes.

---

# 6. Open Decisions / Flagged Gaps

These are unresolved points in the source spec. They are **not** assumptions I've resolved — they need a product decision before the relevant screens are built.

| # | Gap | Impact on Mobile | Status |
|---|-----|------------------|--------|
| **1** | Client can **create** a meeting but **cannot add participants** (Admin/web-only). | Client app produces an empty meeting with no invitees, then waits for web-Admin to populate it. Either (a) give Client add-participant on **own** meetings, or (b) move meeting creation to web entirely and make Client app view/accept/decline only. | **Unresolved — needs decision** |
| **2** | "Leave chat" = ❌ for **all roles**, including Admin. | No leave/exit/mute affordance anywhere. Likely a source error. | **Suspected error — confirm** |
| **3** | CP has **zero creation rights** (no chat, no meeting, view-only Pre-Prod, upload-only Post-Prod). | CP app is effectively a consumption + file-upload app. | **Confirm this is intended product, not under-spec** |
| **4** | File versioning, audit logging, notifications stated as one-liners ("may be implemented"). | Need to be marked in-scope or explicitly deferred per release. | **Needs scoping** |

---

*This document is a faithful translation of the source feature spec, restructured for two-app (CP + Client) mobile development with Admin on web. No entities, endpoints, or data models have been invented; gaps are surfaced in Section 6 rather than silently resolved.*
