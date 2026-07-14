# File Manager — Functional Flow & Design Considerations (Pages 59–74)

Source: `docs/feature/filemanager/Beige App Design.pdf`, pages 59–74. Crew-side mobile client (BEIGE).

> Typography scale, font sizes/weights, exact color values, and spacing pixels arrive as a separate screenshot handoff. This doc covers **flow, structure, and behavior only**.

---

## 1. Information Architecture

```
File Manager (root, bottom-nav tab)
├── Tabs: All Files | Recent Files | Linked Files | Common Events
└── Project folder  (e.g. Corporate_Lana_#123456)
    ├── Pre Production
    │   └── Files (PDF, DOCX, images, …)                 ← leaf: file cards
    └── Post Production
        ├── Raw Footages          → file cards (status: Raw Files Uploaded)
        ├── Edits
        │   ├── Selected for Edits → file cards (status: File Selected For Edits)
        │   └── Revisions
        │       ├── Version 1 → file cards
        │       ├── Version 2 → file cards
        │       └── … (Create Folder CTA adds new version)
        └── Final Deliverables
```

Structural rules
- Every level uses the same shell: back arrow · centered title · search · list · optional sticky bottom CTA.
- Inside a project: pinned **project header row** (avatar + project name + project code).
- Inside a leaf folder: **breadcrumb chip** replaces project header (folder icon + name + file count + chevron).
- Search is scoped to the current folder.
- Kebab (⋮) is present on every folder card, file card, and file-preview sheet.

---

## 2. Screen Inventory

| # | Screen | Purpose |
|---|--------|---------|
| 1 | File Manager root | Project folders list, tabbed by scope |
| 2 | Project view | Pre / Post Production subfolders |
| 3 | Pre Production | Documents (PDF, DOCX) file list |
| 4 | Post Production | Category subfolders + `Upload Files` CTA |
| 5 | Upload sheet — empty | Drag-drop / Browse target |
| 6 | Choose Document sheet | Photos-or-Videos vs. File source picker |
| 7 | Upload sheet — queued | Progress + item list + delete |
| 8 | Raw Footage list | File cards with version + status |
| 9 | Edits Request Sent — success | Confirmation + deep-link CTA |
| 10 | Edits view | Selected for Edits + Revisions folders |
| 11 | Selected for Edits list | File cards marked for edits |
| 12 | File preview sheet | Preview, metadata, comments, actions |
| 13 | Revision view | Version 1 / Version 2 + `Create Folder` CTA |
| 14 | Kebab popover | Open / Share / Download / Delete |
| 15 | Revision – Version N | File cards for that version |

---

## 3. Component Behavior

Visual token specs (size, weight, exact color) live in the separate design handoff. Below = **what each component does**.

### 3.1 App Bar
Back arrow → previous folder. Title = current folder / screen name. No action button in most screens (actions live in cards or sticky CTAs).

### 3.2 Search Field
Local, per-level filter. Filters folders and files in the current view. Does not span nested contents.

### 3.3 Breadcrumb / Context Chip
Shows current folder identity (icon + name + count) with a chevron. Tap → expand/collapse folder metadata or open a filter (Revisions screen uses this for a version filter).

### 3.4 Folder Card
Two variants:
- **Root/linked variant** — includes tag row (`Corporate Event`, `Linked`). Used for project folders.
- **Nested variant** — no tag row. Used for Pre/Post Production and deeper.

Every folder card: name, file count, optional tags, timestamp footer, kebab.
Tap card body → open folder. Tap kebab → action menu.

### 3.5 File Card
Header: file ID + size. Body: preview thumbnail (checkerboard placeholder if unavailable). Footer: filename + version tag + status pill, then uploader + timestamp, kebab.
Tap body → open **File Preview Sheet**. Tap kebab → action menu.

### 3.6 Version Tag
Compound tag: `V{n}` + `Latest` suffix when it is the current version. Absent `Latest` = older version.

### 3.7 Status Pill (semantic)

