import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/account_status.dart';
import 'core_providers.dart';

export '../session/account_status.dart';

class AccountStatusNotifier extends Notifier<AccountStatus> {
  @override
  AccountStatus build() {
    final prefs = ref.watch(prefsProvider);
    return AccountStatus.parse(prefs.getString('account_status'));
  }

  Future<void> setStatus(AccountStatus value) async {
    state = value;
    final prefs = ref.read(prefsProvider);
    await prefs.setString('account_status', value.apiValue);
  }
}

final accountStatusProvider =
    NotifierProvider<AccountStatusNotifier, AccountStatus>(
      AccountStatusNotifier.new,
    );

/// Recovery routes are usable only by an authenticated restricted session.
String? accountStatusRedirect({
  required bool authenticated,
  required AccountStatus status,
  required String location,
  bool cancellationComplete = false,
  bool confirmedReceipt = false,
}) {
  if (location == '/delete-account-success') {
    return confirmedReceipt ? null : '/login';
  }
  const recovery = {'/account-deletion-pending', '/cancel-account-deletion'};
  if (!authenticated) return recovery.contains(location) ? '/login' : null;
  if (status == AccountStatus.deleted || status == AccountStatus.unknown) {
    return location == '/login' ? null : '/login';
  }
  if (status == AccountStatus.deletionPending) {
    if (location == '/delete-account-otp' && confirmedReceipt) {
      return '/delete-account-success';
    }
    return recovery.contains(location) ? null : '/account-deletion-pending';
  }
  if (location == '/cancel-account-deletion' && !cancellationComplete) {
    return '/home';
  }
  if (location == '/account-deletion-pending') {
    return '/home';
  }
  return null;
}
