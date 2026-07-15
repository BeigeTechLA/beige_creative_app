import 'package:flutter/foundation.dart';

/// Presigned upload policy for a single file. Backend response shape is
/// still pending confirmation (see `FILE_MANAGER_API_PLAN.md` §11 Q1) —
/// keep this model flexible until we lock it.
///
/// For S3 multipart the client will need one policy **per part**; this
/// entity models one PUT slot (either the whole file for a single-shot
/// upload or one part in a multipart sequence). FM8 elaborates.
@immutable
class FmUploadPolicy {
  /// The destination the presign was issued for.
  final String filepath;

  /// URL to PUT the payload to.
  final String uploadUrl;

  /// HTTP method — presumed `PUT` but keep it explicit in case the
  /// backend chooses `POST` for some flavours.
  final String method;

  /// Headers the client MUST forward on the PUT (e.g. `Content-Type`,
  /// `x-goog-*` / `x-amz-*` metadata).
  final Map<String, String> headers;

  /// Optional multipart part identifier. Null on single-shot uploads.
  final int? partNumber;

  /// Optional multipart upload id (`uploadId` on S3, session URI on GCS
  /// resumable). Null on single-shot uploads.
  final String? multipartUploadId;

  final DateTime? expiresAt;

  const FmUploadPolicy({
    required this.filepath,
    required this.uploadUrl,
    this.method = 'PUT',
    this.headers = const {},
    this.partNumber,
    this.multipartUploadId,
    this.expiresAt,
  });
}
