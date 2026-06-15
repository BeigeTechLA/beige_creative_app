import '../../domain/entities/chat_details.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/shared_file.dart';
import 'participant_dto.dart';
import 'shared_file_dto.dart';

class ChatDetailsDto {
  /// Canonical dummy-fixture shape. Used by `MessagesDummySource`.
  static ChatDetails fromJson(Map<String, dynamic> json) {
    final contactRaw = json['contact'] as Map<String, dynamic>;
    final shootRaw = json['linkedShoot'] as Map<String, dynamic>?;
    return ChatDetails(
      conversationId: json['conversationId'] as String,
      contact: ContactInfo(
        id: contactRaw['id'] as String,
        name: contactRaw['name'] as String,
        email: contactRaw['email'] as String?,
        phone: contactRaw['phone'] as String?,
        avatarUrl: contactRaw['avatarUrl'] as String?,
      ),
      participants: ((json['participants'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(
            (p) => Participant(
              id: p['id'] as String,
              name: p['name'] as String,
              role: p['role'] as String,
              avatarUrl: p['avatarUrl'] as String?,
            ),
          )
          .toList(growable: false),
      linkedShoot: shootRaw == null
          ? null
          : LinkedShoot(
              id: shootRaw['id'] as String,
              title: shootRaw['title'] as String,
              date: DateTime.parse(shootRaw['date'] as String).toLocal(),
            ),
      sharedFiles: ((json['sharedFiles'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(
            (f) => SharedFile(
              id: f['id'] as String,
              name: f['name'] as String,
              mimeType: f['mimeType'] as String,
              sizeBytes: (f['sizeBytes'] as num).toInt(),
              uploadedAt: DateTime.parse(f['uploadedAt'] as String).toLocal(),
            ),
          )
          .toList(growable: false),
      notes: (json['notes'] as String?) ?? '',
    );
  }

  /// REST shape from `GET /external-chat/room/:roomId/details`.
  /// Assumed shape — confirm with backend (plan §3.3, §11 Q1).
  ///
  /// `conversationId` is passed in because backend response may not echo it
  /// under a stable key.
  static ChatDetails fromRestJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    final contactRaw = (json['contact'] ?? json['client']) as Map<String, dynamic>?;
    final shootRaw = (json['linked_shoot'] ?? json['linkedShoot'] ?? json['booking'])
        as Map<String, dynamic>?;
    final participantsRaw = (json['participants'] as List?) ?? const [];
    final filesRaw = (json['shared_files'] ?? json['sharedFiles'] ?? const []) as List;

    return ChatDetails(
      conversationId: conversationId,
      contact: ContactInfo(
        id: (contactRaw?['id'] ?? contactRaw?['_id'] ?? '').toString(),
        name: (contactRaw?['name'] ?? json['room_name'] ?? '') as String,
        email: (contactRaw?['email'] ?? json['contact_email']) as String?,
        phone: (contactRaw?['phone'] ?? json['contact_phone']) as String?,
        avatarUrl: (contactRaw?['avatar_url'] ??
            contactRaw?['profile_image'] ??
            json['avatar_url']) as String?,
      ),
      participants: participantsRaw
          .cast<Map<String, dynamic>>()
          .map(ParticipantDto.fromRestJson)
          .toList(growable: false),
      linkedShoot: shootRaw == null
          ? null
          : LinkedShoot(
              id: (shootRaw['id'] ?? shootRaw['_id']).toString(),
              title: (shootRaw['title'] ?? shootRaw['name'] ?? '') as String,
              date: DateTime.parse(
                (shootRaw['date'] ?? shootRaw['shoot_date'] ?? shootRaw['createdAt']).toString(),
              ).toLocal(),
            ),
      sharedFiles: filesRaw
          .cast<Map<String, dynamic>>()
          .map(SharedFileDto.fromRestJson)
          .toList(growable: false),
      notes: (json['notes'] as String?) ?? '',
    );
  }
}
