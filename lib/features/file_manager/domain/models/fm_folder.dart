part of 'fm_node.dart';

@immutable
class FmFolder extends FmNode {
  /// Total files contained, including descendants. Server-computed — the
  /// client never recomputes after deletes; it re-fetches the parent.
  final int fileCount;

  /// Free-form tag like `"Corporate Event"`. Rendered as `FmTagChip`.
  final String? tagLabel;

  /// Hidden when null (backend hasn't decided the link signal yet).
  final LinkState? linkState;

  final FmLinkedProject? linkedProject;

  /// Sidecar populated for root-level workspace folders — carries the
  /// object-store paths and console URL needed by downstream mutation
  /// calls (create folder, upload, delete). Null for every non-workspace
  /// folder returned inside a listing.
  final FmWorkspaceMeta? workspaceMeta;

  /// Target key for the folder-listing endpoint when the user taps this
  /// card. Populated by DTOs that know the phase context — root-list
  /// entries (`FmWorkspaceDto`) set `phase=root, path=''`; nested
  /// entries (`FmWorkspaceDetailDto`) translate Pre/Post subfolders into
  /// phase transitions and append name to the parent path.
  ///
  /// Screens must prefer this over reconstructing a key from `id` — the
  /// dummy adapter can still fall back to `FmFolderKey(externalId: id)`
  /// when it is null.
  final FmFolderKey? nextKey;

  /// Absolute object-store path (**trailing `/`**) — used by delete /
  /// share / download-folder mutations that address folders by path.
  /// Populated by DTOs that see the parent's `basePath`; nullable for
  /// the dummy source.
  final String? filepath;

  const FmFolder({
    required super.id,
    required super.name,
    required this.fileCount,
    super.openedAt,
    this.tagLabel,
    this.linkState,
    this.linkedProject,
    this.workspaceMeta,
    this.nextKey,
    this.filepath,
  });
}
