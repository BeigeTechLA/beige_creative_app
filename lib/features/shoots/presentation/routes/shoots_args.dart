import 'package:flutter/foundation.dart';

/// Typed args for `/upcoming-shoot-details`. Replaces the non-null
/// `state.extra as Map<String,dynamic>` cast (P15).
@immutable
class UpcomingShootDetailsArgs {
  const UpcomingShootDetailsArgs({this.projectId});

  final int? projectId;

  Map<String, dynamic> toExtra() => {'projectId': projectId};

  factory UpcomingShootDetailsArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return UpcomingShootDetailsArgs(projectId: _asInt(m['projectId']));
  }
}

/// Typed args for `/cancel-shoot`.
@immutable
class CancelShootArgs {
  const CancelShootArgs({this.projectId});

  final int? projectId;

  Map<String, dynamic> toExtra() => {'projectId': projectId};

  factory CancelShootArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return CancelShootArgs(projectId: _asInt(m['projectId']));
  }
}

int? _asInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
