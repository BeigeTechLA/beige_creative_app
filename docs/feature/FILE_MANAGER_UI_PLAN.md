# File Manager Module — UI Plan

**Status:** FM1–FM6 complete (2026-06-26) — dummy repo wired by default; remote arm built but flag stays `true` until backend confirms endpoints.
**Owner:** Mobile (crew app)
**Scope:** Fresh design — discards current `file_manager` code. UI first w/ dummy data; API wires in FM6.
**Reference design:** `File manager UI.png` (3 surfaces — root listing, folder details, file listing; plus bottom-sheet actions and Linked / Unlinked chip components)

> Treat this UI as fully **API-driven and recursive**. A folder can hold folders or files at any depth. Same widgets render every level. No hard-coded "Pre Production" / "Post Production" rows — those are just example payloads.

> **Legacy override:** Any pre-existing file-manager code, screens, widgets, routes, providers, models, or design assets under `lib/features/file_manager/**` (and any related shared widgets named `file_*` / `folder_*` outside the feature) is treated as **deprecated**. Execution starts from a clean slate — old files are **deleted in FM1.00** before any new file lands. Do **not** preserve, extend, or wrap legacy widgets. If a legacy route name (`fileManager`, etc.) already exists in `Routes`, repoint it to the new screen rather than keeping both. Only the bottom-nav entry and the existing `common_file_viewer.dart` (shared, not feature-owned) survive.

---

## 0. Status Tracking

