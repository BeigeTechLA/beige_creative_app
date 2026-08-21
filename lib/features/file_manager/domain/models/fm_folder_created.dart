import 'package:flutter/foundation.dart';

/// Result of `POST /external-file-manager/folder` (and the
/// common-events creator-folder variant).
@immutable
class FmFolderCreated {
  final String id;
  final String path;
  final String name;

  /// True when the API refused to create a duplicate — folder already
  /// existed at [path]. UI treats this as a soft-success: continue to
  /// the folder rather than surfacing an error.
  final bool alreadyExists;

  const FmFolderCreated({
    required this.id,
    required this.path,
    required this.name,
    this.alreadyExists = false,
  });
}
