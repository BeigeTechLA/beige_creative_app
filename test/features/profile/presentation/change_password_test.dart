import 'package:beige_creative_app/features/profile/domain/repositories/change_password_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/change_password_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ChangePasswordRepository {
  bool requestCalled = false;
  bool verifyCalled = false;
  bool resendCalled = false;
  bool setCalled = false;
  String? lastEmail;
  String? lastOtp;
  String? lastNewPassword;

  bool throwOnRequest = false;
  bool throwOnVerify = false;
  bool throwOnSet = false;

  @override
  Future<void> requestOtp(String email) async {
    requestCalled = true;
    lastEmail = email;
    if (throwOnRequest) throw Exception('Email not registered');
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    verifyCalled = true;
    lastEmail = email;
    lastOtp = otp;
    if (throwOnVerify) throw Exception('Invalid OTP');
  }

  @override
  Future<void> resendOtp(String email) async {
    resendCalled = true;
    lastEmail = email;
  }

  @override
  Future<void> setNewPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    setCalled = true;
    lastEmail = email;
    lastOtp = otp;
    lastNewPassword = newPassword;
    if (throwOnSet) throw Exception('Reset failed');
  }
}

ProviderContainer _container(_FakeRepo repo) {
  final c = ProviderContainer(
    overrides: [
      changePasswordRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('RequestOtpNotifier', () {
    test('rejects empty email', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok =
          await c.read(requestOtpNotifierProvider.notifier).requestOtp('');
      expect(ok, isFalse);
      expect(repo.requestCalled, isFalse);
      expect(
        c.read(requestOtpNotifierProvider).validationMessage,
        'Please enter your email',
      );
    });

    test('rejects malformed email', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok = await c
          .read(requestOtpNotifierProvider.notifier)
          .requestOtp('not-an-email');
      expect(ok, isFalse);
      expect(repo.requestCalled, isFalse);
      expect(
        c.read(requestOtpNotifierProvider).validationMessage,
        contains('valid email'),
      );
    });

    test('happy path sends OTP', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok = await c
          .read(requestOtpNotifierProvider.notifier)
          .requestOtp('  user@example.com  ');
      expect(ok, isTrue);
      expect(repo.requestCalled, isTrue);
      expect(repo.lastEmail, 'user@example.com');
      expect(c.read(requestOtpNotifierProvider).sentOk, isTrue);
    });

    test('surfaces repo error', () async {
      final repo = _FakeRepo()..throwOnRequest = true;
      final c = _container(repo);
      final ok = await c
          .read(requestOtpNotifierProvider.notifier)
          .requestOtp('user@example.com');
      expect(ok, isFalse);
      expect(
        c.read(requestOtpNotifierProvider).errorMessage,
        'Email not registered',
      );
    });
  });

  group('VerifyOtpNotifier', () {
    test('rejects incomplete OTP', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok = await c
          .read(verifyOtpNotifierProvider.notifier)
          .verifyOtp(email: 'u@e.com', otp: '123');
      expect(ok, isFalse);
      expect(repo.verifyCalled, isFalse);
    });

    test('happy path verifies', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok = await c
          .read(verifyOtpNotifierProvider.notifier)
          .verifyOtp(email: 'u@e.com', otp: '123456');
      expect(ok, isTrue);
      expect(repo.verifyCalled, isTrue);
      expect(repo.lastOtp, '123456');
    });

    test('resend calls endpoint', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      await c
          .read(verifyOtpNotifierProvider.notifier)
          .resendOtp('u@e.com');
      expect(repo.resendCalled, isTrue);
      expect(repo.lastEmail, 'u@e.com');
    });
  });

  group('NewPasswordNotifier', () {
    test('rejects mismatched passwords', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok =
          await c.read(newPasswordNotifierProvider.notifier).submit(
                email: 'u@e.com',
                otp: '123456',
                password: 'abcdef',
                confirm: 'xyz',
              );
      expect(ok, isFalse);
      expect(repo.setCalled, isFalse);
      expect(
        c.read(newPasswordNotifierProvider).validationMessage,
        'Passwords do not match',
      );
    });

    test('rejects short password', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok =
          await c.read(newPasswordNotifierProvider.notifier).submit(
                email: 'u@e.com',
                otp: '123456',
                password: 'abc',
                confirm: 'abc',
              );
      expect(ok, isFalse);
      expect(
        c.read(newPasswordNotifierProvider).validationMessage,
        contains('at least 6'),
      );
    });

    test('happy path submits payload', () async {
      final repo = _FakeRepo();
      final c = _container(repo);
      final ok =
          await c.read(newPasswordNotifierProvider.notifier).submit(
                email: 'u@e.com',
                otp: '123456',
                password: 'abcdef',
                confirm: 'abcdef',
              );
      expect(ok, isTrue);
      expect(repo.setCalled, isTrue);
      expect(repo.lastNewPassword, 'abcdef');
      expect(c.read(newPasswordNotifierProvider).savedOk, isTrue);
    });
  });
}
