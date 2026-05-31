import 'package:flutter/foundation.dart';

@immutable
class LoginState {
  final bool isLoggingIn;
  final bool savePassword;
  final bool savedCredentialsLoaded;
  final String? savedEmail;
  final String? savedPassword;
  final String? errorMessage;
  final bool loginSuccess;

  const LoginState({
    this.isLoggingIn = false,
    this.savePassword = false,
    this.savedCredentialsLoaded = false,
    this.savedEmail,
    this.savedPassword,
    this.errorMessage,
    this.loginSuccess = false,
  });

  LoginState copyWith({
    bool? isLoggingIn,
    bool? savePassword,
    bool? savedCredentialsLoaded,
    String? savedEmail,
    String? savedPassword,
    String? errorMessage,
    bool? loginSuccess,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return LoginState(
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      savePassword: savePassword ?? this.savePassword,
      savedCredentialsLoaded:
          savedCredentialsLoaded ?? this.savedCredentialsLoaded,
      savedEmail: savedEmail ?? this.savedEmail,
      savedPassword: savedPassword ?? this.savedPassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loginSuccess: clearSuccess ? false : (loginSuccess ?? this.loginSuccess),
    );
  }
}
