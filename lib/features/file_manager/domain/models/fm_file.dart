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

  const FmFile({
    required super.id,
    required super.name,
    required this.type,
    required this.sizeBytes,
    required this.downloadUrl,
    super.openedAt,
    this.previewUrl,
  });
}
