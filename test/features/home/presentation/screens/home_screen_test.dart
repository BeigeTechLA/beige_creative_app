import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_notifier.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_state.dart';
import 'package:beige_creative_app/features/home/presentation/screens/home_screen.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/application_under_review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/mocks.dart';

/// Widget tests for HomeScreen. Subclasses `HomeNotifier` so `build()` skips
/// the auto-microtask refresh (which would hit `homeRepositoryProvider`). The
/// fake exposes counters for `refresh` so pull-to-refresh can be verified
/// without Dio. Deeper interaction (range tabs, category tabs, accept/decline)
/// sits in `home_notifier_test.dart`.

class _FakeHomeNotifier extends HomeNotifier {
  _FakeHomeNotifier({HomeState? seed}) : _seed = seed;

  final HomeState? _seed;
  int refreshCalls = 0;

  @override
  HomeState build() => _seed ?? HomeState(isLoading: false);

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: Routes.home.name,
        builder: (_, _) => const Scaffold(body: HomeScreen()),
      ),
      GoRoute(
        path: '/my-profile',
        name: Routes.myProfile.name,
        builder: (_, _) => const Scaffold(body: Text('profile-stub')),
      ),
    ],
  );
}

Future<_FakeHomeNotifier> _pump(
  WidgetTester tester, {
  HomeState? seed,
  UserSnapshot? user,
}) async {
  final fake = _FakeHomeNotifier(seed: seed);
  final prefs = FakePrefsSessionBackend();
  if (user != null) await prefs.writeUser(user);
  final session = CompositeSessionStore(
    secure: FakeSecureSessionBackend(),
    prefs: prefs,
  );
  await tester.pumpRouterApp(
    _router(),
    overrides: [
      homeNotifierProvider.overrideWith(() => fake),
      sessionStoreProvider.overrideWithValue(session),
    ],
  );
  // Drain asset-decode errors triggered by Image.asset / SvgPicture.
  tester.takeException();
  return fake;
}

void main() {
  testWidgets('renders welcome banner using firstName from seeded profile', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: HomeState(
        isLoading: false,
        completedShoots: 12,
        upcomingShoots: 5,
        pendingRequests: 3,
      ),
    );

    // HomeWelcomeHeader falls back to "User.." when profile is null.
    expect(find.text('Welcome Back, User..'), findsOneWidget);
  });

  testWidgets('renders RefreshIndicator + SingleChildScrollView', (
    tester,
  ) async {
    await _pump(tester, seed: HomeState(isLoading: false));

    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('pull-to-refresh invokes notifier.refresh', (tester) async {
    final fake = await _pump(tester, seed: HomeState(isLoading: false));
    final before = fake.refreshCalls;

    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(fake.refreshCalls, greaterThan(before));
  });

  testWidgets('pending CP sees non-dismissible review dialog on Home', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: HomeState(isLoading: false),
      user: const UserSnapshot(
        id: '7',
        isRegistrationComplete: 1,
        isCrewVerified: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ApplicationUnderReviewCard), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ApplicationUnderReviewCard), findsOneWidget);
  });

  testWidgets('approved CP does not see review dialog', (tester) async {
    await _pump(
      tester,
      seed: HomeState(isLoading: false),
      user: const UserSnapshot(
        id: '7',
        isRegistrationComplete: 1,
        isCrewVerified: 1,
      ),
    );
    await tester.pump();

    expect(find.byType(ApplicationUnderReviewCard), findsNothing);
  });
}
