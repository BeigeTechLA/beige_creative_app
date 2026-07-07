import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/env.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/participant.dart';
import '../../domain/events/chat_socket_event.dart';
import 'messages_repository_provider.dart';

/// Resolved once per process — backend's canonical `user.id` for the current
/// session, fetched from `creator/get-profile-detail`. Kept module-level so
/// successive thread opens don't re-hit the endpoint.
String? _cachedSelfUserId;

/// Hits `creator/get-profile-detail` and pulls `user.id` (or `id`/`_id` from
/// the nested user block). Backend uses this same id as `message.sent_by`, so
/// it's the most reliable cross-reference for `isMine`. Cached in
/// [_cachedSelfUserId] for the process lifetime — auth interceptor's bearer
/// token scopes the response automatically.
Future<String?> _fetchSelfUserIdFromProfile(DioClient client) async {
  if (_cachedSelfUserId != null && _cachedSelfUserId!.isNotEmpty) {
    return _cachedSelfUserId;
  }
  try {
    final resp = await client.dio.post<dynamic>(
      ApiEndpoints.profiledetails,
      data: <String, dynamic>{},
    );
    final body = resp.data;
    if (body is! Map) return null;
    final data = body['data'];
    if (data is! Map) return null;
    final user = data['user'];
    String? id;
    if (user is Map) {
      final raw = user['id'] ?? user['_id'] ?? user['user_id'];
      if (raw != null) id = raw.toString();
    }
    id ??= (data['user_id'] ?? data['id'])?.toString();
    if (id != null && id.isNotEmpty) {
      _cachedSelfUserId = id;
      return id;
    }
  } catch (e) {
    AppLogger.w('Profile fetch for self-id failed: $e');
  }
  return null;
}

/// Backend `profile_image` may arrive as a CloudFront key (e.g.
/// `profile_photo_5.jpg`) or a fully-qualified URL. Prefix with [Env.imageUrl]
/// only when relative — matches the pattern used across home/profile widgets.
String? _absoluteAvatar(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http')) return raw;
  return '${Env.imageUrl}$raw';
}

/// Resolves the session user against the room's participant list, falling
/// back to the message thread itself. Tries id match (cheap, exact), then
/// email (unique, stable across name edits), then case-insensitive name —
/// first against [participants], then against [messages] by sender name.
///
/// The message-thread pass is critical for 1-1 rooms where the backend's
/// `participants` block lists only the peer; without it, own messages
/// render on the wrong side until the user sends a new message (which
/// reveals the canonical sender id via `sendText`).
String? _resolveSelfId({
  required List<Participant> participants,
  required List<Message> messages,
  required String? currentUserId,
  required String? email,
  required String? name,
}) {
  if (currentUserId != null && currentUserId.isNotEmpty) {
    for (final p in participants) {
      if (p.id == currentUserId) return p.id;
    }
  }
  final normalizedEmail = email?.trim().toLowerCase();
  if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
    for (final p in participants) {
      if ((p.email?.trim().toLowerCase() ?? '') == normalizedEmail) {
        return p.id;
      }
    }
  }
  final normalizedName = name?.trim().toLowerCase();
  if (normalizedName != null && normalizedName.isNotEmpty) {
    for (final p in participants) {
      if (p.name.trim().toLowerCase() == normalizedName) return p.id;
    }
    for (final m in messages) {
      if (m.senderId.isEmpty) continue;
      if (m.senderName.trim().toLowerCase() == normalizedName) return m.senderId;
    }
  }
  // Last-resort id elimination: backend `participants.items` often lists only
  // the peer in 1-1 rooms. Any senderId in the thread that isn't a known
  // peer is us. Works without trusting session name/email at all.
  final peerIds = participants.map((p) => p.id).toSet();
  final candidates = <String>{
    for (final m in messages)
      if (m.senderId.isNotEmpty && !peerIds.contains(m.senderId)) m.senderId,
  };
  if (candidates.length == 1) return candidates.first;
  return null;
}

@immutable
class ChatThreadState {
  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool peerTyping;
  final bool peerOnline;
  final bool isRecording;
  final String? currentUserId;
  /// Canonical sender directory keyed by participant id (from
  /// `participants.items` in chat details). Bubbles resolve name, role, and
  /// avatar by matching `message.senderId` against this map — message payloads
  /// may omit/stale these fields, participants are the source of truth.
  final Map<String, Participant> participantsById;
  final String? peerName;
  final String? peerAvatarUrl;
  final String? peerRole;
  /// Message the composer will quote in the next send. Set via
  /// `setReplyTarget`, cleared via `clearReply` or after successful send.
  final Message? replyTarget;

