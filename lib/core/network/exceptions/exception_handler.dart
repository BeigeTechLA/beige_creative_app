import 'dart:async' as dart_async;
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../firebase/crashlytics_service.dart';
import 'app_exception.dart';

/// Wraps async work in a typed-error envelope.
///
/// Maps the common low-level failure modes (DioException, SocketException,
/// dart:async TimeoutException) into the sealed [AppException] hierarchy and
/// hands back `Either<AppException, T>`.
///
/// Repository pattern:
///
/// ```dart
/// Future<Either<AppException, UserEntity>> login(...) =>
///   ExceptionHandler.guardAsync(() async {
///     final dto = await _remote.login(...);
///     return dto.toEntity();
///   });
/// ```
///
/// Never use raw try/catch in repositories — funnel through here so the
/// exception map stays in one place.
class ExceptionHandler {
  ExceptionHandler._();

  /// Test seam. Overridden by `exception_handler_test.dart` to capture the
  /// forward calls without invoking the static [CrashlyticsService]. Always
  /// `unawaited`-able. Default forwards to [CrashlyticsService.recordError].
  ///
  /// Reset to [defaultCrashRecorder] in `tearDown` so cross-test state can't
  /// leak.
  @visibleForTesting
  static Future<void> Function(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal,
  }) crashRecorder = defaultCrashRecorder;

  /// The production sink — exposed so tests can restore it after stubbing.
  @visibleForTesting
  static Future<void> defaultCrashRecorder(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) =>
      CrashlyticsService.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );

  static Future<Either<AppException, T>> guardAsync<T>(
    Future<T> Function() body,
  ) async {
    try {
      final result = await body();
      return Right(result);
    } on DioException catch (e, st) {
      final mapped = mapDioException(e, st);
      // Forward only the signal-rich branches to Crashlytics. Skip noise:
      // NoInternet / Timeout / RequestCancelled / 401 / 403 / 404 / 429 / 503.
      switch (mapped) {
        case ServerException():
          dart_async.unawaited(
            crashRecorder(
              mapped,
              st,
              reason: 'dio.5xx',
              fatal: false,
            ),
          );
        case ValidationException():
          dart_async.unawaited(
            crashRecorder(
              mapped,
              st,
              reason: 'dio.422',
              fatal: false,
            ),
          );
        case NoInternetException():
        case TimeoutException():
        case RequestCancelledException():
        case UnauthorizedException():
        case ForbiddenException():
        case NotFoundException():
        case TooManyRequestsException():
        case ServiceUnavailableException():
          // Skip — user-visible or expected; would just be noise.
          break;
      }
      return Left(mapped);
    } on SocketException catch (e, st) {
      // Skip — connectivity blip, not a defect.
      return Left(
        NoInternetException(cause: e, stackTrace: st),
      );
    } on dart_async.TimeoutException catch (e, st) {
      // Skip — same reason as SocketException.
      return Left(
        TimeoutException(cause: e, stackTrace: st),
      );
    } on AppException catch (e) {
      // Caller already classified; trust them and don't double-report.
      return Left(e);
    } catch (e, st) {
      // Unknown shape — always forward so the bug isn't silently mapped away.
      dart_async.unawaited(
        crashRecorder(
          e,
          st,
          reason: 'guard.unexpected',
          fatal: false,
        ),
      );
      return Left(
        ServerException(
          message: 'Unexpected error: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Public for re-use by `ErrorInterceptor` so the Dio → AppException
  /// mapping rules live in exactly one place.
  static AppException mapDioException(DioException e, StackTrace st) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(cause: e, stackTrace: st);
      case DioExceptionType.cancel:
        return RequestCancelledException(cause: e, stackTrace: st);
      case DioExceptionType.connectionError:
        return NoInternetException(cause: e, stackTrace: st);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return NoInternetException(cause: e, stackTrace: st);
        }
        return ServerException(
          message: e.message ?? 'Unknown network error',
          cause: e,
          stackTrace: st,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(e, st);
    }
  }

  static AppException _mapStatusCode(DioException e, StackTrace st) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final serverMessage = _extractMessage(data);
    switch (status) {
      case 401:
        return UnauthorizedException(
          message: serverMessage ?? 'Unauthorized',
          cause: e,
          stackTrace: st,
        );
      case 403:
        return ForbiddenException(
          message: serverMessage ?? 'Forbidden',
          cause: e,
          stackTrace: st,
        );
      case 404:
        return NotFoundException(
          message: serverMessage ?? 'Not found',
          cause: e,
          stackTrace: st,
        );
      case 422:
        return ValidationException(
          message: serverMessage ?? 'Validation failed',
          fieldErrors: _extractFieldErrors(data),
          cause: e,
          stackTrace: st,
        );
      case 429:
        return TooManyRequestsException(
          message: serverMessage ?? 'Too many requests',
          retryAfter: _parseRetryAfter(e.response?.headers.value('retry-after')),
          cause: e,
          stackTrace: st,
        );
      case 503:
        return ServiceUnavailableException(
          message: serverMessage ?? 'Service unavailable',
          cause: e,
          stackTrace: st,
        );
      default:
        return ServerException(
          message: serverMessage ?? 'Server error',
          statusCode: status,
          cause: e,
          stackTrace: st,
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final m = data['message'] ?? data['error'] ?? data['detail'];
      return m is String ? m : null;
    }
    return null;
  }

  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map) return const {};
    final errors = data['errors'] ?? data['field_errors'];
    if (errors is! Map) return const {};
    final out = <String, List<String>>{};
    errors.forEach((key, value) {
      if (key is! String) return;
      if (value is List) {
        out[key] = value.map((v) => v.toString()).toList();
      } else if (value is String) {
        out[key] = [value];
      }
    });
    return out;
  }

  static Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final seconds = int.tryParse(header);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }
}
