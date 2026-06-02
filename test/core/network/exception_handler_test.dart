import 'dart:io';

import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Capture {
  Object? error;
  StackTrace? stack;
  String? reason;
  bool? fatal;
  int calls = 0;
}

void main() {
  late _Capture capture;

  setUp(() {
    capture = _Capture();
    ExceptionHandler.crashRecorder = (
      Object error,
      StackTrace? stack, {
      String? reason,
      bool fatal = false,
    }) async {
      capture
        ..calls += 1
        ..error = error
        ..stack = stack
        ..reason = reason
        ..fatal = fatal;
    };
  });

  tearDown(() {
    // Restore so other tests don't inherit the stub.
    ExceptionHandler.crashRecorder = ExceptionHandler.defaultCrashRecorder;
  });

  DioException dioBadResponse(int status, {dynamic data}) {
    final req = RequestOptions(path: '/x');
    return DioException(
      requestOptions: req,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: req,
        statusCode: status,
        data: data,
      ),
    );
  }

  group('ExceptionHandler.guardAsync mapping (preserved)', () {
    test('returns Right on success', () async {
      final result = await ExceptionHandler.guardAsync<int>(() async => 42);
      expect(result, isA<Right<AppException, int>>());
      expect(result.getOrElse(() => -1), 42);
      expect(capture.calls, 0);
    });

    test('maps 401 to UnauthorizedException', () async {
      final result = await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(401, data: {'message': 'token expired'}),
      );
      result.fold(
        (f) {
          expect(f, isA<UnauthorizedException>());
          expect(f.message, 'token expired');
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps 422 to ValidationException with fieldErrors', () async {
      final result = await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(422, data: {
          'message': 'invalid',
          'errors': {
            'email': ['Must be a valid email'],
            'password': ['Too short', 'Missing uppercase'],
          },
        }),
      );
      result.fold(
        (f) {
          expect(f, isA<ValidationException>());
          final v = f as ValidationException;
          expect(v.fieldErrors['email'], ['Must be a valid email']);
          expect(v.fieldErrors['password']?.length, 2);
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps 500 to ServerException with statusCode', () async {
      final result = await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(500),
      );
      result.fold(
        (f) {
          expect(f, isA<ServerException>());
          expect((f as ServerException).statusCode, 500);
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps connectionTimeout to TimeoutException', () async {
      final req = RequestOptions(path: '/slow');
      final result = await ExceptionHandler.guardAsync<int>(
        () async => throw DioException(
          requestOptions: req,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      result.fold(
        (f) => expect(f, isA<TimeoutException>()),
        (_) => fail('expected Left'),
      );
    });

    test('rethrown AppException is propagated as Left', () async {
      final result = await ExceptionHandler.guardAsync<int>(
        () async => throw const ForbiddenException(),
      );
      result.fold(
        (f) => expect(f, isA<ForbiddenException>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('ExceptionHandler.guardAsync Crashlytics forwarding matrix', () {
    test('5xx -> ServerException is forwarded with reason dio.5xx', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(500),
      );
      // unawaited futures run to completion in test zone.
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 1);
      expect(capture.error, isA<ServerException>());
      expect(capture.reason, 'dio.5xx');
      expect(capture.fatal, isFalse);
    });

    test('badCertificate (unknown) -> ServerException forwarded', () async {
      final req = RequestOptions(path: '/cert');
      await ExceptionHandler.guardAsync<int>(
        () async => throw DioException(
          requestOptions: req,
          type: DioExceptionType.badCertificate,
          error: 'oops',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 1);
      expect(capture.error, isA<ServerException>());
      expect(capture.reason, 'dio.5xx');
    });

    test('422 -> ValidationException is forwarded with reason dio.422',
        () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(422, data: {'message': 'invalid'}),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 1);
      expect(capture.error, isA<ValidationException>());
      expect(capture.reason, 'dio.422');
    });

    test('401 (Unauthorized) is NOT forwarded', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(401),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('403 (Forbidden) is NOT forwarded', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(403),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('404 (NotFound) is NOT forwarded', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(404),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('429 (TooManyRequests) is NOT forwarded', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(429),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('503 (ServiceUnavailable) is NOT forwarded', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw dioBadResponse(503),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('connectionTimeout (Timeout) is NOT forwarded', () async {
      final req = RequestOptions(path: '/slow');
      await ExceptionHandler.guardAsync<int>(
        () async => throw DioException(
          requestOptions: req,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('cancel (RequestCancelled) is NOT forwarded', () async {
      final req = RequestOptions(path: '/cancel');
      await ExceptionHandler.guardAsync<int>(
        () async => throw DioException(
          requestOptions: req,
          type: DioExceptionType.cancel,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('connectionError (NoInternet) is NOT forwarded', () async {
      final req = RequestOptions(path: '/down');
      await ExceptionHandler.guardAsync<int>(
        () async => throw DioException(
          requestOptions: req,
          type: DioExceptionType.connectionError,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('top-level SocketException is NOT forwarded', () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw const SocketException('no route'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('rethrown AppException is NOT forwarded (caller already classified)',
        () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw const ForbiddenException(),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('unknown thrown shape is forwarded with reason guard.unexpected',
        () async {
      await ExceptionHandler.guardAsync<int>(
        () async => throw StateError('weird'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 1);
      expect(capture.error, isA<StateError>());
      expect(capture.reason, 'guard.unexpected');
      expect(capture.fatal, isFalse);
    });
  });
}
