# File Manager — API Integration Plan

## Image previews — 2026-09-10

- [x] Share image-extension detection across file DTOs and previews, including
  mixed-case names, signed URLs, and generic MIME responses.
- [x] Use one image-preview widget in file cards (all listing tabs/folders) and
  the preview sheet. Prefer supplied thumbnail/preview URLs; otherwise request
  a signed view URL for the file path, or use a legacy download URL.
- [x] Keep placeholders on missing URLs, request failures, and unsupported image
  codecs. Extension recognition does not guarantee platform decoder support.
- [x] Add helper/DTO/provider regression tests.
- [x] Reuse preview state across scroll disposal with value-based file keys and
  a five-minute keep-alive capped by signed URL expiry (30-second margin).
  Use stable version/metadata-based image cache keys and disable repeated fades.
  Failed requests are released so returning to a card can retry.
- [ ] Verify authenticated image rendering on device.

The user's image-preview request supersedes historical no-inline-image rules
below. Video/document external-open behavior remains unchanged.

## Real-data activation — 2026-09-07

### Navigation review — 2026-09-10

- [x] Trace repeated-folder navigation against the documented browse contract.
- [x] Fix root-phase child browsing: the detail endpoint must be used only when
  both phase is `root` and path is empty; children require `/files` with phase/path.
- [x] Preserve the requested folder key when browse responses omit phase/path,
  and cover nested navigation with regression tests.
- [ ] Confirm parity with the running web flow and authenticated backend.

Fixed root-phase child requests discarding the path and reloading workspace
detail. Response parsing now retains requested phase/path when absent from the
response. Five remote-source regression tests cover endpoint selection, nested
navigation to files, and response-context precedence. All 28 File Manager tests
pass; targeted static analysis is clean. Live authenticated verification remains
pending.

- [x] Default all File Manager repository providers to real Dio implementations.
- [x] Remove simulated upload progress and fabricated upload records; report uploads unavailable until FM8 is implemented.
- [x] Keep widget-test comment fixtures explicit, independent of production defaults.
- [ ] Verify authenticated browse/actions against the live backend on device.

This update supersedes the dummy-default statements in the historical July
snapshots below. Existing remote workspace, folder, file-action, and comment
repositories are now selected by default with no dummy fallback. Multipart
uploads remain pending; this activation does not complete FM8.

**Overall status (audited 2026-07-14):** 🟡 In progress — **9 / 20 tasks
complete, 1 partial, 7 blocked, 3 pending**. FM7 is implementation-complete,
but the app still defaults to dummy repositories; the remote browse/file-ops
implementations are present behind `useDummyFileManagerProvider` and are not
production-enabled yet.

Source: `docs/feature/filemanager/File Manager API doc.docx` (v1, dev host
`https://api.dev.beige.app/v1`, mobile host `https://mobile.beige.app/api`).

Companion docs:
- `FILE_MANAGER_DESIGN.md` — IA, screen inventory, component behavior.
- `FLUTTER_UPLOAD_CONSTRAINTS.md` — hard limits + multipart / background
  / retry / persistence rules. §9 of this doc translates every rule into
  a concrete Flutter task.

> All example responses in this plan are transcribed from the doc's Postman
> screenshots. Any field marked `?` is optional / nullable in the sample.

---

## 0. TL;DR — What This Plan Changes

Today the client speaks a **synthetic contract** (`FileManagerRepository`
returning `FmFolder`/`FmFile` with opaque `id`s + a `dummy` implementation).
The real API is **path-addressed** (every mutation identifies a resource by
its `filepath`, and folders are scoped by `phase` + relative `path`).

Migration strategy: keep the domain models, add the concept of a **canonical
path**, split the current single `FileManagerRepository` into three
focused contracts (workspace list, folder browse, file ops), and thread
`externalId + phase + path` through the presentation layer wherever we
currently pass a bare `folderId`.

**File opening policy (updated 2026-09-10):** image previews render inline in
cards and the preview sheet. Video and documents use external viewers.
Explicit open / download hands off to the OS (`url_launcher` with
`LaunchMode.externalApplication`, or `share_plus` for share). See §4.9.

Two implementations remain in tree until the remote path is green:
`FileManagerRepositoryDummy` (in-memory, drives UI dev) and
`FileManagerRepositoryRemote` (Dio).

### 0.1 Progress at a glance

| Phase | Scope | State |
|-------|-------|-------|
| **FM7** | Browse · open · preview · kebab · delete | ✅ **6/6 implementation-complete**; remote providers remain behind the dummy-default flag |
| **FM8** | Uploads · Edits workflow | 🟡 **3/10 complete, 7/10 blocked** — 8.02 picker · 8.09 send-for-edits · 8.10 revision + version folder are complete; multipart infrastructure awaits §11 Q0 |
| **FM9** | Comments · Sharing · Common Events | 🟡 **1/4 complete, 1/4 partial** — 9.01 comments wired end-to-end (repo/notifier/preview sheet); 9.02 Common Events listing shipped in 7.02, creator-folder CTA still pending |

Full task-level status + file touch points in §10.

---

## 1. Environment & Auth

| Item | Value |
|------|-------|
| Base URL (dev) | `https://api.dev.beige.app/v1` |
| Base URL (mobile) | `https://mobile.beige.app/api` |
| Auth header | `Authorization: Bearer <TOKEN>` |
| `Content-Type` | `application/json` |
| Token — Client / Admin | `{{TOKEN}}` (User App uses this) |
| Token — Creative Partner | `{{CP_TOKEN}}` (CP App uses this) |

BEIGE = crew-side CP app → default token = `{{CP_TOKEN}}` from
`SessionStore`. Wire via existing `dioClientProvider`; no separate
`Dio` instance.

**Envelope** — every JSON response follows:

```json
{ "success": true, "message": "…optional…", "data": { … } }
```

`FileManagerRemoteSource._unwrap` already peels `data`. Keep that helper
and reuse.

---

## 2. Endpoint Catalog

| # | Verb | Path | Purpose | Screen(s) |
|---|------|------|---------|-----------|
| 1 | GET | `/external-file-manager/workspaces` | List all project workspaces | Root — All Files / Linked Files |
| 2 | GET | `/external-file-manager/workspace/{externalId}` | Workspace detail (Pre/Post folders) | Project view |
| 3 | GET | `/external-file-manager/workspace/{externalId}/files?phase&path` | Open folder contents | Every folder listing |
| 4 | POST | `/external-file-manager/folder-download-url` | Signed URL for folder ZIP | Kebab → Download (folder) |
| 5 | POST | `/external-file-manager/folder` | Create folder (also `Create Version N`) | Post-Prod + Revisions |
| 6 | POST | `/external-file-manager/upload-policies/batch` | Presigned upload policies | Upload sheet — start |
| 7 | POST | `/external-file-manager/files-uploaded/batch` | Confirm items landed | Upload sheet — after PUT |
| 8 | POST | `/external-file-manager/file-view-url` | Signed inline view URL | File Preview Sheet |
| 9 | POST | `/external-file-manager/file-download-url` | Signed download URL | Kebab → Download (file) |
| 10 | POST | `/external-file-manager/delete` | Delete file or folder | Kebab → Delete |
| 11 | POST | `/external-file-manager/copy-files` | Send to `Selected for Edits` | Raw Footage → Request Edits |
| 12 | POST | `/external-file-manager/folder` | Create `VersionN` folder (path=`Edits/Revisions`) | Revisions → Create Folder |
| 12b | POST | `/external-file-manager/revision-file/review` | Approve / request_revision | File Preview Sheet |
| 13a | POST | `/comments` | Add comment | Preview Sheet — comments |
| 13b | GET | `/comments?metaId=<fileMetaId>` | List comments | Preview Sheet |
| 13c | POST | `/comments/{commentId}/reply` | Reply | Preview Sheet — thread |
| 13d | DELETE | `/comments/{commentId}` | Delete own comment | Preview Sheet — thread |
| 14a | POST | `/external-file-manager/share` | Create share | Kebab → Share |
| 14b | GET | `/external-file-manager/share` | Share info | Share manager |
| 14c | GET | `/external-file-manager/share/access-logs` | Access logs | Share manager |
| 14d | DELETE | `/external-file-manager/share` | Revoke | Share manager |
| 15 | POST | `/external-file-manager/share/request-otp` | Request OTP (external viewer) | Public link |
| 16 | POST | `/external-file-manager/share/verify-otp` | Verify OTP → JWT | Public link |
| 17 | GET | `/external-file-manager/share/{shareToken}/content` | Shared browse | Public link |
| 18 | GET | `/external-file-manager/share/{shareToken}/view-url` | Shared view URL | Public link |
| 19 | GET | `/external-file-manager/share/{shareToken}/download-url` | Shared download URL | Public link |
| 20a | POST | `/external-file-manager/common-events` | Create common event (admin) | — (admin surface) |
| 20b | GET | `/external-file-manager/common-events` | List common events | Root — Common Events tab |
| 20c | PATCH | `/external-file-manager/common-events/{externalId}` | Update visibility (admin) | — |
| 20d | POST | `/external-file-manager/common-events/{externalId}/creator-folder` | Create CP folder inside event | Common Event → Create Folder |

