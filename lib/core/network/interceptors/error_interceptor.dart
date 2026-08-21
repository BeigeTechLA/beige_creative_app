import 'package:dio/dio.dart';

import '../exceptions/exceptions.dart';

/// Attaches a typed `AppException` to `DioException.error` so consumers that
/// don't use `ExceptionHandler.guardAsync` still get a typed failure on the
/// catching side.
///
/// Logic intentionally delegates to `ExceptionHandler.mapDioException` so the
/// mapping rules stay in exactly one place.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ExceptionHandler.mapDioException(
      err,
      err.stackTrace,
    );
    final wrapped = err.copyWith(error: appException);
    handler.next(wrapped);
  }
}
