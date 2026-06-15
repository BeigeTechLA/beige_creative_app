import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/shoots/presentation/providers/shoots_providers.dart';
import 'package:beige_creative_app/features/shoots/presentation/screens/shoots_screen.dart';
import 'package:beige_creative_app/model_class/shoot_count_model.dart' as cm;
import 'package:beige_creative_app/model_class/shoots_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';

/// Widget tests for ShootsScreen. Subclasses `ShootsListNotifier` so build()
/// skips the auto-microtask refresh + Dio call. Verifies the screen renders
/// the four count cards and routes search text into `updateSearch`.

class _FakeShootsListNotifier extends ShootsListNotifier {
  _FakeShootsListNotifier({this.seed = const ShootsListState()});

  final ShootsListState seed;
  int refreshCalls = 0;
  int searchCalls = 0;
  String? lastSearch;

  @override
  ShootsListState build() => seed;

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  void updateSearch(String query) {
    searchCalls++;
    lastSearch = query;
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/shoots',
    routes: [
      GoRoute(
        path: '/shoots',
        name: Routes.shoots.name,
        builder: (_, _) => const Scaffold(body: ShootsScreen()),
      ),
      GoRoute(
        path: '/cancel-shoot',
        name: Routes.cancelShoot.name,
        builder: (_, _) => const Scaffold(body: Text('cancel-stub')),
      ),
      GoRoute(
        path: '/upcoming-details',
        name: Routes.upcomingShootDetails.name,
        builder: (_, _) => const Scaffold(body: Text('details-stub')),
      ),
    ],
  );
}

Future<_FakeShootsListNotifier> _pump(
  WidgetTester tester, {
  ShootsListState? seed,
}) async {
  final fake = _FakeShootsListNotifier(seed: seed ?? const ShootsListState());
  await tester.pumpRouterApp(
    _router(),
    overrides: [shootsListProvider.overrideWith(() => fake)],
  );
  tester.takeException();
  return fake;
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  testWidgets(
    'renders the four count cards (Pending/Confirmed/Completed/Declined)',
    (tester) async {
      await _pump(
        tester,
        seed: ShootsListState(
          counts: cm.ShootCountData(
            completedShoots: 7,
            pendingRequests: 3,
            confirmedRequests: 5,
            rejectedRequests: 1,
          ),
        ),
      );

      expect(find.text('Pending Shoots'), findsOneWidget);
      expect(find.text('Confirmed Shoots'), findsOneWidget);
      expect(find.text('Completed Shoots'), findsOneWidget);
      expect(find.text('Declined'), findsOneWidget);
      // Numbers are zero-padded: pending=03, confirmed=05, completed=07, declined=01.
      expect(find.text('03'), findsOneWidget);
      expect(find.text('05'), findsOneWidget);
      expect(find.text('07'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
    },
  );

  testWidgets('renders search bar with placeholder', (tester) async {
    await _pump(tester);
    expect(find.text('Search events or crew...'), findsOneWidget);
    expect(find.text('shoots'), findsOneWidget);
  });

  testWidgets('typing in search routes to notifier.updateSearch', (
    tester,
  ) async {
    final fake = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'wedding');
    await tester.pump();

    expect(fake.searchCalls, greaterThanOrEqualTo(1));
    expect(fake.lastSearch, 'wedding');
  });

  testWidgets('pending shoot action buttons use shoot action color tokens', (
    tester,
  ) async {
    final shoot = Shoot.fromJson(singleShootJson());

    await _pump(
      tester,
      seed: ShootsListState(allShoots: [shoot], visibleShoots: [shoot]),
    );

    final accept = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Accept'),
    );
    final decline = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Decline'),
    );

    expect(
      accept.style?.backgroundColor?.resolve(<WidgetState>{}),
      AppColors.shootAcceptButtonBackground,
    );
    expect(
      accept.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColors.shootAcceptButtonText,
    );
    expect(
      decline.style?.backgroundColor?.resolve(<WidgetState>{}),
      AppColors.shootDeclineButtonBackground,
    );
    expect(
      decline.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColors.shootDeclineButtonText,
    );
    expect(
      tester.widget<Text>(find.text('Accept')).style?.color,
      AppColors.shootAcceptButtonText,
    );
    expect(
      tester.widget<Text>(find.text('Decline')).style?.color,
      AppColors.shootDeclineButtonText,
    );
  });
}
