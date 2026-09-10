import '../../../../config/env.dart';
import '../../domain/models/file_type.dart';
import '../../domain/models/fm_node.dart';

/// File DTO. `type` accepts either a coarse bucket (`pdf`, `image`, …) or a
/// raw extension; [FileTypeX.fromApi] handles both. Relative `download_url`
/// values are resolved against `Env.imageUrl` so the entity always carries
/// an absolute URL.
class FmFileDto {
  static FmFile fromJson(Map<String, dynamic> j) {
    final name = (j['name'] ?? '').toString();
    final typeStr = j['type']?.toString();
    final type = isImageFile(name)
        ? FileType.image
        : typeStr != null
        ? FileTypeX.fromApi(typeStr)
        : FileTypeX.fromExtension(name);
    return FmFile(
      id: j['id']?.toString() ?? '',
      name: name,
      type: type,
      sizeBytes: _asInt(j['size_bytes']) ?? 0,
      downloadUrl: _resolveUrl(j['download_url']?.toString()) ?? '',
      previewUrl: _resolveUrl(j['preview_url']?.toString()),
      openedAt: _parseDate(j['opened_at']),
      version: _asInt(j['version']),
      isLatest: j['is_latest'] as bool? ?? true,
      statusLabel: j['status_label']?.toString(),
      uploaderName: j['uploader_name']?.toString(),
    );
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
    return null;
  }

  static String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${Env.imageUrl}$url';
  }
}
