import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/post_production_screen.dart';
import '../screens/pre_production_screen.dart';

/// File-manager routes (beyond the root `/files` tab — that one lives in the
/// StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> fileManagerRoutes = [
  GoRoute(
    path: '/post-production',
    name: RouteNames.postProduction,
    builder: (context, state) => const PostProductionScreen(),
  ),
  GoRoute(
    path: '/pre-production',
    name: RouteNames.preProduction,
    builder: (context, state) => const PreProductionScreen(),
  ),
];
