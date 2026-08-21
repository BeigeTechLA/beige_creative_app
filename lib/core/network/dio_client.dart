import 'package:dio/dio.dart';

import '../../config/env.dart';

/// Singleton-style Dio holder. **Never instantiated globally** — wired up via
/// `dioClientProvider` (Task 3.11) so tests can swap a mock client.
///
/// `BaseOptions`:
/// - `baseUrl` reads `Env.apiUrl` once at construction. Env must be initialized
///   (via `Env.init(...)` in `startApp`) before the first instance is built.
/// - 15s connect / receive / send timeouts — Risk #20 (slow-loris path closed).
/// - `Accept: application/json` header by default.
///
/// Interceptor wiring is intentionally absent here; `DioClient.attachInterceptors`
/// is a single-call extension point used by the provider so this class stays
/// thin and testable.
class DioClient {
  final Dio _dio;

  Dio get dio => _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: Env.apiUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: const {
              'Accept': 'application/json',
            },
            responseType: ResponseType.json,
          ),
        );

  /// Test seam — inject a pre-configured Dio (e.g. with `DioAdapter` mocks).
  DioClient.withDio(Dio dio) : _dio = dio;

  /// Adds interceptors in the order given. Idempotent only at the caller's
  /// discretion; calling twice doubles the chain. Wired up by the provider
  /// after Task 3.10 lands the concrete interceptors.
  void attachInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }
}
