import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/login_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepo implements AuthRepository {
  String? capturedEmail;
  String? capturedPassword;
  LoginResult? result;
  Object? throwError;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    capturedEmail = email;
    capturedPassword = password;
    final err = throwError;
    if (err != null) throw err;
    return result ??
        const LoginResult(token: 'tok-123', user: null);
  }

  @override
  Future<void> requestPasswordReset(String email) async {}
  @override
  Future<void> verifyResetOtp({required String email, required String otp}) async {}
  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {}
  @override
  Future<int> registerStep1(Step1Payload payload) async => 0;
  @override
  Future<void> registerStep2(Step2Payload payload) async {}
  @override
  Future<void> registerStep3(Step3Payload payload) async {}
  @override
  Future<List<LookupOption>> fetchRoles() async => const [];
  @override
  Future<List<LookupOption>> fetchSkills() async => const [];
  @override
  Future<List<LookupOption>> searchEquipments(String query) async => const [];
}

class _FakeSession implements SessionStore {
  String? writtenToken;
  UserSnapshot? writtenUser;
  DateTime? writtenLoginAt;

  @override
  Future<void> writeToken(String token) async {
    writtenToken = token;
  }

  @override
  Future<void> writeUser(UserSnapshot user) async {
    writtenUser = user;
  }

  @override
  Future<void> writeLastLoginAt(DateTime when) async {
    writtenLoginAt = when;
  }

  // Unused — throw-style not needed since notifier never touches these.
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> clearToken() async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clearRefreshToken() async {}
  @override
  Future<UserSnapshot?> readUser() async => null;
  @override
  Future<void> clearUser() async {}
  @override
  Future<DateTime?> readLastLoginAt() async => null;
  @override
  Future<bool> readOnboardingSeen() async => false;
  @override
  Future<void> writeOnboardingSeen(bool seen) async {}
  @override
  Future<bool> isLoggedIn() async => writtenToken != null;
  @override
  Future<void> clearSession() async {}
}

ProviderContainer _container({
  required _FakeAuthRepo repo,
  required _FakeSession session,
}) {
  final c = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      sessionStoreProvider.overrideWithValue(session),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('LoginNotifier.login validation', () {
    test('rejects empty email', () async {
      final c = _container(repo: _FakeAuthRepo(), session: _FakeSession());
      await c
          .read(loginNotifierProvider.notifier)
          .login(email: '   ', password: 'pw');
      expect(
        c.read(loginNotifierProvider).errorMessage,
        'Please enter your email address',
      );
    });

    test('rejects malformed email', () async {
      final c = _container(repo: _FakeAuthRepo(), session: _FakeSession());
      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'not-an-email', password: 'pw');
      expect(
        c.read(loginNotifierProvider).errorMessage,
        'Please enter a valid email address',
      );
    });

    test('rejects empty password', () async {
      final c = _container(repo: _FakeAuthRepo(), session: _FakeSession());
      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: '  ');
      expect(
        c.read(loginNotifierProvider).errorMessage,
        'Please enter your password',
      );
    });
  });

  group('LoginNotifier.login happy path', () {
    test('persists token + flips auth state on success', () async {
      final repo = _FakeAuthRepo()
        ..result = const LoginResult(
          token: 'tok-xyz',
          user: UserSnapshot(id: '42', email: 'user@example.com'),
        );
      final session = _FakeSession();
      final c = _container(repo: repo, session: session);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(repo.capturedEmail, 'user@example.com');
      expect(repo.capturedPassword, 'secret');
      expect(session.writtenToken, 'tok-xyz');
      expect(session.writtenUser?.id, '42');
      expect(session.writtenLoginAt, isNotNull);
      expect(c.read(authStateProvider), isTrue);
      final LoginState s = c.read(loginNotifierProvider);
      expect(s.loginSuccess, isTrue);
      expect(s.isLoggingIn, isFalse);
      expect(s.errorMessage, isNull);
    });

    test('repo error surfaces message and keeps auth off', () async {
      final repo = _FakeAuthRepo()
        ..throwError = Exception('Invalid email or password');
      final session = _FakeSession();
      final c = _container(repo: repo, session: session);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(session.writtenToken, isNull);
      expect(c.read(authStateProvider), isFalse);
      final s = c.read(loginNotifierProvider);
      expect(s.errorMessage, 'Invalid email or password');
      expect(s.loginSuccess, isFalse);
      expect(s.isLoggingIn, isFalse);
    });
  });
}
