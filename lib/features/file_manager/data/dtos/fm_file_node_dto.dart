import '../../../../config/env.dart';
import '../../domain/models/file_type.dart';
import '../../domain/models/fm_node.dart';
import 'fm_envelope_dto.dart';

/// File entry returned inside `files[]` on a folder-listing response.
///
/// Locked against the API doc's request examples plus the design's
/// version + status metadata. The doc's response screenshot only shows
/// empty `files: []` arrays — fields marked "verify" here need a live
/// curl per `FILE_MANAGER_API_PLAN.md` §11 Q2 before we ship.
///
/// Assumed shape:
///
/// ```json
/// {
///   "id": "6a424fe8253c42d7a139b7be",
///   "name": "5.jpeg",
///   "path": "corporate_harsh_#4833/Post-Production/Raw Footage/5.jpeg",
///   "fullPath": "Website_Shoots_Flow/…/5.jpeg",
///   "size": 271606,
///   "contentType": "image/jpeg",
///   "version": 1,
///   "isLatest": true,
///   "status": "raw_files_uploaded",
///   "uploadedBy": { "id": "281", "name": "…" },
///   "createdAt": "…",
///   "updatedAt": "…"
/// }
/// ```
class FmFileNodeDto {
  static FmFile fromJson(Map<String, dynamic> j) {
    final name = (j['name'] ?? '').toString();
    final contentType =
        j['contentType']?.toString() ?? j['mimeType']?.toString();

    // MIME wins when conclusive. But servers often serve RAW/obscure formats
    // as `application/octet-stream` (→ `other`); fall back to the filename
    // extension in that case so RAW (`.nef`, `.cr2`, …) and friends still
    // land in the right bucket.
    final mimeType = contentType != null
        ? FileTypeX.fromApi(_mimeBucket(contentType))
        : FileType.other;
    final type = isImageFile(name) || isImageFile(j['path']?.toString())
        ? FileType.image
        : mimeType != FileType.other
        ? mimeType
        : FileTypeX.fromExtension(name);

    final uploader = FmJson.asMap(j['uploadedBy']);

    return FmFile(
      id: (j['id'] ?? j['path'] ?? '').toString(),
      name: name,
      type: type,
      sizeBytes: FmJson.asInt(j['size']) ?? FmJson.asInt(j['sizeBytes']) ?? 0,
      // The listing endpoint does not return a signed download URL — the
      // client fetches one on demand via `POST /file-download-url`.
      // Keep the field as an empty string so existing widgets that only
      // read `filepath` stay happy.
      downloadUrl: '',
      previewUrl: _resolveUrl(
        j['thumbnailUrl']?.toString() ?? j['previewUrl']?.toString(),
      ),
      openedAt: FmJson.asDate(j['updatedAt']) ?? FmJson.asDate(j['createdAt']),
      version: FmJson.asInt(j['version']),
      isLatest: FmJson.asBool(j['isLatest'], orElse: true),
      statusLabel: _statusLabel(FmJson.nonEmpty(j['status'])),
      uploaderName: uploader != null
          ? FmJson.nonEmpty(uploader['name'])
          : FmJson.nonEmpty(j['uploaderName']),
      filepath: FmJson.nonEmpty(j['path']),
    );
  }

  /// Reduces a full MIME (`image/jpeg`) to the coarse bucket
  /// [FileTypeX.fromApi] understands (`image`).
  static String _mimeBucket(String mime) {
    final slash = mime.indexOf('/');
    if (slash < 0) return mime;
    final head = mime.substring(0, slash);
    switch (head) {
      case 'image':
      case 'video':
      case 'audio':
        return head;
      case 'application':
        final tail = mime.substring(slash + 1).toLowerCase();
        if (tail.contains('pdf')) return 'pdf';
        if (tail.contains('sheet') ||
            tail.contains('excel') ||
            tail.contains('csv')) {
          return 'sheet';
        }
        if (tail.contains('word') || tail.contains('doc')) return 'doc';
        if (tail.contains('zip') ||
            tail.contains('x-rar') ||
            tail.contains('x-7z')) {
          return 'zip';
        }
        return 'other';
      default:
        return 'other';
    }
  }

  /// Maps the backend `status` slug to the human-readable pill label the
  /// design expects (`FmStatusPill.label`). Unknown values fall through
  /// with the raw slug so we notice new backend values in QA.
  static String? _statusLabel(String? status) {
    if (status == null) return null;
    switch (status) {
      case 'raw_files_uploaded':
        return 'Raw Files Uploaded';
      case 'selected_for_edits':
        return 'File Selected For Edits';
      case 'pending_review':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'revision_requested':
        return 'Revision Requested';
      default:
        return status;
    }
  }

  static String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${Env.imageUrl}$url';
  }
}
