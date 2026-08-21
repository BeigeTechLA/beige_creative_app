import 'package:flutter/foundation.dart';

/// Result of `POST /external-file-manager/delete`.
@immutable
class FmDeleteResult {
  final bool deleted;
  final int deletedCount;
  final int metadataDeletedCount;
  final int embeddingDeletedCount;

  const FmDeleteResult({
    required this.deleted,
    this.deletedCount = 0,
    this.metadataDeletedCount = 0,
    this.embeddingDeletedCount = 0,
  });
}
