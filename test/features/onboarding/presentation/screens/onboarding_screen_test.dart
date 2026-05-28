import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/providers/onboarding_seen_provider.dart';
import 'package:beige_creative_app/core/session/prefs_session_store.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/onboarding/presentation/providers/onboarding_notifier.dart';
import 'package:beige_creative_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSecureBackend implements SecureSessionBackend {
  String? _t;
  String? _r;
  @override
  Future<String?> readToken() async => _t;
  @override
  Future<void> writeToken(String token) async => _t = token;
  @override
  Future<void> clearToken() async => _t = null;
  @override
  Future<String?> readRefreshToken() async => _r;
  @override
  Future<void> writeRefreshToken(String token) async => _r = token;
  @override
  Future<void> clearRefreshToken() async => _r = null;
}

Future<CompositeSessionStore> _buildSession() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return CompositeSessionStore(
    secure: _FakeSecureBackend(),
    prefs: PrefsSessionStore(prefs),
  );
}

GoRouter _harnessRouter() => GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (_, _) => const Scaffold(body: Text('LOGIN STUB')),
        ),
        GoRoute(
          path: '/signup-step-1',
          name: 'signup_step_1',
          builder: (_, _) => const Scaffold(body: Text('SIGNUP STUB')),
        ),
      ],
    );

Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _harnessRouter()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('OnboardingScreen renders title + description + Login CTA',
      (tester) async {
    final session = await _buildSession();
    await _pumpWithRouter(
      tester,
      overrides: [sessionStoreProvider.overrideWithValue(session)],
    );

    expect(find.textContaining('Find Your Next'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets,
        reason: 'sign-up gesture detector present');
  });

  testWidgets('Login tap persists onboardingSeen + flips provider',
      (tester) async {
    final session = await _buildSession();
    await _pumpWithRouter(
      tester,
      overrides: [sessionStoreProvider.overrideWithValue(session)],
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(OnboardingScreen)),
    );

    expect(container.read(onboardingSeenProvider), isFalse);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(container.read(onboardingSeenProvider), isTrue);
    expect(await session.readOnboardingSeen(), isTrue);
    expect(find.text('LOGIN STUB'), findsOneWidget);
  });

  test('OnboardingNotifier setPage clamps invalid indexes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(onboardingNotifierProvider.notifier)
        .configurePageCount(3);
    container.read(onboardingNotifierProvider.notifier).setPage(2);
    expect(container.read(onboardingNotifierProvider).currentPage, 2);

    container.read(onboardingNotifierProvider.notifier).setPage(9);
    expect(container.read(onboardingNotifierProvider).currentPage, 2,
        reason: 'out-of-range index ignored');

    container.read(onboardingNotifierProvider.notifier).setPage(-1);
    expect(container.read(onboardingNotifierProvider).currentPage, 2,
        reason: 'negative index ignored');
  });
}