| Label | Meaning | When shown |
|-------|---------|------------|
| Linked | Folder is tied to a shoot/event | Project-linked folders |
| Raw Files Uploaded | Untouched raw upload | Raw Footages files |
| File Selected For Edits | Marked for edit request | Selected for Edits + File Preview |
| Corporate Event | Event/type descriptor | Linked project folders |

Never rely on color alone — the label text is always present.

### 3.8 Bottom Sheet Shell
Drag handle → header (title + subtitle + × close) → divider → body → action row (Cancel outline + Primary filled). Sheets echo the **destination context** in the subtitle (e.g. "Files will be uploaded to the folder Lana Guzman").

### 3.9 Dropzone
Tappable region. Drag-drop or tap `Browse` → opens **Choose Document sheet**.

### 3.10 Upload Progress Row
Shows `Uploaded X/Y` and `Failed X / Pending Y`. Linear progress fills as items complete. Row is visible only after items are queued.

### 3.11 Upload Queue Item
Thumbnail + filename + size + delete (trash). Removes item from queue only; does not delete uploaded files.

### 3.12 Primary CTA
Full-width, sticky bottom of scroll screen. Never placed in the app bar. Contextual labels: `Upload Files`, `Create Folder`, `Open Edit Folder`, `Post Comment`.

### 3.13 Secondary CTA
Outline button paired with primary in sheets (Cancel / dismiss / back-off action).

### 3.14 Success Screen
Icon (check + confetti) → headline → 2-line body → single primary CTA that **deep-links to the resulting state** (e.g. `Open Edit Folder` → `Edits › Selected for Edits`).

### 3.15 Kebab Action Popover
Universal 4-item set: `Open`, `Share`, `Download`, `Delete` (destructive). Same set for folders and files. Delete should trigger a confirm dialog before executing.

### 3.16 File Preview Sheet
Header: filename + close. Chip row: version tag + current status pill. Action row: `Request Revision` (warning-styled) · Download · Share. Preview media. Metadata block (Uploaded by · Last updated · File type · Current version). Comments block (empty-state message + input + `Post Comment`).

### 3.17 Bottom Nav
4 tabs: Dashboard · Shoots · **File Manager** · Messages. File Manager is a top-level destination.

---

## 4. Functional Flows

### 4.1 Browse
File Manager tab → project folder (root list) → Pre / Post Production → subfolder → file card → **File Preview Sheet**.
Back arrow always returns one level; state (scroll, search) restored on return.

### 4.2 Upload
Entry: `Post Production` (or any folder that allows uploads) → tap **Upload Files** sticky CTA.
1. **Upload sheet — empty**: shows destination in subtitle.
2. Tap **Browse** → **Choose Document sheet** → pick `Choose Photos or Videos` **or** `Choose from File`.
3. System picker → returns items to **Upload sheet — queued**.
4. Queue shows progress header (`Uploaded 0/N`) + item list. User can trash items before starting.
5. Tap **Upload Files** → progress fills, items resolve.
6. On success, sheet dismisses; folder list refreshes.

Considerations:
- Destination folder must be visible in the sheet subtitle at all times.
- Failed items should surface a retry action (design shows `Failed 0 / Pending 2` counters — implies failure is trackable).
- User can cancel mid-upload (Cancel button); partial uploads should be handled.

### 4.3 Request Edits
Raw Footage list → select one or more files → send edits request → **Edits Request Sent Successfully** screen → tap **Open Edit Folder** → land in `Edits › Selected for Edits`. Selected files carry the purple `File Selected For Edits` pill.

Considerations:
- Selection UI is not visible in these frames; assume long-press or multi-select mode.
- Deep-link CTA must skip back stack to prevent user from popping into an intermediate success screen.

### 4.4 Revisions & Versioning
`Edits › Revisions` shows one folder per version. `Create Folder` CTA adds Version N+1 (new revision cycle). Files inside a version folder show `V{n} Latest` when they represent the current head; older versions show `V{n}` alone. Revisions screen exposes a **Version filter** (right of search) to jump between versions.

Considerations:
- Only one version can carry the `Latest` badge at any time.
- Creating a new version folder should carry forward context (files pending edits, request metadata).

