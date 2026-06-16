import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/messages_repository_impl.dart';
import '../../data/sources/messages_remote_source.dart';
import '../../data/sources/messages_socket_source.dart';
import '../../domain/repositories/messages_repository.dart';

final _remoteMessagesSourceProvider = Provider<MessagesRemoteSource>(
  (ref) => MessagesRemoteSource(
    ref.watch(dioClientProvider),
    ref.watch(sessionStoreProvider),
  ),
);

/// **Singleton** — plain `Provider`, never `autoDispose`. Owns the one
/// `io.Socket` for the app session. See `MESSAGES_M6_API_SOCKET_PLAN.md` §5.0.
final _socketMessagesSourceProvider = Provider<MessagesSocketSource>((ref) {
  final source = MessagesSocketSource(ref.watch(sessionStoreProvider));
  ref.onDispose(source.disconnect);
  return source;
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(
    remote: ref.watch(_remoteMessagesSourceProvider),
    socket: ref.watch(_socketMessagesSourceProvider),
  );
});

/// Owns the socket connection lifecycle relative to auth state.
///
/// Connect when authenticated; disconnect otherwise. Mount once via
/// `ref.watch(chatSocketLifecycleProvider)` in `App.build` so the provider
/// stays alive for the app session — without a watcher Riverpod never builds
/// it.
///
/// Idempotent — `connect()` early-returns when already connected.
final chatSocketLifecycleProvider = Provider<void>((ref) {
  final isAuthed = ref.watch(authStateProvider);
  final socket = ref.watch(_socketMessagesSourceProvider);
  if (isAuthed) {
    unawaited(socket.connect());
  } else {
    unawaited(socket.disconnect());
  }
});