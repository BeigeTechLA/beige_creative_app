import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import 'crashlytics_keys.dart';
import 'crashlytics_service.dart';

/// Best-effort Crashlytics breadcrumbs for high-risk user actions.
///
/// Call this from presentation/notifier success paths, not repositories. The
/// helper intentionally does not await Firebase calls so UX is never blocked by
/// telemetry.
class CrashlyticsBreadcrumbs {
  CrashlyticsBreadcrumbs._();

  @visibleForTesting
  static Future<void> Function(String key, Object value) setCustomKey =
      CrashlyticsService.setCustomKey;

  @visibleForTesting
  static Future<void> Function(String message) log = CrashlyticsService.log;

  @visibleForTesting
  static void resetForTesting() {
    setCustomKey = CrashlyticsService.setCustomKey;
    log = CrashlyticsService.log;
  }

  static void start({required String featureArea, required String message}) {
    unawaited(setCustomKey(CrashlyticsKeys.featureArea, featureArea));
    unawaited(log(message));
  }

  static void success(String message) {
    unawaited(log(message));
  }

  static void failure(String message) {
    unawaited(log(message));
  }
}
