import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/change_password_repository.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final DioClient _client;

  const ChangePasswordRepositoryImpl(this._client);

  Future<void> _postOrThrow(String path, Map<String, dynamic> body) async {
    final response = await _client.dio.post(path, data: body);
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }

  @override
  Future<void> requestOtp(String email) =>
      _postOrThrow(ApiEndpoints.forgotpassword, {'email': email});

  @override
  Future<void> verifyOtp({required String email, required String otp}) =>
      _postOrThrow(
        ApiEndpoints.forgotpasswordverifyotp,
        {'email': email, 'otp': otp},
      );

  @override
  Future<void> resendOtp(String email) =>
      _postOrThrow(ApiEndpoints.restartpassword, {'email': email});

  @override
  Future<void> setNewPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _postOrThrow(ApiEndpoints.restartpassword, {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });
}