Endpoints scoped **outside the crew mobile app** (14/15/16/17/18/19 public
share flow + 20a/20c admin) live in this catalog for completeness but are
**not on the phase-1 delivery list** — see §7.

---

## 3. DTO Definitions

All DTOs live under `lib/features/file_manager/data/dtos/`. Naming:
`<Resource>Dto` per envelope-inner object; static `fromJson` on each.
Every DTO has a `toDomain(...)` returning the corresponding `FmNode` /
domain model.

### 3.1 Envelope

```dart
class FmEnvelope<T> {
  final bool success;
  final String? message;
  final T data;
  // fromJson(json, (d) => T.fromJson(d))
}
```

### 3.2 Workspace (project folder at root)

Response sample (endpoint 1):

```json
{
  "externalId": "3134",
  "folderName": "private_neha_#3134",
  "rootPath": "private_neha_#3134/",
  "fullPath": "Website_Shoots_Flow/private_neha_#3134/",
  "consoleUrl": "https://console.cloud.google.com/…",
  "fileCount": 0,
  "createdAt": "2026-04-13T12:14:03.001Z",
  "updatedAt": "2026-04-13T12:14:04.239Z",
  "isCommonEvent": true,      // optional; true → Common Events tab
  "eventId": 5,               // optional (present when isCommonEvent)
  "eventName": "Indexing",    // optional
  "visibleUntil": null        // optional; string ISO or null
}
```

`WorkspaceDto` → `FmFolder` mapping:

| DTO field | Domain field |
|-----------|--------------|
| `externalId` | `id` |
| `folderName` | `name` |
| `fileCount` | `fileCount` |
| `updatedAt` | `openedAt` (parse ISO) |
| `isCommonEvent == true` → `LinkState.linked` else `null` | `linkState` |
| `eventName` (if present) | `tagLabel` |

Extra fields (`rootPath`, `fullPath`, `consoleUrl`) go on a new
`FmWorkspaceMeta` sidecar model kept on the `FmFolder` via composition — the
UI card doesn't need them, but downstream calls (create folder, upload,
delete) require `rootPath`.

### 3.3 Pagination

```json
"pagination": {
  "page": 1, "limit": 13, "total": 13,
  "totalPages": 1, "hasNextPage": false, "hasPreviousPage": false
}
```

Maps to the existing `FmPage<T>` shape by translating
`hasNextPage → nextCursor = (page + 1).toString()`, else `null`.

### 3.4 Workspace Detail (endpoint 2)

```json
{
  "workspace": { … WorkspaceDto … },
  "folders": [
    {
      "name": "Post-Production",
      "path": "corporate_harsh_#4833/Post-Production/",
      "fullPath": "Website_Shoots_Flow/corporate_harsh_#4833/Post-Production/",
      "folderType": "postproduction",
      "fileCount": 0,
      "updatedAt": "…",
      "createdAt": "…"
    }
  ],
  "files": []
}
```

`FolderNodeDto.folderType` enum: `preproduction | postproduction | edits |
revisions | raw_footage | final_deliverables | selected_for_edits |
version | custom`. Case-insensitive parse; unknown → `custom`.

### 3.5 Folder Contents (endpoint 3)

```json
{
  "workspace": { … },
  "phase": "root" | "pre" | "post",
  "path": "",
  "basePath": "corporate_harsh_#4833/",
  "folders": [ FolderNodeDto ],
  "files":   [ FileNodeDto ]
}
```

Same DTOs as 3.4 for `folders`. `FileNodeDto` (inferred from doc + view/
download shape — verify against a live response with files present):

```json
{
  "id": "6a424fe8253c42d7a139b7be",
  "name": "5.jpeg",
  "path": "corporate_harsh_#4833/Post-Production/Raw Footage/5.jpeg",
  "fullPath": "Website_Shoots_Flow/…/5.jpeg",
  "size": 271606,
  "contentType": "image/jpeg",
  "version": 1,
  "isLatest": true,
  "status": "raw_files_uploaded",
  "uploadedBy": { "id": "281", "name": "…" },
  "createdAt": "…",
  "updatedAt": "…"
}
```

`FileNodeDto → FmFile`:

| DTO | Domain |
|-----|--------|
| `id` | `id` (opaque; retained for comments' `fileMetaId` fallback) |
| `name` | `name` |
| `contentType` | `type` (via `FileType.fromMime`) |
| `size` | `sizeBytes` |
| `path` | new `filepath` field (path is what mutations use) |
| `version`, `isLatest` | same |
| `status` | `statusLabel` (mapped through §4.4 status enum) |
| `uploadedBy.name` | `uploaderName` |

Add `FmFile.filepath` (nullable while dummy still emits stubs). All mutation
calls source it from this field.

### 3.6 Create Folder (endpoint 5 + 12)

Request:
```json
{ "bookingId": 934, "phase": "post", "path": "", "folderName": "David" }
```

Response `data`:
```json
{
  "folder": { "id": "…", "path": "…/Test1/", "name": "Test1", "isFolder": true },
  "alreadyExists": false
}
```

Endpoint 12 (create version folder) uses `externalId` instead of `bookingId`
per the doc. Confirm with backend which is canonical; source layer should
support both keys behind one Dart parameter.

### 3.7 Upload — Presign + Confirm (endpoint 6 + 7)

Presign request:
```json
{
  "items": [
    {
      "filepath": "corporate_neha_#1273/Post-Production/Raw Footage/5.jpeg",
      "fileContentType": "image/jpeg",
      "fileSize": 271606
    }
  ]
}
```

**Response is not screenshotted.** Expected shape (align with GCS/S3 presign
convention BEIGE uses elsewhere — verify with live curl before merge):

```json
{
  "items": [
    {
      "filepath": "…",
      "uploadUrl": "https://storage.googleapis.com/…?…",
      "method": "PUT",
      "headers": { "Content-Type": "image/jpeg", "x-goog-…": "…" },
      "expiresAt": "…"
    }
  ]
}
```

Confirm request (endpoint 7):
```json
{
  "items": [
    {
      "filepath": "…/Raw Footage/4.jpeg",
      "fileContentType": "image/jpeg",
      "fileSize": 271606,
      "fileName": "4.jpeg"
    }
  ]
}
```

Response: envelope + inferred `{ items: [{filepath, ok, error?}] }`.
Verify.

### 3.8 View / Download File (endpoints 8, 9)

Request:
```json
{ "filepath": "corporate_harsh_#4833/Post-Production/Edits/Revisions/Version1/5.jpeg" }
```

Response `data`:
```json
{
  "url": "https://storage.googleapis.com/…?X-Goog-Signature=…",
  "expiresIn": 3600         // seconds (naming per §8 audit)
}
```

### 3.9 Download Folder (endpoint 4)

Request:
```json
{ "externalId": "1273", "phase": "post", "path": "Edits" }
```

Response `data`:
```json
{
  "url": "http://api2.dev.beige.app/v1/gcp/download-folder?folderpath=…",
  "filepath": "corporate_harsh_#4833/"
}
```

### 3.10 Delete (endpoint 10)

Request:
```json
{ "filepath": "corporate_harsh_#4833/Post-Production/Test1" }
```

Response `data`:
```json
{
  "deleted": true,
  "deletedCount": 1,
  "metadataDeletedCount": 0,
  "embeddingDeletedCount": 0
}
```

Folder delete: append trailing `/` to `filepath` (per doc: `"Event -
testing/"`).

### 3.11 Copy Files — Send For Edits (endpoint 11)

Request:
```json
{
  "externalId": "1273",
  "phase": "post",
  "targetPath": "Edits/Selected for Edits",
  "sourcePaths": [
    "corporate_neha_#1273/Post-Production/Raw Footage/5.jpeg"
  ]
}
```

Response `data`:
```json
{
  "total": 1,
  "successCount": 1,
  "failedCount": 0,
  "sourcePath": "…",
  "targetPath": "…",
  "items": [
    {
      "sourcePath": "…",
      "destinationPath": "…/Selected for Edits/…",
      "success": true,
      "metadata": {
        "id": "…", "name": "…", "size": 271606, "…": "…"
      }
    }
  ]
}
```

Side-effect (per doc): "Email sent to Admin, Email sent to Creative
Partner." Client does nothing extra — server fans out.

### 3.12 Revision Review (endpoint 12b)

Request:
```json
{
  "externalId": "1273",
  "filepath": "…/Version1/5.jpeg",
  "action": "request_revision" | "approve"
}
```

Response `data` — two shapes depending on action:

```json
// action = request_revision
{
  "action": "request_revision",
  "versionNumber": 1,
  "nextVersionNumber": 2,
  "nextVersionPath": "corporate_harsh_#4833/Post-Production/Edits/Revisions/Version2"
}

// action = approve
{
  "action": "approve",
  "versionNumber": 1,
  "finalDeliverable": {
    "id": "6a424fe8253c42d7a139b7be",
    "path": "corporate_harsh_#4833/Post-Production/Final Deliverables/…",
    "name": "Radical+Trust.webp"
  }
}
```

Enum: `RevisionAction { approve, requestRevision }` with `apiValue`.

### 3.13 Comments (endpoint 13)

Comment object (used by list, add, reply):
```json
{
  "id": "6a4257f3f5594aec67ad6cff",
  "fileMetaId": "corporate_harsh_#4833/…/Version1/5.jpeg",
  "userId": {
    "id": "626", "name": "test c2",
    "email": "aivideoverse40@gmail.com",
    "role": "Creative", "user_type": 2,
    "profile_picture": null
  },
  "comment": "Okay",
  "timestamp": null,               // video timestamp (nullable)
  "frameioCommentId": null,
  "frameioSyncedAt": null,
  "parentId": null,                // reply → parent comment id
  "reactions": [],
  "createdAt": "2026-06-29T11:33:07.030Z",
  "updatedAt": "2026-06-29T11:33:07.030Z",
  "replies": []                    // only on list; recursive
}
```

Add request:
```json
{ "fileMetaId": "…", "user_id": "281", "comment": "Ok", "timestamp": null }
```

Reply request (path `POST /comments/{commentId}/reply`):
```json
{ "user_id": "281", "comment": "Done" }
```

Delete: `DELETE /comments/{commentId}` body `{ "user_id": "247" }`.

`user_id` is the current session's user id (`SessionStore.user.id`).
`fileMetaId` = the file's `filepath` (per doc's use of the same value in
mutation examples). Confirm — some backends key comments off the opaque
file `id` instead.

