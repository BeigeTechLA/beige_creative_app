import 'package:go_router/go_router.dart';

/// Meetings-feature routes (beyond the `/meetings` tab — that one lives in
/// the StatefulShellRoute in `lib/app/router.dart`).
///
/// Create / scheduled-success routes removed: CP cannot create meetings per
/// the booking spec — Admin-only on web.
final List<RouteBase> meetingsRoutes = <RouteBase>[];