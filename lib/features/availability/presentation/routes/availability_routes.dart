import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/add_availability_screen.dart';

/// Availability-feature routes (beyond the root `/manage-availability` tab —
/// that one lives in the StatefulShellRoute in `lib/app/router.dart`).
final List<RouteBase> availabilityRoutes = [
  GoRoute(
    path: '/add-availability',
    name: RouteNames.addAvailability,
    builder: (context, state) => const AddAvailabilityScreen(),
  ),
];
