import 'package:flutter/foundation.dart';

import 'fm_phase.dart';

/// Identifies a folder listing across the API and the browse notifier
/// family. Replaces the old opaque `String folderId` — every path-scoped
/// endpoint (`GET /workspace/{extId}/files`, `POST /folder`,
/// `POST /copy-files`, `POST /delete`, etc.) is keyed by the same tuple.
///
/// `path` is the **relative** folder path inside the phase (e.g.
/// `Edits/Revisions`, empty string for the phase root). Never carries a
/// leading or trailing `/` — [FmPath] adds them at the boundary.
@immutable
class FmFolderKey {
  final String externalId;
  final FmPhase phase;
  final String path;

  const FmFolderKey({
    required this.externalId,
    this.phase = FmPhase.root,
    this.path = '',
  });

  FmFolderKey copyWith({String? externalId, FmPhase? phase, String? path}) =>
      FmFolderKey(
        externalId: externalId ?? this.externalId,
        phase: phase ?? this.phase,
        path: path ?? this.path,
      );

  /// Child key one level deeper.
  FmFolderKey child(String segment) => copyWith(
    path: path.isEmpty ? segment : '$path/$segment',
  );

  @override
  bool operator ==(Object other) =>
      other is FmFolderKey &&
      other.externalId == externalId &&
      other.phase == phase &&
      other.path == path;

  @override
  int get hashCode => Object.hash(externalId, phase, path);

  @override
  String toString() =>
      'FmFolderKey(externalId: $externalId, phase: ${phase.apiValue}, path: "$path")';
}
