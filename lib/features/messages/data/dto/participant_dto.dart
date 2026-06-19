import '../../domain/entities/participant.dart';

/// REST mapper for participant payloads served by
/// `GET /external-chat/participants/:roomId` and
/// `GET /external-chat/room/:roomId/details` (`participants.items[]`).
///
/// Supports two shapes:
///
/// Flat:
/// ```json
/// { "id": "uid_1", "name": "Ronak", "role": "client",
///   "profile_image": "...", "email": "..." }
/// ```
///
/// Nested (item wraps user doc + carries item-level role):
/// ```json
/// { "user": { "_id": "uid_1", "name": "Ronak", "profile_image": "..." },
///   "role": "client" }
/// ```
///
/// Match id against `Message.senderId` (which the backend serves as `sent_by`).
class ParticipantDto {
  static Participant fromRestJson(Map<String, dynamic> json) {
    final nested = json['user'];
    final user = nested is Map<String, dynamic> ? nested : const <String, dynamic>{};

    // Prefer the underlying user id — message `sent_by` is the user id, not
    // the participant/membership id. Falling back to top-level id/_id only
    // when no user-id key is present (flat payloads).
    final id = (json['userId'] ??
            json['user_id'] ??
            user['_id'] ??
            user['id'] ??
            user['userId'] ??
            json['id'] ??
            json['_id'])
        ?.toString() ??
        '';

    final name = (json['name'] ?? user['name'] ?? '') as String;

    // Item-level role wins (e.g. participant role inside this room).
    final role = (json['role'] ?? user['role'] ?? 'member') as String;

    final avatar = (json['profile_image'] ??
        json['profileImage'] ??
        json['avatarUrl'] ??
        json['avatar_url'] ??
        user['profile_image'] ??
        user['profileImage'] ??
        user['avatarUrl'] ??
        user['avatar_url']) as String?;

    final email = (json['email'] ?? user['email']) as String?;

    return Participant(
      id: id,
      name: name,
      role: role,
      avatarUrl: avatar,
      email: email,
    );
  }
}
