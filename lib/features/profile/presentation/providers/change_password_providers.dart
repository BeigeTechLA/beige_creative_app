import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/change_password_repository_impl.dart';
import '../../domain/repositories/change_password_repository.dart';

final changePasswordRepositoryProvider = Provider<ChangePasswordRepository>(
  (ref) => ChangePasswordRepositoryImpl(ref.read(dioClientProvider)),
);

bool isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$')
      .hasMatch(email);
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — request OTP from the change-password screen.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class RequestOtpState {
  final bool isSubmitting;
  final bool sentOk;
  final String? validationMessage;
  final String? errorMessage;

  const RequestOtpState({
    this.isSubmitting = false,
    this.sentOk = false,
    this.validationMessage,
    this.errorMessage,
  });

  RequestOtpState copyWith({
    bool? isSubmitting,
    bool? sentOk,
    String? validationMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return RequestOtpState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      sentOk: sentOk ?? this.sentOk,
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RequestOtpNotifier extends AutoDisposeNotifier<RequestOtpState> {
  @override
  RequestOtpState build() => const RequestOtpState();

  Future<bool> requestOtp(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(validationMessage: 'Please enter your email');
      return false;
    }
    if (!isValidEmail(trimmed)) {
      state = state.copyWith(
        validationMessage: 'Please enter a valid email address',
      );
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref
          .read(changePasswordRepositoryProvider)
          .requestOtp(trimmed);
      state = state.copyWith(isSubmitting: false, sentOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('RequestOtp failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final requestOtpNotifierProvider =
    AutoDisposeNotifierProvider<RequestOtpNotifier, RequestOtpState>(
  RequestOtpNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — verify OTP + resend.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class VerifyOtpState {
  final bool isSubmitting;
  final bool isResending;
  final bool verifiedOk;
  final String? validationMessage;
  final String? errorMessage;

  const VerifyOtpState({
    this.isSubmitting = false,
    this.isResending = false,
    this.verifiedOk = false,
    this.validationMessage,
    this.errorMessage,
  });

  VerifyOtpState copyWith({
    bool? isSubmitting,
    bool? isResending,
    bool? verifiedOk,
    String? validationMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return VerifyOtpState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResending: isResending ?? this.isResending,
      verifiedOk: verifiedOk ?? this.verifiedOk,
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class VerifyOtpNotifier extends AutoDisposeNotifier<VerifyOtpState> {
  @override
  VerifyOtpState build() => const VerifyOtpState();

  Future<bool> verifyOtp({required String email, required String otp}) async {
    if (otp.length != 6) {
      state = state.copyWith(validationMessage: 'Please enter complete OTP');
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref
          .read(changePasswordRepositoryProvider)
          .verifyOtp(email: email, otp: otp);
      state = state.copyWith(isSubmitting: false, verifiedOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('VerifyOtp failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            e.toString().replaceFirst('Exception: ', '').isEmpty
                ? 'Invalid or expired OTP'
                : e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> resendOtp(String email) async {
    state = state.copyWith(isResending: true, clearMessages: true);
    try {
      await ref.read(changePasswordRepositoryProvider).resendOtp(email);
      state = state.copyWith(isResending: false);
    } catch (e, st) {
      AppLogger.e('ResendOtp failed', e, st);
      state = state.copyWith(
        isResending: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final verifyOtpNotifierProvider =
    AutoDisposeNotifierProvider<VerifyOtpNotifier, VerifyOtpState>(
  VerifyOtpNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — set new password.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class NewPasswordState {
  final bool isSubmitting;
  final bool savedOk;
  final String? validationMessage;
  final String? errorMessage;

  const NewPasswordState({
    this.isSubmitting = false,
    this.savedOk = false,
    this.validationMessage,
    this.errorMessage,
  });

  NewPasswordState copyWith({
    bool? isSubmitting,
    bool? savedOk,
    String? validationMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return NewPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      savedOk: savedOk ?? this.savedOk,
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class NewPasswordNotifier extends AutoDisposeNotifier<NewPasswordState> {
  @override
  NewPasswordState build() => const NewPasswordState();

  String? _validate(String password, String confirm) {
    if (password.isEmpty) return 'Password cannot be empty';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }

  Future<bool> submit({
    required String email,
    required String otp,
    required String password,
    required String confirm,
  }) async {
    final issue = _validate(password, confirm);
    if (issue != null) {
      state = state.copyWith(validationMessage: issue);
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(changePasswordRepositoryProvider).setNewPassword(
            email: email,
            otp: otp,
            newPassword: password,
            confirmPassword: confirm,
          );
      state = state.copyWith(isSubmitting: false, savedOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('SetNewPassword failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final newPasswordNotifierProvider =
    AutoDisposeNotifierProvider<NewPasswordNotifier, NewPasswordState>(
  NewPasswordNotifier.new,
);
