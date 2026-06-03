import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page-object robot for the auth flow. Encapsulates UI gestures + assertions
/// so integration tests read like English. Reused across `login_logout_test`,
/// `signup_test`, and future flows.
class AuthRobot {
  AuthRobot(this.tester);

  final WidgetTester tester;

  /// Drain microtasks + frame callbacks. `runAsync` lets the real async work
  /// (Dio mock futures, session writes) complete in vm-mode; the inner
  /// `pump` cycles repaint once that work is done.
  Future<void> _settle() async {
    await tester.runAsync(() async {
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  // ── LoginScreen ────────────────────────────────────────────────────────

  Future<void> expectOnLoginScreen() async {
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email ID*'), findsOneWidget);
    expect(find.text('Password*'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  }

  Future<void> enterEmail(String email) async {
    await tester.enterText(find.byType(TextField).first, email);
    await tester.pump();
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.pump();
  }

  Future<void> tapLogin() async {
    await tester.tap(find.text('Login'));
    await _settle();
  }

  // ── Home + logout ──────────────────────────────────────────────────────

  Future<void> expectOnHome() async {
    expect(find.text('home-stub'), findsOneWidget);
  }

  Future<void> tapLogout() async {
    await tester.tap(find.text('Logout'));
    await _settle();
  }
}
