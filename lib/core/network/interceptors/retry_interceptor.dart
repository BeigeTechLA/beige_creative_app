import 'dart:async';

import 'package:dio/dio.dart';

/// Retries 5xx responses with exponential backoff. Never retries 4xx (caller
/// fault) and never retries on `DioExceptionType.cancel` (token tripped).
///
/// Defaults: 3 attempts at 250ms, 500ms, 1000ms.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxAttempts;
  final List<Duration> backoff;

  static const String _attemptKey = '__retry_attempt__';

  RetryInterceptor({
    required this.dio,
    this.maxAttempts = 3,
    this.backoff = const [
      Duration(milliseconds: 250),
      Duration(milliseconds: 500),
      Duration(milliseconds: 1000),
    ],
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (attempt >= maxAttempts) {
      handler.next(err);
      return;
    }
    final delay = backoff[attempt.clamp(0, backoff.length - 1)];
    await Future.delayed(delay);

    final newOptions = err.requestOptions
      ..extra[_attemptKey] = attempt + 1;
    try {
      final response = await dio.fetch<dynamic>(newOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.cancel) return false;
    final status = err.response?.statusCode;
    if (status == null) {
      // No response → transient transport failure, worth a retry.
      return err.type == DioExceptionType.connectionError ||
          err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout;
    }
    return status >= 500 && status < 600;
  }
}
