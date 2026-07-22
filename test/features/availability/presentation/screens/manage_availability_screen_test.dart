import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/features/availability/domain/entities/availability_entry.dart';
import 'package:beige_creative_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:beige_creative_app/features/availability/presentation/screens/manage_availability_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Widget tests for ManageAvailabilityScreen. Subclasses
/// `ManageAvailabilityNotifier` so build() skips the auto-microtask refresh
/// (which would hit `availabilityRepositoryProvider`). Verifies the screen
/// renders the header / info banner / month label / Add CTA, and that
/// month-shift buttons drive the notifier.

class _FakeManageNotifier extends ManageAvailabilityNotifier {
  _FakeManageNotifier({this.seed});

  final ManageAvailabilityState? seed;
  int refreshCalls = 0;
  int shiftCalls = 0;
  int? lastShiftDelta;

  @override
  ManageAvailabilityState build() =>
      seed ?? ManageAvailabilityState(isLoading: false);

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  void shiftMonth(int delta) {
    shiftCalls++;
    lastShiftDelta = delta;
    state = state.copyWith(
      focusedDay: DateTime(
        state.focusedDay.year,
        state.focusedDay.month + delta,
      ),
    );
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/manage',
    routes: [
      GoRoute(
        path: '/manage',
        name: Routes.manageAvailability.name,
        builder: (_, _) =>
            const Scaffold(body: ManageAvailabilityScreen()),
      ),
      GoRoute(
        path: '/add',
        name: Routes.addAvailability.name,
        builder: (_, _) => const Scaffold(body: Text('add-stub')),
      ),
      GoRoute(
        path: '/shoot-details',
        name: Routes.upcomingShootDetails.name,
        builder: (_, state) {
          final projectId = (state.extra as Map?)?['projectId'];
          return Scaffold(body: Text('shoot-details-$projectId'));
        },
      ),
    ],
  );
}

Future<_FakeManageNotifier> _pump(
  WidgetTester tester, {
  ManageAvailabilityState? seed,
}) async {
  final fake = _FakeManageNotifier(seed: seed);
  await tester.pumpRouterApp(
    _router(),
    overrides: [
      manageAvailabilityNotifierProvider.overrideWith(() => fake),
    ],
  );
  tester.takeException();
  return fake;
}

void main() {
  testWidgets('renders title + info banner + Add Availability CTA',
      (tester) async {
    await _pump(tester);

    expect(find.text('Manage Availability'), findsOneWidget);
    expect(
      find.text(
        'Your availability is automatically blocked for confirmed shoots',
      ),
      findsOneWidget,
    );
    expect(find.text('Add Availability'), findsOneWidget);
  });

  testWidgets('renders count cards from seeded events', (tester) async {
    final focused = DateTime(2026, 6, 15);
    await _pump(
      tester,
      seed: ManageAvailabilityState(
        isLoading: false,
        focusedDay: focused,
        events: {
          DateTime(2026, 6, 1):
              const AvailabilityDay(status: AvailabilityStatus.available),
          DateTime(2026, 6, 5):
              const AvailabilityDay(status: AvailabilityStatus.available),
          DateTime(2026, 6, 8): const AvailabilityDay(
            status: AvailabilityStatus.shoot,
            bookingId: 8,
          ),
        },
      ),
    );

    expect(find.text('This Month'), findsOneWidget);
  });

  testWidgets('tap previous-month icon invokes shiftMonth(-1)', (tester) async {
    final fake = await _pump(tester);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    expect(fake.shiftCalls, greaterThanOrEqualTo(1));
    expect(fake.lastShiftDelta, -1);
  });

  testWidgets('tap next-month icon invokes shiftMonth(1)', (tester) async {
    final fake = await _pump(tester);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    expect(fake.shiftCalls, greaterThanOrEqualTo(1));
    expect(fake.lastShiftDelta, 1);
  });

  testWidgets('tap a Shoot day opens shoot details with its booking id',
      (tester) async {
    final focused = DateTime(2026, 6, 15);
    await _pump(
      tester,
      seed: ManageAvailabilityState(
        isLoading: false,
        focusedDay: focused,
        events: {
          DateTime(2026, 6, 15): const AvailabilityDay(
            status: AvailabilityStatus.shoot,
            bookingId: 77,
          ),
        },
      ),
    );

    await tester.ensureVisible(find.text('Shoot'));
    await tester.tap(find.text('Shoot'));
    await tester.pumpAndSettle();

    expect(find.text('shoot-details-77'), findsOneWidget);
  });

  testWidgets('tap an Available day does not navigate', (tester) async {
    final focused = DateTime(2026, 6, 15);
    await _pump(
      tester,
      seed: ManageAvailabilityState(
        isLoading: false,
        focusedDay: focused,
        events: {
          DateTime(2026, 6, 15):
              const AvailabilityDay(status: AvailabilityStatus.available),
        },
      ),
    );

    await tester.ensureVisible(find.text('Available'));
    await tester.tap(find.text('Available'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Availability'), findsOneWidget);
  });
}
