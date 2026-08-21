part of 'fm_node.dart';

@immutable
class FmFile extends FmNode {
  final FileType type;

  /// Raw byte size. UI formats lazily via a presentation-layer helper.
  final int sizeBytes;

  /// Absolute URL. Relative paths must be resolved through `Env.imageUrl` at
  /// the DTO boundary before reaching this entity.
  final String downloadUrl;

  /// Optional remote thumbnail. Ignored in FM4 (icon-only previews) but
  /// kept on the entity so the future inline-preview phase can opt in
  /// without a domain change.
  final String? previewUrl;

  /// The version number of this file (e.g., 1, 2)
  final int? version;

  /// Flag indicating if this is the latest version of the file
  final bool isLatest;

  /// Custom status text (e.g. "Raw Files Uploaded", "File Selected For Edits")
  final String? statusLabel;

  /// Name of the user who uploaded the file
  final String? uploaderName;

  /// Object-store `filepath` used by every path-addressed mutation
  /// (view/download URL, delete, copy-files, revision review, comments'
  /// `fileMetaId`). Absolute path — e.g.
  /// `corporate_harsh_#4833/Post-Production/Raw Footage/5.jpeg`.
  /// Nullable while the dummy source still emits synthetic ids without
  /// a real path; remote source always populates it.
  final String? filepath;

  const FmFile({
    required super.id,
    required super.name,
    required this.type,
    required this.sizeBytes,
    required this.downloadUrl,
    super.openedAt,
    this.previewUrl,
    this.version,
    this.isLatest = true,
    this.statusLabel,
    this.uploaderName,
    this.filepath,
  });
}
