import '../../domain/entities/chat_details.dart';
import 'participant_dto.dart';
import 'shared_file_dto.dart';

class ChatDetailsDto {
  /// REST shape from `GET /external-chat/room/:roomId/details`.
  ///
  /// Backend returns:
  /// ```
  /// { success, data: { room, profile, participants: { items, ... },
  ///   sharedFiles: { items, ... } } }
  /// ```
  /// `PaginationEnvelope.unwrapItem` strips `data`, so this receives the
  /// inner object.
  ///
  /// `conversationId` is passed in because backend response may not echo it
  /// under a stable key.
  static ChatDetails fromRestJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    final room = (json['room'] as Map<String, dynamic>?) ?? const {};
    final profile = (json['profile'] ??
            room['client_snapshot'] ??
            json['contact'] ??
            json['client'])
        as Map<String, dynamic>?;

    final participantsBlock = json['participants'];
    final List participantsRaw = participantsBlock is Map<String, dynamic>
        ? (participantsBlock['items'] as List? ?? const [])
        : (participantsBlock as List? ?? const []);

    final filesBlock = json['sharedFiles'] ?? json['shared_files'];
    final List filesRaw = filesBlock is Map<String, dynamic>
        ? (filesBlock['items'] as List? ?? const [])
        : (filesBlock as List? ?? const []);

    return ChatDetails(
      conversationId: conversationId,
      contact: ContactInfo(
        id: (profile?['id'] ??
                profile?['_id'] ??
                json['id'] ??
                json['_id'] ??
                '')
            .toString(),
        name: (profile?['name'] ??
                room['display_name'] ??
                room['name'] ??
                json['room_name'] ??
                json['name'] ??
                '')
            as String,
        email: (profile?['email'] ??
            room['contact_email'] ??
            json['contact_email'] ??
            json['email']) as String?,
        phone: (profile?['phone'] ??
            room['contact_phone'] ??
            json['contact_phone'] ??
            json['phone']) as String?,
        avatarUrl: (profile?['profileImage'] ??
            profile?['profile_image'] ??
            profile?['avatar_url'] ??
            json['avatar_url'] ??
            json['profileImage'] ??
            json['profile_image']) as String?,
      ),
      participants: participantsRaw
          .cast<Map<String, dynamic>>()
          .map(ParticipantDto.fromRestJson)
          .toList(growable: false),
      sharedFiles: filesRaw
          .cast<Map<String, dynamic>>()
          .map(SharedFileDto.fromRestJson)
          .toList(growable: false),
    );
  }
}
