import 'package:dio/dio.dart';

/// Formats any error object (DioException, Exception, String, etc.) into a clean,
/// user-friendly customer error message suitable for UI overlays and toasts.
///
/// Strips raw stack traces, technical DioException debug dumps, and internal prefixes.
String parseErrorMessage(dynamic error, {String? fallback}) {
  if (error == null) {
    return fallback ?? 'An unexpected error occurred. Please try again.';
  }

  // 1. Extract message if it's a DioException
  if (error is DioException) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final serverMsg = responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          responseData['msg'];
      if (serverMsg != null && serverMsg.toString().trim().isNotEmpty) {
        return _sanitizeMessage(serverMsg.toString(), fallback: fallback);
      }
    }

    // Fallback based on DioExceptionType for network/timeout errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your network and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        break;
    }
  }

  // 2. Fallback for string / Exception objects
  return _sanitizeMessage(error.toString(), fallback: fallback);
}

String _sanitizeMessage(String rawMsg, {String? fallback}) {
  var clean = rawMsg;

  // Extract message after "Error: " if present in technical logs
  if (clean.contains('Error: ')) {
    clean = clean.split('Error: ').last;
  }

  // Strip prefixes like "Exception: ", "ServerException: ", "DioException: ", "Server"
  clean = clean
      .replaceFirst(
        RegExp(
          r'^(Exception|ServerException|DioException|ClientException):\s*',
          caseSensitive: false,
        ),
        '',
      )
      .replaceFirst(RegExp(r'^Server', caseSensitive: false), '')
      .trim();

  // If the message still contains raw DioException technical dumps, return clean fallback
  if (clean.isEmpty ||
      clean.contains('DioException') ||
      clean.contains('RequestOptions') ||
      clean.contains('validateStatus')) {
    return fallback ?? 'An unexpected error occurred. Please try again.';
  }

  return clean;
}
