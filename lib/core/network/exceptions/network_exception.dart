part of 'app_exception.dart';

/// Connectivity dropped before/during the request (SocketException, no route).
final class NoInternetException extends AppException {
  const NoInternetException({
    String message = 'No internet connection',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// Request exceeded the connect/receive timeout.
final class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Request timed out',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// Request was cancelled (CancelToken fired — usually screen disposed).
final class RequestCancelledException extends AppException {
  const RequestCancelledException({
    String message = 'Request was cancelled',
    super.cause,
    super.stackTrace,
  }) : super(message);
}
