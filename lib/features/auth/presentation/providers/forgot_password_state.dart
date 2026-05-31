import 'package:flutter/foundation.dart';

enum ForgotPasswordStep { idle, otpSent, otpVerified, resetSucceeded }

@immutable
class ForgotPasswordState {
  final ForgotPasswordStep step;
  final bool isSubmitting;
  final bool isResending;
  final String? errorMessage;
  final String? toastMessage;

  const ForgotPasswordState({
    this.step = ForgotPasswordStep.idle,
    this.isSubmitting = false,
    this.isResending = false,
    this.errorMessage,
    this.toastMessage,
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    bool? isSubmitting,
    bool? isResending,
    String? errorMessage,
    String? toastMessage,
    bool clearError = false,
    bool clearToast = false,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResending: isResending ?? this.isResending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }
}
