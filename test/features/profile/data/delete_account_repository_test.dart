import 'dart:convert';
import 'dart:typed_data';

import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/core/network/dio_client.dart';
import 'package:beige_creative_app/core/network/exceptions/exception_handler.dart';
import 'package:beige_creative_app/core/network/interceptors/app_headers_interceptor.dart';
import 'package:beige_creative_app/core/network/interceptors/retry_interceptor.dart';
import 'package:beige_creative_app/features/profile/data/repositories/delete_account_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  Object? body = {
    'data': {'request_id': 'DEL-1'},
  };
  DioExceptionType? failure;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _Adapter adapter;
  late DeleteAccountRepositoryImpl repository;

  setUp(() {
    adapter = _Adapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.addAll([
      AppHeadersInterceptor(deviceType: 'iOS'),
      RetryInterceptor(dio: dio, backoff: const [Duration.zero]),
    ]);
    repository = DeleteAccountRepositoryImpl(DioClient.withDio(dio));
  });
  tearDown(() => dio.close());

  test(
    'all deletion calls use canonical creative headers and correct methods',
    () async {
      await repository.requestOtp();
      await repository.confirm('123456');
      await repository.status();
      await repository.cancel();
      expect(adapter.requests.map((r) => r.path), [
        ApiEndpoints.deleteAccountRequest,
        ApiEndpoints.deleteAccountConfirm,
        ApiEndpoints.deleteAccountStatus,
        ApiEndpoints.deleteAccountCancel,
      ]);
      expect(adapter.requests.map((r) => r.method), [
        'POST',
        'POST',
        'GET',
        'PATCH',
      ]);
      expect(adapter.requests[1].data, {'otp': '123456'});
      for (final request in adapter.requests) {
        expect(request.headers['device_type'], 'iOS');
        expect(request.headers['user_type'], 2);
        expect(request.headers['user_type_name'], 'creative');
        expect(request.headers.containsKey('device-type'), isFalse);
        expect(request.headers.containsKey('user-type'), isFalse);
        expect(request.headers.containsKey('user-type-name'), isFalse);
        expect(request.extra['skipRetry'], isTrue);
      }
    },
  );

  for (final failure in [
    null,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  ]) {
    test('deletion mutations are sent once on $failure / HTTP 500', () async {
      adapter.status = 500;
      adapter.failure = failure;
      for (final operation in [
        repository.requestOtp,
        () => repository.confirm('123456'),
        repository.cancel,
      ]) {
        adapter.requests.clear();
        await expectLater(operation(), throwsA(isA<DioException>()));
        expect(adapter.requests, hasLength(1));
      }
    });
  }

  test('ordinary requests still retry server failures', () async {
    adapter.status = 500;
    await expectLater(
      dio.get<dynamic>('/ordinary'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, hasLength(4));
  });

  test('backend rejection retains its user-facing message', () async {
    adapter.body = {'success': false, 'message': 'Verification code expired'};
    final result = await ExceptionHandler.guardAsync(repository.requestOtp);
    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.message, 'Verification code expired'),
      (_) => fail('Expected rejection'),
    );
  });
}
