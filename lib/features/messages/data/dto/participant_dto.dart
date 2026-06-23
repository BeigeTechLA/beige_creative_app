import '../../domain/entities/participant.dart';

/// REST mapper for participant payloads served by
/// `GET /external-chat/room/:roomId/details` (`participants.items[]`).
///
/// Shape:
/// ```json
/// { "id": "751", "name": "Krunal CP Joshi", "email": "...",
///   "role": "cp", "profileImage": "profile_photo_98_….jpg",
///   "phone": "...", "group": "cps" }
/// ```
///
/// `id` is the canonical numeric user id — matches `Message.senderId`
/// (backend `sent_by.id`), so this map keys consistently with messages.
class ParticipantDto {
  static Participant fromRestJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      role: (json['role'] ?? 'member') as String,
      avatarUrl: json['profileImage'] as String?,
      email: json['email'] as String?,
    );
  }
}
