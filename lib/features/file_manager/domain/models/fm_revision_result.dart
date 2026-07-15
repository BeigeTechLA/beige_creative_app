import 'package:flutter/foundation.dart';

import 'fm_revision_action.dart';

/// Result of `POST /external-file-manager/revision-file/review`.
/// Two shapes depending on [action] — see `FILE_MANAGER_API_PLAN.md`
/// §3.12.
@immutable
class FmRevisionResult {
  final FmRevisionAction action;
  final int versionNumber;

  /// Populated when [action] == `requestRevision`. Path of the new
  /// `VersionN+1` folder the client should route to.
  final int? nextVersionNumber;
  final String? nextVersionPath;

  /// Populated when [action] == `approve`. Path of the file that landed
  /// under `Final Deliverables`.
  final FmRevisionDeliverable? finalDeliverable;

  const FmRevisionResult({
    required this.action,
    required this.versionNumber,
    this.nextVersionNumber,
    this.nextVersionPath,
    this.finalDeliverable,
  });
}

@immutable
class FmRevisionDeliverable {
  final String id;
  final String path;
  final String name;

  const FmRevisionDeliverable({
    required this.id,
    required this.path,
    required this.name,
  });
}
