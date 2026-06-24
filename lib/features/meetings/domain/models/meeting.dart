import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_participant.dart';
import 'meeting_platform.dart';
import 'meeting_response.dart';
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

  /// Per-user RSVP map, keyed by participant userId (stringified). Mirrors
  /// the `participant_responses` array on the server payload — server entry
  /// shape: `{ user_id, response: "accepted" | "declined" }`. Unknown /
  /// unmapped values are dropped at the DTO boundary.
  final Map<String, MeetingResponse> participantResponses;

  /// Current logged-in CP's response if present in [participantResponses].
  /// Resolved at the DTO boundary against the session userId so UI layers
  /// don't need to look up the session themselves.
  final MeetingResponse? myResponse;

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
    this.participantResponses = const {},
    this.myResponse,
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
    Map<String, MeetingResponse>? participantResponses,
    MeetingResponse? myResponse,
    bool clearMyResponse = false,
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
      participantResponses: participantResponses ?? this.participantResponses,
      myResponse: clearMyResponse ? null : (myResponse ?? this.myResponse),
    );
  }
}
