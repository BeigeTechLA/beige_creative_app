import 'package:beige_creative_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/forgot_password_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/forgot_password_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepo implements AuthRepository {
  String? capturedEmail;
  String? capturedOtp;
  String? capturedNewPassword;
  String? capturedConfirmPassword;
  int requestCount = 0;
  Object? throwOnRequest;
  Object? throwOnVerify;
  Object? throwOnReset;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> requestPasswordReset(String email) async {
    capturedEmail = email;
    requestCount++;
    final err = throwOnRequest;
    if (err != null) throw err;
  }

  @override
  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    capturedEmail = email;
    capturedOtp = otp;
    final err = throwOnVerify;
    if (err != null) throw err;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    capturedEmail = email;
    capturedOtp = otp;
    capturedNewPassword = newPassword;
    capturedConfirmPassword = confirmPassword;
    final err = throwOnReset;
    if (err != null) throw err;
  }

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

ProviderContainer _container(_FakeAuthRepo repo) {
  final c = ProviderContainer(
    overrides: [
      forgotPasswordRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('ForgotPasswordNotifier.requestOtp', () {
    test('rejects empty email', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('  ');
      expect(ok, isFalse);
      expect(
        c.read(forgotPasswordNotifierProvider).errorMessage,
        'Please enter email',
      );
    });

    test('rejects malformed email', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('not-an-email');
      expect(ok, isFalse);
      expect(
        c.read(forgotPasswordNotifierProvider).errorMessage,
        'Please enter a valid email address',
      );
    });

    test('happy path advances to otpSent', () async {
      final repo = _FakeAuthRepo();
      final c = _container(repo);
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('user@example.com');
      expect(ok, isTrue);
      expect(repo.capturedEmail, 'user@example.com');
      final s = c.read(forgotPasswordNotifierProvider);
      expect(s.step, ForgotPasswordStep.otpSent);
      expect(s.errorMessage, isNull);
    });

    test('surfaces repo error', () async {
      final repo = _FakeAuthRepo()
        ..throwOnRequest = Exception('Email not registered');
      final c = _container(repo);
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('user@example.com');
      expect(ok, isFalse);
      expect(
        c.read(forgotPasswordNotifierProvider).errorMessage,
        'Email not registered',
      );
    });
  });

  group('ForgotPasswordNotifier.verifyOtp', () {
    test('rejects partial OTP', () async {
      final repo = _FakeAuthRepo();
      final c = _container(repo);
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .verifyOtp(email: 'user@example.com', otp: '123');
      expect(ok, isFalse);
      expect(repo.capturedOtp, isNull);
      expect(
        c.read(forgotPasswordNotifierProvider).errorMessage,
        'Please enter complete OTP',
      );
    });

    test('happy path advances to otpVerified', () async {
      final repo = _FakeAuthRepo();
      final c = _container(repo);
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .verifyOtp(email: 'user@example.com', otp: '654321');
      expect(ok, isTrue);
      expect(repo.capturedOtp, '654321');
      expect(
        c.read(forgotPasswordNotifierProvider).step,
        ForgotPasswordStep.otpVerified,
      );
    });
  });

  group('ForgotPasswordNotifier.resetPassword', () {
    test('rejects mismatched passwords', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .resetPassword(
            email: 'user@example.com',
            otp: '654321',
            newPassword: 'abcdef',
            confirmPassword: 'zzzzzz',
          );
      expect(ok, isFalse);
      expect(
        c.read(forgotPasswordNotifierProvider).errorMessage,
        'Passwords do not match',
      );
    });

    test('rejects short password', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .resetPassword(
            email: 'user@example.com',
            otp: '654321',
            newPassword: 'abc',
            confirmPassword: 'abc',
          );
      expect(ok, isFalse);
      expect(
        c.read(forgotPasswordNotifierProvider).errorMessage,
        'Password must be at least 6 characters',
      );
    });

    test('happy path advances to resetSucceeded', () async {
      final repo = _FakeAuthRepo();
      final c = _container(repo);
      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .resetPassword(
            email: 'user@example.com',
            otp: '654321',
            newPassword: 'newpass',
            confirmPassword: 'newpass',
          );
      expect(ok, isTrue);
      expect(repo.capturedNewPassword, 'newpass');
      final s = c.read(forgotPasswordNotifierProvider);
      expect(s.step, ForgotPasswordStep.resetSucceeded);
      expect(s.toastMessage, 'Password reset successfully');
    });
  });

  group('ForgotPasswordNotifier.resendOtp', () {
    test('hits repo and sets toast', () async {
      final repo = _FakeAuthRepo();
      final c = _container(repo);
      await c
          .read(forgotPasswordNotifierProvider.notifier)
          .resendOtp('user@example.com');
      expect(repo.requestCount, 1);
      expect(
        c.read(forgotPasswordNotifierProvider).toastMessage,
        'OTP resent',
      );
    });
  });
}
