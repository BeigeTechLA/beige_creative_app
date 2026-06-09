import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_details.dart';
import 'messages_repository_provider.dart';

/// Loads details for a conversation. AsyncValue so screen can branch on
/// loading / error / data without rolling its own state class.
final chatDetailsProvider =
    AutoDisposeFutureProviderFamily<ChatDetails, String>((ref, conversationId) {
      return ref.read(messagesRepositoryProvider).fetchDetails(conversationId);
    });
