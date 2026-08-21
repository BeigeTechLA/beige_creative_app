import '../../domain/models/fm_signed_url.dart';
import 'fm_envelope_dto.dart';

/// Signed URL payload returned by:
/// - `POST /external-file-manager/file-view-url`
/// - `POST /external-file-manager/file-download-url`
/// - `POST /external-file-manager/folder-download-url`
///
/// Doc doesn't lock the expiry field name — [fromJson] accepts either
/// `expiresAt` (ISO) or `expiresIn` (seconds).
class FmSignedUrlDto {
  static FmSignedUrl fromJson(Map<String, dynamic> j) {
    return FmSignedUrl(
      url: (j['url'] ?? '').toString(),
      expiresAt: FmJson.asDate(j['expiresAt']) ?? _fromExpiresIn(j['expiresIn']),
      filepath: FmJson.nonEmpty(j['filepath']),
    );
  }

  static DateTime? _fromExpiresIn(dynamic v) {
    final seconds = FmJson.asInt(v);
    if (seconds == null || seconds <= 0) return null;
    return DateTime.now().add(Duration(seconds: seconds));
  }
}
