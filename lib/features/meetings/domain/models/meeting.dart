import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_participant.dart';
import 'meeting_platform.dart';
import 'meeting_status.dart';

@immutable
class Meeting {
  final String id;
  final String title;
  final String description;
  final String project;
  final MeetingPlatform platform;
  final DateTime startAt;
  final DateTime endAt;
  final String link;
  final int reminderMinutes;
  final MeetingStatus status;
  final MeetingCategory category;
  final List<String> agenda;
  final List<MeetingParticipant> participants;

  const Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.project,
    required this.platform,
    required this.startAt,
    required this.endAt,
    required this.link,
    required this.reminderMinutes,
    required this.status,
    required this.category,
    required this.agenda,
    required this.participants,
  });

  Meeting copyWith({
    String? id,
    String? title,
    String? description,
    String? project,
    MeetingPlatform? platform,
    DateTime? startAt,
    DateTime? endAt,
    String? link,
    int? reminderMinutes,
    MeetingStatus? status,
    MeetingCategory? category,
    List<String>? agenda,
    List<MeetingParticipant>? participants,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      project: project ?? this.project,
      platform: platform ?? this.platform,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      link: link ?? this.link,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      status: status ?? this.status,
      category: category ?? this.category,
      agenda: agenda ?? this.agenda,
      participants: participants ?? this.participants,
    );
  }
}
