import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

/// Thin wrapper in front of `FirebaseAnalytics`.
///
/// All methods are static, all bodies tolerate missing Firebase config —
/// `Firebase.apps.isEmpty` short-circuits before the SDK is touched so dev
/// builds work pre-flutterfire-configure. Real config landing is a separate
/// pre-prod task.
class AnalyticsService {
  AnalyticsService._();

  static bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static FirebaseAnalytics? get _instance =>
      _isFirebaseAvailable ? FirebaseAnalytics.instance : null;

  /// Convenience for `routerProvider.observers` — re-exposed so the router
  /// file doesn't import `firebase_analytics` directly.
  ///
  /// [nameExtractor] customises how a route's `screen_name` is computed.
  /// Default is `FirebaseAnalyticsObserver`'s built-in extractor which reads
  /// `route.settings.name`. Phase F passes a custom one so the observer
  /// honours `RouteSpec.trackScreenView` opt-outs.
  static FirebaseAnalyticsObserver? buildObserver({
    ScreenNameExtractor? nameExtractor,
  }) {
    final inst = _instance;
    if (inst == null) return null;
    return FirebaseAnalyticsObserver(
      analytics: inst,
      nameExtractor: nameExtractor ?? defaultNameExtractor,
    );
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    final inst = _instance;
    if (inst == null) {
      if (kDebugMode) {
        AppLogger.d('Analytics(stubbed): $name params=$parameters');
      }
      return;
    }
    try {
      await inst.logEvent(name: name, parameters: parameters);
    } catch (e) {
      AppLogger.w('AnalyticsService.logEvent($name) failed: $e');
    }
  }

  static Future<void> logLogin({String method = 'password'}) async {
    final inst = _instance;
    if (inst == null) return;
    try {
      await inst.logLogin(loginMethod: method);
    } catch (e) {
      AppLogger.w('AnalyticsService.logLogin failed: $e');
    }
  }

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    final inst = _instance;
    if (inst == null) return;
    try {
      await inst.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      AppLogger.w('AnalyticsService.logScreenView($screenName) failed: $e');
    }
  }

  /// Sets the Firebase Analytics user id. Pass `null` on logout to clear.
  static Future<void> setUserId(String? id) async {
    final inst = _instance;
    if (inst == null) return;
    try {
      await inst.setUserId(id: id);
    } catch (e) {
      AppLogger.w('AnalyticsService.setUserId failed: $e');
    }
  }
}
