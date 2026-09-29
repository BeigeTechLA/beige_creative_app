import 'package:dio/dio.dart';

/// Injects `Authorization: Bearer <token>` on every request and reacts to
/// explicit session-expiry codes by clearing the session and signalling logout.
///
/// Extends `QueuedInterceptor` (not plain `Interceptor`) so concurrent
/// requests are serialised through one token-read lane — important once a
/// refresh-token flow lands. The current backend has no refresh endpoint
/// (per `AUDIT_SEC.md`). HTTP status alone never ends a session.
///
/// `tokenReader` is async — `SessionStore` may read `flutter_secure_storage`.
/// `onUnauthorized` is async to allow session-clear and router redirect.
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() tokenReader;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor({required this.tokenReader, this.onUnauthorized});

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

  bool _endsSession(dynamic data) {
    if (data is! Map) return false;
    final code = data['code']?.toString().toUpperCase();
    return code == 'SESSION_EXPIRED' || code == 'TOKEN_INVALID';
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_endsSession(response.data)) {
      await onUnauthorized?.call();
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_endsSession(err.response?.data)) {
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
