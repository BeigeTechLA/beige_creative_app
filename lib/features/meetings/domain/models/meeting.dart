import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_participant.dart';
import 'meeting_platform.dart';
import 'meeting_response.dart';
import 'meeting_status.dart';
import 'meeting_type.dart';

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

  /// Server `meeting_type` — production stage (planning / pre_production /
  /// production / post_production / review / delivery). Nullable when the
  /// backend value is empty or falls outside the known set.
  final MeetingType? meetingType;

  /// Raw server `meeting_type` string, preserved for unmapped values so the
  /// UI can fall back to it via [meetingTypeDisplay] when [meetingType] is
  /// null.
  final String? meetingTypeRaw;

  /// Human-readable stage — [MeetingType.label] when mapped, otherwise the
  /// raw server string. `null` when both are empty.
  String? get meetingTypeDisplay =>
      meetingType?.label ??
      (meetingTypeRaw?.isEmpty ?? true ? null : meetingTypeRaw);

  final List<String> agenda;
  final List<MeetingParticipant> participants;

  /// Id of the user who created the meeting. Sourced from `created_by.id` on
  /// the REST payload. Nullable — payload occasionally omits the field on
  /// legacy / system-generated meetings.
  final String? createdById;

  /// Per-user RSVP map, keyed by participant userId (stringified). Mirrors
  /// the `participant_responses` array on the server payload — server entry
  /// shape: `{ user_id, response: "accepted" | "declined" }`. Unknown /
  /// unmapped values are dropped at the DTO boundary.
  final Map<String, MeetingResponse> participantResponses;

  /// Current logged-in user's response if present in [participantResponses].
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
    this.meetingType,
    this.meetingTypeRaw,
    this.createdById,
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
    MeetingType? meetingType,
    String? meetingTypeRaw,
    List<String>? agenda,
    List<MeetingParticipant>? participants,
    String? createdById,
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
      meetingType: meetingType ?? this.meetingType,
      meetingTypeRaw: meetingTypeRaw ?? this.meetingTypeRaw,
      agenda: agenda ?? this.agenda,
      participants: participants ?? this.participants,
      createdById: createdById ?? this.createdById,
      participantResponses: participantResponses ?? this.participantResponses,
      myResponse: clearMyResponse ? null : (myResponse ?? this.myResponse),
    );
  }
}
