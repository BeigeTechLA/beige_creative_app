import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/app_logger.dart';

/// Dev-only request/response logger. Gated by `kDebugMode` so it compiles out
/// of release builds (tree-shaken when bodies are empty).
///
/// **Never logs the `Authorization` header value** — token leakage was an
/// AUDIT_SEC finding for the legacy `ApiService` logger.
class LoggingInterceptor extends Interceptor {
  static const String _redacted = '<redacted>';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final safeHeaders = _redactSensitive(options.headers);
      AppLogger.d(
        '→ ${options.method} ${options.uri}\n'
        '  headers: $safeHeaders\n'
        '  data: ${options.data}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      AppLogger.d(
        '← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.w(
        '✗ ${err.type} ${err.requestOptions.uri} '
        '(status=${err.response?.statusCode})',
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _redactSensitive(Map<String, dynamic> headers) {
    final clone = Map<String, dynamic>.from(headers);
    for (final key in clone.keys.toList()) {
      if (key.toLowerCase() == 'authorization' ||
          key.toLowerCase() == 'cookie' ||
          key.toLowerCase() == 'x-api-key') {
        clone[key] = _redacted;
      }
    }
    return clone;
  }
}
