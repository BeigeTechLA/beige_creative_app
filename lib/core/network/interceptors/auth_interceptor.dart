import 'package:dio/dio.dart';

/// Injects `Authorization: Bearer <token>` on every request and reacts to
/// explicit session-expiry codes by clearing the session and signalling logout.
/// Also reacts to `ACCOUNT_DELETION_IN_PROGRESS` by signalling deletion-pending state.
///
/// Extends `QueuedInterceptor` (not plain `Interceptor`) so concurrent
/// requests are serialised through one token-read lane.
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() tokenReader;
  final Future<void> Function()? onUnauthorized;
  final Future<void> Function()? onDeletionPending;

  AuthInterceptor({
    required this.tokenReader,
    this.onUnauthorized,
    this.onDeletionPending,
  });

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

  Future<void> _handleSessionError(dynamic data, RequestOptions request) async {
    if (request.extra['_hadAuthToken'] != true) return;
    if (data is! Map) return;
    final code = data['code']?.toString().toUpperCase();

    if (code == 'ACCOUNT_DELETION_IN_PROGRESS' && onDeletionPending != null) {
      await onDeletionPending!();
    }

    final sessionInvalid = code == 'SESSION_EXPIRED' || code == 'TOKEN_INVALID';
    if (sessionInvalid && onUnauthorized != null) {
      await onUnauthorized!();
    }
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    await _handleSessionError(response.data, response.requestOptions);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _handleSessionError(err.response?.data, err.requestOptions);
    handler.next(err);
  }
}
