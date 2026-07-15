import '../../domain/models/file_type.dart';
import '../../domain/models/fm_linked_project.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/link_state.dart';

/// In-memory recursive tree consumed by [FileManagerRepositoryDummy].
///
/// Layout:
///
/// ```
/// root
/// ├── fld_lana       (linked, project L#1, tag Corporate Event)
/// │   ├── fld_lana_pre        (Pre Production)
/// │   │   ├── fld_lana_pre_brief   (3rd-level folder — proves recursion)
/// │   │   │   ├── fil_brief.pdf
/// │   │   │   └── fil_moodboard.jpg
/// │   │   ├── fil_script.docx
/// │   │   └── fil_storyboard.pdf
/// │   └── fld_lana_post       (Post Production)
/// │       ├── fil_edit_v1.mp4
/// │       ├── fil_edit_v2.mp4
/// │       └── fil_color_notes.pdf
/// ├── fld_aria       (linked, tag Wedding)
/// │   ├── fld_aria_pre
/// │   │   └── fil_aria_brief.pdf
/// │   └── fld_aria_post
/// │       └── fil_aria_final.mp4
/// ├── fld_zen        (unlinked, no project)
/// │   ├── fil_zen_invoice.pdf
/// │   └── fil_zen_contract.docx
/// └── fld_drafts     (no link state — badge hidden)
///     └── fil_idea.docx
/// ```
///
/// Keyed by folderId so the dummy repo can do O(1) page lookups.
class DummyFileTree {
  DummyFileTree._();

  static const String rootKey = 'root';

  static final DateTime _now = DateTime(2026, 6, 26, 12);
  static DateTime _ago(Duration d) => _now.subtract(d);

  static final FmLinkedProject _lanaProject = const FmLinkedProject(
    id: 'prj_3926',
    displayName: 'Corporate_Lana_#123456',
    projectCode: '3926',
    badgeLabel: 'L#1',
  );

  static final FmLinkedProject _ariaProject = const FmLinkedProject(
    id: 'prj_4001',
    displayName: 'Aria_Wedding_#4001',
    projectCode: '4001',
    badgeLabel: 'L#2',
  );