  const ChatThreadState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.peerTyping = false,
    this.peerOnline = false,
    this.isRecording = false,
    this.currentUserId,
    this.participantsById = const {},
    this.peerName,
    this.peerAvatarUrl,
    this.peerRole,
    this.replyTarget,
  });

  ChatThreadState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? peerTyping,
    bool? peerOnline,
    bool? isRecording,
    String? currentUserId,
    Map<String, Participant>? participantsById,
    String? peerName,
    String? peerAvatarUrl,
    String? peerRole,
    Message? replyTarget,
    bool clearReplyTarget = false,
  }) {
    return ChatThreadState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      peerTyping: peerTyping ?? this.peerTyping,
      peerOnline: peerOnline ?? this.peerOnline,
      isRecording: isRecording ?? this.isRecording,
      currentUserId: currentUserId ?? this.currentUserId,
      participantsById: participantsById ?? this.participantsById,
      peerName: peerName ?? this.peerName,
      peerAvatarUrl: peerAvatarUrl ?? this.peerAvatarUrl,
      peerRole: peerRole ?? this.peerRole,
      replyTarget:
          clearReplyTarget ? null : (replyTarget ?? this.replyTarget),
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
      if (kDebugMode) {
        debugPrint('[thread] HYDRATE conversationId=$arg');
      }
      final Map<String, Participant> participantsById = {};
      String? currentUserId;
      String? sessionUserName;
      String? sessionUserEmail;
      try {
        final user = await ref.read(sessionStoreProvider).readUser();
        currentUserId = user?.id;
        sessionUserName = user?.name;
        sessionUserEmail = user?.email;
      } catch (_) {
        // Fallback for tests where sessionStoreProvider is not overridden.
      }
      String? peerName;
      String? peerAvatarUrl;
      String? peerRole;
      List<Participant> detailsParticipants = const [];
      try {
        final details = await repo.fetchDetails(arg);
        detailsParticipants = details.participants;
        for (final p in details.participants) {
          participantsById[p.id] = p;
        }
        // AppBar shows chat-room identity, not per-message sender.
        // Prefer the room-level contact (room display_name + avatar). Only
        // fall back to a participant when the room carries no display name
        // (rare — DM rooms can omit `contact`).
        if (details.contact.name.isNotEmpty) {
          peerName = details.contact.name;
          peerAvatarUrl = _absoluteAvatar(details.contact.avatarUrl);
        } else {
          final others = details.participants
              .where((p) => p.id != currentUserId)
              .toList();
          if (others.isNotEmpty) {
            peerName = others.first.name;
            peerAvatarUrl = _absoluteAvatar(others.first.avatarUrl);
            peerRole = others.first.role;
          }
        }
      } on UnauthorizedException {
        rethrow;
      } catch (e) {
        AppLogger.w('Failed to fetch chat details for roles: $e');
      }
      // Join first so any backend events emitted during/after fetch are
      // captured by the listener below. Idempotent on the source side.
      await repo.joinConversation(arg);
      _eventsSub = repo.events(arg).listen(_onEvent);
      final thread = await repo.fetchThread(arg);
      // Authoritative pass: pull canonical `user.id` from the profile
      // endpoint. Backend uses the same id for `message.sent_by`, so this
      // bypasses every mismatch (crew_member_id vs user_id, name/email
      // drift, peer-only participants list). Cached per-process.
      try {
        final profileSelfId = await _fetchSelfUserIdFromProfile(
          ref.read(dioClientProvider),
        );
        if (profileSelfId != null && profileSelfId.isNotEmpty) {
          currentUserId = profileSelfId;
        }
      } catch (_) {
        // Network failure — fall through to the heuristic resolver.
      }
      // Resolve self after both details + thread are in. 1-1 rooms may list
      // only the peer in `participants` — falling back to the message
      // thread's senderName lets `isMine` resolve on first render instead
      // of waiting for the user to send a message.
      final resolvedSelfId = _resolveSelfId(
        participants: detailsParticipants,
        messages: thread.messages,
        currentUserId: currentUserId,
        email: sessionUserEmail,
        name: sessionUserName,
      );
      if (resolvedSelfId != null) {
        currentUserId = resolvedSelfId;
      }
      if (kDebugMode) {
        debugPrint(
          '[thread] self-resolve conversationId=$arg '
          'sessionId=${currentUserId ?? '∅'} '
          'sessionEmail=${sessionUserEmail ?? '∅'} '
          'sessionName=${sessionUserName ?? '∅'} '
          'resolvedSelfId=${resolvedSelfId ?? '∅'} '
          'participantIds=${detailsParticipants.map((p) => p.id).toList()}',
        );
      }
      state = state.copyWith(
        messages: thread.messages,
        isLoading: false,
        currentUserId: currentUserId,
        participantsById: participantsById,
        peerName: peerName,
        peerAvatarUrl: peerAvatarUrl,
        peerRole: peerRole,
      );
      if (thread.messages.isNotEmpty) {
        unawaited(markRead());
      }
    } catch (e, st) {
      AppLogger.e('Chat thread hydrate failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load messages',
      );
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
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

  /// Sets/replaces the reply target. Composer picks it up via `state.replyTarget`.
  void setReplyTarget(Message m) {
    state = state.copyWith(replyTarget: m);
  }

  /// Drops the reply target — called by composer's X button or after send.
  void clearReply() {
    state = state.copyWith(clearReplyTarget: true);
  }

  /// Emoji reaction. POSTs `external-chat/messages/:id/reaction` and patches
  /// the target message's reactions map optimistically so the pill appears
  /// before the socket echo lands. On error, rolls back + surfaces a hint.
  Future<void> sendReaction(String messageId, String emoji) async {
    final selfId = state.currentUserId ?? '';
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.id == messageId)
            m.copyWith(reactions: _addReactor(m.reactions, emoji, selfId))
          else
            m,
      ],
    );
    try {
      await ref.read(messagesRepositoryProvider).sendReaction(
            conversationId: arg,
            messageId: messageId,
            emoji: emoji,
          );
    } catch (e, st) {
      AppLogger.e('Send reaction failed', e, st);
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == messageId)
              m.copyWith(reactions: _removeReactor(m.reactions, emoji, selfId))
            else
              m,
        ],
        errorMessage: 'Could not add reaction',
      );
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
    }
  }

  Map<String, Set<String>> _addReactor(
    Map<String, Set<String>> current,
    String emoji,
    String userId,
  ) {
    final next = <String, Set<String>>{
      for (final entry in current.entries) entry.key: {...entry.value},
    };
    next[emoji] = {...?next[emoji], userId};
    return next;
  }

  Map<String, Set<String>> _removeReactor(
    Map<String, Set<String>> current,
    String emoji,
    String userId,
  ) {
    final next = <String, Set<String>>{
      for (final entry in current.entries) entry.key: {...entry.value},
    };
    final set = next[emoji];
    if (set == null) return next;
    set.remove(userId);
    if (set.isEmpty) next.remove(emoji);
    return next;
  }

  Future<void> sendText(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    // Snapshot the reply target so the optimistic bubble + POST use the same
    // id even if the user changes/clears it mid-flight.
    final replyTarget = state.replyTarget;
    final replyToId = replyTarget?.id;
    final replyPreview = replyTarget == null
        ? null
        : MessageReplyPreview(
            id: replyTarget.id,
            senderId: replyTarget.senderId,
            senderName: replyTarget.senderName,
            type: replyTarget.type,
            body: replyTarget.body,
            fileName: replyTarget.file?.name,
          );

    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = Message(
      id: localId,
      senderId: 'user_me',
      senderName: 'Me',
      type: MessageType.text,
      body: trimmed,
      sentAt: DateTime.now(),
      deliveryStatus: DeliveryStatus.sending,
      replyToId: replyToId,
      replyTo: replyPreview,
    );
    state = state.copyWith(
      messages: [...state.messages, optimistic],
      clearReplyTarget: true,
    );

    try {
      final saved = await ref
          .read(messagesRepositoryProvider)
          .sendText(arg, trimmed, replyToId: replyToId);
      // Backend's `sent_by` is the canonical sender id. Session may persist a
      // different id (e.g. crew_member_id vs user_id) — adopt the saved id so
      // `isMine` resolves correctly for this and any prior socket-echoed own
      // messages on the next rebuild.
      final selfId = saved.senderId.isNotEmpty
          ? saved.senderId
          : state.currentUserId;
      // Preserve the local reply preview if the server echo dropped it —
      // socket payload sometimes omits the expanded `replyTo` block.
      final merged = (saved.replyTo == null && replyPreview != null)
          ? Message(
              id: saved.id,
              senderId: saved.senderId,
              senderName: saved.senderName,
              type: saved.type,
              sentAt: saved.sentAt,
              body: saved.body,
              file: saved.file,
              isEdited: saved.isEdited,
              isDeleted: saved.isDeleted,
              replyToId: saved.replyToId ?? replyToId,
              replyTo: replyPreview,
              deliveryStatus: saved.deliveryStatus,
              reactions: saved.reactions,
            )
          : saved;
      final alreadyReceived = state.messages.any((m) => m.id == merged.id);
      if (alreadyReceived) {
        state = state.copyWith(
          currentUserId: selfId,
          messages: state.messages.where((m) => m.id != localId).toList(),
        );
      } else {
        state = state.copyWith(
          currentUserId: selfId,
          messages: [
            for (final m in state.messages)
              if (m.id == localId) merged else m,
          ],
        );
      }
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
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
    }
  }

  /// Composer → backend pulse. Notifier wraps so the screen doesn't need a
  /// direct repository handle.
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
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
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
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
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
