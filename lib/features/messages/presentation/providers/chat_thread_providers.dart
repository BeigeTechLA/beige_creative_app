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
    final repo = ref.read(messagesRepositoryProvider);
    ref.onDispose(() {
      _eventsSub?.cancel();
      _eventsSub = null;
      // Best-effort leave — socket source closes per-room stream regardless
      // of connection state.
      unawaited(repo.leaveConversation(arg));
    });
    Future.microtask(_hydrate);
    return const ChatThreadState(isLoading: true);
  }

  Future<void> _hydrate() async {
    final repo = ref.read(messagesRepositoryProvider);
    try {
      // Join first so any backend events emitted during/after fetch are
      // captured by the listener below. Idempotent on the source side.
      await repo.joinConversation(arg);
      _eventsSub = repo.events(arg).listen(_onEvent);
      final thread = await repo.fetchThread(arg);
      state = state.copyWith(messages: thread.messages, isLoading: false);
      if (thread.messages.isNotEmpty) {
        unawaited(markRead());
      }
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
        // Dedupe — backend echoes our own POSTed messages back via socket.
        // `sendText` already swapped the optimistic placeholder with the
        // server's saved Message (same id) before this fires. If the id is
        // present, bump status only.
        final existing = state.messages.indexWhere((m) => m.id == message.id);
        if (existing >= 0) {
          final patched = [...state.messages];
          patched[existing] = patched[existing].copyWith(
            deliveryStatus: DeliveryStatus.delivered,
          );
          state = state.copyWith(messages: patched);
        } else {
          state = state.copyWith(messages: [...state.messages, message]);
          // Genuine inbound message (not our own echo) — flush read receipt.
          unawaited(markRead());
        }
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
      case SocketErrored():
        // Throttled at the socket source (≤1 per 30s until reconnect), so
        // surfacing here is a one-shot user-visible banner per outage.
        state = state.copyWith(
          errorMessage: 'Connection lost. Reconnecting…',
        );
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

  /// Composer → backend pulse. No-op on dummy. Notifier wraps so the screen
  /// doesn't need a direct repository handle.
  void notifyTyping() =>
      ref.read(messagesRepositoryProvider).notifyTyping(arg);

  void notifyStopTyping() =>
      ref.read(messagesRepositoryProvider).notifyStopTyping(arg);

  /// Marks the room read on the backend. Called on hydrate, on every genuine
  /// inbound `MessageReceived`, and on app resume from the screen.
  /// Backend `PATCH /external-chat/room/:roomId/mark-read` takes no `upTo`
  /// field today (REST §4) — `upToMessageId` is forwarded for future
  /// per-message granularity but currently dropped server-side.
  Future<void> markRead() async {
    final latestId = state.messages.isEmpty ? '' : state.messages.last.id;
    try {
      await ref.read(messagesRepositoryProvider).markRead(arg, latestId);
    } catch (e, st) {
      // Read receipts are best-effort — never bubble to UI.
      AppLogger.e('Mark read failed', e, st);
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
