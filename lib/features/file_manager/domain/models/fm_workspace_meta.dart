import 'package:flutter/foundation.dart';

/// Object-store coordinates for a workspace-root folder. Populated only
/// on the folders returned by `GET /external-file-manager/workspaces`
/// (or the equivalent detail endpoint). Downstream calls that mutate
/// paths (`POST /folder`, upload presign, delete, copy-files, …) require
/// [rootPath] to compose absolute filepaths — see `FmPath`.
@immutable
class FmWorkspaceMeta {
  /// The workspace's own root — e.g. `corporate_harsh_#4833/`. Always
  /// ends with `/`.
  final String rootPath;

  /// Full storage path including any prefix like `Website_Shoots_Flow/`.
  /// Present for read-only surfacing (e.g. console link labels).
  final String? fullPath;

  /// GCS/S3 console URL — surfaced only if the user has admin rights.
  final String? consoleUrl;

  /// True when the workspace is a common-event folder (`isCommonEvent`
  /// discriminator on the API). Drives the Common Events tab + tag.
  final bool isCommonEvent;

  final int? eventId;
  final String? eventName;

  /// ISO date after which the common event is hidden. Null = never.
  final DateTime? visibleUntil;

  const FmWorkspaceMeta({
    required this.rootPath,
    this.fullPath,
    this.consoleUrl,
    this.isCommonEvent = false,
    this.eventId,
    this.eventName,
    this.visibleUntil,
  });
}
