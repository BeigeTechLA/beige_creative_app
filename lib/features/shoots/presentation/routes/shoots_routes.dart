import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/shoot_cancelled_lotties_screen.dart';
import '../screens/shoot_cancelled_screen.dart';
import '../screens/upcoming_shoot_view_details_screen.dart';

/// Shoots-feature routes (beyond the root `/shoots` tab — that one lives in
/// the StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> shootsRoutes = [
  GoRoute(
    path: '/upcoming-shoot-details',
    name: RouteNames.upcomingShootDetails,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return UpcomingShootViewDetails(projectid: data["projectId"]);
    },
  ),
  GoRoute(
    path: '/cancel-shoot',
    name: RouteNames.cancelShoot,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return ShootCancelledScreen(projectId: data["projectId"]);
    },
  ),
  GoRoute(
    path: '/shoot-cancelotties',
    name: RouteNames.shootCancelotties,
    builder: (context, state) => const ShootCancelledLottiesScreen(),
  ),
];
