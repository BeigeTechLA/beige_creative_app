import 'package:flutter/foundation.dart';

/// Typed args for `/file-viewer`. Carries the folder/shoot id the screen
/// will render.
@immutable
class FileViewerArgs {
  const FileViewerArgs({required this.folderId});

  final String folderId;

  Map<String, dynamic> toExtra() => {'folderId': folderId};

  factory FileViewerArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return FileViewerArgs(folderId: (m['folderId'] as String?) ?? '');
  }
}
