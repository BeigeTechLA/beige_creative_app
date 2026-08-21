import 'package:flutter/foundation.dart';

/// One entry in `GET /external-file-manager/common-events`. Surfaced in
/// the Common Events root tab.
@immutable
class FmCommonEvent {
  final int eventId;
  final String eventName;
  final String eventSlug;

  /// Stable string id used by the creator-folder endpoint
  /// (`/common-events/{externalId}/creator-folder`). Not a numeric id.
  final String externalId;

  /// Storage root — e.g. `Event - Common/`. Always ends with `/`.
  final String rootPath;

  /// Null = event stays visible indefinitely.
  final DateTime? visibleUntil;

  final int? createdByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FmCommonEvent({
    required this.eventId,
    required this.eventName,
    required this.eventSlug,
    required this.externalId,
    required this.rootPath,
    this.visibleUntil,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
  });
}
