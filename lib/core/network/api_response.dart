import 'exceptions/exceptions.dart';

/// Generic envelope for the Beige API response shape:
///
/// ```json
/// { "error": false, "message": "ok", "data": { ... } }
/// ```
///
/// Usage in a remote data source:
///
/// ```dart
/// final raw = await _dio.get('creator/dashboard-count');
/// final envelope = ApiResponse<DashboardDto>.fromJson(
///   raw.data,
///   (json) => DashboardDto.fromJson(json as Map<String, dynamic>),
/// );
/// envelope.assertNoError();
/// return envelope.data!;
/// ```
class ApiResponse<T> {
  final bool error;
  final String? message;
  final T? data;

  const ApiResponse({
    required this.error,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) dataParser,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      error: json['error'] is bool ? json['error'] as bool : false,
      message: json['message'] as String?,
      data: rawData == null ? null : dataParser(rawData),
    );
  }

  /// Throws [ServerException] if the envelope's `error` flag is true.
  /// Repositories should call this immediately after parsing the envelope,
  /// before reading `data`. The thrown exception is caught by
  /// `ExceptionHandler.guardAsync` and converted to `Either.Left`.
  void assertNoError() {
    if (error) {
      throw ServerException(message: message ?? 'API returned error=true');
    }
  }
}
