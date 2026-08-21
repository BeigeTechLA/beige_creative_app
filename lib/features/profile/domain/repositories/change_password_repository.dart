/// Repository contract for the 3-step "change password from inside profile"
/// flow: request OTP → verify OTP → set new password (final step also acts as
/// the OTP-resend hook, matching the legacy backend coupling on
/// `auth/reset-password`).
abstract class ChangePasswordRepository {
  /// POST `auth/forgot-password-check { email }` — triggers the OTP email.
  Future<void> requestOtp(String email);

  /// POST `auth/forgot-password-verify-otp { email, otp }`. Throws on
  /// non-2xx or `error: true`.
  Future<void> verifyOtp({required String email, required String otp});

  /// POST `auth/reset-password { email }` — resends the OTP. Same endpoint
  /// is reused for the finalize step; payload shape disambiguates server-side.
  Future<void> resendOtp(String email);

  /// POST `auth/reset-password { email, otp, new_password, confirm_password }`.
  Future<void> setNewPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
}
