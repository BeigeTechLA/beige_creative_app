/// Sealed `AppException` hierarchy and its concrete subclasses.
///
/// Repositories return `Either<AppException, T>` rather than throwing.
/// Pattern-match in UI/presentation layers to render friendly errors:
///
/// ```dart
/// switch (failure) {
///   NoInternetException() => 'No internet',
///   UnauthorizedException() => 'Please log in again',
///   ValidationException(:final fieldErrors) => fieldErrors.toString(),
///   _ => 'Something went wrong',
/// }
/// ```
///
/// The concrete subclasses live in adjacent `part` files for organization.
library;

part 'network_exception.dart';
part 'server_exception.dart';
part 'client_exception.dart';

sealed class AppException implements Exception {
  final String message;
  final dynamic cause;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}
