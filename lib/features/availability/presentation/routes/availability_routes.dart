import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/add_availability_screen.dart';

/// Availability-feature routes (beyond the root `/manage-availability` tab —
/// that one lives in the StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> availabilityRoutes = [
  GoRoute(
    path: Routes.addAvailability.path,
    name: Routes.addAvailability.name,
    builder: (context, state) => const AddAvailabilityScreen(),
  ),
];
