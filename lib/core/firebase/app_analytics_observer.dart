import 'package:flutter/widgets.dart';

import '../../app/routes.dart';
import 'analytics_service.dart';
import 'crashlytics_keys.dart';
import 'crashlytics_service.dart';

/// Project's `NavigatorObserver` wired into `routerProvider.observers`.
///
/// On every push/replace/pop:
/// - delegates to `FirebaseAnalyticsObserver` (if Firebase config is
///   present) which emits `screen_view`. The delegate's `nameExtractor`
///   honours `RouteSpec.trackScreenView` — routes flagged `false` (splash,
///   OTP success surfaces) get no `screen_view`.
/// - writes the current route as the Crashlytics `last_route` custom key
///   so crash reports come with breadcrumbs regardless of the opt-out flag.
///
/// Both delegates are no-ops when Firebase config is missing — keeps dev
/// builds compiling pre-`flutterfire configure`.
class AppAnalyticsObserver extends NavigatorObserver {
  AppAnalyticsObserver()
      : _delegate = AnalyticsService.buildObserver(
          nameExtractor: _trackedNameOf,
        );

  final NavigatorObserver? _delegate;

  /// Returns the screen name to log, or `null` to skip `screen_view` for
  /// this route. Crashlytics breadcrumb is written separately in
  /// `_recordRoute` so the route still appears in crash reports.
  static String? _trackedNameOf(RouteSettings settings) {
    final name = settings.name;
    if (name == null || name.isEmpty) return null;
    final spec = Routes.byName[name];
    if (spec != null && !spec.trackScreenView) return null;
    return name;
  }

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
    final spec = Routes.byName[name];
    if (spec?.featureArea != null) {
      CrashlyticsService.setCustomKey(CrashlyticsKeys.featureArea, spec!.featureArea!);
    }
  }
}
