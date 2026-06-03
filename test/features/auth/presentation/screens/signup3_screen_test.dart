import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/signup_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/signup_state.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/signup3_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Smoke render tests for SignUp3Screen. The screen drives 4 file pickers,
/// 3 modal bottom sheets, and many notifier mutators — full interaction
/// coverage lives in `signup_notifier_test.dart`. This file pins:
///   1. The screen mounts under `pumpRouterApp` with `signupNotifierProvider`
///      overridden — render path doesn't blow up.
///   2. Section CTAs ("Add Social Links", "Add Portfolio Link (Optional)",
///      "Create Profile") render — so a layout regression that drops one is
///      caught early.
///   3. The Create Profile CTA wires through to `submitStep3` on the
///      notifier.
///
/// Subclasses `SignupNotifier` directly so only the two methods the screen
/// touches on the render + happy-tap path (`seedStep3FromRoute` is a pure
/// state update inherited as-is; `submitStep3` is overridden so the test
/// doesn't pull in `authRepositoryProvider` / Firebase).

class _FakeSignupNotifier extends SignupNotifier {
  int submitCalls = 0;

  @override
  SignupState build() => const SignupState();

  @override
  Future<bool> submitStep3() async {
    submitCalls++;
    return false;
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/signup3',
    routes: [
      GoRoute(
        path: '/signup3',
        name: Routes.signupStep3.name,
        builder: (_, _) => const SignUp3Screen(step2Progress: 0),
      ),
      GoRoute(
        path: '/login',
        name: Routes.login.name,
        builder: (_, _) => const Scaffold(body: Text('login-stub')),
      ),
    ],
  );
}

Future<_FakeSignupNotifier> _pump(WidgetTester tester) async {
  final fake = _FakeSignupNotifier();
  await tester.runAsync(() async {
    FlutterError.onError = (_) {};
    await tester.pumpRouterApp(
      _router(),
      overrides: [
        signupNotifierProvider.overrideWith(() => fake),
      ],
    );
    await tester.pump();
    await tester.pump();
  });
  return fake;
}

void main() {
  testWidgets('renders section CTAs and Create Profile button',
      (tester) async {
    await _pump(tester);

    expect(find.text('Social Engagement'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Add Social Links'), findsOneWidget);
    expect(find.text('Add Portfolio Link (Optional)'), findsOneWidget);
    expect(find.text('Create Profile'), findsOneWidget);
  });

  testWidgets('tap Create Profile invokes submitStep3', (tester) async {
    final fake = await _pump(tester);

    await tester.ensureVisible(find.text('Create Profile'));
    await tester.tap(find.text('Create Profile'));
    await tester.pump();

    expect(fake.submitCalls, 1);
  });
}
