import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `roomId` of the chat thread the user is currently viewing, or `null` when
/// no thread is open. `ChatThreadNotifier` sets on `build` and clears in
/// `onDispose`. Read by `ConversationListNotifier` to skip incrementing the
/// unread badge for the room the user is actively reading.
final activeChatRoomProvider = StateProvider<String?>((_) => null);
