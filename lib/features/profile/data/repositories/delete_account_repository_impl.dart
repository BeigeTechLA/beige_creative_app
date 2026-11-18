import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/app_exception.dart';
import '../../domain/models/deletion_request.dart';
import '../../domain/repositories/delete_account_repository.dart';

class DeleteAccountRepositoryImpl implements DeleteAccountRepository {
  final DioClient _client;

  const DeleteAccountRepositoryImpl(this._client);

  // AppHeadersInterceptor supplies the canonical creative identity headers.
  Options get _options => Options(extra: {'skipRetry': true});

  Future<Map<String, dynamic>> _call(
    String path,
    String method, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _client.dio.request<dynamic>(
      path,
      data: data,
      options: _options.copyWith(method: method),
    );
    final body = response.data;
    if (body == null && method == 'PATCH') return {};
    if (body is! Map) {
      throw const FormatException('Invalid account deletion response');
    }
    final result = Map<String, dynamic>.from(body);
    if (result['error'] == true ||
        result['success'] == false ||
        result['code'] == 'ACCOUNT_DELETION_IN_PROGRESS') {
      throw ServerException(
        message:
            result['message']?.toString() ??
            'Request failed. Please try again.',
      );
    }
    return result;
  }

  @override
  Future<void> requestOtp() async {
    await _call(ApiEndpoints.deleteAccountRequest, 'POST');
  }

  @override
  Future<DeletionRequest> confirm(String otp) async {
    final result = await _call(
      ApiEndpoints.deleteAccountConfirm,
      'POST',
      data: {'otp': otp},
    );
    return DeletionRequest.fromResponse(result);
  }

  @override
  Future<DeletionRequest> status() async {
    final result = await _call(ApiEndpoints.deleteAccountStatus, 'GET');
    return DeletionRequest.fromResponse(result);
  }

  @override
  Future<DeletionRequest> cancel() async {
    final result = await _call(ApiEndpoints.deleteAccountCancel, 'PATCH');
    return DeletionRequest.fromResponse(result);
  }
}
