import 'package:flutter/foundation.dart';

@immutable
class MeetingParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? role;

  const MeetingParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.role,
  });

  MeetingParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? role,
  }) {
    return MeetingParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }
}
