import 'package:flutter/widgets.dart';

import 'analytics_service.dart';
import 'crashlytics_keys.dart';
import 'crashlytics_service.dart';

/// Project's `NavigatorObserver` wired into `routerProvider.observers`.
///
/// On every push/replace/pop, delegates to the live `FirebaseAnalyticsObserver`
/// (if Firebase config is present) AND records the current route as the
/// Crashlytics `last_route` custom key so crash reports come with breadcrumbs.
///
/// Both delegates are no-ops when Firebase config is missing — keeps dev
/// builds compiling pre-`flutterfire configure`.
class AppAnalyticsObserver extends NavigatorObserver {
  AppAnalyticsObserver() : _delegate = AnalyticsService.buildObserver();

  final NavigatorObserver? _delegate;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _delegate?.didPush(route, previousRoute);
    _recordRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _delegate?.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _recordRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _delegate?.didPop(route, previousRoute);
    if (previousRoute != null) _recordRoute(previousRoute);
  }

  void _recordRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    CrashlyticsService.setCustomKey(CrashlyticsKeys.route, name);
  }
}