Domain: `FmComment { id, fileMetaId, author: FmCommentAuthor, body,
timestamp, parentId, reactions, createdAt, updatedAt, replies }`.

### 3.14 Common Events (endpoint 20b + 20d)

List item:
```json
{
  "eventId": 2,
  "eventName": "Diwana December Event",
  "eventSlug": "diwana_december_event",
  "externalId": "event_diwana_december_event_1776415230475",
  "rootPath": "Event - Diwana December Event/",
  "visibleUntil": null,
  "createdByUserId": 198,
  "createdAt": "…",
  "updatedAt": "…"
}
```

Maps to `FmCommonEvent` — surfaced in the **Common Events** root tab. Reuses
`FmFolder` at the UI layer with `linkState = null` and
`tagLabel = "Common Event"`.

Creator-folder response (20d):
```json
{
  "externalId": "event_test_123_1781240829711",
  "phase": null,
  "path": null,
  "folderName": "test 123",
  "folder": { "id": "…", "path": "Event - test 123/test 123/", "name": "test 123", "isFolder": true }
}
```

---

## 4. Semantics

### 4.1 Path Grammar

```
<workspace.rootPath> + <phase-segment>/ + <relative path>/ + <fileName>
```

- `phase-segment` ∈ `Pre-Production | Post-Production` (present iff
  `phase != root`).
- Trailing `/` on directory paths; absent on file paths.
- URL query — API decodes standard percent-encoding: `?path=Edits/Selected%20for%20Edits`.

Helper (put in `data/util/fm_path.dart`):

```dart
class FmPath {
  static String join(String base, String segment);
  static String phaseSegment(FmPhase phase);   // pre → "Pre-Production"
  static String folderPath({required String rootPath, required FmPhase phase, String? relative});
  static bool isFolder(String path) => path.endsWith('/');
}
```

### 4.2 Phase Enum

```dart
enum FmPhase { root, pre, post }
extension FmPhaseX on FmPhase {
  String get apiValue => switch (this) { root => 'root', pre => 'pre', post => 'post' };
  static FmPhase fromApi(String v) => …;
}
```

### 4.3 Folder Type → UI treatment

| `folderType` | UI badge | Notes |
|--------------|----------|-------|
| `preproduction` | — | Docs list |
| `postproduction` | — | Category grid + Upload CTA |
| `raw_footage` | "Raw Files Uploaded" pill on children | Read-only for Client |
| `selected_for_edits` | "File Selected For Edits" pill on children | Populated by copy-files (§3.11) |
| `edits` | — | Container |
| `revisions` | — | Contains VersionN folders |
| `version` | `V{n} Latest` when latest | Files inherit version tag |
| `final_deliverables` | — | Deliverable landing |
| `custom` | — | User-created |

### 4.4 File `status` → StatusPill (design §3.7)

| API `status` | Pill label |
|--------------|-----------|
| `raw_files_uploaded` | Raw Files Uploaded |
| `selected_for_edits` | File Selected For Edits |
| `pending_review` | Pending Review |
| `approved` | Approved |
| `revision_requested` | Revision Requested |
| (missing) | no pill |

Unknown values fall through to the raw string (dev safety) with a
`debugPrint` so we notice new backend values.

### 4.5 Upload Flow (design §4.2)

1. User picks files → build `List<UploadCandidate>` client-side
   (`filepath` computed via §4.1 helper, MIME sniffed from extension).
2. `POST /upload-policies/batch` → one presign per item.
3. For each item: `PUT presign.uploadUrl` with the file bytes and the
   returned headers. Report per-item progress via `Dio.onSendProgress`.
4. Once all `PUT`s complete: `POST /files-uploaded/batch` to finalise.
5. Invalidate the destination `folderContentsProvider(family)`.

Failure handling:
- Presign fail → whole batch aborts; sheet shows error, retains queue.
- Individual `PUT` fail → keep item in queue with `failed` state (design
  shows `Failed X / Pending Y` counters).
- Confirm-batch fail → items are on GCS but not indexed; retryable.

Background survival: run the upload from a **notifier** (not the sheet
widget) so `Navigator.pop` doesn't cancel the transfer (design
consideration §5.14).

### 4.6 Send For Edits Flow (design §4.3)

Raw Footage list → multi-select → `POST /copy-files` with `phase=post`,
`targetPath=Edits/Selected for Edits`, `sourcePaths=[<file.path>…]` → on
`success` navigate to the reusable `SuccessScreen` (existing
`success_screen.dart`) with deep-link target
`Edits › Selected for Edits`.

### 4.7 Revision & Versioning Flow (design §4.4, §4.6)

- **Create Version folder** — `POST /folder`, `phase=post`,
  `path=Edits/Revisions`, `folderName=Version{n+1}`.
  Compute `n` client-side from the current `VersionN` list.
- **Request Revision** — Preview Sheet → `POST /revision-file/review`,
  `action=request_revision`. Response's `nextVersionPath` becomes the
  destination we route the user to.
- **Approve** — same endpoint, `action=approve`. Response's
  `finalDeliverable.path` becomes the deep-link target
  (`Final Deliverables`).

### 4.8 Kebab Actions (design §3.15, §4.5)

All file open / download hand off to the OS — see §4.9. No in-app
render, no `dio.download` + `OpenFile` two-step.

| Kebab | Target | Endpoint(s) | OS handoff |
|-------|--------|-------------|------------|
| Open (folder) | client-side push | — | — |
| Open (file) | signed view URL | `POST /file-view-url` | `launchUrl(url, mode: externalApplication)` |
| Share (file) | signed view URL | `POST /file-view-url` | `share_plus.Share.shareUri(url)` |
| Share (folder) | share OTP flow | `POST /share` (FM9) | share sheet w/ token URL |
| Download (file) | signed download URL | `POST /file-download-url` | `launchUrl(url, mode: externalApplication)` — OS browser downloads |
| Download (folder) | server-side ZIP URL | `POST /folder-download-url` | same |
| Delete | — | `POST /delete` (folders: trailing `/`) | confirm dialog first |

Delete always fires the existing confirm dialog before hitting the endpoint.

### 4.9 File Opening & Download Policy

