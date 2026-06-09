import '../../domain/events/chat_socket_event.dart';

/// socket.io connection lifecycle. Stubbed for UI phases (M1-M5).
/// Implemented in M6 against `NEXT_PUBLIC_CHAT_SOCKET_URL`-equivalent env
/// using `socket_io_client` with `userId` + `userRole` join handshake.
class MessagesSocketSource {
  Future<void> connect() {
    throw UnimplementedError('Socket source lands in M6');
  }

  Future<void> joinRoom(String conversationId) {
    throw UnimplementedError('Socket source lands in M6');
  }

  Future<void> leaveRoom(String conversationId) {
    throw UnimplementedError('Socket source lands in M6');
  }

  Stream<ChatSocketEvent> events(String conversationId) {
    throw UnimplementedError('Socket source lands in M6');
  }

  Future<void> disconnect() {
    throw UnimplementedError('Socket source lands in M6');
  }
}
