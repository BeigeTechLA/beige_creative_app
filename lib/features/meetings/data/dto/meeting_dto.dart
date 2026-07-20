import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meeting_type.dart';
import '../mappers/meeting_enum_mapper.dart';
import 'meeting_user_dto.dart';

/// REST mapper for the Meeting payload served by:
///   - `GET /external-meetings/user/:userId` (each entry of `results[]`)
///   - `GET /external-meetings/:id` (single, unwrapped)
///   - `POST /external-meetings` (create response)
///   - `POST /external-meetings/:id/participants` (full updated)
///   - `PATCH /external-meetings/:id` (full updated)
///   - `PATCH /external-meetings/:id/respond` (full updated)
///
/// Nullables observed in live data: `description`, `client`, `admin`,
/// `created_by`, `change_request`, `order`. Each guarded individually.
///
/// Per-user RSVP state lives in the meeting-level `participant_responses[]`
/// array — NOT inside the User sub-object on `participants[]`. The current
/// viewer's response is precomputed into [Meeting.myResponse] using the
/// session-resolved [currentUserId] so the UI doesn't need to look it up.
class MeetingDto {
  /// [currentUserId] is the session-resolved user id used to populate
  /// `myResponse` from the `participant_responses` array. Pass empty when no
  /// user is in session — caller already guards against that for list calls.
  static Meeting fromRestJson(
    Map<String, dynamic> json, {
    String currentUserId = '',
  }) {
    final order = json['order'];
    final projectName = order is Map<String, dynamic>
        ? (order['name'] as String?) ?? ''
        : '';

    final link = (json['meetLink'] ?? json['meet_link'] ?? '') as String;
    final responses = _readParticipantResponses(json['participant_responses']);

    return Meeting(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['meeting_title'] ?? '') as String,
      description: (json['description'] as String?) ?? '',
      project: projectName,
      platform: MeetingEnumMapper.platformFromLink(link),
      startAt: _parseUtc(json['meeting_date_time']),
      endAt: _parseUtc(json['meeting_end_time']),
      link: link,
      // Server has no reminder field. Default to 15min; UI does not roundtrip.
      reminderMinutes: 15,
      status: MeetingEnumMapper.statusFromServer(
        json['meeting_status'] as String?,
      ),
      category: MeetingEnumMapper.categoryFromServer(
        json['meeting_type'] as String?,
      ),
      meetingType: MeetingType.fromServer(json['meeting_type'] as String?),
      meetingTypeRaw: json['meeting_type'] as String?,
      // Server has no structured agenda — leave empty.
      agenda: const <String>[],
      participants: _readParticipants(json),
      createdById: _readCreatedById(json['created_by']),
      participantResponses: responses,
      myResponse: currentUserId.isEmpty ? null : responses[currentUserId],
    );
  }

  /// `created_by` arrives as the full user sub-object (`{id, name, ...}`)
  /// when present, occasionally as a bare scalar id, or null on legacy /
  /// system-generated rows. Extract the id only.
  static String? _readCreatedById(Object? raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) {
      final id = raw['id'] ?? raw['_id'];
      if (id == null) return null;
      final s = id.toString();
      return s.isEmpty ? null : s;
    }
    final s = raw.toString();
    return s.isEmpty ? null : s;
  }

  /// Server shape: `participant_responses: [{ user_id, response }]`.
  /// Unknown response strings are dropped (treated as no response).
  /// `pending` entries are stripped so callers can keep treating
  /// `myResponse == null` as "not responded".
  static Map<String, MeetingResponse> _readParticipantResponses(Object? raw) {
    if (raw is! List) return const {};
    final out = <String, MeetingResponse>{};
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) continue;
      final userId = (entry['user_id'] ?? entry['userId'] ?? '').toString();
      if (userId.isEmpty) continue;
      final r = rsvpFromServer(entry['response'] as String?);
      if (r != null && r != MeetingResponse.pending) out[userId] = r;
    }
    return out;
  }

  static List<MeetingParticipant> _readParticipants(Map<String, dynamic> json) {
    final raw = json['participants'] ??
        json['participants_preview'] ??
        json['participantsPreview'] ??
        json['participants_list'] ??
        json['participantsList'];
    if (raw is! List) return const [];

    final seen = <String>{};
    final participants = <MeetingParticipant>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        final p = MeetingUserDto.fromRestJson(entry);
        if (p.id.isNotEmpty) {
          if (seen.add(p.id)) {
            participants.add(p);
          }
        } else {
          participants.add(p);
        }
      }
    }
    return List.unmodifiable(participants);
  }

  /// Server emits ISO 8601 UTC with `Z` suffix. Convert to local for display
  /// layer consistency (UI formatters assume local time).
  static DateTime _parseUtc(Object? raw) {
    if (raw is! String || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.parse(raw).toLocal();
  }
}