Every leaf that would show file bytes to the user goes through the OS:

- **Open** (kebab or card tap or Preview Sheet's primary CTA) → fetch
  `POST /file-view-url` → `url_launcher.launchUrl(uri, mode:
  LaunchMode.externalApplication)`. iOS opens in Safari (or the
  registered handler); Android opens in Chrome / the registered viewer.
- **Download** → fetch `POST /file-download-url` → same
  `launchUrl` + `externalApplication`. OS handles the actual download +
  save location. No temp-file staging inside the app, no `dio.download`,
  no `OpenFile.open`.
- **Share** → fetch view URL, hand to `share_plus.Share.shareUri(uri)`.
  System share sheet takes it from there.
- **Upload complete** → refresh folder listing; do not auto-open the
  uploaded file.
- **Preview Sheet** — retained as the metadata + comments + actions
  surface. The old inline media/checkerboard area becomes a **tap
  target** whose action = the same external-open flow. Video icon + "Open
  in Player" / image icon + "Open Image" label depending on MIME.

Dependencies:
- Add `url_launcher: ^6.x` to `pubspec.yaml`.
- Add `share_plus: ^10.x` to `pubspec.yaml`.
- **Remove** `open_file` (currently used by
  `presentation/providers/node_action_notifier.dart`). No local file
  handoff needed once downloads are OS-driven.

iOS `Info.plist`: add `LSApplicationQueriesSchemes` for `https` (already
default) — no extra scheme needed for HTTPS handoff. Android
`AndroidManifest.xml`: no change (implicit `VIEW` intent).

---

## 5. Repository & Provider Surface

### 5.1 New / changed domain contracts

Split the current `FileManagerRepository` into three, keeping the existing
one as a **facade** for compatibility until presentation callers migrate:

```dart
// domain/repositories/workspaces_repository.dart
abstract class WorkspacesRepository {
  Future<FmPage<FmFolder>> list({FmTab tab, int page, int limit});
  Future<FmWorkspaceDetail> get(String externalId);
}

// domain/repositories/folder_browse_repository.dart
abstract class FolderBrowseRepository {
  Future<FmFolderContents> open({
    required String externalId,
    required FmPhase phase,
    String path,
  });
  Future<FmFolderCreated> createFolder({
    required String externalId,      // sent as bookingId or externalId per §3.6
    required FmPhase phase,
    required String path,
    required String folderName,
  });
}

// domain/repositories/file_ops_repository.dart
abstract class FileOpsRepository {
  Future<FmSignedUrl> viewUrl(String filepath);
  Future<FmSignedUrl> downloadUrl(String filepath);
  Future<FmSignedUrl> folderDownloadUrl({
    required String externalId, FmPhase? phase, String? path,
  });
  Future<FmDeleteResult> delete(String filepath);
  Future<FmCopyResult> copyToEdits({
    required String externalId,
    required FmPhase phase,
    required String targetPath,
    required List<String> sourcePaths,
  });
  Future<FmRevisionResult> reviewRevision({
    required String externalId,
    required String filepath,
    required RevisionAction action,
  });
  Future<List<FmUploadPolicy>> presignUploads(List<FmUploadItem> items);
  Future<void> confirmUploads(List<FmUploadItem> items);
}

// domain/repositories/comments_repository.dart
abstract class CommentsRepository {
  Future<List<FmComment>> list(String fileMetaId);
  Future<FmComment> add({
    required String fileMetaId, required String userId,
    required String comment, int? timestamp,
  });
  Future<FmComment> reply({
    required String commentId, required String userId, required String comment,
  });
  Future<void> delete({required String commentId, required String userId});
}

// domain/repositories/common_events_repository.dart
abstract class CommonEventsRepository {
  Future<List<FmCommonEvent>> list();
  Future<FmFolderCreated> createCreatorFolder({
    required String eventExternalId,
    required String folderName,
    String path = '',
  });
}
```

### 5.2 Deprecation of current facade

`FileManagerRepository` today mixes browse + share + delete + download +
upload. After migration:

- `listRoot` → `WorkspacesRepository.list`
- `listFolder` → `FolderBrowseRepository.open` (signature changes:
  `folderId` becomes `externalId + phase + path`).
- `getShareLink` → the actual share flow is a separate multi-step OTP
  system. Phase-1 kebab "Share" uses `/file-view-url` and hands the URL
  to the system share sheet; the real `/external-file-manager/share`
  goes in a follow-up ticket (see §7).
- `deleteNode` → `FileOpsRepository.delete` (path-addressed).
- `downloadFile` → `FileOpsRepository.downloadUrl` + `dio.download` on
  the returned URL (two hops now).
- `uploadFiles` → `FileOpsRepository.presignUploads` +
  per-file `PUT` + `confirmUploads`.

Keep the facade for one release cycle marked
`@Deprecated('Use the split repositories — remove after FM7.02')`.

### 5.3 Providers

`presentation/providers/`:

- `workspacesRepositoryProvider`, `folderBrowseRepositoryProvider`,
  `fileOpsRepositoryProvider`, `commentsRepositoryProvider`,
  `commonEventsRepositoryProvider` — thin `Provider`s that select
  dummy/remote via `useDummyFileManagerProvider`.
- `fileManagerRootNotifier` → stays, delegates to `WorkspacesRepository`;
  add pagination via `hasNextPage`.
- `folderContentsNotifier` — `AutoDisposeFamilyNotifier<
    FolderContentsState, FmFolderKey>` where
  `FmFolderKey { externalId, phase, path }`. Replaces the current single
  `folderId` key.
- `commentsNotifier(fileMetaId)` — `AutoDisposeFamilyAsyncNotifier`.
- `uploadNotifier(folderKey)` — `AutoDisposeFamilyNotifier<UploadState,
    FmFolderKey>`. Long-lived (kept alive while sheet dismissed) via
    `ref.keepAlive()`.
- `nodeActionNotifier` — stays for kebab commands; internally routes to
  `FileOpsRepository`.

### 5.4 Endpoints file (`core/network/api_endpoints.dart`)

Replace the current stubs (`file-manager/root`, `file-manager/folders/{id}`)
with the real routes; keep constants grouped:

```dart
static const String fmWorkspaces = 'external-file-manager/workspaces';
static String fmWorkspace(String extId) => 'external-file-manager/workspace/$extId';
static String fmWorkspaceFiles(String extId) =>
    'external-file-manager/workspace/$extId/files';
static const String fmFolder = 'external-file-manager/folder';
static const String fmFolderDownloadUrl = 'external-file-manager/folder-download-url';
static const String fmUploadPolicies = 'external-file-manager/upload-policies/batch';
static const String fmFilesUploaded = 'external-file-manager/files-uploaded/batch';
static const String fmFileViewUrl = 'external-file-manager/file-view-url';
static const String fmFileDownloadUrl = 'external-file-manager/file-download-url';
static const String fmDelete = 'external-file-manager/delete';
static const String fmCopyFiles = 'external-file-manager/copy-files';
static const String fmRevisionReview = 'external-file-manager/revision-file/review';
static const String fmShare = 'external-file-manager/share';
static const String fmShareRequestOtp = 'external-file-manager/share/request-otp';
static const String fmShareVerifyOtp = 'external-file-manager/share/verify-otp';
static String fmShareContent(String token) => 'external-file-manager/share/$token/content';
static String fmShareViewUrl(String token) => 'external-file-manager/share/$token/view-url';
static String fmShareDownloadUrl(String token) => 'external-file-manager/share/$token/download-url';
static const String comments = 'comments';
static String commentReply(String id) => 'comments/$id/reply';
static String commentById(String id) => 'comments/$id';
static const String fmCommonEvents = 'external-file-manager/common-events';
static String fmCommonEvent(String extId) => 'external-file-manager/common-events/$extId';
static String fmCommonEventCreatorFolder(String extId) =>
    'external-file-manager/common-events/$extId/creator-folder';
```

---

## 6. Screen-by-Screen Wiring

| Screen (design §2) | Provider / Repo call |
|-------------------|----------------------|
| 1. Root (All Files) | `workspacesRepositoryProvider.list(tab: allFiles, page: 1)` |
| 1. Root (Linked Files) | `workspacesRepositoryProvider.list(tab: linked)` — filter client-side on `isCommonEvent == false && linkState != null`, or add server flag |
| 1. Root (Common Events) | `commonEventsRepositoryProvider.list()` |
| 2. Project view | `folderBrowseRepositoryProvider.open(externalId, phase=root)` (returns Pre + Post subfolders) |
| 3. Pre-Production | `.open(externalId, phase=pre, path='')` |
| 4. Post-Production | `.open(externalId, phase=post, path='')` + `Upload Files` sticky CTA opens upload sheet |
| 5. Upload sheet — empty | no API |
| 6. Choose Document sheet | no API |
| 7. Upload sheet — queued | `uploadNotifier(folderKey).start(files)` → presign → PUT → confirm |
| 8. Raw Footage list | `.open(externalId, phase=post, path='Raw Footage')` |
| 9. Edits Request Sent — success | after `copyToEdits(...)` succeeds |
| 10. Edits view | `.open(externalId, phase=post, path='Edits')` |
| 11. Selected for Edits | `.open(externalId, phase=post, path='Edits/Selected for Edits')` |
| 12. File preview sheet | `fileOpsRepositoryProvider.viewUrl(filepath)` + `commentsRepositoryProvider.list(filepath)` |
| 13. Revision view | `.open(externalId, phase=post, path='Edits/Revisions')` |
| 14. Kebab popover | routes to `nodeActionNotifier` (see §4.8) |
| 15. Revision — Version N | `.open(externalId, phase=post, path='Edits/Revisions/Version{n}')` |

`FmFolderKey` (see §5.3) is the family arg for every browse/upload/comments
notifier — keeps navigation predictable and lets us invalidate a single
folder's cache after a mutation without dropping siblings.

---

## 7. Current UI Baseline (what already exists)

Snapshot of `lib/features/file_manager/` at the time of writing. Everything
listed here is **on-screen today**, wired to the dummy repo. Alignment
work in §8 targets the deltas — not a rewrite.

### 7.1 Screens

| File | Status | Notes |
|------|--------|-------|
| `presentation/screens/file_manager_screen.dart` | shipped | Root tabs (`FmTab`) + search + folder list |
| `presentation/screens/folder_contents_screen.dart` | shipped | Nested list, multi-select, version filter, Upload / Request-Edits CTA |
| `presentation/screens/success_screen.dart` | shipped | Reusable success page with deep-link CTA |

### 7.2 Widgets (all under `presentation/widgets/`)

`fm_folder_card`, `fm_file_card`, `fm_file_preview_sheet`,
`fm_upload_sheet`, `fm_choose_document_sheet`, `fm_actions_sheet`
(kebab), `fm_delete_confirm_dialog`, `fm_status_pill`, `fm_version_tag`,
`fm_tag_chip`, `fm_linked_badge`, `fm_project_badge_card`,
`fm_recursive_list`, `fm_search_field`, `fm_empty_view`, `fm_error_view`,
`fm_file_type_icon`, `fm_tab_bar`. Complete against the design widget
list.

### 7.3 Providers

| Provider | Family arg (today) | Family arg (needed) |
|----------|--------------------|---------------------|
| `fileManagerRootNotifierProvider` | none (holds `FmTab`) | unchanged |
| `folderContentsNotifierProvider` | **`String folderId`** | **`FmFolderKey`** (§5.3) |
| `nodeActionNotifierProvider` | none | unchanged; internals rewire to path-addressed calls |

### 7.4 Routing

`presentation/routes/file_manager_routes.dart`:

- `filesFolder` — path `/files/folder/:id`, `extra` = `{title,
  linkedProject?}`. `id` is an opaque `FmFolder.id`.
- `filesSuccess` — success screen; `extra` = title/message/ctaText/onCta.

### 7.5 Upload sheet — already-implemented pieces (do not rebuild)

Reference: `presentation/widgets/fm_upload_sheet.dart`.

- 5 GB / 50-file hard limits with `_isSizeExceeded` /
  `_isCountExceeded` — matches `FLUTTER_UPLOAD_CONSTRAINTS.md`.
- ≥ 50 MB Wi-Fi recommendation card + cellular override switch —
  matches "Network Rules".
- Queued list with per-item trash button — matches queue-item design.
- Progress row (`Uploading X/N`, %, linear bar) — matches design §3.10.
- Cancel button pops the sheet + surface a snackbar.

### 7.6 Upload sheet — stub / gap pieces

- **Picker is mocked** (`_openPicker` returns hard-coded file records).
  Needs a real picker (`file_selector` for docs, `image_picker` for
  photo/video — align with the two "Choose Document" options).
- **Progress is a `Timer.periodic`**, not a real transfer.
- Calls `repo.uploadFiles(folderId, files)` on the dummy path only. No
  presign, no PUT, no confirm, no multipart, no background survival,
  no persistence, no checksum, no per-file failure state, no auto
  pause/resume, no MIME allowlist.
- On success, invalidates `folderContentsNotifierProvider(widget.folderId)`
  — will still work once the family arg becomes `FmFolderKey`.

### 7.7 Preview sheet — stubbed pieces

- **Inline media block must go.** Current sheet renders a checkerboard
  + `Image.network(previewUrl)` fallback. Per project rule (§4.9), no
  in-app render. Replace the media box with a tap-through "Open in
  {Player|Viewer}" affordance that fires the external-open flow.
- Comments list is local `_comments` array; needs
  `commentsRepository.list(filepath)` + notifier (§3.13).
- "Request Revision" opens a local `AlertDialog` and SnackBar — needs
  `fileOpsRepository.reviewRevision(...)` + routing to the response's
  `nextVersionPath` (§3.12).
- Download / Share go through `nodeActionNotifier` with an opaque id +
  local `OpenFile.open`. Rewire to the OS-handoff flow (§4.9): fetch
  signed URL → `url_launcher` / `share_plus`. Drop `open_file`.

### 7.8 Multi-select / Send-For-Edits gap

`folder_contents_screen._onRequestEdits` currently only navigates to the
success screen — no `POST /copy-files`. Needs
`fileOpsRepository.copyToEdits(...)` before the navigation (§4.6).

### 7.9 Tab enum divergence

`FmTab` includes `recent` — **not present in the API doc**. Options:

1. Drop it from `FmTab` and `FmTabBar`.
2. Keep it, back it client-side by sorting `/workspaces` by `updatedAt`
   and taking the top N.

Recommend option 2 for phase 1 (no design change, cheap to build).
Confirm with product before FM7.02.

---

## 8. Gap Matrix — Current UI ↔ API Plan ↔ Design ↔ Upload Constraints

| Area | Current | Design (`FILE_MANAGER_DESIGN.md`) | API plan (§3-§4) | Upload spec (`FLUTTER_UPLOAD_CONSTRAINTS.md`) | Gap → action |
|------|---------|------------------------------------|------------------|------------------------------------------------|--------------|
| Route param | opaque `folderId` string | breadcrumb chip per level | `externalId + phase + path` | — | Change route to `/files/w/:externalId/:phase?path=…`; migrate `FolderContentsArgs` |
| Folder open | `listFolder(folderId)` | shell/scroll per level | `GET /workspace/{extId}/files?phase&path` | — | Rewire `FolderContentsNotifier` to `FmFolderKey`; adapt DTO → `FmNode` |
| Root workspaces | dummy `listRoot(tab)` | Tabs: All / Recent / Linked / Common Events | `GET /workspaces` + `GET /common-events` | — | Two data sources per tab; Recent = client sort by `updatedAt` (§7.9) |
| Project view (Pre/Post cards) | rendered from dummy sub-nodes | Design §2 screen #2 | `GET /workspace/{extId}` returns `folders[]` at root level | — | New screen wiring; reuse `FmRecursiveList` |
| Kebab · Open | works | Design §3.15 | client-side | — | ✓ ok |
| Kebab · Share (file) | copy-URL via `getShareLink` | system share sheet | Phase-1 uses `file-view-url` + share; real `/share` = OTP flow deferred FM9 | — | `fileOpsRepository.viewUrl(filepath)` → `share_plus.Share.shareUri` (§4.9) |
| Kebab · Share (folder) | copy-URL | system share sheet | Real `/external-file-manager/share` OTP flow | — | Deferred FM9.03 |
| Kebab · Download (file) | `_repo.downloadFile(fileId)` + `OpenFile.open` | OS save | `POST /file-download-url` → **OS handoff** via `url_launcher(externalApplication)` (§4.9) | — | Drop `dio.download`, drop `open_file` dep, drop local temp write |
| Kebab · Download (folder) | not shown | server-generated ZIP link | `POST /folder-download-url` → `launchUrl(externalApplication)` | — | New in `FileOpsRepository`; kebab item enabled |
| Kebab · Delete | `_repo.deleteNode(id, kind)` | confirm dialog | `POST /delete` with trailing `/` on folders | — | Rewire — folder path must end with `/` |
| Version filter dropdown | client-side by `.version` | Design §3.6 | Server provides `version, isLatest` on file node (§3.5) | — | ✓ ok once DTO fills fields |
| Multi-select → Request Edits | UI only; skips to success | Design §4.3 | `POST /copy-files` before success screen | — | Add in `_onRequestEdits`; on 200 → success screen |
| File open (card tap / preview CTA) | opens Preview Sheet w/ inline media stub | Design §3.16 | Fetch signed view URL, **hand off to OS** (§4.9) | — | Preview Sheet keeps metadata + comments + actions; media area becomes "Open in Player/Viewer" tap → `url_launcher(externalApplication)` |
| Comments | local `_comments` list | Design §3.16 / §4.7 | `GET /comments?metaId=…` + `POST /comments` + reply/delete | — | Add `commentsNotifier(fileMetaId)`; use `SessionStore.user.id` |
| Request Revision | AlertDialog + SnackBar | Design §4.6 | `POST /revision-file/review` action=`request_revision`; route to `nextVersionPath` | — | Wire; on success `context.pushNamed(filesFolder, …nextVersionPath)` |
| Approve | not shown in UI | implicit in §4.4 | `POST /revision-file/review` action=`approve`; route to `Final Deliverables` | — | Add "Approve" button next to Request Revision when file is a `VersionN` head |
| Create version folder | not wired | Design §4.4 (Revisions → Create Folder CTA) | `POST /folder` with `phase=post`, `path=Edits/Revisions`, `folderName=Version{n+1}` | — | Enable CTA when title matches Revisions folder; wire to `folderBrowseRepository.createFolder` |
| Upload · picker | mocked | Design §4.2 | client picks files → build `UploadCandidate[]` | — | Real picker (`file_selector` + `image_picker`) |
| Upload · limits | 5 GB / 50 files | Design §4.2 (implicit) | — | 5 GB total, 50 count, pre-flight | ✓ ok |
| Upload · MIME allowlist | none | — | — | required | Add explicit allowlist check pre-queue |
| Upload · transfer | fake `Timer.periodic` | — | Presign → PUT → confirm (§3.7) | Direct-to-S3 multipart; per-file independent upload id; part 8-16 MB; streamed; off-main-isolate | Full rewrite — see §9 |
| Upload · background | dies with sheet | Design §5.14 ("uploads survive navigation") | — | OS-native background transfer | New — `background_downloader` package (see §9.4) |
| Upload · resume | none | — | — | persist per-part state; auto-resume on reconnect | New — §9.6 |
| Upload · retry | none | — | — | part-level exponential backoff, capped | New — §9.7 |
| Upload · checksum | none | — | — | verify per part; complete only when all parts confirmed | New — §9.5 |
| Upload · cancellation | cancels timer only | design shows Cancel button | — | must call `AbortMultipartUpload` on server | New — §9.8 |
| Upload · queue persistence | none | — | — | survive app kill mid-batch | New — Drift or Hive table; §9.9 |
| Tab · Common Events | dummy | Design §2 | `GET /common-events` | — | New `CommonEventsRepository` |
| Tab · Recent | dummy | Design §2 | not in doc | — | Decision needed (§7.9) |
| SessionStore.user.id | present | — | Required for `POST /comments`, `POST /comments/{id}/reply`, `DELETE /comments/{id}` | — | Read via `ref.read(sessionStoreProvider).user?.id` in `CommentsNotifier` |
| `share_plus` / `url_launcher` deps | neither on pubspec; `open_file` present | Design §4.5 + external-open rule (§4.9) | file share = signed URL → share sheet; open/download = external URL | — | Add `share_plus`, `url_launcher`; **remove `open_file`** |

Legend: ✓ = matches, no work. Everything else appears in the FM7-FM9
task lists (§10 rollout).

---

## 9. Upload Implementation Spec (multipart / background / resume)

Cross-reference: `FLUTTER_UPLOAD_CONSTRAINTS.md` sections. This section
translates each rule into a Flutter task; §10 rollout schedules them.

### 9.1 Storage backend confirmation (blocker)

`FLUTTER_UPLOAD_CONSTRAINTS.md` §Architecture says **AWS S3 multipart**.
API doc's signed URLs are **GCS** (`storage.googleapis.com`,
`X-Goog-Signature`). GCS supports resumable uploads and XML-API
multipart, but the presign response shape and the "complete / abort"
endpoints differ from S3.

