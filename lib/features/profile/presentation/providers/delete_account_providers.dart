import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
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
      validationMessage: clearMessages
          ? null
          : (validationMessage ?? this.validationMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// TODO(delete-account-api): API binding is pending for the delete-account flow.
// Keep request, OTP verification and resend actions preview-only until bound.
class DeleteAccountNotifier extends Notifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  void selectReason(String reason) {
    state = state.copyWith(selectedReason: reason, clearMessages: true);
  }

  // TODO(delete-account-api): Request a deletion challenge here once the new
  // backend contract is available. UI preview must never call the legacy API.
  Future<bool> requestDelete() async {
    state = state.copyWith(
      errorMessage: 'UI preview only. No request was sent.',
    );
    return false;
  }

  // TODO(delete-account-api): Verify OTP and submit the deletion request here.
  // Session invalidation and analytics require server-confirmed success.
  Future<bool> confirmDelete(String otp) async {
    state = state.copyWith(errorMessage: 'UI preview only. Account unchanged.');
    return false;
  }

  // TODO(delete-account-api): Resend the deletion challenge here, using the
  // future deletion endpoint and server cooldown, not password reset.
  Future<void> resendOtp() async {
    state = state.copyWith(errorMessage: 'UI preview only. No email was sent.');
  }
}

final deleteAccountNotifierProvider =
    NotifierProvider.autoDispose<DeleteAccountNotifier, DeleteAccountState>(
      DeleteAccountNotifier.new,
    );
