import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/entities/chat_details.dart';
import 'messages_repository_provider.dart';

/// Loads details for a conversation. AsyncValue so screen can branch on
/// loading / error / data without rolling its own state class.
final chatDetailsProvider =
    AutoDisposeFutureProviderFamily<ChatDetails, String>((ref, conversationId) async {
      try {
        return await ref.read(messagesRepositoryProvider).fetchDetails(conversationId);
      } catch (e) {
        if (e is UnauthorizedException) {
          unawaited(ref.read(authStateProvider.notifier).logout());
        }
        rethrow;
      }
    });
