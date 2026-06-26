import 'package:flutter/foundation.dart';

/// Project / shoot bound to a folder. Drives the `FmProjectBadgeCard` row
/// shown above the contents list in folder-details (e.g.
/// `L#1 Corporate_Lana_#123456 — Project Code: 3926`).
///
/// All fields except [id] and [displayName] are optional — the backend may
/// drop the thumbnail, badge label, or project code per project.
@immutable
class FmLinkedProject {
  final String id;
  final String displayName;
  final String? projectCode;
  final String? thumbnailUrl;
  final String? badgeLabel;

  const FmLinkedProject({
    required this.id,
    required this.displayName,
    this.projectCode,
    this.thumbnailUrl,
    this.badgeLabel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FmLinkedProject &&
          other.id == id &&
          other.displayName == displayName &&
          other.projectCode == projectCode &&
          other.thumbnailUrl == thumbnailUrl &&
          other.badgeLabel == badgeLabel;

  @override
  int get hashCode => Object.hash(id, displayName, projectCode, thumbnailUrl, badgeLabel);
}
