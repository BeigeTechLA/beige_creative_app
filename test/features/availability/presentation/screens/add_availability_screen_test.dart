import 'package:beige_creative_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:beige_creative_app/features/availability/presentation/screens/add_availability_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Widget smoke for AddAvailabilityScreen. Subclasses
/// `AddAvailabilityNotifier` so submit() can be intercepted without hitting
/// the repository. Verifies the screen renders the title / Cancel / Save
/// CTAs and that tapping Save routes through `notifier.submit(...)`.

class _FakeAddNotifier extends AddAvailabilityNotifier {
  _FakeAddNotifier({this.seed = const AddAvailabilityState()});

  final AddAvailabilityState seed;
  int submitCalls = 0;
  String? lastDate;
  String? lastNotes;

  @override
  AddAvailabilityState build() => seed;

  @override
  Future<bool> submit({
    required String formattedDate,
    required String startTime,
    required String endTime,
    required String recurrenceUntil,
    required String repeatDay,
    required String notes,
  }) async {
    submitCalls++;
    lastDate = formattedDate;
    lastNotes = notes;
    // Match the real notifier's validation surface so the test sees state
    // change without a real repo call.
    if (state.type == null) {
      state = state.copyWith(validationMessage: 'Please select type');
      return false;
    }
    return true;
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/add',
    routes: [
      GoRoute(
        path: '/add',
        builder: (_, _) => const Scaffold(body: AddAvailabilityScreen()),
      ),
    ],
  );
}

Future<_FakeAddNotifier> _pump(
  WidgetTester tester, {
  AddAvailabilityState? seed,
}) async {
  final fake = _FakeAddNotifier(seed: seed ?? const AddAvailabilityState());
  await tester.pumpRouterApp(
    _router(),
    overrides: [
      addAvailabilityNotifierProvider.overrideWith(() => fake),
    ],
  );
  tester.takeException();
  return fake;
}

void main() {
  testWidgets('renders title, subtitle, and Save / Cancel CTAs',
      (tester) async {
    await _pump(tester);

    expect(find.text('Add Availability'), findsOneWidget);
    expect(
      find.text('Set your availability, time off, or block time for shoots.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('renders Select Type dropdown placeholder', (tester) async {
    await _pump(tester);

    expect(find.text('Select Type*'), findsOneWidget);
  });

  testWidgets('tap Save with default state routes to notifier.submit',
      (tester) async {
    final fake = await _pump(tester);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(fake.submitCalls, 1);
  });

  testWidgets('Save shows spinner instead of label when isSubmitting=true',
      (tester) async {
    await _pump(
      tester,
      seed: const AddAvailabilityState(isSubmitting: true),
    );

    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
