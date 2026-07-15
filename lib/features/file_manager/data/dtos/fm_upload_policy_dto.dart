import '../../domain/models/fm_upload_policy.dart';
import 'fm_envelope_dto.dart';

/// Presign policy entry returned by
/// `POST /external-file-manager/upload-policies/batch`.
///
/// **Backend has not confirmed the response schema** — see
/// `FILE_MANAGER_API_PLAN.md` §11 Q1. This DTO accepts a superset of the
/// likely shapes (single PUT and multipart) so the source layer can hand
/// back a plausible `FmUploadPolicy` today; revisit once the doc is
/// updated.
///
/// Assumed shape:
///
/// ```json
/// {
///   "items": [
///     {
///       "filepath": "…",
///       "uploadUrl": "https://storage.googleapis.com/…?…",
///       "method": "PUT",
///       "headers": { "Content-Type": "image/jpeg" },
///       "partNumber": 1,               // optional (multipart)
///       "multipartUploadId": "…",       // optional (multipart)
///       "expiresAt": "…"
///     }
///   ]
/// }
/// ```
class FmUploadPolicyDto {
  static FmUploadPolicy fromJson(Map<String, dynamic> j) {
    final headersRaw = FmJson.asMap(j['headers']) ?? const {};
    final headers = <String, String>{
      for (final entry in headersRaw.entries) entry.key: entry.value.toString(),
    };
    return FmUploadPolicy(
      filepath: (j['filepath'] ?? '').toString(),
      uploadUrl: (j['uploadUrl'] ?? j['url'] ?? '').toString(),
      method: (j['method'] ?? 'PUT').toString().toUpperCase(),
      headers: headers,
      partNumber: FmJson.asInt(j['partNumber']),
      multipartUploadId: FmJson.nonEmpty(j['multipartUploadId'] ?? j['uploadId']),
      expiresAt: FmJson.asDate(j['expiresAt']),
    );
  }

  static List<FmUploadPolicy> listFromJson(Map<String, dynamic> j) =>
      FmJson.asList(j['items']).map(fromJson).toList();
}
