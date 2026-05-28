part of 'app_exception.dart';

/// HTTP 401 — token expired, missing, or invalid. AuthInterceptor should
/// trigger refresh/logout flow before this surfaces to the repository.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 403 — authenticated but not permitted.
final class ForbiddenException extends AppException {
  const ForbiddenException({
    String message = 'Forbidden',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 404 — resource not found.
final class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Not found',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 422 — request validation failed. `fieldErrors` maps field name to
/// the list of error strings the backend returned. Auth signup3 consumes
/// this directly.
final class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    String message = 'Validation failed',
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 429 — caller is rate-limited.
final class TooManyRequestsException extends AppException {
  final Duration? retryAfter;

  const TooManyRequestsException({
    String message = 'Too many requests',
    this.retryAfter,
    super.cause,
    super.stackTrace,
  }) : super(message);
}
