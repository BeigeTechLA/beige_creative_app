import 'package:flutter/foundation.dart';

/// Typed args for `/upcoming-shoot-details`. Replaces the non-null
/// `state.extra as Map<String,dynamic>` cast (P15).
@immutable
class UpcomingShootDetailsArgs {
  const UpcomingShootDetailsArgs({this.projectId});

  final int? projectId;

  Map<String, dynamic> toExtra() => {'projectId': projectId};

  factory UpcomingShootDetailsArgs.fromExtra(Object? extra) {
    if (extra is UpcomingShootDetailsArgs) return extra;
    if (extra is int) return UpcomingShootDetailsArgs(projectId: extra);
    if (extra is num) return UpcomingShootDetailsArgs(projectId: extra.toInt());
    if (extra is String) return UpcomingShootDetailsArgs(projectId: int.tryParse(extra));
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return UpcomingShootDetailsArgs(
      projectId: _asInt(m['projectId']) ??
          _asInt(m['booking_id']) ??
          _asInt(m['bookingId']) ??
          _asInt(m['shoot_id']) ??
          _asInt(m['project_id']) ??
          _asInt(m['order_id']) ??
          _asInt(m['id']),
    );
  }
}

/// Typed args for `/cancel-shoot`.
@immutable
class CancelShootArgs {
  const CancelShootArgs({this.projectId});

  final int? projectId;

  Map<String, dynamic> toExtra() => {'projectId': projectId};

  factory CancelShootArgs.fromExtra(Object? extra) {
    if (extra is CancelShootArgs) return extra;
    if (extra is int) return CancelShootArgs(projectId: extra);
    if (extra is num) return CancelShootArgs(projectId: extra.toInt());
    if (extra is String) return CancelShootArgs(projectId: int.tryParse(extra));
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return CancelShootArgs(
      projectId: _asInt(m['projectId']) ??
          _asInt(m['booking_id']) ??
          _asInt(m['bookingId']) ??
          _asInt(m['shoot_id']) ??
          _asInt(m['project_id']) ??
          _asInt(m['id']),
    );
  }
}

int? _asInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