| Phase | Status | Notes |
|---|---|---|
| FM1 — Foundation | ✅ Complete (2026-06-26) | Legacy purge (12 src + 2 test files dropped, 3 stale route specs removed). Sealed `FmNode` library w/ `part`-of `FmFolder`/`FmFile`. Enums (`FileType` w/ `fromApi`+`fromExtension`, `FmTab`, `LinkState`). `FmLinkedProject`, `FmPage<T>`. Dummy tree (4 roots, Lana branch 3 levels deep, mixed pdf/doc/image/video). Dummy repo (300ms latency, offset cursor, tab filter incl. `commonEvents` → empty). Repo provider + flag. Nested routes + placeholder screens. Router 16/16 green. |
| FM2 — Root listing | ✅ Complete (2026-06-26) | `fileManagerRootNotifier` (`load`/`loadMore`/`refresh`/`selectTab`/`setSearchQuery`). `FileManagerScreen` real shell. `FmTabBar` (4 pills, gold gradient, scale-clamped). `FmSearchField`, `FmFolderCard`, `FmRecursiveList` (sealed `switch`, `NotificationListener` infinite scroll, refresh wrapper, footer spinner). `FmEmptyView` (root/search/folder), `FmErrorView`. |
| FM3 — Folder details (recursive) | ✅ Complete (2026-06-26) | `folderContentsNotifier` (`AutoDisposeFamilyNotifier<…, String>`). `FolderContentsScreen` real. `FmFileCard` (icon header + 16:10 preview block + footer). `FmProjectBadgeCard` (L#1 thumb + project code; renders only when `linkedProject != null`). `state.extra` carries `title` + `linkedProject`. Recursion proven via fresh push per child. |
| FM4 — File preview + actions sheet | ✅ Complete (2026-06-26) | `nodeActionNotifier` (per-id sharingIds/deletingIds/downloadProgress, `lastSignal`). `showFmActionsSheet(kind)` w/ folder (Open/Share/Delete) + file (Open/Share/Download/Delete) variants. `showFmDeleteConfirmDialog`. `ref.listen` on `lastSignal` → `TopMessage`. Delete invalidates relevant notifier. File tap → `CommonFileViewer.open` inline. |
| FM5 — Search, empty / error, polish | ✅ Complete (2026-06-26) | Search filter (FM5.01) already wired in FM2/FM3 via `visibleItems` selector. Scale clamp on `FmTabBar` (1.0..1.2). 11 tests: 4 root-notifier, 1 folder-notifier, 3 node-action, 4 screen widget. 5 goldens (`fm_chip_badge`, `fm_folder_card_tagged`/`_plain`, `fm_file_card_pdf`/`_video`). All green. |
| FM6 — API integration | ✅ Complete w/ deviation (2026-06-26) | DTOs w/ `kind` discriminator (`FmNodeDto`). `Env.imageUrl` resolves relative URLs. `FmPageDto` accepts envelope OR raw list. `FileManagerRemoteSource` (5 methods, `_guard` → `mapDioException`, envelope unwrap, Dart 3.10 null-aware map entries). `FileManagerRepositoryRemote` pass-through. Provider remote arm wired. **Flag default stays `true`** — backend endpoints unconfirmed; flip is one-line change once API contract lands. |

---

## 1. Information Architecture

### 1.1 Surfaces

```
┌─ File Manager (tab) ─────────────────────────────┐
│  Toolbar (drawer + "File Manager" title)         │
│  ┌──────── Search Folder… ────────────┐          │
│  Tab bar: [All Files] Recent  Linked  Common…    │
│  ─────────────────────────────────────           │
│  FmFolderCard (root folder)                      │  ← tap → FolderContentsScreen(folderId)
│  FmFolderCard                                    │
│  FmFolderCard                                    │
│   …                                               │
│  Bottom nav (Dashboard / Shoots / FileManager*)  │
└──────────────────────────────────────────────────┘

┌─ Folder Contents (push) ─────────────────────────┐
│  Toolbar (back + folder name centered)           │
│  Search field (client-side filter)               │
│  [Optional] FmProjectBadgeCard (linked shoot)    │  ← only when folder has `linkedProject`
│  FmFolderCard | FmFileCard | FmFolderCard | …    │  ← order = server order
└──────────────────────────────────────────────────┘
```

### 1.2 Recursion

Every level after root pushes another `FolderContentsScreen(folderId: child.id, title: child.name)`. No depth limit. The screen is **stateless about depth** — it asks the family provider for the children of `folderId` and renders.

### 1.3 Bottom-nav placement

The existing crew app tab "File Manager" routes to `FileManagerScreen` (root). `FolderContentsScreen` is a stacked route on top of that tab.

---

## 2. Widget Decomposition

All widgets live in `lib/features/file_manager/presentation/widgets/`. None of these contain layout assumptions about depth — they only render their input model.

| Widget | Reused at | Responsibility |
|---|---|---|
| `FmSearchField` | Root + folder details | Themed search input. Owns `TextEditingController`; emits `onChanged(String)`. |
| `FmTabBar` | Root only | Pill bar — `All Files` / `Recent` / `Linked` / `Common Events`. `goldHorizontalGradient` active state matching `MeetingsTabBar`. |
| `FmFolderCard` | Every level | Folder icon + name (1 line ellipsis) + `02 Files` count, optional `FmTagChip`, optional `FmLinkedBadge`, trailing `⋮`, footer meta (`Opened 2 hours ago`). Whole card tappable. |
| `FmFileCard` | Folder details only | Header row (file-type icon + name + `⋮`), preview block (large file-type icon centered on muted surface), footer meta. Whole card tappable → file viewer. |
| `FmProjectBadgeCard` | Folder details (conditional) | The `L#1 Corporate_Lana_#123456 / Project Code: 3926` row — small thumb (project / shoot name initials or image) + title + project code. Driven by `folder.linkedProject`; hidden when null. |
| `FmTagChip` | `FmFolderCard` | Outline chip, e.g. `Corporate Event`. Data-driven `label`. |
| `FmLinkedBadge` | `FmFolderCard` | Pill — variants: `Linked` (success bg) / `Unlinked` (warning bg). Driven by `LinkState` enum. **Hidden** when backend doesn't yet expose link state (see §7 open question). |
| `FmFileTypeIcon` | `FmFileCard` + actions sheet preview | Color-coded square icon for `pdf` / `doc` / `image` / `video` / `sheet` / `zip` / `other`. Single source of truth for type → icon + tint. |
| `FmActionsSheet` | Folder + file long-press / `⋮` | Bottom sheet: `Open`, `Share`, `Download`, `Delete` (destructive). Variant for folder hides `Download`. Built with the existing `bottomSheetTheme`. |
| `FmDeleteConfirmDialog` | `FmActionsSheet` Delete | Standard destructive dialog (Cancel / Delete). |
| `FmRecursiveList` | Root + folder details | `RefreshIndicator` + `ListView.separated` + infinite-scroll trigger. Takes `List<FmNode>` + branches to `FmFolderCard` / `FmFileCard`. |
| `FmEmptyView` | Both screens | Wraps `AppEmptyState` with file-manager-specific copy per context (no folders / no files / no search results). |
| `FmErrorView` | Both screens | Icon + message + `Retry` `AppButton` (matches meetings pattern). |

### 2.1 Reuse from existing shared widgets

- `AppMainToolbar` for both screens (root uses drawer button; details uses back).
- `AppTextField` (or its themed variant) backs `FmSearchField`.
- `AppButton` for retry / delete confirm.
- `AppCard` is **not** reused — file-manager cards have a distinct internal layout; building dedicated cards avoids prop-bloat.
- `AppEmptyState`, `AppLoader`, existing `common_file_viewer.dart` for the file preview screen.

---

## 3. Domain Models

`lib/features/file_manager/domain/models/`

```dart
// fm_tab.dart
enum FmTab { all, recent, linked, commonEvents }
extension FmTabLabel on FmTab { String get label => switch (this) { ... }; String get apiValue => switch (this) { ... }; }

// file_type.dart
enum FileType { pdf, doc, sheet, image, video, audio, zip, other }
extension FileTypeFrom on FileType { static FileType fromExt(String ext) { ... } }

// link_state.dart
enum LinkState { linked, unlinked }

// fm_node.dart  (sealed)
sealed class FmNode {
  final String id;
  final String name;
  final DateTime? openedAt;   // last-opened — drives the "Opened 2 hours ago" line
  const FmNode({required this.id, required this.name, this.openedAt});
}

class FmFolder extends FmNode {
  final int fileCount;             // includes nested files; backend computes
  final String? tagLabel;          // e.g. "Corporate Event"
  final LinkState? linkState;      // null = don't render badge
  final FmLinkedProject? linkedProject;
  const FmFolder({ ... });
}

class FmFile extends FmNode {
  final FileType type;
  final int sizeBytes;
  final String downloadUrl;        // absolute (use Env.imageUrl for relative)
  final String? previewUrl;        // optional remote thumbnail; ignored in FM4 (icon-only)
  const FmFile({ ... });
}

// fm_linked_project.dart
class FmLinkedProject {
  final String id;
  final String displayName;        // "Corporate_Lana_#123456"
  final String? projectCode;       // "3926"
  final String? thumbnailUrl;      // tiny project thumb for FmProjectBadgeCard
  final String? badgeLabel;        // "L#1"
}

// fm_page.dart
class FmPage<T> {
  final List<T> items;
  final String? nextCursor;        // null = end
  final int? total;                // optional, for header counts if backend returns
}
```

`FmNode` is **sealed** so the recursive list can pattern-match on `switch (node) { FmFolder() => ..., FmFile() => ... }` without runtime type checks.

---

## 4. Repository Contract

`lib/features/file_manager/domain/repositories/file_manager_repository.dart`

```dart
abstract class FileManagerRepository {
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  });

  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  });

  Future<String> getShareLink({required String nodeId, required FmNodeKind kind});
  Future<void> deleteNode({required String nodeId, required FmNodeKind kind});

  /// Returns local file path after streaming download; UI surfaces progress via callback.
  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  });
}

enum FmNodeKind { folder, file }
```

Two implementations live side by side, gated by `useDummyFileManagerProvider`:
- `FileManagerRepositoryDummy` — in-memory tree (FM1).
- `FileManagerRepositoryRemote` — Dio against the API (FM6).

---

## 5. State / Providers

`lib/features/file_manager/presentation/providers/`

| Provider | Type | Lifetime | Notes |
|---|---|---|---|
| `fileManagerRepositoryProvider` | `Provider<FileManagerRepository>` | App | Branches on `useDummyFileManagerProvider`. |
| `useDummyFileManagerProvider` | `StateProvider<bool>` | App | Default `true` in FM1–FM5; flipped in FM6. |
| `fileManagerRootNotifierProvider` | `AutoDisposeNotifier<FileManagerRootState>` | Root screen | Holds `tab`, `items`, `cursor`, `status`, `searchQuery`. Methods: `selectTab(FmTab)`, `refresh()`, `loadMore()`, `setSearchQuery(String)`. |
| `folderContentsNotifierProvider` | `AutoDisposeFamilyNotifier<FolderContentsState, String>` (folderId) | Per folder detail screen | Mirrors root notifier shape but for `List<FmNode>`. |
| `nodeActionNotifierProvider` | `AutoDisposeNotifier<NodeActionState>` | Per action sheet invocation | Tracks share / download / delete progress so the UI can show spinners and snackbars via `ref.listen`. |

State shapes:

```dart
class FileManagerRootState {
  final FmTab tab;
  final List<FmFolder> items;
  final String? cursor;
  final FmListStatus status;   // initial | loading | loaded | loadingMore | error | empty
  final String? errorMessage;
  final String searchQuery;    // client-side filter applied at the selector level
}

class FolderContentsState {
  final List<FmNode> items;
  final String? cursor;
  final FmListStatus status;
  final String? errorMessage;
  final String searchQuery;
}
```

Selectors expose `visibleItems` after `searchQuery` filtering so the notifier never mutates the raw page list (keeps `loadMore` deterministic).

UI side effects (snackbars, navigation, sheet pop) live in the widgets via `ref.listen` — matches the meetings pattern.

---

## 6. Routes

`lib/features/file_manager/presentation/routes/file_manager_routes.dart`

| Route name | Path | Builder |
|---|---|---|
| `fileManager` (existing tab) | `/file-manager` | `FileManagerScreen()` |
| `fileManagerFolder` | `/file-manager/folder/:id` | `FolderContentsScreen(folderId, title)` — title passed via `state.extra` `{ title: String, linkedProject?: FmLinkedProject }` so children render the breadcrumb without an extra fetch. |
| `fileManagerFileViewer` | `/file-manager/file/:id` | Reuses existing `common_file_viewer.dart` viewer; `state.extra = { file: FmFile }`. |

All navigation via `context.pushNamed` / `context.goNamed`. No raw `Navigator.push`.

---

## 7. Open Questions / Deviations to Confirm Before FM2

1. **`Linked` / `Unlinked` badge gating** — confirmed from product: backend does not yet flag link state reliably. Plan: read `linkState` from API response when present; otherwise hide `FmLinkedBadge`. `FmTagChip` (`Corporate Event`) is independent and always rendered when present.
2. **`L#1` project badge** — confirmed it represents the linked shoot / project thumbnail. `FmLinkedProject.badgeLabel` (`L#1`, `L#2`, …) is server-driven; if absent, render initials of `displayName`.
3. **Common Events tab** — server-side filter. UI ships the tab in FM2; if backend returns 4xx for `tab=common_events`, surface a friendly empty state and log a Crashlytics breadcrumb (does not block release).
4. **Sort order inside a folder** — assume backend returns the correct order (folders first or mixed by `updatedAt`). UI does not re-sort.
5. **Delete permissions** — assume the API rejects with 403 when the user lacks permission; we render that via the standard error snackbar. No client-side role gating in this phase.
6. **Download destination** — files save to the app sandbox + are surfaced via `share_plus` "open with" so the user can hand them to another app. No public Downloads write yet (avoids per-platform permission churn).
7. **Pagination size** — start with `limit=20`. Tune after backend integration.

---

## 8. Backend API Contract (drafted last — confirm with BE)

> All endpoints are prefixed with `Env.apiUrl`. Auth via existing bearer-token interceptor. Responses use the existing `ApiResponse<T>` envelope (`{ success, data, message, meta }`).

### 8.1 List root folders

`GET /api/file-manager/root`

| Query | Type | Required | Notes |
|---|---|---|---|
| `tab` | `all` \| `recent` \| `linked` \| `common_events` | yes | Maps to `FmTab.apiValue`. |
| `q` | string | no | Reserved for future server-side search. Phase 1 leaves the param off. |
| `cursor` | string | no | Opaque. First page omits. |
| `limit` | int | no | Default 20. Max 50. |

Response:

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "fld_01",
        "name": "Corporate_Lana_#123456",
        "fileCount": 2,
        "tagLabel": "Corporate Event",
        "linkState": "linked",
        "linkedProject": {
          "id": "prj_42",
          "displayName": "Corporate_Lana_#123456",
          "projectCode": "3926",
          "thumbnailUrl": "https://…/thumb.png",
          "badgeLabel": "L#1"
        },
        "openedAt": "2026-06-26T10:21:00Z"
      }
    ],
    "nextCursor": "eyJvIjoyMH0=",
    "total": 134
  }
}
```

### 8.2 List folder contents (recursive — any depth)

`GET /api/file-manager/folders/:id`

Same query shape as 8.1 (no `tab`).

Response `items[]` is a **mixed array** of nodes; each item carries `"kind": "folder" | "file"` so the client deserializer can branch.

```json
{
  "items": [
    { "kind": "folder", "id": "fld_99", "name": "Pre Production", "fileCount": 2, "openedAt": "…" },
    { "kind": "file",   "id": "fil_12", "name": "Example.pdf", "type": "pdf",
      "sizeBytes": 184320, "downloadUrl": "https://…/example.pdf",
      "previewUrl": null, "openedAt": "…" }
  ],
  "nextCursor": null
}
```

### 8.3 Share

`POST /api/file-manager/share`

Body: `{ "nodeId": "fil_12", "kind": "file" }`

Response: `{ "shareUrl": "https://…/s/abc", "expiresAt": "…" }`

UI passes `shareUrl` to `share_plus` `Share.share(...)`.

### 8.4 Download

`GET /api/file-manager/files/:id/download` — streams binary. Repository pipes through Dio's `ResponseType.stream` and writes to `getTemporaryDirectory()`; UI subscribes to `onReceiveProgress`.

### 8.5 Delete

`DELETE /api/file-manager/folders/:id`
`DELETE /api/file-manager/files/:id`

Both return `{ "success": true }`. On success the screen invalidates the relevant notifier (`ref.invalidate(folderContentsNotifierProvider(folderId))` or root).

### 8.6 Error mapping

Handled centrally by the existing Dio `ErrorInterceptor` → `AppException`. Feature surfaces them via snackbars (one helper in `presentation/widgets/fm_error_snackbar.dart`).

---

## 9. File / Folder Layout

```
lib/features/file_manager/
├── data/
│   ├── dummy/
│   │   └── dummy_file_tree.dart          # recursive seed (≥ 3 levels, mixed types)
│   ├── dtos/
│   │   ├── fm_folder_dto.dart
│   │   ├── fm_file_dto.dart
│   │   ├── fm_node_dto.dart              # discriminator deserializer
│   │   └── fm_page_dto.dart
│   └── repositories/
│       ├── file_manager_repository_dummy.dart
│       └── file_manager_repository_remote.dart
├── domain/
│   ├── models/
│   │   ├── fm_node.dart                  # sealed
│   │   ├── fm_folder.dart
│   │   ├── fm_file.dart
│   │   ├── fm_linked_project.dart
│   │   ├── fm_page.dart
│   │   ├── fm_tab.dart
│   │   ├── file_type.dart
│   │   └── link_state.dart
│   └── repositories/
│       └── file_manager_repository.dart
└── presentation/
    ├── providers/
    │   ├── file_manager_repository_provider.dart
    │   ├── file_manager_root_state.dart
    │   ├── file_manager_root_notifier.dart
    │   ├── folder_contents_state.dart
    │   ├── folder_contents_notifier.dart
    │   └── node_action_notifier.dart
    ├── routes/
    │   └── file_manager_routes.dart
    ├── screens/
    │   ├── file_manager_screen.dart
    │   └── folder_contents_screen.dart
    └── widgets/
        ├── fm_search_field.dart
        ├── fm_tab_bar.dart
        ├── fm_folder_card.dart
        ├── fm_file_card.dart
        ├── fm_project_badge_card.dart
        ├── fm_tag_chip.dart
        ├── fm_linked_badge.dart
        ├── fm_file_type_icon.dart
        ├── fm_recursive_list.dart
        ├── fm_actions_sheet.dart
        ├── fm_delete_confirm_dialog.dart
        ├── fm_empty_view.dart
        └── fm_error_view.dart
