import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../config/env.dart';
import '../../../../core/session/session_store.dart';
import '../../domain/events/chat_socket_event.dart';
import '../dto/message_dto.dart';

/// **Singleton** owner of the single `io.Socket` for the app session.
///
/// Multiplexes server events into per-room broadcast streams. Held alive by
/// the plain (non-`autoDispose`) `_socketMessagesSourceProvider` in
/// `messages_repository_provider.dart`. See `MESSAGES_M6_API_SOCKET_PLAN.md`
/// §5.0 for lifecycle rules — do not construct directly.
///
/// Transport + event taxonomy mirrors `web-chat-socket-reference.md`.
class MessagesSocketSource {
  MessagesSocketSource(this._session);

  final SessionStore _session;

  io.Socket? _socket;
  UserSnapshot? _user;

  /// Coalesces socket-error emits during reconnect storms. `onConnectError`
  /// + `onError` can fire many times per second while the manager retries —
  /// we surface at most one [SocketErrored] per [_errorThrottleWindow].
  /// Cleared on every successful connect.
  bool _suppressErrors = false;
  Timer? _errorSuppressionTimer;
  static const Duration _errorThrottleWindow = Duration(seconds: 30);

  /// Per-room broadcast streams. Lazily created in [events]. Cleaned up
  /// in [leaveRoom] + [disconnect].
  final Map<String, StreamController<ChatSocketEvent>> _roomControllers = {};

  /// Rooms the client wants to be in. Source of truth for reconnect — every
  /// successful `onConnect` replays `joinRoom` for each id here so the backend
  /// keeps fanning events to this socket. socket.io v4 does **not** auto-rejoin
  /// rooms on reconnect; we have to.
  final Set<String> _activeRoomIds = <String>{};

  /// Bypasses per-room routing — receives every event regardless of room.
  /// Used by the conversation-list notifier for preview/unread refresh.
  final StreamController<ChatSocketEvent> _globalController =
      StreamController<ChatSocketEvent>.broadcast();

  /// Connect-once. Re-entrant safe — repeated calls after a successful
  /// connect are no-ops. Reads user + token from session on first call.
  Future<void> connect() async {
    if (_socket?.connected == true) return;
    if (_socket != null) {
      // Half-open from a previous failed attempt — clean before retry.
      _socket!.dispose();
      _socket = null;
    }

    final user = await _session.readUser();
    if (user == null) {
      // No session — caller (lifecycle provider) should not have called us.
      // Stay silent rather than throw; lifecycle will retry after login.
      return;
    }
    final token = await _session.readToken();
    _user = user;

    final socket = io.io(
      Env.socketUrl,
      io.OptionBuilder()
          .setTransports(const ['websocket', 'polling'])
          .setExtraHeaders({
            if (token != null && token.isNotEmpty) 'Authorization': token,
          })
          .setAuth({
            if (token != null && token.isNotEmpty) 'token': token,
            'userId': user.id,
            if (user.role != null) 'userRole': user.role,
          })
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(15000)
          .build(),
    );

    _socket = socket;
    _bindLifecycle(socket);
    _bindServerEvents(socket);
  }

  /// Join the per-user notification room + the selected chat room.
  /// Safe to call before [connect] resolves — handshake replays on reconnect
  /// via the cached `_user` snapshot.
  ///
  /// Adds [conversationId] to [_activeRoomIds] so reconnect can replay.
  Future<void> joinRoom(String conversationId) async {
    _activeRoomIds.add(conversationId);
    final user = _user ?? await _session.readUser();
    if (user == null) return;
    _emitJoinRoom(conversationId, user);
  }

  /// Best-effort leave — closes the per-room stream regardless of socket
  /// state. Backend may or may not support an explicit `leaveRoom` event
  /// (plan §11 Q10); emit anyway and let the server ignore unknown events.
  ///
  /// Removes [conversationId] from [_activeRoomIds] so reconnect skips it.
  Future<void> leaveRoom(String conversationId) async {
    _activeRoomIds.remove(conversationId);
    _socket?.emit('leaveRoom', {'roomId': conversationId});
    await _roomControllers.remove(conversationId)?.close();
  }

  void _emitJoinRoom(String roomId, UserSnapshot user) {
    _socket?.emit('joinRoom', {
      'roomId': roomId,
      'userId': user.id,
      'userName': user.name ?? '',
    });
  }

  /// Per-room event stream. Broadcast so multiple listeners (notifier +
  /// debug overlay) can subscribe.
  Stream<ChatSocketEvent> events(String conversationId) {
    return _roomControllers
        .putIfAbsent(
          conversationId,
          () => StreamController<ChatSocketEvent>.broadcast(),
        )
        .stream;
  }

  /// Global event firehose for cross-room listeners (conversation list).
  Stream<ChatSocketEvent> globalEvents() => _globalController.stream;

  /// Composer → broadcast typing status to room.
  void emitTyping(String conversationId) {
    final user = _user;
    if (user == null) return;
    _socket?.emit('userTyping', {
      'roomId': conversationId,
      'userId': user.id,
      'userName': user.name ?? '',
    });
  }

  void emitStopTyping(String conversationId) {
    final user = _user;
    if (user == null) return;
    _socket?.emit('stopTyping', {
      'roomId': conversationId,
      'userId': user.id,
    });
  }

