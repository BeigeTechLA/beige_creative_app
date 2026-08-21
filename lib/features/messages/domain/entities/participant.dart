import 'package:flutter/foundation.dart';

@immutable
class Participant {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  /// Used by chat thread to reconcile `self` when [id] doesn't match the
  /// persisted session user id (e.g. crew_member_id vs user_id divergence).
  final String? email;

  const Participant({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.email,
  });
}
