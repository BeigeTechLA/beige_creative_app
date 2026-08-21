part of 'app_exception.dart';

/// Generic 5xx server failure (excludes 503, which uses [ServiceUnavailableException]).
final class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    String message = 'Server error',
    this.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 503 — service temporarily unavailable (often retryable).
final class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException({
    String message = 'Service unavailable',
    super.cause,
    super.stackTrace,
  }) : super(message);
}
