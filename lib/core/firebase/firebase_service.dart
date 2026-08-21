import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../config/env.dart';
import '../utils/app_logger.dart';
import 'crashlytics_keys.dart';
import 'crashlytics_service.dart';

/// Boot-time Firebase initialization. Tolerant of missing native config
/// (`google-services.json` / `GoogleService-Info.plist`) so dev builds work
/// before `flutterfire configure` has produced them.
///
/// `startApp` calls [initialize] once, right after
/// `WidgetsFlutterBinding.ensureInitialized()` and before any other
/// Firebase-touching code.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Returns true if Firebase was successfully initialized (and the
  /// downstream `AnalyticsService` / `CrashlyticsService` wrappers will
  /// actually fire). Returns false if config was absent — wrappers will
  /// stay in their stub-log mode.
  static bool get isInitialized => _initialized;

  static Future<bool> initialize(Environment env) async {
    if (_initialized) return true;

    try {
      await Firebase.initializeApp();
      _initialized = true;

      // Debug builds: suppress collection so dev sessions don't pollute prod
      // dashboards. `DebugView` is still reachable via the platform-level
      // `debug.firebase.analytics.app` prop when QA needs it.
      try {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
        await FirebaseAnalytics.instance
            .setAnalyticsCollectionEnabled(!kDebugMode);
      } catch (e) {
        AppLogger.w(
          'FirebaseService.initialize: collection toggle failed ($e)',
        );
      }

      CrashlyticsService.registerErrorHandlers();
      await CrashlyticsService.setCustomKey(
        CrashlyticsKeys.flavor,
        env.name,
      );

      if (kDebugMode) {
        AppLogger.d('FirebaseService.initialize: success (flavor=${env.name})');
      }
      return true;
    } catch (e, st) {
      // Most common reason: native config files absent. Swallow + log so the
      // app still boots; telemetry just no-ops until config lands.
      AppLogger.w(
        'FirebaseService.initialize: skipped — '
        'Firebase config likely absent ($e)',
      );
      if (kDebugMode) {
        AppLogger.d('FirebaseService.initialize stack: $st');
      }
      return false;
    }
  }
}
