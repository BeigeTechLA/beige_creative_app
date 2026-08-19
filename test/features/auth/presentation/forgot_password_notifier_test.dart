import 'dart:io';

import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
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
  Future<List<int>> uploadStep3File({
    required int crewMemberId,
    required String fileType,
    required List<File> files,
  }) async =>
      const [100];
  @override
  Future<List<LookupOption>> fetchRoles() async => const [];
  @override
  Future<List<LookupOption>> fetchSkills() async => const [];
  @override
  Future<List<LookupOption>> searchEquipments(String query) async => const [];
}

class _RecordingTelemetry implements TelemetryClient {
  final List<({String name, Map<String, Object>? parameters})> events =
      <({String name, Map<String, Object>? parameters})>[];

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {}

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

ProviderContainer _container(
  _FakeAuthRepo repo, {
  _RecordingTelemetry? telemetry,
}) {
  final c = ProviderContainer(
    overrides: [
      forgotPasswordRepositoryProvider.overrideWithValue(repo),
      if (telemetry != null)
        telemetryClientProvider.overrideWithValue(telemetry),
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

  group('ForgotPasswordNotifier event emission (B1)', () {
    test('emits password_reset_requested on requestOtp success', () async {
      final repo = _FakeAuthRepo();
      final telemetry = _RecordingTelemetry();
      final c = _container(repo, telemetry: telemetry);

      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('user@example.com');
      expect(ok, isTrue);
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.passwordResetRequested)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, isNull);
    });

    test('does not emit on validation failure', () async {
      final repo = _FakeAuthRepo();
      final telemetry = _RecordingTelemetry();
      final c = _container(repo, telemetry: telemetry);

      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('  ');
      expect(ok, isFalse);
      expect(
        telemetry.events
            .where((e) => e.name == AnalyticsEvents.passwordResetRequested),
        isEmpty,
      );
    });

    test('does not emit on repo failure', () async {
      final repo = _FakeAuthRepo()..throwOnRequest = Exception('boom');
      final telemetry = _RecordingTelemetry();
      final c = _container(repo, telemetry: telemetry);

      final ok = await c
          .read(forgotPasswordNotifierProvider.notifier)
          .requestOtp('user@example.com');
      expect(ok, isFalse);
      expect(
        telemetry.events
            .where((e) => e.name == AnalyticsEvents.passwordResetRequested),
        isEmpty,
      );
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
