import 'package:flutter/foundation.dart';

/// Result of `POST /external-file-manager/copy-files` (Send For Edits).
@immutable
class FmCopyResult {
  final int total;
  final int successCount;
  final int failedCount;
  final String? sourcePath;
  final String? targetPath;
  final List<FmCopyItem> items;

  const FmCopyResult({
    required this.total,
    required this.successCount,
    required this.failedCount,
    required this.items,
    this.sourcePath,
    this.targetPath,
  });

  bool get allFailed => successCount == 0 && total > 0;
}

@immutable
class FmCopyItem {
  final String sourcePath;
  final String? destinationPath;
  final bool success;
  final String? errorMessage;

  const FmCopyItem({
    required this.sourcePath,
    required this.success,
    this.destinationPath,
    this.errorMessage,
  });
}
