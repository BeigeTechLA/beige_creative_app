import '../../domain/entities/shared_file.dart';

/// REST mapper for shared-file rows under chat-details.
///
/// Assumed shape (backend response not documented — confirm):
/// ```json
/// {
///   "_id": "file_1",
///   "name": "brief.pdf",
///   "url": "https://...",
///   "mime_type": "application/pdf",
///   "size_bytes": 1048576,
///   "uploaded_at": "2026-06-14T10:00:00.000Z"
/// }
/// ```
class SharedFileDto {
  static SharedFile fromRestJson(Map<String, dynamic> json) {
    return SharedFile(
      id: (json['id'] ?? json['_id']).toString(),
      name: (json['name'] ?? json['file_name'] ?? '') as String,
      mimeType: (json['mime_type'] ?? json['mimeType'] ?? json['file_type'] ?? 'application/octet-stream') as String,
      sizeBytes: ((json['size_bytes'] ?? json['sizeBytes'] ?? 0) as num).toInt(),
      uploadedAt: DateTime.parse(
        (json['uploaded_at'] ?? json['uploadedAt'] ?? json['createdAt']).toString(),
      ).toLocal(),
    );
  }
}
