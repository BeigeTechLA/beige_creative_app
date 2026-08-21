import '../../domain/entities/shared_file.dart';

/// REST mapper for `sharedFiles.items[]` under chat-details.
///
/// Items today are folder rows (`mimeType` / `size` null); real file rows
/// will reuse the same keys when backend ships them. `path` is the stable
/// id for folder rows; size and timestamps default safely.
class SharedFileDto {
  static SharedFile fromRestJson(Map<String, dynamic> json) {
    final updatedAt = json['updatedAt'] as String?;
    final size = json['size'];
    return SharedFile(
      id: (json['path'] ?? json['name'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      mimeType: (json['mimeType'] as String?) ?? 'application/octet-stream',
      sizeBytes: size is num ? size.toInt() : 0,
      uploadedAt: updatedAt == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(updatedAt).toLocal(),
    );
  }
}
