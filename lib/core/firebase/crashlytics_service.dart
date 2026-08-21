import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

/// Thin wrapper in front of `FirebaseCrashlytics`.
///
/// All methods are static and tolerate missing Firebase config — bodies
/// short-circuit before the SDK is touched. In debug builds reporting is
/// suppressed by the SDK itself; the wrapper logs to console as a fallback.
class CrashlyticsService {
  CrashlyticsService._();

  static bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static FirebaseCrashlytics? get _instance =>
      _isFirebaseAvailable ? FirebaseCrashlytics.instance : null;

  /// Wires up Flutter framework + Dart isolate error handlers to forward into
  /// Crashlytics. Idempotent — safe to call from `FirebaseService.initialize`.
  static void registerErrorHandlers() {
    final inst = _instance;
    if (inst == null) return;
    FlutterError.onError = (details) {
      inst.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      inst.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> setCustomKey(String key, Object value) async {
    final inst = _instance;
    if (inst == null) {
      if (kDebugMode) {
        AppLogger.d('Crashlytics(stubbed): setCustomKey $key=$value');
      }
      return;
    }
    try {
      await inst.setCustomKey(key, value);
    } catch (e) {
      AppLogger.w('CrashlyticsService.setCustomKey($key) failed: $e');
    }
  }

  static Future<void> setUserIdentifier(String id) async {
    final inst = _instance;
    if (inst == null) return;
    try {
      await inst.setUserIdentifier(id);
    } catch (e) {
      AppLogger.w('CrashlyticsService.setUserIdentifier failed: $e');
    }
  }

  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    final inst = _instance;
    if (inst == null) {
      AppLogger.e('Crashlytics(stubbed): $error', error, stack);
      return;
    }
    try {
      await inst.recordError(error, stack, reason: reason, fatal: fatal);
    } catch (e) {
      AppLogger.w('CrashlyticsService.recordError failed: $e');
    }
  }

  static Future<void> log(String message) async {
    final inst = _instance;
    if (inst == null) return;
    try {
      await inst.log(message);
    } catch (_) {
      // No-op — logs are best-effort.
    }
  }
}
