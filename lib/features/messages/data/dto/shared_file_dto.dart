import '../../domain/entities/shared_file.dart';

/// REST mapper for shared-file rows under chat-details.
///
/// Backend returns folder-style rows today (mime/size null) and may return
/// real files later — keep this tolerant. Folders fall back to `path` for id
/// and `updatedAt` for the timestamp.
class SharedFileDto {
  static SharedFile fromRestJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['_id'] ?? json['path'] ?? json['fullPath'] ?? '')
        .toString();
    final mime = (json['mime_type'] ?? json['mimeType'] ?? json['file_type']) as String?;
    final size = json['size_bytes'] ?? json['sizeBytes'] ?? json['size'];
    final dateStr =
        (json['uploaded_at'] ?? json['uploadedAt'] ?? json['updatedAt'] ?? json['createdAt'])
            ?.toString();
    return SharedFile(
      id: id,
      name: (json['name'] ?? json['file_name'] ?? '') as String,
      mimeType: mime ?? 'application/octet-stream',
      sizeBytes: size is num ? size.toInt() : 0,
      uploadedAt: dateStr == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(dateStr).toLocal(),
    );
  }
}
