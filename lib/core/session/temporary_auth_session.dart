import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_store.dart';

/// Process-only authentication used while a creator is completing signup or
/// waiting for approval. Nothing in this state is written to secure storage or
/// shared preferences, so it disappears when the app process is terminated.
@immutable
class TemporaryAuthState {
  final String? token;
  final UserSnapshot? user;
  final DateTime? loginAt;

  const TemporaryAuthState({this.token, this.user, this.loginAt});

  bool get isActive => token != null && token!.isNotEmpty && user != null;
}

class TemporaryAuthSessionNotifier extends Notifier<TemporaryAuthState> {
  @override
  TemporaryAuthState build() => const TemporaryAuthState();

  void begin({
    required String token,
    required UserSnapshot user,
    required DateTime loginAt,
  }) {
    state = TemporaryAuthState(token: token, user: user, loginAt: loginAt);
  }

  void updateUser(UserSnapshot user) {
    if (!state.isActive) return;
    state = TemporaryAuthState(
      token: state.token,
      user: user,
      loginAt: state.loginAt,
    );
  }

  void clear() => state = const TemporaryAuthState();
}

final temporaryAuthSessionProvider =
    NotifierProvider<TemporaryAuthSessionNotifier, TemporaryAuthState>(
      TemporaryAuthSessionNotifier.new,
    );
