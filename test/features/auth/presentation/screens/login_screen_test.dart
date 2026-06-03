import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/login_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/login_state.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Widget tests for LoginScreen. Replace `loginNotifierProvider` with a fake
/// so login submit / pre-hydration / form-gating can be exercised without
/// SharedPreferences / Dio / GoRouter redirect logic. A 3-route stub router
/// handles the screen's `context.goNamed(home)` / `context.pushNamed(forgot)`
/// / `context.pushNamed(signupStep1)` calls.

class _FakeLoginNotifier extends AutoDisposeNotifier<LoginState>
    implements LoginNotifier {
  _FakeLoginNotifier({this.initial = const LoginState()});

  final LoginState initial;
  int loginCalls = 0;
  String? capturedEmail;
  String? capturedPassword;

  @override
  LoginState build() => initial;

  @override
  Future<void> loadSavedCredentials() async {}

  @override
  void setSavePassword(bool value) =>
      state = state.copyWith(savePassword: value);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    capturedEmail = email;
    capturedPassword = password;
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: Routes.login.name,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: Routes.home.name,
        builder: (_, _) => const Scaffold(body: Text('home-stub')),
      ),
      GoRoute(
        path: '/forgot-password',
        name: Routes.forgotPassword.name,
        builder: (_, _) =>
            const Scaffold(body: Text('forgot-password-stub')),
      ),
      GoRoute(
        path: '/signup1',
        name: Routes.signupStep1.name,
        builder: (_, _) => const Scaffold(body: Text('signup1-stub')),
      ),
    ],
  );
}

Future<_FakeLoginNotifier> _pump(
  WidgetTester tester, {
  LoginState initial = const LoginState(savedCredentialsLoaded: true),
}) async {
  final fake = _FakeLoginNotifier(initial: initial);
  await tester.runAsync(() async {
    FlutterError.onError = (_) {};
    await tester.pumpRouterApp(
      _router(),
      overrides: [
        loginNotifierProvider.overrideWith(() => fake),
      ],
    );
    await tester.pump();
  });
  return fake;
}

void main() {
  testWidgets('renders email + password fields and Login CTA', (tester) async {
    await _pump(tester);

    expect(find.text('Email ID*'), findsOneWidget);
    expect(find.text('Password*'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Login button is disabled while form is empty', (tester) async {
    await _pump(tester);

    final loginBtn = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Login'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(loginBtn.onPressed, isNull);
  });

  testWidgets('tapping Login with valid form invokes notifier.login',
      (tester) async {
    final fake = await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'hunter2');
    await tester.pump();

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(fake.loginCalls, 1);
    expect(fake.capturedEmail, 'user@example.com');
    expect(fake.capturedPassword, 'hunter2');
  });

  testWidgets('hydrates email + password from savedCredentialsLoaded state',
      (tester) async {
    await _pump(
      tester,
      initial: const LoginState(
        savedCredentialsLoaded: true,
        savedEmail: 'saved@x.io',
        savedPassword: 'saved-pw',
      ),
    );

    expect(find.text('saved@x.io'), findsOneWidget);
    expect(find.text('saved-pw'), findsOneWidget);
  });
}
