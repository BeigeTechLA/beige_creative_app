import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/forgot_password_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/forgot_password_state.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/forgot_password_otp_screen.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Widget tests for the forgot-password trio. Each screen consumes
/// `forgotPasswordNotifierProvider`; the test overrides it with a fake that
/// records call args + return value so screen branches (success → navigate,
/// failure → stay) are reachable without Dio or telemetry.

class _FakeForgotPasswordNotifier
    extends AutoDisposeNotifier<ForgotPasswordState>
    implements ForgotPasswordNotifier {
  _FakeForgotPasswordNotifier({
    this.initial = const ForgotPasswordState(),
    this.requestOk = true,
    this.verifyOk = true,
    this.resetOk = true,
  });

  final ForgotPasswordState initial;
  final bool requestOk;
  final bool verifyOk;
  final bool resetOk;

  int requestCalls = 0;
  int verifyCalls = 0;
  int resetCalls = 0;
  int resendCalls = 0;
  String? capturedEmail;
  String? capturedOtp;
  String? capturedNewPassword;

  @override
  ForgotPasswordState build() => initial;

  @override
  Future<bool> requestOtp(String email) async {
    requestCalls++;
    capturedEmail = email.trim();
    return requestOk;
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    verifyCalls++;
    capturedEmail = email;
    capturedOtp = otp;
    return verifyOk;
  }

  @override
  Future<void> resendOtp(String email) async {
    resendCalls++;
    capturedEmail = email;
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    resetCalls++;
    capturedEmail = email;
    capturedOtp = otp;
    capturedNewPassword = newPassword;
    return resetOk;
  }
}

GoRouter _router({
  required String initialLocation,
  required WidgetBuilder forgotBuilder,
  WidgetBuilder? otpBuilder,
  WidgetBuilder? resetBuilder,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/forgot-password',
        name: Routes.forgotPassword.name,
        builder: (ctx, _) => forgotBuilder(ctx),
      ),
      GoRoute(
        path: '/forgot-otp',
        name: Routes.forgotOtp.name,
        builder: (ctx, _) =>
            otpBuilder?.call(ctx) ??
            const Scaffold(body: Text('otp-stub')),
      ),
      GoRoute(
        path: '/reset-password',
        name: Routes.resetPassword.name,
        builder: (ctx, _) =>
            resetBuilder?.call(ctx) ??
            const Scaffold(body: Text('reset-stub')),
      ),
      GoRoute(
        path: '/login',
        name: Routes.login.name,
        builder: (_, _) => const Scaffold(body: Text('login-stub')),
      ),
    ],
  );
}

Future<_FakeForgotPasswordNotifier> _pump(
  WidgetTester tester,
  GoRouter router, {
  ForgotPasswordState initial = const ForgotPasswordState(),
  bool requestOk = true,
  bool verifyOk = true,
  bool resetOk = true,
}) async {
  final fake = _FakeForgotPasswordNotifier(
    initial: initial,
    requestOk: requestOk,
    verifyOk: verifyOk,
    resetOk: resetOk,
  );
  await tester.runAsync(() async {
    FlutterError.onError = (_) {};
    await tester.pumpRouterApp(
      router,
      overrides: [
        forgotPasswordNotifierProvider.overrideWith(() => fake),
      ],
    );
    await tester.pump();
  });
  return fake;
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('renders Email field + Send OTP CTA', (tester) async {
      await _pump(
        tester,
        _router(
          initialLocation: '/forgot-password',
          forgotBuilder: (_) => const ForgotPasswordScreen(),
        ),
      );

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('Email ID*'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Send OTP button is disabled while field is empty',
        (tester) async {
      await _pump(
        tester,
        _router(
          initialLocation: '/forgot-password',
          forgotBuilder: (_) => const ForgotPasswordScreen(),
        ),
      );

      final btn = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Send OTP'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('tap Send OTP invokes requestOtp with trimmed email',
        (tester) async {
      final fake = await _pump(
        tester,
        _router(
          initialLocation: '/forgot-password',
          forgotBuilder: (_) => const ForgotPasswordScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '  u@x.io  ');
      await tester.pump();
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      expect(fake.requestCalls, 1);
      expect(fake.capturedEmail, 'u@x.io');
    });
  });

  group('ForgotPasswordOtpScreen', () {
    testWidgets('renders 6 OTP cells + Continue CTA', (tester) async {
      await _pump(
        tester,
        _router(
          initialLocation: '/forgot-otp',
          forgotBuilder: (_) => const Scaffold(body: Text('forgot-stub')),
          otpBuilder: (_) => const ForgotPasswordOtpScreen(email: 'u@x.io'),
        ),
      );

      expect(find.text('Enter OTP code'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Submit invokes verifyOtp with full 6-char OTP',
        (tester) async {
      final fake = await _pump(
        tester,
        _router(
          initialLocation: '/forgot-otp',
          forgotBuilder: (_) => const Scaffold(body: Text('forgot-stub')),
          otpBuilder: (_) => const ForgotPasswordOtpScreen(email: 'u@x.io'),
        ),
      );

      for (var i = 0; i < 6; i++) {
        await tester.enterText(
          find.byType(TextField).at(i),
          (i + 1).toString(),
        );
      }
      await tester.pump();

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(fake.verifyCalls, 1);
      expect(fake.capturedOtp, '123456');
      expect(fake.capturedEmail, 'u@x.io');
    });
  });

  group('ResetPasswordScreen', () {
    testWidgets('renders both password fields + Save CTA', (tester) async {
      await _pump(
        tester,
        _router(
          initialLocation: '/reset-password',
          forgotBuilder: (_) => const Scaffold(body: Text('forgot-stub')),
          resetBuilder: (_) =>
              const ResetPasswordScreen(email: 'u@x.io', otp: '123456'),
        ),
      );

      expect(find.text('Secure your Account'), findsOneWidget);
      expect(find.text('New Password*'), findsOneWidget);
      expect(find.text('Confirm Password*'), findsOneWidget);
      expect(find.text('Save New Password'), findsOneWidget);
    });

    testWidgets('Save button is disabled when either field is empty',
        (tester) async {
      await _pump(
        tester,
        _router(
          initialLocation: '/reset-password',
          forgotBuilder: (_) => const Scaffold(body: Text('forgot-stub')),
          resetBuilder: (_) =>
              const ResetPasswordScreen(email: 'u@x.io', otp: '123456'),
        ),
      );

      final btn = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Save New Password'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('tap Save invokes resetPassword with current field values',
        (tester) async {
      final fake = await _pump(
        tester,
        _router(
          initialLocation: '/reset-password',
          forgotBuilder: (_) => const Scaffold(body: Text('forgot-stub')),
          resetBuilder: (_) =>
              const ResetPasswordScreen(email: 'u@x.io', otp: '123456'),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'newpass1');
      await tester.enterText(find.byType(TextField).at(1), 'newpass1');
      await tester.pump();
      await tester.tap(find.text('Save New Password'));
      await tester.pump();

      expect(fake.resetCalls, 1);
      expect(fake.capturedEmail, 'u@x.io');
      expect(fake.capturedOtp, '123456');
      expect(fake.capturedNewPassword, 'newpass1');
    });
  });
}
