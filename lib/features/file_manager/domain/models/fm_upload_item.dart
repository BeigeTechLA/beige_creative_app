import 'package:flutter/foundation.dart';

/// One entry in a `POST /upload-policies/batch` or `POST /files-uploaded/
/// batch` request. `filepath` = the fully-composed destination path
/// (built via `FmPath`).
@immutable
class FmUploadItem {
  final String filepath;
  final String fileContentType;
  final int fileSize;

  /// Present only on the confirm-uploaded request; presign uses
  /// [filepath]'s trailing segment implicitly.
  final String? fileName;

  const FmUploadItem({
    required this.filepath,
    required this.fileContentType,
    required this.fileSize,
    this.fileName,
  });

  Map<String, dynamic> toPresignJson() => {
    'filepath': filepath,
    'fileContentType': fileContentType,
    'fileSize': fileSize,
  };

  Map<String, dynamic> toConfirmJson() => {
    'filepath': filepath,
    'fileContentType': fileContentType,
    'fileSize': fileSize,
    'fileName': fileName,
  };
}
