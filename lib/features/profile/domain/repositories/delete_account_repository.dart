import '../models/deletion_request.dart';

abstract class DeleteAccountRepository {
  Future<void> requestOtp();
  Future<DeletionRequest> confirm(String otp);
  Future<DeletionRequest> status();
  Future<DeletionRequest> cancel();
}
