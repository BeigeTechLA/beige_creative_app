import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/shoot_cancelled_lotties_screen.dart';
import '../screens/shoot_cancelled_screen.dart';
import '../screens/upcoming_shoot_view_details_screen.dart';
import 'shoots_args.dart';

/// Shoots-feature routes (beyond the root `/shoots` tab — that one lives in
/// the StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> shootsRoutes = [
  GoRoute(
    path: Routes.upcomingShootDetails.path,
    name: Routes.upcomingShootDetails.name,
    builder: (context, state) {
      final args = UpcomingShootDetailsArgs.fromExtra(state.extra);
      return UpcomingShootViewDetails(projectid: args.projectId);
    },
  ),
  GoRoute(
    path: Routes.cancelShoot.path,
    name: Routes.cancelShoot.name,
    builder: (context, state) {
      final args = CancelShootArgs.fromExtra(state.extra);
      return ShootCancelledScreen(projectId: args.projectId);
    },
  ),
  GoRoute(
    path: Routes.shootCancelotties.path,
    name: Routes.shootCancelotties.name,
    builder: (context, state) => const ShootCancelledLottiesScreen(),
  ),
];
