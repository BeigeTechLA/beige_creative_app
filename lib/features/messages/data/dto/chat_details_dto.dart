import '../../domain/entities/chat_details.dart';
import 'participant_dto.dart';
import 'shared_file_dto.dart';

class ChatDetailsDto {
  /// REST shape from `GET /external-chat/room/:roomId/details`.
  ///
  /// Backend returns:
  /// ```
  /// { success, data: { room, profile, participants: { items, ... },
  ///   sharedFiles: { items, ... }, linkedShoot, notes } }
  /// ```
  /// `PaginationEnvelope.unwrapItem` strips `data`, so this receives the
  /// inner object.
  ///
  /// `conversationId` is passed in because the room is keyed by `room.id`
  /// (Mongo doc id) and we want to stay aligned with the caller's id.
  static ChatDetails fromRestJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    final room = (json['room'] as Map<String, dynamic>?) ?? const {};
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const {};

    final participantsItems =
        ((json['participants'] as Map<String, dynamic>?)?['items'] as List?) ??
            const [];

    final filesItems =
        ((json['sharedFiles'] as Map<String, dynamic>?)?['items'] as List?) ??
            const [];

    return ChatDetails(
      conversationId: conversationId,
      roomName: (room['display_name'] ?? room['name'] ?? '') as String,
      contact: ContactInfo(
        id: (profile['id'] ?? '').toString(),
        name: (profile['name'] ?? '') as String,
        email: profile['email'] as String?,
        phone: profile['phone'] as String?,
        avatarUrl: profile['profileImage'] as String?,
      ),
      participants: participantsItems
          .cast<Map<String, dynamic>>()
          .map(ParticipantDto.fromRestJson)
          .toList(growable: false),
      sharedFiles: filesItems
          .cast<Map<String, dynamic>>()
          .map(SharedFileDto.fromRestJson)
          .toList(growable: false),
    );
  }
}
