import 'package:dio/dio.dart';

/// Injects `Authorization: Bearer <token>` on every request and reacts to
/// explicit session-expiry codes by clearing the session and signalling logout.
///
/// Extends `QueuedInterceptor` (not plain `Interceptor`) so concurrent
/// requests are serialised through one token-read lane — important once a
/// refresh-token flow lands. The current backend has no refresh endpoint
/// (per `AUDIT_SEC.md`). HTTP status alone never ends a session, and a
/// session-expiry code only ends the session when the failing request actually
/// carried a token (guarded via the `_hadAuthToken` request flag).
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
    final hadToken = token != null && token.isNotEmpty;
    if (hadToken) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Recorded so a session-expiry code only ends the session when the failing
    // request actually carried a token — a tokenless/public-endpoint response
    // must never nuke a fresh session.
    options.extra['_hadAuthToken'] = hadToken;
    handler.next(options);
  }

  bool _endsSession(dynamic data, RequestOptions request) {
    if (request.extra['_hadAuthToken'] != true) return false;
    if (data is! Map) return false;
    final code = data['code']?.toString().toUpperCase();
    return code == 'SESSION_EXPIRED' || code == 'TOKEN_INVALID';
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_endsSession(response.data, response.requestOptions)) {
      await onUnauthorized?.call();
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_endsSession(err.response?.data, err.requestOptions)) {
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
