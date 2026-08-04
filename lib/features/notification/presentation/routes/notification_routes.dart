import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/notification_screen.dart';
import '../screens/notification_section_screen.dart';

/// Notification-feature routes.
final List<RouteBase> notificationRoutes = [
  GoRoute(
    path: Routes.notificationList.path,
    name: Routes.notificationList.name,
    builder: (context, state) => const NotificationScreen(),
  ),
  GoRoute(
    path: Routes.notificationSectionList.path,
    name: Routes.notificationSectionList.name,
    builder: (context, state) {
      final args = NotificationSectionScreenArgs.fromExtra(state.extra);
      return NotificationSectionScreen(args: args);
    },
  ),
];