```

> Legacy files under `lib/features/file_manager/` are deleted in **FM1.00** before any new file lands. No backwards-compat shims, no parallel old/new screens, no renamed wrappers. If a legacy widget had a behavior the new design dropped, that behavior is gone — re-add only if a confirmed product requirement.

---

## 10. Phase Task Breakdown

### FM1 — Foundation ✅

| Task | Status | Output |
|---|---|---|
| FM1.00 Legacy purge | ✅ | Deleted `lib/features/file_manager/**` (12 files) + `test/features/file_manager/**` (2 files). Removed `Routes.postProduction` / `preProduction` / `fileViewer`, `fileManagerRoutes` spread + `FileManagerScreen` import in `router.dart`. Bottom-nav repointed to `MenuPlaceholderScreen` until FM1.06. Analyze clean, router 16/16. |
| FM1.01 Enums + sealed `FmNode` | ✅ | 7 files under `domain/models/`. Sealed `FmNode` library w/ `part 'fm_folder.dart'` + `part 'fm_file.dart'` (subclasses must share library). `FmTab`, `FileType` (`fromApi`+`fromExtension`), `LinkState`, `FmLinkedProject`, `FmPage<T>`. |
| FM1.02 Repo contract | ✅ | `file_manager_repository.dart` — `listRoot`, `listFolder`, `getShareLink`, `deleteNode`, `downloadFile`. Imports only `fm_node.dart` (part-of files can't be imported directly). |
| FM1.03 Dummy tree | ✅ | `dummy_file_tree.dart` — `Map<String, List<FmNode>>` keyed by parent id. 4 roots, Lana branch 3 levels deep (`Pre Production → Creative Brief → Brief.pdf + Moodboard.jpg`), Post Production w/ MP4 + PDF, Aria + Zen + Drafts cover linked / unlinked / null badge states. |
| FM1.04 Dummy repo | ✅ | `file_manager_repository_dummy.dart` — 300ms latency, offset-string cursor, tab filter (`recent` sorts by `openedAt`; `linked` filters; `commonEvents` returns empty so empty branch exercises). `downloadFile` simulates 6 progress ticks; honors `CancelToken`. |
| FM1.05 Providers skeleton | ✅ | `file_manager_repository_provider.dart` w/ `useDummyFileManagerProvider` flag (default `true`). Remote arm throws `UnimplementedError` until FM6.02. |
| FM1.06 Routes + placeholders | ✅ | Added `Routes.filesFolder` (`/files/folder/:id`). Note: `filesFileViewer` was added then dropped in FM4 — files open inline. `FileManagerScreen` + `FolderContentsScreen` placeholders, `FolderContentsArgs` for `state.extra`. Router 16/16. |

### FM2 — Root listing ✅

| Task | Status | Output |
|---|---|---|
| FM2.01 `fileManagerRootNotifier` + state | ✅ | `FmListStatus` enum (`idle`/`loading`/`loadingMore`/`ready`/`error`). State w/ `tab`, `items`, `cursor`, `searchQuery`. `visibleItems` selector applies client filter w/o mutating `items`. Notifier methods: `loadMore`, `refresh`, `selectTab`, `setSearchQuery`. |
| FM2.02 `FileManagerScreen` shell | ✅ | `AppMainToolbar` + `FmSearchField` + `FmTabBar` + `Expanded` body. `ref.listen` on `nodeActionNotifierProvider.lastSignal` → `TopMessage`. |
| FM2.03 `FmTabBar` | ✅ | 4 pills (All / Recent / Linked / Common Events). Gold horizontal gradient when active, `AnimatedContainer` `fast250`. Wrapped in `MediaQuery` text-scaler clamp 1.0..1.2 (FM5.02). |
| FM2.04 `FmFolderCard` | ✅ | Folder icon + name (1-line ellipsis) + zero-padded file count + `Wrap` chip row (tag + linked badge, hidden when both null) + `⋮` + divider + footer (opened-ago). Whole card `InkWell` tappable. |
| FM2.05 `FmRecursiveList` + infinite scroll | ✅ | Sealed `switch (node)` → `FmFolderCard` / `FmFileCard`. `NotificationListener<ScrollNotification>` triggers `onLoadMore` within 240 px of end. `RefreshIndicator` wrapper. Footer spinner when `loadingMore`. |
| FM2.06 Loading / empty / error branches | ✅ | `_Body` switches on `status`. `FmEmptyView` w/ `.search` / `.folder` named variants. `FmErrorView` w/ retry `AppButton`. |

### FM3 — Folder details (recursive) ✅

| Task | Status | Output |
|---|---|---|
| FM3.01 `folderContentsNotifier` (family) | ✅ | `AutoDisposeFamilyNotifier<FolderContentsState, String>` keyed by `folderId`. State shape mirrors root minus `tab`. Reuses `FmListStatus`. |
| FM3.02 `FolderContentsScreen` | ✅ | `AppBar` w/ back + centered title. Search field + conditional `FmProjectBadgeCard` + `FmRecursiveList`. `FolderContentsArgs` parses `state.extra` for `title` + `linkedProject`. |
| FM3.03 `FmFileCard` | ✅ | Header row (small `FmFileTypeIcon` + name + `⋮`) + 16:10 preview block (large icon centered on `surfaceMid`) + divider + footer. |
| FM3.04 Navigation hop | ✅ | Tap on child folder calls `context.pushNamed(filesFolder, pathParameters: {id}, extra: {title, linkedProject})` — same screen instance pushes recursively; depth has no client-side cap. |

### FM4 — File preview + actions sheet ✅

| Task | Status | Output |
|---|---|---|
| FM4.00 Drop file viewer route | ✅ | Removed `Routes.filesFileViewer` + placeholder screen. `CommonFileViewer.open` is inline (image dialog / Dio download → `OpenFile`) — no in-app screen needed. |
| FM4.01 File tap → viewer | ✅ | `_openFile` in `FolderContentsScreen` calls `CommonFileViewer.open(context, filePath: file.downloadUrl)` directly. |
| FM4.02 `FmActionsSheet` | ✅ | `showFmActionsSheet(kind)` returns `FmNodeAction?`. Folder = Open / Share / Delete. File = Open / Share / Download / Delete. Destructive row uses `AppColors.error`. |
| FM4.03 `nodeActionNotifier` | ✅ | `NodeActionState` — `sharingIds`, `deletingIds`, `downloadProgress: Map<String, double>`, `lastSignal` (`FmActionSignal`). `share`/`download`/`delete` set + clear flight sets. `clearSignal` after UI consumes. |
| FM4.04 `FmDeleteConfirmDialog` | ✅ | `showFmDeleteConfirmDialog(title, message) → Future<bool?>`. Caller `invalidate`s the matching listing notifier on `true`. |
| FM4.05 Share + download wiring | ✅ w/ deviation | Share = `Clipboard.setData` + `TopMessage('Share link copied to clipboard')` — `share_plus` not in pubspec; matches existing `meeting_details_sheet.dart` link affordance. Download = repo (`onProgress` 0..1) → `OpenFile.open(localPath)` + success `TopMessage`. |

### FM5 — Polish + tests ✅

| Task | Status | Output |
|---|---|---|
| FM5.01 Client-side search filter | ✅ | Already shipped in FM2/FM3 via `visibleItems` selector on both states. `FmEmptyView.search` empty-results branch active when `searchQuery.trim().isNotEmpty` and `visibleItems.isEmpty`. |
| FM5.02 A11y + scale clamping on tabs | ✅ | `FmTabBar` wrapped in `MediaQuery` w/ `TextScaler.linear(textScaler.scale(1.0).clamp(1.0, 1.2))`. `Semantics(button, selected, label)` on each `_Pill`. |
| FM5.03 Widget tests | ✅ | 4 root-notifier tests (load + cursor, tab switch, search filter on visible w/o mutating raw, plus search edge case). 1 folder-notifier test (load + filter + clear). 3 actions-notifier tests (clipboard share, delete success, delete failure). 4 screen tests (root list, tab swap, empty search state, ⋮ → folder action sheet excludes Download). |
| FM5.04 Golden tests | ✅ | `test/golden/file_manager_test.dart` + 5 PNGs: `fm_chip_badge_dark`, `fm_folder_card_tagged_dark`, `fm_folder_card_plain_dark`, `fm_file_card_pdf_dark`, `fm_file_card_video_dark`. Each test sets its own viewport via `tester.view.physicalSize` (avoids 800×600 default overflow). |
| FM5.05 Analyze pass | ✅ | `flutter analyze --no-fatal-infos` clean across whole repo. 25/25 file-manager + router + golden tests green. |

### FM6 — API integration ✅ (w/ deviation)

| Task | Status | Output |
|---|---|---|
| FM6.01 DTOs + JSON discriminator | ✅ | 5 files under `data/dtos/`: `fm_folder_dto`, `fm_file_dto`, `fm_node_dto` (kind switch), `fm_page_dto` (envelope or raw list), `fm_linked_project_dto`. Relative URLs resolve via `Env.imageUrl`. `FmNodeDto.fromJson` throws on unknown `kind`; `FmPageDto` catches + drops the row so a single bad payload doesn't kill the page. |
| FM6.02a API endpoint constants | ✅ | `ApiEndpoints` got `fileManagerRoot`, `fileManagerFolder(id)`, `fileManagerFolderDelete(id)`, `fileManagerFileDelete(id)`, `fileManagerFileDownload(id)`, `fileManagerShare`. Paths follow §8 — adjust when backend confirms. |
| FM6.02b Remote source + impl | ✅ | `FileManagerRemoteSource` (Dio wrapper, `_guard` → `mapDioException`, `_unwrap` envelope, Dart 3.10 null-aware map entries `'cursor': ?cursor`). `FileManagerRepositoryRemote` = pure pass-through. |
| FM6.03 Flag flip | ⚠️ deferred | Remote arm wired in provider. **Flag default stays `true`** — backend endpoints not yet confirmed live. Flip is one-line change once API contract is verified end-to-end. Premature flip → 404 on every list. |
| FM6.04 Re-run goldens | ✅ | All 5 goldens still match after FM6 work (no widget changes). `flutter test --update-goldens` not re-run since no widget edits. |

---

## 11. Realized Deviations (FM1–FM6)

Sorted by phase. Capture only differences vs the original §10 plan — not generic decisions.

| # | Phase | Deviation | Reason |
|---|---|---|---|
| 1 | FM1.01 | `FmFolder` + `FmFile` declared as `part of 'fm_node.dart'` instead of standalone files. | Sealed class restriction — subclasses must share a library. Files stay split per §9 layout via `part`/`part of`. |
| 2 | FM1.06 → FM4.00 | `Routes.filesFileViewer` + `FileViewerScreen` were added in FM1.06 then deleted in FM4.00. | `CommonFileViewer.open` is inline — image dialog or `Dio.download` + `OpenFile.open`. No in-app screen needed. `Routes.all` net change vs original plan: +1 (folder only). |
| 3 | FM2.02 | `Routes.files` (not `Routes.fileManager`) is the bottom-nav spec. | Existing convention — every shell tab uses single-word names (`shoots`, `meetings`, `files`). Renaming would touch `app_shell.dart` + analytics + navigation history for no gain. |
| 4 | FM4.05 | Share = `Clipboard.setData` + `TopMessage`, not `share_plus` native sheet. | `share_plus` not yet in pubspec. Matches existing `meeting_details_sheet.dart` link affordance — no new dep. Swap to native share once product confirms it's wanted. |
| 5 | FM4.05 | No standalone download progress UI. | `NodeActionState.downloadProgress[fileId]` exists for future inline progress; current UX = start → snackbar on completion → `OpenFile.open`. Acceptable for FM4 scope; revisit if files grow large. |
| 6 | FM6.03 | `useDummyFileManagerProvider` stays `true` by default. | Backend endpoints in §8 not yet confirmed live. Remote arm compiles + is wired; flip is a one-line change once API integration tested end-to-end. |
| 7 | FM6 | `Env.imageUrl` (not a separate `Env.apiUrl`-based base) resolves relative URLs. | Matches existing pattern from `home_pending_shoot_card.dart` etc — `imageUrl` is the CDN base for all asset paths. |

---

## 12. Out of Scope (explicit)

- Folder creation, file upload, rename, move — not in this phase.
- Multi-select / bulk actions.
- Offline cache of folder trees.
- Inline PDF / image previews inside the listing card (icon-only per design).
- Per-role permission UI (server-enforced; client surfaces 403 as snackbar).
