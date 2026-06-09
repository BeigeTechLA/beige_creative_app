import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/message.dart';
import '../../domain/events/chat_socket_event.dart';
import 'messages_repository_provider.dart';

@immutable
class ChatThreadState {
  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool peerTyping;
  final bool peerOnline;
  final bool isRecording;

  const ChatThreadState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.peerTyping = false,
    this.peerOnline = false,
    this.isRecording = false,
  });

  ChatThreadState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? peerTyping,
    bool? peerOnline,
    bool? isRecording,
  }) {
    return ChatThreadState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      peerTyping: peerTyping ?? this.peerTyping,
      peerOnline: peerOnline ?? this.peerOnline,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}

class ChatThreadNotifier
    extends AutoDisposeFamilyNotifier<ChatThreadState, String> {
  StreamSubscription<ChatSocketEvent>? _eventsSub;

  @override
  ChatThreadState build(String arg) {
    ref.onDispose(() {
      _eventsSub?.cancel();
      _eventsSub = null;
    });
    Future.microtask(_hydrate);
    return const ChatThreadState(isLoading: true);
  }

  Future<void> _hydrate() async {
    final repo = ref.read(messagesRepositoryProvider);
    try {
      final thread = await repo.fetchThread(arg);
      state = state.copyWith(messages: thread.messages, isLoading: false);
      _eventsSub = repo.events(arg).listen(_onEvent);
    } catch (e, st) {
      AppLogger.e('Chat thread hydrate failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load messages',
      );
    }
  }

  void _onEvent(ChatSocketEvent event) {
    switch (event) {
      case MessageReceived(:final conversationId, :final message)
          when conversationId == arg:
        state = state.copyWith(messages: [...state.messages, message]);
      case MessageEdited(
            :final conversationId,
            :final messageId,
            :final newBody,
          )
          when conversationId == arg:
        state = state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == messageId)
                m.copyWith(body: newBody, isEdited: true)
              else
                m,
          ],
        );
      case MessageDeleted(:final conversationId, :final messageId)
          when conversationId == arg:
        state = state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == messageId) m.copyWith(isDeleted: true) else m,
          ],
        );
      case TypingStarted(:final conversationId) when conversationId == arg:
        state = state.copyWith(peerTyping: true);
      case TypingStopped(:final conversationId) when conversationId == arg:
        state = state.copyWith(peerTyping: false);
      case PresenceChanged(:final isOnline):
        state = state.copyWith(peerOnline: isOnline);
      case _:
        // Other events (read receipts, room preview, etc.) ignored here —
        // conversationListProvider handles preview refresh in its own scope.
        break;
    }
  }

  Future<void> sendText(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = Message(
      id: localId,
      senderId: 'user_me',
      senderName: 'Me',
      type: MessageType.text,
      body: trimmed,
      sentAt: DateTime.now(),
      deliveryStatus: DeliveryStatus.sending,
    );
    state = state.copyWith(messages: [...state.messages, optimistic]);

    try {
      final saved = await ref
          .read(messagesRepositoryProvider)
          .sendText(arg, trimmed);
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == localId) saved else m,
        ],
      );
    } catch (e, st) {
      AppLogger.e('Send text failed', e, st);
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == localId)
              m.copyWith(deliveryStatus: DeliveryStatus.failed)
            else
              m,
        ],
        errorMessage: 'Could not send message',
      );
    }
  }

  void toggleRecording() {
    state = state.copyWith(isRecording: !state.isRecording);
  }

  Future<void> finishRecording(Duration duration) async {
    state = state.copyWith(isRecording: false);
    try {
      final saved = await ref
          .read(messagesRepositoryProvider)
          .sendAudio(arg, 'local://voice', duration);
      state = state.copyWith(messages: [...state.messages, saved]);
    } catch (e, st) {
      AppLogger.e('Send audio failed', e, st);
      state = state.copyWith(errorMessage: 'Could not send voice note');
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final chatThreadProvider =
    AutoDisposeNotifierProviderFamily<
      ChatThreadNotifier,
      ChatThreadState,
      String
    >(ChatThreadNotifier.new);
