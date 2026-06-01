import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../service/prefs_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(dioClientProvider)),
);

class LoginNotifier extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() {
    Future.microtask(loadSavedCredentials);
    return const LoginState();
  }

  Future<void> loadSavedCredentials() async {
    try {
      final email = PrefsService.savedLoginEmail;
      final password = await PrefsService.getSavedLoginPassword();
      if (email != null && password != null) {
        state = state.copyWith(
          savedEmail: email,
          savedPassword: password,
          savePassword: true,
          savedCredentialsLoaded: true,
        );
        return;
      }
    } catch (_) {
      // Prefs not initialised (test harness) — treat as no saved credentials.
    }
    state = state.copyWith(savedCredentialsLoaded: true);
  }

  void setSavePassword(bool value) {
    state = state.copyWith(savePassword: value);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address');
      return;
    }
    if (!isValidEmail(trimmedEmail)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email address');
      return;
    }
    if (trimmedPassword.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your password');
      return;
    }

    state = state.copyWith(
      isLoggingIn: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final result = await ref.read(authRepositoryProvider).login(
            email: trimmedEmail,
            password: trimmedPassword,
          );

      final session = ref.read(sessionStoreProvider);
      await session.writeToken(result.token);
      if (result.user != null) {
        await session.writeUser(result.user!);
      }
      await session.writeLastLoginAt(DateTime.now().toUtc());

      try {
        if (state.savePassword) {
          await PrefsService.setSavedLoginEmail(trimmedEmail);
          await PrefsService.setSavedLoginPassword(trimmedPassword);
        } else {
          await PrefsService.clearSavedLogin();
        }
      } catch (_) {
        // Best-effort — remember-me persistence must not block login success.
      }

      ref.read(authStateProvider.notifier).markLoggedIn();
      state = state.copyWith(isLoggingIn: false, loginSuccess: true);
    } catch (e, st) {
      AppLogger.e('Login.submit failed', e, st);
      state = state.copyWith(
        isLoggingIn: false,
        errorMessage:
            _formatError(e) ?? 'Invalid email or password',
      );
    }
  }

  String? _formatError(Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '');
    if (raw.contains('{') && raw.contains('"message"')) {
      final match = RegExp(r'"message":"(.*?)"').firstMatch(raw);
      if (match != null) return match.group(1);
    }
    return raw.isEmpty ? null : raw;
  }
}

final loginNotifierProvider =
    AutoDisposeNotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
