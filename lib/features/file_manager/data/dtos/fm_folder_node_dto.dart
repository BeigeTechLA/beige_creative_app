import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_phase.dart';
import 'fm_envelope_dto.dart';

/// Folder entry returned inside `folders[]` of a folder-listing response.
/// Distinct from `FmWorkspaceDto` (root-level workspaces) — this one is
/// the nested / sub-folder shape:
///
/// ```json
/// {
///   "name": "Post-Production",
///   "path": "corporate_harsh_#4833/Post-Production/",
///   "fullPath": "Website_Shoots_Flow/…/Post-Production/",
///   "folderType": "postproduction",
///   "fileCount": 0,
///   "updatedAt": "2026-06-29T06:33:19.619Z",
///   "createdAt": "2026-06-29T06:33:19.619Z"
/// }
/// ```
class FmFolderNodeDto {
  /// Nested folders need the [parent] key to compute a correct [nextKey]
  /// for tap-through navigation. When the child's `folderType` marks a
  /// phase transition (Pre/Post-Production sitting at workspace root),
  /// the returned key jumps to that phase with `path=''`; otherwise the
  /// child's name is appended to the parent's path.
  static FmFolder fromJson(Map<String, dynamic> j, {required FmFolderKey parent}) {
    final name = (j['name'] ?? '').toString();
    final folderType = FmFolderTypeX.fromApi(j['folderType']?.toString());

    final path = FmJson.nonEmpty(j['path']);
    return FmFolder(
      // Nested folders don't carry a stable id — path is the natural key.
      id: (path ?? name),
      name: name,
      fileCount: FmJson.asInt(j['fileCount']) ?? 0,
      openedAt: FmJson.asDate(j['updatedAt']),
      tagLabel: null,
      linkState: null,
      linkedProject: null,
      nextKey: _childKey(parent: parent, name: name, folderType: folderType),
      filepath: path,
    );
  }

  static FmFolderKey _childKey({
    required FmFolderKey parent,
    required String name,
    required FmFolderType folderType,
  }) {
    // Phase transitions land only at workspace root — Pre-Production /
    // Post-Production sit directly under the workspace, so treat them
    // as phase switches even if the server tags them as `custom`.
    if (parent.phase == FmPhase.root) {
      if (folderType == FmFolderType.preproduction ||
          name.toLowerCase() == 'pre-production' ||
          name.toLowerCase() == 'preproduction') {
        return FmFolderKey(externalId: parent.externalId, phase: FmPhase.pre);
      }
      if (folderType == FmFolderType.postproduction ||
          name.toLowerCase() == 'post-production' ||
          name.toLowerCase() == 'postproduction') {
        return FmFolderKey(externalId: parent.externalId, phase: FmPhase.post);
      }
      // Common-event root folders and unknown top-level entries — treat
      // as deeper paths inside root.
      return parent.child(name);
    }
    return parent.child(name);
  }
}

/// Enum discriminator returned on nested folders. Case-insensitive
/// parse; unknown values → [FmFolderType.custom] so a rogue future value
/// never breaks the list.
enum FmFolderType {
  preproduction,
  postproduction,
  rawFootage,
  edits,
  selectedForEdits,
  revisions,
  version,
  finalDeliverables,
  custom,
}

extension FmFolderTypeX on FmFolderType {
  String get apiValue {
    switch (this) {
      case FmFolderType.preproduction:
        return 'preproduction';
      case FmFolderType.postproduction:
        return 'postproduction';
      case FmFolderType.rawFootage:
        return 'raw_footage';
      case FmFolderType.edits:
        return 'edits';
      case FmFolderType.selectedForEdits:
        return 'selected_for_edits';
      case FmFolderType.revisions:
        return 'revisions';
      case FmFolderType.version:
        return 'version';
      case FmFolderType.finalDeliverables:
        return 'final_deliverables';
      case FmFolderType.custom:
        return 'custom';
    }
  }

  static FmFolderType fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'preproduction':
      case 'pre-production':
        return FmFolderType.preproduction;
      case 'postproduction':
      case 'post-production':
        return FmFolderType.postproduction;
      case 'raw_footage':
      case 'rawfootage':
        return FmFolderType.rawFootage;
      case 'edits':
        return FmFolderType.edits;
      case 'selected_for_edits':
      case 'selectedforedits':
        return FmFolderType.selectedForEdits;
      case 'revisions':
        return FmFolderType.revisions;
      case 'version':
        return FmFolderType.version;
      case 'final_deliverables':
      case 'finaldeliverables':
        return FmFolderType.finalDeliverables;
      default:
        return FmFolderType.custom;
    }
  }
}