  /// Whole tree, keyed by parent folder id. `rootKey` holds the top level.
  static final Map<String, List<FmNode>> tree = {
    rootKey: [
      FmFolder(
        id: 'fld_lana',
        name: 'Corporate_Lana_#123456',
        fileCount: 8,
        openedAt: _ago(const Duration(hours: 2)),
        tagLabel: 'Corporate Event',
        linkState: LinkState.linked,
        linkedProject: _lanaProject,
      ),
      FmFolder(
        id: 'fld_aria',
        name: 'Aria_Wedding_#4001',
        fileCount: 2,
        openedAt: _ago(const Duration(hours: 5)),
        tagLabel: 'Wedding',
        linkState: LinkState.linked,
        linkedProject: _ariaProject,
      ),
      FmFolder(
        id: 'fld_zen',
        name: 'Zen_Studios_#3104',
        fileCount: 2,
        openedAt: _ago(const Duration(days: 1)),
        tagLabel: 'Commercial',
        linkState: LinkState.unlinked,
      ),
      FmFolder(
        id: 'fld_drafts',
        name: 'Drafts',
        fileCount: 1,
        openedAt: _ago(const Duration(days: 3)),
      ),
    ],

    // ── Lana branch ───────────────────────────────────────────────────
    'fld_lana': [
      FmFolder(
        id: 'fld_lana_pre',
        name: 'Pre Production',
        fileCount: 4,
        openedAt: _ago(const Duration(hours: 2)),
      ),
      FmFolder(
        id: 'fld_lana_post',
        name: 'Post Production',
        fileCount: 3,
        openedAt: _ago(const Duration(hours: 3)),
      ),
    ],
    'fld_lana_pre': [
      FmFolder(
        id: 'fld_lana_pre_brief',
        name: 'Creative Brief',
        fileCount: 2,
        openedAt: _ago(const Duration(hours: 1)),
      ),
      FmFile(
        id: 'fil_lana_script',
        name: 'Script.docx',
        type: FileType.doc,
        sizeBytes: 184320,
        downloadUrl: 'https://files.dummy/lana/script.docx',
        openedAt: _ago(const Duration(hours: 2)),
        version: 1,
        isLatest: true,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'Lana Guzman',
      ),
      FmFile(
        id: 'fil_lana_storyboard',
        name: 'Storyboard.pdf',
        type: FileType.pdf,
        sizeBytes: 980000,
        downloadUrl: 'https://files.dummy/lana/storyboard.pdf',
        openedAt: _ago(const Duration(hours: 2)),
        version: 1,
        isLatest: true,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'James Chen',
      ),
    ],
    'fld_lana_pre_brief': [
      FmFile(
        id: 'fil_lana_brief',
        name: 'Brief.pdf',
        type: FileType.pdf,
        sizeBytes: 120000,
        downloadUrl: 'https://files.dummy/lana/brief.pdf',
        openedAt: _ago(const Duration(hours: 1)),
        version: 1,
        isLatest: true,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'Lana Guzman',
      ),
      FmFile(
        id: 'fil_lana_moodboard',
        name: 'Moodboard.jpg',
        type: FileType.image,
        sizeBytes: 2400000,
        downloadUrl: 'https://files.dummy/lana/moodboard.jpg',
        previewUrl: 'https://files.dummy/lana/moodboard_thumb.jpg',
        openedAt: _ago(const Duration(hours: 1)),
        version: 1,
        isLatest: true,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'James Chen',
      ),
    ],
    'fld_lana_post': [
      FmFile(
        id: 'fil_lana_edit_v1',
        name: 'Edit_v1.mp4',
        type: FileType.video,
        sizeBytes: 48000000,
        downloadUrl: 'https://files.dummy/lana/edit_v1.mp4',
        openedAt: _ago(const Duration(hours: 3)),
        version: 1,
        isLatest: false,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'Lana Guzman',
      ),
      FmFile(
        id: 'fil_lana_edit_v2',
        name: 'Edit_v2.mp4',
        type: FileType.video,
        sizeBytes: 52000000,
        downloadUrl: 'https://files.dummy/lana/edit_v2.mp4',
        openedAt: _ago(const Duration(hours: 4)),
        version: 2,
        isLatest: true,
        statusLabel: 'File Selected For Edits',
        uploaderName: 'Lana Guzman',
      ),
      FmFile(
        id: 'fil_lana_color_notes',
        name: 'Color_Notes.pdf',
        type: FileType.pdf,
        sizeBytes: 64000,
        downloadUrl: 'https://files.dummy/lana/color_notes.pdf',
        openedAt: _ago(const Duration(hours: 5)),
        version: 1,
        isLatest: true,
        statusLabel: 'Raw Files Uploaded',
        uploaderName: 'James Chen',
      ),
    ],

    // ── Aria branch ───────────────────────────────────────────────────
    'fld_aria': [
      FmFolder(
        id: 'fld_aria_pre',
        name: 'Pre Production',
        fileCount: 1,
        openedAt: _ago(const Duration(hours: 5)),
      ),
      FmFolder(
        id: 'fld_aria_post',
        name: 'Post Production',
        fileCount: 1,
        openedAt: _ago(const Duration(hours: 6)),
      ),
    ],
    'fld_aria_pre': [
      FmFile(
        id: 'fil_aria_brief',
        name: 'Aria_Brief.pdf',
        type: FileType.pdf,
        sizeBytes: 220000,
        downloadUrl: 'https://files.dummy/aria/brief.pdf',
        openedAt: _ago(const Duration(hours: 5)),
      ),
    ],
    'fld_aria_post': [
      FmFile(
        id: 'fil_aria_final',
        name: 'Aria_Final.mp4',
        type: FileType.video,
        sizeBytes: 88000000,
        downloadUrl: 'https://files.dummy/aria/final.mp4',
        openedAt: _ago(const Duration(hours: 6)),
      ),
    ],

    // ── Zen branch ────────────────────────────────────────────────────
    'fld_zen': [
      FmFile(
        id: 'fil_zen_invoice',
        name: 'Invoice.pdf',
        type: FileType.pdf,
        sizeBytes: 48000,
        downloadUrl: 'https://files.dummy/zen/invoice.pdf',
        openedAt: _ago(const Duration(days: 1)),
      ),
      FmFile(
        id: 'fil_zen_contract',
        name: 'Contract.docx',
        type: FileType.doc,
        sizeBytes: 96000,
        downloadUrl: 'https://files.dummy/zen/contract.docx',
        openedAt: _ago(const Duration(days: 1)),
      ),
    ],

    // ── Drafts branch ─────────────────────────────────────────────────
    'fld_drafts': [
      FmFile(
        id: 'fil_idea',
        name: 'Idea.docx',
        type: FileType.doc,
        sizeBytes: 12000,
        downloadUrl: 'https://files.dummy/drafts/idea.docx',
        openedAt: _ago(const Duration(days: 3)),
      ),
    ],
  };

  /// Quick lookup for a folder entity by id — used by the dummy repo when
  /// the UI needs metadata (e.g. linkedProject for the project badge card)
  /// before listing children.
  static FmFolder? findFolder(String id) {
    for (final children in tree.values) {
      for (final node in children) {
        if (node is FmFolder && node.id == id) return node;
      }
    }
    return null;
  }
}
