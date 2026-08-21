/// Two-step delete-account flow contract:
/// 1. `requestDelete(reason)` triggers the OTP email.
/// 2. `confirmDelete(otp)` finalizes; backend revokes the user account.
abstract class DeleteAccountRepository {
  Future<void> requestDelete(String reason);
  Future<void> confirmDelete(String otp);
  Future<void> resendOtp();
}
