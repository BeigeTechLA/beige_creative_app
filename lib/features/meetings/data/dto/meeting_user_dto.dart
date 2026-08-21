import '../../domain/models/meeting_participant.dart';

/// REST mapper for the User sub-object served by `external-meetings` reads.
///
/// Used by every nested user slot: `client`, `admin`, `created_by`, and each
/// entry of `cps[]` / `participants[]`. Observed shape
/// (`MEETINGS_API.md` §User sub-object):
///
/// ```json
/// { "id": 198, "name": "Arpit S", "email": "arpits85@gmail.com", "role": "admin" }
/// ```
///
/// Server does not include an avatar URL in the observed payload — keep the
/// extractor defensive in case it lands later.
///
/// Per-user RSVP is NOT carried on this object — it lives in the meeting-level
/// `participant_responses[]` array. See [MeetingDto].
class MeetingUserDto {
  static MeetingParticipant fromRestJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['_id'] ?? '').toString();
    final name = (json['name'] ?? '') as String;
    final avatar = (json['profile_image'] ??
        json['profileImage'] ??
        json['avatar_url'] ??
        json['avatarUrl']) as String?;
    final role = json['role'] as String?;

    return MeetingParticipant(
      id: id,
      name: name,
      avatarUrl: avatar,
      role: role,
    );
  }
}
