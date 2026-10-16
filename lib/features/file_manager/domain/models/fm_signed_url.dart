import 'package:flutter/foundation.dart';

/// Short-lived signed URL returned by the view / download / folder-
/// download endpoints. Used for image previews and external open/download.
@immutable
class FmSignedUrl {
  final String url;

  /// Optional server-supplied expiry. Backend has not confirmed the
  /// field name (see `FILE_MANAGER_API_PLAN.md` §11 Q7) — accepts either
  /// `expiresIn` (seconds) or `expiresAt` (ISO). Presented as an absolute
  /// `DateTime` here so downstream code doesn't care.
  final DateTime? expiresAt;

  /// Only set by the folder-download endpoint. Echoes the folder path
  /// the ZIP was generated for; useful in log lines.
  final String? filepath;

  const FmSignedUrl({required this.url, this.expiresAt, this.filepath});
}
