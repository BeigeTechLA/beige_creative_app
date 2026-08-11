import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory guest flag. NOT written to SharedPreferences or SessionStore.
/// True between onboarding "Skip" tap and successful login.
/// Rebuilt as false on app start, so cold start re-shows onboarding.
class GuestModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;

  void exit() => state = false;
}

final guestModeProvider = NotifierProvider<GuestModeNotifier, bool>(
  GuestModeNotifier.new,
);
