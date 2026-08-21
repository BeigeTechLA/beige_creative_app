import 'package:dio/dio.dart';

/// Injects `Authorization: Bearer <token>` on every request and reacts to
/// 401 responses by clearing the session and signalling logout.
///
/// Extends `QueuedInterceptor` (not plain `Interceptor`) so concurrent
/// requests are serialised through one token-read lane — important once a
/// refresh-token flow lands. The current backend has no refresh endpoint
/// (per `AUDIT_SEC.md`); 401 is treated as "session over → redirect to login".
///
/// `tokenReader` is async — `SessionStore` may read `flutter_secure_storage`.
/// `onUnauthorized` is async to allow session-clear and router redirect.
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() tokenReader;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor({
    required this.tokenReader,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenReader();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
