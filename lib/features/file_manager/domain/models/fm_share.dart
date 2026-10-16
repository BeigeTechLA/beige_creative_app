import 'package:flutter/foundation.dart';

import 'fm_folder_key.dart';
import 'fm_phase.dart';

enum FmSharePermission { canDownload, canUploadAndDownload }

extension FmSharePermissionX on FmSharePermission {
  String get label => switch (this) {
    FmSharePermission.canDownload => 'Can Download',
    FmSharePermission.canUploadAndDownload => 'Can Upload & Download',
  };
  String get apiValue => switch (this) {
    FmSharePermission.canDownload => 'view_download',
    FmSharePermission.canUploadAndDownload => 'upload_download',
  };
}

@immutable
class FmShareTarget {
  const FmShareTarget({required this.key, required this.name});
  final FmFolderKey key;
  final String name;

  // Nested paths require a confirmed share API contract. Never silently
  // widen their scope to the containing workspace or production phase.
  bool get isSupported => key.externalId.isNotEmpty && key.path.isEmpty;
  Map<String, dynamic> get parameters {
    if (!isSupported) {
      throw StateError('Sharing this folder is not available yet.');
    }
    return {
      'resourceType': key.phase == FmPhase.root ? 'workspace' : 'folder',
      'externalId': key.externalId,
      if (key.phase != FmPhase.root) 'phase': key.phase.apiValue,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is FmShareTarget && other.key == key && other.name == name;
  @override
  int get hashCode => Object.hash(key, name);
}

@immutable
class FmShareRecipient {
  const FmShareRecipient({
    this.shareId,
    this.email,
    required this.permission,
    this.shareLink,
    this.shareToken,
  });
  final int? shareId;
  final String? email;
  final FmSharePermission permission;
  final String? shareLink;
  final String? shareToken;
  bool get isPublic => email == null;
}

@immutable
class FmShareAccessLog {
  const FmShareAccessLog({required this.action, this.email, this.createdAt});
  final String action;
  final String? email;
  final DateTime? createdAt;
}
