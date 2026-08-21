import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/chat_details_screen.dart';
import '../screens/chat_thread_screen.dart';
import 'messages_args.dart';

/// Messages-feature routes (beyond the `/messages` tab — that one lives in
/// the StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> messagesRoutes = [
  GoRoute(
    path: Routes.chat.path,
    name: Routes.chat.name,
    builder: (context, state) {
      final args = ChatArgs.fromExtra(state.extra);
      return ChatThreadScreen(
        conversationId: args.conversationId,
        contactName: args.contactName,
      );
    },
  ),
  GoRoute(
    path: Routes.chatDetails.path,
    name: Routes.chatDetails.name,
    builder: (context, state) {
      final args = ChatDetailsArgs.fromExtra(state.extra);
      return ChatDetailsScreen(conversationId: args.conversationId);
    },
  ),
];
