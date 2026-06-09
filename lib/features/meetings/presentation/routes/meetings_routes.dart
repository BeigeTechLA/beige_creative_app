import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/create_meeting_screen.dart';
import '../screens/meeting_scheduled_screen.dart';

/// Meetings-feature routes (beyond the `/meetings` tab — that one lives in
/// the StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> meetingsRoutes = [
  GoRoute(
    path: Routes.meetingCreate.path,
    name: Routes.meetingCreate.name,
    builder: (context, state) => const CreateMeetingScreen(),
  ),
  GoRoute(
    path: Routes.meetingScheduled.path,
    name: Routes.meetingScheduled.name,
    builder: (context, state) => const MeetingScheduledScreen(),
  ),
];
