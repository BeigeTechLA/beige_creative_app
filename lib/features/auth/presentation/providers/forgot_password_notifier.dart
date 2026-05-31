import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

final forgotPasswordRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(dioClientProvider)),
);

class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> requestOtp(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter email');
      return false;
    }
    if (!isValidEmail(trimmed)) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid email address',
      );
      return false;
    }
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearToast: true,
    );
    try {
      await ref
          .read(forgotPasswordRepositoryProvider)
          .requestPasswordReset(trimmed);
      state = state.copyWith(
        isSubmitting: false,
        step: ForgotPasswordStep.otpSent,
      );
      return true;
    } catch (e, st) {
      AppLogger.e('ForgotPassword.requestOtp failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e) ?? 'Email not registered',
      );
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    if (otp.length != 6) {
      state = state.copyWith(errorMessage: 'Please enter complete OTP');
      return false;
    }
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearToast: true,
    );
    try {
      await ref
          .read(forgotPasswordRepositoryProvider)
          .verifyResetOtp(email: email, otp: otp);
      state = state.copyWith(
        isSubmitting: false,
        step: ForgotPasswordStep.otpVerified,
      );
      return true;
    } catch (e, st) {
      AppLogger.e('ForgotPassword.verifyOtp failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e) ?? 'Invalid OTP. Please try again.',
      );
      return false;
    }
  }

  Future<void> resendOtp(String email) async {
    state = state.copyWith(isResending: true, clearError: true, clearToast: true);
    try {
      await ref
          .read(forgotPasswordRepositoryProvider)
          .requestPasswordReset(email);
      state = state.copyWith(
        isResending: false,
        toastMessage: 'OTP resent',
      );
    } catch (e, st) {
      AppLogger.e('ForgotPassword.resendOtp failed', e, st);
      state = state.copyWith(
        isResending: false,
        errorMessage: _formatError(e) ?? 'Failed to resend OTP',
      );
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final issue = _validatePassword(newPassword, confirmPassword);
    if (issue != null) {
      state = state.copyWith(errorMessage: issue);
      return false;
    }
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearToast: true,
    );
    try {
      await ref.read(forgotPasswordRepositoryProvider).resetPassword(
            email: email,
            otp: otp,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          );
      state = state.copyWith(
        isSubmitting: false,
        step: ForgotPasswordStep.resetSucceeded,
        toastMessage: 'Password reset successfully',
      );
      return true;
    } catch (e, st) {
      AppLogger.e('ForgotPassword.resetPassword failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e) ?? 'Failed to reset password',
      );
      return false;
    }
  }

  String? _validatePassword(String password, String confirm) {
    if (password.trim().isEmpty || confirm.trim().isEmpty) {
      return 'Please enter password';
    }
    if (password.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password.trim() != confirm.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _formatError(Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '');
    return raw.isEmpty ? null : raw;
  }
}

final forgotPasswordNotifierProvider = AutoDisposeNotifierProvider<
    ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);