  /// Disconnect + close all per-room streams. Called on logout via
  /// `chatSocketLifecycleProvider`.
  Future<void> disconnect() async {
    _errorSuppressionTimer?.cancel();
    _errorSuppressionTimer = null;
    _suppressErrors = false;
    _socket?.dispose();
    _socket = null;
    _user = null;
    _activeRoomIds.clear();
    for (final ctrl in _roomControllers.values) {
      await ctrl.close();
    }
    _roomControllers.clear();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Internal
  // ═══════════════════════════════════════════════════════════════════════

  void _bindLifecycle(io.Socket socket) {
    socket.onConnect((_) {
      // Healthy connection — reopen the error gate so the next storm can
      // surface a fresh banner.
      _suppressErrors = false;
      _errorSuppressionTimer?.cancel();
      _errorSuppressionTimer = null;

      final user = _user;
      if (user == null) return;
      // Auto-join notification room on every (re)connect so unread counts
      // resume after transient drops.
      socket.emit('joinNotificationRoom', {
        'userId': user.id,
        if (user.role != null) 'userRole': user.role,
      });
      // socket.io v4 does not auto-rejoin chat rooms after reconnect —
      // replay every active join so the backend resumes fanning room events
      // to this socket.id.
      for (final roomId in _activeRoomIds) {
        _emitJoinRoom(roomId, user);
      }
    });

    socket.onConnectError((data) {
      _emitSocketError('Socket connect error: $data');
    });

    socket.onError((data) {
      _emitSocketError('Socket error: $data');
    });

    socket.onReconnect((_) {
      // No-op: onConnect already replays joinNotificationRoom + clears
      // error suppression.
    });

    socket.onDisconnect((reason) {
      if (kDebugMode) {
        debugPrint('[MessagesSocketSource] disconnected: $reason');
      }
    });
  }

  /// Coalesced error surface — one emit per [_errorThrottleWindow] until the
  /// next successful connect. Prevents reconnect storms from flooding the UI.
  void _emitSocketError(String message) {
    if (_suppressErrors) return;
    _suppressErrors = true;
    _errorSuppressionTimer?.cancel();
    _errorSuppressionTimer = Timer(_errorThrottleWindow, () {
      _suppressErrors = false;
    });
    _emitGlobal(SocketErrored(message));
  }

  void _bindServerEvents(io.Socket socket) {
    socket.on('message', (raw) {
      final payload = _asMap(raw);
      if (payload == null) return;
      final roomId = (payload['roomId'] ?? payload['chat_room_id'])?.toString();
      if (roomId == null) return;
      final msg = MessageDto.fromSocketJson(payload);
      _fan(roomId, MessageReceived(roomId, msg));
    });

    socket.on('messageEdited', (raw) {
      final p = _asMap(raw);
      if (p == null) return;
      final roomId = (p['roomId'] ?? p['chat_room_id'])?.toString();
      final messageId = (p['messageId'] ?? p['_id'])?.toString();
      final newBody = (p['message'] ?? p['content']) as String?;
      if (roomId == null || messageId == null || newBody == null) return;
      _fan(roomId, MessageEdited(roomId, messageId, newBody));
    });

    socket.on('messageDeleted', (raw) {
      final p = _asMap(raw);
      if (p == null) return;
      final roomId = (p['roomId'] ?? p['chat_room_id'])?.toString();
      final messageId = (p['messageId'] ?? p['_id'])?.toString();
      if (roomId == null || messageId == null) return;
      _fan(roomId, MessageDeleted(roomId, messageId));
    });

    socket.on('updateChatRoom', (raw) {
      final p = _asMap(raw);
      final roomId = p?['roomId']?.toString();
      if (roomId == null) return;
      _fan(roomId, RoomPreviewUpdated(roomId));
    });

    socket.on('participantAdded', (raw) => _participantsChanged(raw));
    socket.on('participantRemoved', (raw) => _participantsChanged(raw));

    socket.on('chatRoomStatusChanged', (raw) {
      final p = _asMap(raw);
      final roomId = p?['roomId']?.toString();
      final status = (p?['status'] ?? '') as String;
      if (roomId == null) return;
      _fan(roomId, RoomStatusChanged(roomId, status));
    });

    socket.on('notification:new', (raw) {
      final p = _asMap(raw);
      final roomId = p?['roomId']?.toString();
      final body = (p?['body'] ?? p?['message'] ?? '') as String;
      _emitGlobal(NotificationReceived(body, conversationId: roomId));
      if (roomId != null) _fan(roomId, NotificationReceived(body, conversationId: roomId));
    });

    socket.on('userTyping', (raw) {
      final p = _asMap(raw);
      final roomId = p?['roomId']?.toString();
      final userId = p?['userId']?.toString();
      final userName = (p?['userName'] ?? '') as String;
      if (roomId == null || userId == null) return;
      // Suppress own-typing echo so the composer doesn't see itself.
      if (userId == _user?.id) return;
      _fan(roomId, TypingStarted(roomId, userId, userName));
    });

    socket.on('stopTyping', (raw) {
      final p = _asMap(raw);
      final roomId = p?['roomId']?.toString();
      final userId = p?['userId']?.toString();
      if (roomId == null || userId == null) return;
      if (userId == _user?.id) return;
      _fan(roomId, TypingStopped(roomId, userId));
    });

    socket.on('socketError', (raw) {
      final p = _asMap(raw);
      final msg = (p?['message'] ?? 'Unknown socket error') as String;
      _emitSocketError(msg);
    });
  }

  void _participantsChanged(dynamic raw) {
    final p = _asMap(raw);
    final roomId = p?['roomId']?.toString();
    if (roomId == null) return;
    _fan(roomId, ParticipantsChanged(roomId));
  }

  /// Routes an event to the per-room stream (if any) AND the global firehose.
  void _fan(String roomId, ChatSocketEvent event) {
    _roomControllers[roomId]?.add(event);
    _emitGlobal(event);
  }

  void _emitGlobal(ChatSocketEvent event) {
    if (_globalController.isClosed) return;
    _globalController.add(event);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return null;
  }
}
