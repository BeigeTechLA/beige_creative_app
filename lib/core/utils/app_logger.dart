import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../firebase/crashlytics_service.dart';

class AppLogger {
  AppLogger._();

  /// Test seam — overridden by `app_logger_test.dart` so the forwarding
  /// logic in [e] can be asserted without invoking the static
  /// [CrashlyticsService]. Defaults to [defaultCrashRecorder] which forwards
  /// to `CrashlyticsService.recordError`. Reset to [defaultCrashRecorder] in
  /// `tearDown` to keep cross-test state from leaking.
  @visibleForTesting
  static Future<void> Function(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal,
  }) crashRecorder = defaultCrashRecorder;

  /// Production sink — exposed so tests can restore it after stubbing.
  @visibleForTesting
  static Future<void> defaultCrashRecorder(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) =>
      CrashlyticsService.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );

  /// Test seam — overridden by `app_logger_test.dart` to flip the runtime
  /// gate without relying on [kDebugMode] (which is a const true in
  /// `flutter test`). Production code reads [kDebugMode] directly through
  /// this getter.
  @visibleForTesting
  static bool Function() debugModeOverride = _kDebugModeDefault;

  static bool _kDebugModeDefault() => kDebugMode;

  static void d(String message) {
    if (kDebugMode) {
      debugPrint('🐛 [DEBUG] $message');
    }
  }

  static void i(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ [INFO] $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [WARN] $message');
    }
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace:\n$stackTrace');
      }
    }
    // Bridge to Crashlytics non-fatal pipeline. Skip in debug builds (noise
    // during dev; A3 also disables collection there) and when the caller
    // didn't pass an error object (message-only logs are not actionable in
    // Crashlytics). Fire-and-forget — `recordError` swallows its own
    // failures via try/catch + `AppLogger.w`, so no recursion risk.
    if (!debugModeOverride() && error != null) {
      unawaited(
        crashRecorder(
          error,
          stackTrace,
          reason: 'logger.e: $message',
          fatal: false,
        ),
      );
    }
  }
}
