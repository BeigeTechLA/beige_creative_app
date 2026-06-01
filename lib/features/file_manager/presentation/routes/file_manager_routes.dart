import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/post_production_screen.dart';
import '../screens/pre_production_screen.dart';

/// File-manager routes (beyond the root `/files` tab — that one lives in the
/// StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> fileManagerRoutes = [
  GoRoute(
    path: Routes.postProduction.path,
    name: Routes.postProduction.name,
    builder: (context, state) => const PostProductionScreen(),
  ),
  GoRoute(
    path: Routes.preProduction.path,
    name: Routes.preProduction.name,
    builder: (context, state) => const PreProductionScreen(),
  ),
];
