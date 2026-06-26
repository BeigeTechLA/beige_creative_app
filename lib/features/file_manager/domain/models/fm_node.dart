import 'package:flutter/foundation.dart';

import 'file_type.dart';
import 'fm_linked_project.dart';
import 'link_state.dart';

part 'fm_folder.dart';
part 'fm_file.dart';

/// Base type for any item shown in a file-manager listing.
///
/// Sealed so the recursive list widget can pattern-match on
/// `switch (node) { FmFolder() => …, FmFile() => … }` without runtime
/// type checks. Subclasses live as part files in this same library.
@immutable
sealed class FmNode {
  final String id;
  final String name;

  /// Last-opened timestamp from the backend. Drives the
  /// "Opened 2 hours ago" footer. Null when never opened or when the
  /// backend omits the field.
  final DateTime? openedAt;

  const FmNode({required this.id, required this.name, this.openedAt});
}

/// Discriminator emitted by the backend on every node payload. Used by the
/// DTO boundary to branch between [FmFolder] and [FmFile] deserialization,
/// and by the share / delete endpoints to identify the target.
enum FmNodeKind { folder, file }

extension FmNodeKindX on FmNodeKind {
  String get apiValue {
    switch (this) {
      case FmNodeKind.folder:
        return 'folder';
      case FmNodeKind.file:
        return 'file';
    }
  }

  static FmNodeKind? fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'folder':
        return FmNodeKind.folder;
      case 'file':
        return FmNodeKind.file;
      default:
        return null;
    }
  }
}