### 4.5 File actions (kebab)
Kebab on any folder or file card → `Open · Share · Download · Delete`.
- `Open` = same as tapping the card body.
- `Share` = system share sheet (link or file).
- `Download` = save to device; show a lightweight progress indicator.
- `Delete` = destructive; confirm before executing; refresh list.

### 4.6 Request Revision (from preview)
File Preview Sheet → **Request Revision** (yellow) → opens a revision request against the current version. On submit, a new version folder is created (or the request is attached to the pending version).

### 4.7 Comments
Available inside File Preview Sheet. Empty state: `No comments yet. Be the first to comment!`. Textarea + `Post Comment` primary. Comments are per-file (per-version if versioning applies).

---

## 5. Design Considerations (what to keep in mind)

1. **Consistent shell across levels.** Back · title · search · list · sticky CTA. Don't diverge per screen — users navigate deep hierarchies and need spatial predictability.
2. **Every card carries recency.** `Opened X ago` on folders, `Uploaded by … on <date>` on files. Surfaces freshness without extra taps.
3. **Semantic pills, never color-only.** Every status has a label. Colorblind-safe.
4. **Version metadata is first-class.** Every editable asset shows its version. Never hide it behind a menu.
5. **Sheets confirm target.** Upload / edit / delete sheets must echo the destination folder or file in the subtitle. Prevents "wrong folder" mistakes.
6. **Primary CTAs are contextual and sticky-bottom.** Not in the app bar. One primary per screen.
7. **Search is per-level, not global.** Users expect scoped search inside a folder.
8. **Placeholders = checkerboard.** For loading / non-previewable media (video without thumbnail, unsupported types).
9. **Universal kebab.** Same 4 actions everywhere (Open · Share · Download · Delete). Predictable muscle memory.
10. **Destructive actions are red and confirmed.** Delete in kebab, trash on queue items. Always confirm before executing on server-side data.
11. **Success screens are celebratory and actionable.** After a request completes, show confirmation with a deep-link CTA to the resulting state, not just "OK".
12. **Selection state is persistent.** Files marked `Selected for Edits` retain that state across navigation; the pill travels with the file everywhere it appears.
13. **Empty states are explicit.** Comments show a written empty-state message rather than silent absence.
14. **Uploads survive navigation.** Progress row keeps counters (`Uploaded / Failed / Pending`) — assume background upload continues if the sheet is dismissed.
15. **One primary action per surface.** Sheets pair one filled primary (right) with one outline secondary (left). Don't stack multiple primaries.
16. **Breadcrumb chip = orientation aid.** Inside a leaf folder, show the chip so users always know their scope, not just via the title bar.
17. **Filter dropdowns coexist with search.** Revisions screen shows both — search filters names, dropdown filters versions.
18. **Bottom nav persists on root levels.** Hidden once deep inside a folder tree? Confirm during build — designs show bottom nav on root only.

---

## 6. Implementation Notes (Flutter)

Follow the established Phase 4 pattern:

- Domain contract under `lib/features/filemanager/domain/repositories/`.
- Data implementation under `lib/features/filemanager/data/repositories/`.
- Providers under `lib/features/filemanager/presentation/providers/`, one `AsyncNotifier` or `AutoDisposeFamilyNotifier` per folder scope.
- Screens as `ConsumerWidget` / `ConsumerStatefulWidget`.
- `ref.watch` for state, `ref.read(...notifier)` for commands.
- Side effects (upload progress → SnackBar, success screen navigation, sheet dismissal) via `ref.listen` in widgets — not inside repositories.
- Multipart uploads through `dioClientProvider` (existing pattern).

Widgets to introduce under `lib/features/filemanager/presentation/widgets/`:
- `FolderCard` (root variant + nested variant)
- `FileCard`
- `BreadcrumbChip`
- `VersionTag`
- `StatusPill`
- `UploadSheet` (empty + queued states)
- `ChooseDocumentSheet`
- `FilePreviewSheet`
- `SuccessScreen` (reusable — matches confetti pattern)
- `KebabActionMenu`

Design tokens (colors, typography, spacing) will map to `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii` once the token screenshot handoff arrives.
