import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExceptionHandler.guardAsync', () {
    test('returns Right on success', () async {
      final result = await ExceptionHandler.guardAsync<int>(() async => 42);
      expect(result, isA<Right<AppException, int>>());
      expect(result.getOrElse(() => -1), 42);
    });

    test('maps 401 DioException to UnauthorizedException', () async {
      final requestOptions = RequestOptions(path: '/whatever');
      final dioErr = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'token expired'},
        ),
      );
      final result =
          await ExceptionHandler.guardAsync<int>(() async => throw dioErr);
      result.fold(
        (failure) {
          expect(failure, isA<UnauthorizedException>());
          expect(failure.message, 'token expired');
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps 422 DioException to ValidationException with fieldErrors',
        () async {
      final requestOptions = RequestOptions(path: '/signup');
      final dioErr = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 422,
          data: {
            'message': 'invalid',
            'errors': {
              'email': ['Must be a valid email'],
              'password': ['Too short', 'Missing uppercase'],
            },
          },
        ),
      );
      final result =
          await ExceptionHandler.guardAsync<int>(() async => throw dioErr);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationException>());
          final v = failure as ValidationException;
          expect(v.fieldErrors['email'], ['Must be a valid email']);
          expect(v.fieldErrors['password']?.length, 2);
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps 5xx DioException to ServerException with statusCode', () async {
      final requestOptions = RequestOptions(path: '/ping');
      final dioErr = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 500,
          data: null,
        ),
      );
      final result =
          await ExceptionHandler.guardAsync<int>(() async => throw dioErr);
      result.fold(
        (failure) {
          expect(failure, isA<ServerException>());
          expect((failure as ServerException).statusCode, 500);
        },
        (_) => fail('expected Left'),
      );
    });

    test('maps connectionTimeout DioException to TimeoutException', () async {
      final requestOptions = RequestOptions(path: '/slow');
      final dioErr = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );
      final result =
          await ExceptionHandler.guardAsync<int>(() async => throw dioErr);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<TimeoutException>()),
        (_) => fail('expected Left'),
      );
    });

    test('rethrown AppException is propagated as Left', () async {
      final result = await ExceptionHandler.guardAsync<int>(
        () async => throw const ForbiddenException(),
      );
      result.fold(
        (failure) => expect(failure, isA<ForbiddenException>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
