import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
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
    pageBuilder: (context, state) {
      final args = CancelShootArgs.fromExtra(state.extra);
      return CustomTransitionPage<bool>(
        key: state.pageKey,
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.black.withValues(alpha: 0.6),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        child: ShootCancelledScreen(projectId: args.projectId),
      );
    },
  ),
  GoRoute(
    path: Routes.shootCancelotties.path,
    name: Routes.shootCancelotties.name,
    builder: (context, state) => const ShootCancelledLottiesScreen(),
  ),
];
