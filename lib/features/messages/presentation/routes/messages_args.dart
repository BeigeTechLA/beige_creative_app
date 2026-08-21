import 'package:flutter/foundation.dart';

/// Typed args for `/chat`.
@immutable
class ChatArgs {
  const ChatArgs({required this.conversationId, this.contactName});

  final String conversationId;
  final String? contactName;

  Map<String, dynamic> toExtra() => {
    'conversationId': conversationId,
    'contactName': contactName,
  };

  factory ChatArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return ChatArgs(
      conversationId: (m['conversationId'] as String?) ?? '',
      contactName: m['contactName'] as String?,
    );
  }
}

/// Typed args for `/chat-details`.
@immutable
class ChatDetailsArgs {
  const ChatDetailsArgs({required this.conversationId});

  final String conversationId;

  Map<String, dynamic> toExtra() => {'conversationId': conversationId};

  factory ChatDetailsArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return ChatDetailsArgs(
      conversationId: (m['conversationId'] as String?) ?? '',
    );
  }
}
