import '../../domain/entities/chat_details.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/shared_file.dart';

class ChatDetailsDto {
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
}
