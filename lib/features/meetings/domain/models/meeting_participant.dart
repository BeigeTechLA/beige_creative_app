import 'package:flutter/foundation.dart';

@immutable
class MeetingParticipant {
  final String id;
  final String name;
  final String? avatarUrl;

  const MeetingParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}
