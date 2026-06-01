import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/delete_account_repository_impl.dart';
import '../../domain/repositories/delete_account_repository.dart';

final deleteAccountRepositoryProvider = Provider<DeleteAccountRepository>(
  (ref) => DeleteAccountRepositoryImpl(ref.read(dioClientProvider)),
);

@immutable
class DeleteAccountState {
  final String? selectedReason;
  final bool isSubmitting;
  final bool requestOk;
  final bool confirmOk;
  final String? validationMessage;
  final String? errorMessage;

  const DeleteAccountState({
    this.selectedReason,
    this.isSubmitting = false,
    this.requestOk = false,
    this.confirmOk = false,
    this.validationMessage,
    this.errorMessage,
  });

  DeleteAccountState copyWith({
    String? selectedReason,
    bool? isSubmitting,
    bool? requestOk,
    bool? confirmOk,
    String? validationMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return DeleteAccountState(
      selectedReason: selectedReason ?? this.selectedReason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      requestOk: requestOk ?? this.requestOk,
      confirmOk: confirmOk ?? this.confirmOk,
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DeleteAccountNotifier extends AutoDisposeNotifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  void selectReason(String reason) {
    state = state.copyWith(selectedReason: reason, clearMessages: true);
  }

  Future<bool> requestDelete() async {
    final reason = state.selectedReason;
    if (reason == null || reason.isEmpty) {
      state = state.copyWith(
        validationMessage: 'Please select delete reason',
      );
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(deleteAccountRepositoryProvider).requestDelete(reason);
      state = state.copyWith(isSubmitting: false, requestOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('DeleteAccount.requestDelete failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Confirms the OTP, then — on success — clears the session and flips the
  /// auth state so the splash/router redirect lands the user on `/login`.
  Future<bool> confirmDelete(String otp) async {
    if (otp.length != 6) {
      state = state.copyWith(validationMessage: 'Please enter complete OTP');
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(deleteAccountRepositoryProvider).confirmDelete(otp);
      await ref.read(authStateProvider.notifier).logout();
      state = state.copyWith(isSubmitting: false, confirmOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('DeleteAccount.confirmDelete failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> resendOtp() async {
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(deleteAccountRepositoryProvider).resendOtp();
      state = state.copyWith(isSubmitting: false);
    } catch (e, st) {
      AppLogger.e('DeleteAccount.resendOtp failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final deleteAccountNotifierProvider =
    AutoDisposeNotifierProvider<DeleteAccountNotifier, DeleteAccountState>(
  DeleteAccountNotifier.new,
);
