import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_response.dart';
import '../mappers/meeting_enum_mapper.dart';
import 'meeting_user_dto.dart';

/// REST mapper for the Meeting payload served by:
///   - `GET /external-meetings` (each entry of `results[]`)
///   - `GET /external-meetings/:id` (single, unwrapped)
///   - `POST /external-meetings` (create response)
///   - `POST /external-meetings/:id/participants` (full updated)
///   - `PATCH /external-meetings/:id` (full updated)
///
/// Observed shape confirmed identical across all five reads
/// (`MEETINGS_API.md` §Meeting object).
///
/// Nullables observed in live data: `description`, `client`, `admin`,
/// `created_by`, `change_request`, `order`. Each guarded individually.
class MeetingDto {
  /// [currentUserId] is the session-resolved CP user id used to populate
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
      // Server has no structured agenda — leave empty. UI Details sheet
      // renders the empty list as no agenda section content.
      agenda: const <String>[],
      participants: _readParticipants(json['participants']),
      participantResponses: responses,
      myResponse: currentUserId.isEmpty ? null : responses[currentUserId],
    );
  }

  /// Server shape: `participant_responses: [{ user_id, response }]`.
  /// Unknown response strings are dropped (treated as no response).
  static Map<String, MeetingResponse> _readParticipantResponses(Object? raw) {
    if (raw is! List) return const {};
    final out = <String, MeetingResponse>{};
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) continue;
      final userId = (entry['user_id'] ?? entry['userId'] ?? '').toString();
      if (userId.isEmpty) continue;
      final r = _parseResponse(entry['response']);
      if (r != null) out[userId] = r;
    }
    return out;
  }

  static MeetingResponse? _parseResponse(Object? raw) {
    if (raw is! String) return null;
    switch (raw.toLowerCase()) {
      case 'accepted':
        return MeetingResponse.accepted;
      case 'declined':
      case 'rejected':
        return MeetingResponse.declined;
    }
    return null;
  }

  static List<MeetingParticipant> _readParticipants(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MeetingUserDto.fromRestJson)
        .toList(growable: false);
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