Before FM8.01, confirm with backend:

- Is the bucket S3 or GCS?
- Which upload protocol does `/upload-policies/batch` presign — S3
  multipart (`CreateMultipartUpload` + `UploadPart` + `CompleteMulti…`),
  GCS resumable (single session URI, `Content-Range` chunked PUT), or
  GCS XML multipart?
- Does the client call the object-store directly for
  `CompleteMultipartUpload` / `AbortMultipartUpload`, or does BEIGE
  proxy those via `/files-uploaded/batch` and (new)
  `/upload-policies/abort`?

Answer drives §9.3-§9.8. Rest of this section assumes the **canonical
S3 multipart** flow; if GCS resumable, swap "one presign per part" for
"one session URI, chunked PUT with `Content-Range`" — everything else
(state machine, persistence, retries, background) stays.

### 9.2 Batch validation gate

Pre-queue, before **any** network call:

1. Collect picker output → `List<PickedFile>` with `{ name, sizeBytes,
   mimeType, localPath }`.
2. Sum sizes; count files.
3. Reject batch if `sum > 5 GB` **or** `count > 50` — do not partially
   accept.
4. MIME allowlist check (image/*, video/*, application/pdf,
   application/msword, docx, xlsx, pptx — confirm with product). Reject
   with per-file surface.
5. "Upload" button stays disabled until validation completes — no race
   window.

Existing `fm_upload_sheet` covers 1-3; add 4 + wire 5 to a
`validationCompleted` bool.

### 9.3 Per-file state machine

```
queued → uploading → (paused | complete | failed)
paused → uploading (on reconnect / user resume)
```

Batch has **no** batch-wide bool. Batch progress = derived
`(fileStates.count(complete)) / total`.

Domain:

```dart
enum UploadFileStatus { queued, uploading, paused, complete, failed }

class UploadFileState {
  final String batchId;
  final String fileId;               // client uuid
  final String localPath;
  final String filepath;             // remote destination (§4.1)
  final String mimeType;
  final int sizeBytes;
  final String? multipartUploadId;   // S3 uploadId, null pre-init
  final List<UploadPartState> parts; // one entry per 8-16 MB slice
  final UploadFileStatus status;
  final int retryCountForCurrentPart;
  final String? errorMessage;
}

class UploadPartState {
  final int partNumber;              // 1-indexed
  final int offset;
  final int lengthBytes;
  final String? etag;                // S3 returns per completed part
  final String? checksum;            // sha256 or md5 of the slice
  final bool completed;
}
```

### 9.4 Background transfer

Use `background_downloader` (`^8.x`) — one package that wraps iOS
`URLSession` background configuration and Android
`WorkManager`/`ForegroundService`. Configure:

- **Uploads** as `UploadTask` with `httpMethod: PUT`, per-part payload
  streamed via `TaskFile` (no in-memory load).
- **Requires Wi-Fi** flag = `!cellularOverride && sizeBytes > 50 MB`.
- Task ID = `${batchId}:${fileId}:${partNumber}` — stable across app
  restarts.
- Task group = batchId — enables per-batch cancellation.

Callbacks fire on `TaskUpdate` stream even when the app is
backgrounded, so completion / progress lands in the persistence layer
without needing the sheet to be alive.

### 9.5 Chunking + checksum

- Fixed part size = **8 MB** (min GCS/S3 part = 5 MB, 8 MB gives clean
  binary alignment).
- Reading: `RandomAccessFile.setPosition(offset)` +
  `read(chunkSize)` inside a compute isolate (`compute()` or a
  long-lived `Isolate` per batch). **Never** load the full file.
- Per-part checksum (sha256) computed alongside the read. Sent as
  `x-amz-checksum-sha256` header (S3) or verified locally against the
  ETag returned by GCS. Only mark `UploadPartState.completed = true`
  after checksum matches.
- `CompleteMultipartUpload` (or GCS equivalent) only fires when
  **every** part for that file is `completed`.

### 9.6 Persistence

Store the full batch queue + per-part progress in a local DB. Options:

- **Drift** (preferred — existing patterns; strongly typed; migration
  story).
- **Hive** (lighter; sufficient if no complex queries).

Tables:

- `upload_batches { id, createdAt, totalBytes, totalFiles, cellularOverride }`
- `upload_files { batchId, fileId, filepath, localPath, mimeType, sizeBytes, multipartUploadId, status, errorMessage }`
- `upload_parts { batchId, fileId, partNumber, offset, lengthBytes, etag, checksum, completed }`

On app launch: `uploadNotifier.rehydrate()` reads any batch with
non-terminal files, re-queues incomplete parts via
`background_downloader`.

Batch is "complete" only when every `upload_files.status = complete`.
No optimistic marking.

### 9.7 Retry policy

- Exponential backoff on part failure: `1s, 2s, 4s, 8s, 16s`,
  cap at 5 attempts per part.
- Attempt counter lives on `UploadFileState.retryCountForCurrentPart`
  (resets on part success).
- File → `failed` after part exhausts retries. Other files in the
  batch continue.
- Failed files surface individually in the queue (badge on the queue
  row + a "Retry" affordance). Never collapse into "batch failed".

### 9.8 Cancellation

- User taps × on a queued item → remove from batch (persistence
  cleared, presign discarded).
- User taps Cancel while uploading → for each file in the batch:
  1. Cancel outstanding `background_downloader` tasks (task-group id).
  2. Call `POST /upload-policies/abort` (new endpoint — confirm with
     backend; if missing, hit S3's `DELETE ?uploadId=` /
     GCS's `DELETE` on the resumable session URI directly).
  3. Delete the persisted rows.
- App-kill mid-batch does **not** abort — bucket lifecycle policy
  (backend infra) auto-aborts after 3 days per constraints doc.

### 9.9 Connectivity handling

- `connectivity_plus` provides the reachability stream.
- On loss: every `uploading` file → `paused`;
  `background_downloader.pauseAll(group: batchId)`.
- On reconnect + (Wi-Fi OR `cellularOverride`): resume paused files
  from the last completed part.
- No silent failure; no forced user restart.

### 9.10 UI surface impact

`fm_upload_sheet` already shows counters, per-item trash, and the
Wi-Fi warning. Additions:

- Per-item badge: `Queued | Uploading NN% | Paused | Failed | ✓`.
- Retry button on Failed rows.
- Sheet **dismisses without cancelling** — the notifier owns the batch;
  the sheet is a viewport. A persistent bottom bar (`FmUploadStatusBar`,
  new widget) surfaces active batch progress on any screen after
  dismiss (Design §5.14).
- Bar tap → re-open the sheet on the same batch.

### 9.11 New / renamed endpoints (subject to §9.1 confirmation)

- `POST /external-file-manager/upload-policies/batch` — presign (already
  in catalog). Response fields need lockdown (§8 Q1).
- `POST /external-file-manager/upload-policies/abort` — **not in doc**;
  needed for §9.8. If backend doesn't expose it, client hits the
  object-store abort URL directly (requires per-part-URL signing).
- `POST /external-file-manager/files-uploaded/batch` — confirm (already
  in catalog).

---

## 10. Phased Rollout

Status legend: ✅ shipped · 🟡 partial · ⏳ pending · 🚧 blocked on §11.

**Phase FM7 — Core browse + open + preview + kebab** — ✅ **implementation-complete (6/6; remote activation pending)**

| # | Status | Task | Touches (current files) |
|---|:-:|------|--------------------------|
| 7.01 | ✅ | DTOs + `FmPath` helper + `FmPhase` enum + `FmFolderKey` | new `data/dtos/`, `data/util/`, `domain/models/` |
| 7.02 | ✅ | `WorkspacesRepository` remote (endpoints 1, 20b) + provider swap; `fileManagerRootNotifierProvider` reads from new repo; Recent tab decision (§7.9) | `presentation/providers/file_manager_root_notifier.dart` |
| 7.03 | ✅ | `FolderBrowseRepository` remote (endpoints 2, 3, 5); migrate `folderContentsNotifierProvider` from `String folderId` → `FmFolderKey` | `presentation/providers/folder_contents_notifier.dart`, `presentation/screens/folder_contents_screen.dart`, `presentation/routes/file_manager_args.dart`, `presentation/routes/file_manager_routes.dart` |
| 7.04 | ✅ | `FileOpsRepository.viewUrl / downloadUrl / folderDownloadUrl / delete`; rewire `NodeActionNotifier` — `.download` → `launchUrl(externalApplication)`, `.share` → `share_plus.shareUri`, drop `open_file` + temp write (§4.9) | `presentation/providers/node_action_notifier.dart`, `pubspec.yaml` |
| 7.05 | ✅ | Preview Sheet: strip inline media block; add "Open in Player/Viewer" tap-through → external open. Folder kebab gains Download (folder-download-url) | `presentation/widgets/fm_file_preview_sheet.dart`, `presentation/widgets/fm_actions_sheet.dart` |
| 7.06 | ✅ | Widget tests updated for `FmFolderKey`; goldens re-baselined; `share_plus` added, `open_file` retained (still used by `common_file_viewer.dart` — remove decoupled from FM7) | `test/features/file_manager/**`, `pubspec.yaml` |

**Phase FM8 — Uploads + Edits workflow** — 🟡 **partial (3/10 complete, 7 blocked on §11 Q0)**

| # | Status | Task | Touches (current files) |
|---|:-:|------|--------------------------|
| 8.01 | 🚧 | §9.1 confirm backend; add abort endpoint if needed | doc + backend |
| 8.02 | ✅ | Real picker: `image_picker.pickMultipleMedia` (photos+video) + `FilePicker.pickFiles(type: custom)` (docs); MIME allowlist gate (§9.2) | `presentation/widgets/fm_upload_sheet.dart` |
| 8.03 | 🚧 | Persistence tables + `uploadNotifier(FmFolderKey)` state machine (§9.3, §9.6) — blocked on 8.01 | new `data/upload/`, `presentation/providers/upload_notifier.dart` |
| 8.04 | 🚧 | Presign + chunked multipart PUT via `background_downloader` (§9.4-§9.5) — blocked on 8.01 | new `data/upload/multipart_uploader.dart` |
| 8.05 | 🚧 | Retry + connectivity pause/resume (§9.7, §9.9) — blocked on 8.04 | `data/upload/multipart_uploader.dart` |
| 8.06 | 🚧 | Cancellation + abort call (§9.8) — blocked on 8.01 abort semantics | `presentation/widgets/fm_upload_sheet.dart` |
| 8.07 | 🚧 | Confirm-uploaded batch + folder invalidation on complete — blocked on 8.04 | `data/upload/multipart_uploader.dart`, `presentation/providers/folder_browse_provider.dart` |
| 8.08 | 🚧 | Persistent `FmUploadStatusBar` widget (survive sheet dismiss) — blocked on 8.03 | new `presentation/widgets/fm_upload_status_bar.dart`, shell mount |
| 8.09 | ✅ | `FileOpsRepository.copyFiles` + Send-For-Edits: `_onRequestEdits` maps selected file ids → filepaths → `POST /copy-files` → invalidates folder → success screen | `presentation/screens/folder_contents_screen.dart`, `domain/repositories/file_ops_repository.dart`, `data/**` |
| 8.10 | ✅ | `FileOpsRepository.reviewRevision`; Preview Sheet Review chooser (Approve / Request Revision) → `POST /revision-file/review`; Revisions folder CTA now labels "Create Folder" → next `Version{N+1}` via `FolderBrowseRepository.createFolder` | `presentation/widgets/fm_file_preview_sheet.dart`, `presentation/screens/folder_contents_screen.dart`, `domain/repositories/file_ops_repository.dart`, `data/**` |

Upload sheet still calls the deprecated `FileManagerRepository.uploadFiles`
(dummy adapter's in-memory save) on tap. Real multipart wiring waits on
§11 Q0 backend answer.

**Phase FM9 — Comments + Sharing + Common Events** — 🟡 **partial (1/4 complete, 1 partial)**

| # | Status | Task | Touches (current files) |
|---|:-:|------|--------------------------|
| 9.01 | ✅ | `CommentsRepository` (domain + remote + dummy) + `CommentsRemoteSource` + `commentsNotifierProvider(fileMetaId)` (AutoDisposeAsyncNotifier family) with post / reply / delete; preview sheet swapped from local `_comments` to notifier state (loading / error / empty / thread with nested replies) | `domain/repositories/comments_repository.dart`, `data/sources/comments_remote_source.dart`, `data/repositories/comments_repository_{remote,dummy}.dart`, `presentation/providers/comments_{notifier,repository_provider}.dart`, `presentation/widgets/fm_file_preview_sheet.dart` |
| 9.02 | 🟡 | Common Events root-tab list already wired in 7.02 (via `WorkspacesRepository.listCommonEvents`). Still to do: `CommonEventsRepository.createCreatorFolder` + CTA inside a common event | `presentation/screens/file_manager_screen.dart` |
| 9.03 | ⏳ | `/share` create + get + revoke — in-app share manager screen | new screen |
| 9.04 | ⏳ | External share OTP flow (public route surface) | new — separate Dio instance |

Public share endpoints (17-19) require an unauthenticated Dio instance
scoped to the share JWT — deferred to FM9.04 with its own DI branch.

### 10.1 Implementation Snapshot (audited 2026-07-15)

**Shipped, running on the dummy repo + wire-shaped for the remote flip:**

- Whole browse surface: workspaces list, workspace detail, folder listings (all phases + arbitrary paths), Common Events tab.
- Path-addressed kebab: Open · Share · Download · Delete for both files and folders — all via signed URL + OS handoff (`url_launcher` + `share_plus`).
- File Preview Sheet: metadata + version tag + status pill + Review chooser (Approve / Request Revision) + Download + Share + tap-through "Open in Player/Viewer".
- Comments (FM9.01): `CommentsRepository` (remote + dummy) + `commentsNotifierProvider(fileMetaId)` — post / reply / delete flow with nested-reply rendering, loading + error + empty states, session-user id sourced from `SessionStore`.
- Send-For-Edits: multi-select in Raw Footage → `POST /copy-files` → success screen.
- Revisions folder: "Create Folder" CTA computes next `Version{N+1}` and calls `POST /folder`.
- Real picker with 5 GB / 50-file / MIME allowlist validation.

**Not shipped (blocked or later phase):**

- Real multipart upload (§9 spec) — blocked on §11 Q0.
- Persistence + background survival + retry + abort (§9.6-§9.9).
- In-app share manager + external share JWT flow (`FM9.03-9.04`).
- Common-event creator-folder CTA (`FM9.02` remainder).

**Toolbelt state:**

- Repo flip flag `useDummyFileManagerProvider` still defaults to `true`. Every real repo (`Workspaces`, `FolderBrowse`, `FileOps`, `Comments`) already has a Dio impl behind the same flag — production flip is a single `false`.
- Legacy `FileManagerRepository` facade retained under `@Deprecated('Removed in FM8')`; only surviving caller is `FmUploadSheet` dummy save. Delete once FM8.04 lands.
- Verification: `flutter test test/features/file_manager/` passes **23/23**
  unit/widget tests (adds 6 for `CommentsNotifier`);
  `flutter test test/golden/file_manager_test.dart` passes **5/5** goldens;
  `flutter analyze lib/features/file_manager` reports no issues.

---

## 11. Open Questions (remaining backend confirmations)

0. **Storage backend** (blocks FM8) — S3 vs GCS; multipart flavour; whether
   client hits the object-store directly for `Complete` / `Abort` or
   BEIGE proxies. See §9.1.
1. **Upload presign response shape** — `uploadUrl`, `method`, `headers`,
   `expiresAt` field names. Once confirmed, remove the "Verify" note in
   §3.7.
2. **File node response** — the doc only shows folder responses with
   `files: []`. Need one live response containing files to lock down
   `FileNodeDto` (§3.5). Curl to run:
   `GET /external-file-manager/workspace/1273/files?phase=post&path=Raw%20Footage`.
3. **`fileMetaId` for comments** — is it the file's `filepath` or the
   opaque `id`? Doc uses `filepath`-shaped strings but backend may
   normalise. Curl: `POST /comments` with a known file, then
   `GET /comments?metaId=…` twice (once with each) and see which returns.
4. **`bookingId` vs `externalId` on `POST /folder`** — endpoint 5 uses
   `bookingId`, endpoint 12 uses `externalId`. Backend should pick one;
   we'll support both in the source until they align.
5. **`isCommonEvent` tab filter** — Common Events tab: is it a client-side
   filter on `/workspaces` (`isCommonEvent == true`) or does
   `/common-events` return the same items in a different envelope?
   Currently doc suggests both work. Decision: use `/common-events` for
   the tab (it returns event-native metadata: `visibleUntil`,
   `createdByUserId`).
6. **File-node `status` values** — enum table §4.4 is inferred from the
   design pills; need the backend's full list.
7. **Signed URL expiry field** — `expiresIn` seconds or `expiresAt` ISO?
   Doc doesn't show. Verify.
8. **Recent tab** — API doc has no `recent` filter. Confirm whether to
   drop `FmTab.recent` or back it client-side via `updatedAt` sort of
   `/workspaces` (§7.9).
9. **`FmTab.linked` filter** — is "Linked Files" the `isCommonEvent ==
   false` subset of `/workspaces`, or a separate flag / endpoint?

Answering these unlocks freezing DTO field names — everything else in
this plan is grammar-stable.

---

## 12. File Layout

New:

```
lib/features/file_manager/
├── data/
│   ├── dtos/
│   │   ├── fm_envelope_dto.dart
│   │   ├── fm_workspace_dto.dart
│   │   ├── fm_workspace_detail_dto.dart
│   │   ├── fm_folder_contents_dto.dart
│   │   ├── fm_folder_node_dto.dart
│   │   ├── fm_file_node_dto.dart              (extend existing)
│   │   ├── fm_folder_created_dto.dart
│   │   ├── fm_signed_url_dto.dart
│   │   ├── fm_delete_result_dto.dart
│   │   ├── fm_copy_result_dto.dart
│   │   ├── fm_revision_result_dto.dart
│   │   ├── fm_upload_policy_dto.dart
│   │   ├── fm_comment_dto.dart
│   │   └── fm_common_event_dto.dart
│   ├── sources/
│   │   ├── workspaces_remote_source.dart
│   │   ├── folder_browse_remote_source.dart
│   │   ├── file_ops_remote_source.dart
│   │   ├── comments_remote_source.dart
│   │   └── common_events_remote_source.dart
│   ├── repositories/
│   │   ├── workspaces_repository_remote.dart
│   │   ├── folder_browse_repository_remote.dart
│   │   ├── file_ops_repository_remote.dart
│   │   ├── comments_repository_remote.dart
│   │   └── common_events_repository_remote.dart
│   └── util/
│       └── fm_path.dart
├── domain/
│   ├── models/
│   │   ├── fm_phase.dart
│   │   ├── fm_folder_key.dart
│   │   ├── fm_workspace_meta.dart
│   │   ├── fm_folder_contents.dart
│   │   ├── fm_signed_url.dart
│   │   ├── fm_upload_item.dart
│   │   ├── fm_upload_policy.dart
│   │   ├── fm_revision_action.dart
│   │   ├── fm_revision_result.dart
│   │   ├── fm_copy_result.dart
│   │   ├── fm_delete_result.dart
│   │   ├── fm_comment.dart
│   │   └── fm_common_event.dart
│   └── repositories/
│       ├── workspaces_repository.dart
│       ├── folder_browse_repository.dart
│       ├── file_ops_repository.dart
│       ├── comments_repository.dart
│       └── common_events_repository.dart
└── presentation/
    ├── providers/
    │   ├── workspaces_provider.dart
    │   ├── folder_browse_provider.dart
    │   ├── file_ops_provider.dart
    │   ├── comments_provider.dart
    │   ├── common_events_provider.dart
    │   └── upload_notifier.dart
    └── (existing screens/widgets keep names; internals rewired)
```

Modified:
- `lib/core/network/api_endpoints.dart` — replace FM stubs (§5.4).
- `lib/features/file_manager/domain/models/fm_file.dart` — add `filepath`.
- `lib/features/file_manager/domain/models/fm_folder.dart` — add
  `workspaceMeta` (nullable; non-root folders leave it null).
- `presentation/providers/folder_contents_notifier.dart` — key becomes
  `FmFolderKey`.

Deleted after FM7.03 stable:
- The current facade `FileManagerRepository` (once presentation callers
  migrate to the four new contracts).

---

## 13. Testing Notes

- Every remote source ships with a golden fixture file under
  `test/features/file_manager/data/fixtures/` — one JSON per endpoint,
  copied from the doc's screenshots. `..._remote_source_test.dart`
  parses fixture → asserts `toDomain` mapping.
- `FileNodeDto` fixture stays flagged pending live curl (§8 Q2). The
  test currently locks the folder-only shape.
- Widget tests: `FmFolderKey` is `const`-constructible; migrate existing
  test helpers (`test/features/file_manager/presentation/…`) to pass
  `FmFolderKey(externalId: '1', phase: FmPhase.post, path: 'Edits')`
  instead of the current `folderId: 'edits-1'`.
- Integration test candidate (`integration_test/`): browse root → open
  workspace → open Post → open Raw Footage → send-for-edits (fake
  backend). Deferred to FM8.05 once the flow is code-complete.
