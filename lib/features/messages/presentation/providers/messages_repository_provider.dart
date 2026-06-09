import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/messages_repository_impl.dart';
import '../../data/sources/messages_dummy_source.dart';
import '../../data/sources/messages_remote_source.dart';
import '../../data/sources/messages_socket_source.dart';
import '../../domain/repositories/messages_repository.dart';

/// Routes all messaging reads/writes to the dummy source while `true`.
/// Flip to `false` in M6 once REST + socket sources land.
final useDummyMessagesProvider = Provider<bool>((ref) => true);

final _dummyMessagesSourceProvider = Provider<MessagesDummySource>(
  (ref) => MessagesDummySource(),
);

final _remoteMessagesSourceProvider = Provider<MessagesRemoteSource>(
  (ref) => MessagesRemoteSource(),
);

final _socketMessagesSourceProvider = Provider<MessagesSocketSource>(
  (ref) => MessagesSocketSource(),
);

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(
    dummy: ref.watch(_dummyMessagesSourceProvider),
    remote: ref.watch(_remoteMessagesSourceProvider),
    socket: ref.watch(_socketMessagesSourceProvider),
    useDummy: ref.watch(useDummyMessagesProvider),
  );
});
