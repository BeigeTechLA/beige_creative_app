import '../../domain/entities/participant.dart';

/// REST mapper for participant payloads served by `GET /external-chat/participants/:roomId`
/// and `GET /external-chat/room/:roomId/details`.
///
/// Assumed shape (backend response not documented in source — confirm):
/// ```json
/// {
///   "id": "uid_1",
///   "name": "Ronak",
///   "role": "client",
///   "profile_image": "profile_photo_5.jpg",
///   "email": "ronak@example.com"
/// }
/// ```
class ParticipantDto {
  static Participant fromRestJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['id'] ?? json['_id'] ?? json['userId']).toString(),
      name: (json['name'] ?? '') as String,
      role: (json['role'] ?? 'member') as String,
      avatarUrl: (json['profile_image'] ??
          json['profileImage'] ??
          json['avatarUrl'] ??
          json['avatar_url']) as String?,
    );
  }
}
