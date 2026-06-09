import '../../domain/entities/conversation.dart';

class ConversationDto {
  static Conversation fromJson(Map<String, dynamic> json) {
    final tab = _parseTab(json['tab'] as String?);
    final last = json['lastMessage'] as Map<String, dynamic>?;
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      tab: tab,
      lastMessage: last == null
          ? null
          : ConversationPreview(
              preview: last['preview'] as String,
              sentAt: DateTime.parse(last['sentAt'] as String).toLocal(),
              fromMe: last['fromMe'] as bool,
            ),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: (json['isOnline'] as bool?) ?? false,
      linkedShootId: json['linkedShootId'] as String?,
      participantIds: ((json['participants'] as List?) ?? const [])
          .cast<String>(),
    );
  }

  static ConversationTab _parseTab(String? raw) {
    switch (raw) {
      case 'shoots':
        return ConversationTab.shoots;
      case 'admin':
        return ConversationTab.admin;
      default:
        return ConversationTab.all;
    }
  }
}
