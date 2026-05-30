import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/delete_account_repository.dart';

class DeleteAccountRepositoryImpl implements DeleteAccountRepository {
  final DioClient _client;
  const DeleteAccountRepositoryImpl(this._client);

  Future<void> _postOrThrow(String path, Map<String, dynamic> body) async {
    final response = await _client.dio.post(path, data: body);
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }

  @override
  Future<void> requestDelete(String reason) =>
      _postOrThrow(ApiEndpoints.accountDeleted, {'delete_reason': reason});

  @override
  Future<void> confirmDelete(String otp) =>
      _postOrThrow(ApiEndpoints.account_deleted_otp, {'otp': otp});

  @override
  Future<void> resendOtp() =>
      _postOrThrow(ApiEndpoints.restartpassword, const {});
}
