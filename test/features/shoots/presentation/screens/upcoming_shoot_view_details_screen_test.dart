import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/shoots/presentation/providers/upcoming_shoot_providers.dart';
import 'package:beige_creative_app/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart';
import 'package:beige_creative_app/model_class/upcoming_shootview_model.dart';
import 'package:beige_creative_app/shared/widgets/app_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Widget smoke for UpcomingShootViewDetails. Subclasses
/// `UpcomingShootDetailNotifier` so build() skips the auto-microtask
/// refresh + Dio call. Seeded `MyData` drives on-screen text.

class _FakeDetailNotifier extends UpcomingShootDetailNotifier {
  _FakeDetailNotifier({this.seed});

  final UpcomingShootDetailState? seed;
  int refreshCalls = 0;

  @override
  UpcomingShootDetailState build(int arg) =>
      seed ?? const UpcomingShootDetailState(isLoading: false);

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

MyData _seedData({
  String clientName = 'Jane Director',
  String idLabel = '#42',
  int projectId = 42,
}) {
  return MyData.fromJson({
    'project': {
      'project_id': projectId,
      'project_name': 'Skyline',
      'status': 'confirmed',
      'image_url': null,
      'event_date': '2026-06-15',
      'start_time': '09:00',
      'end_time': '17:00',
      'event_location': 'NYC',
      'shoot_type': 'Editorial',
      'booking_type': 'Solo',
      'last_updated': null,
      'total_time_duration_hours': 8,
      'budget': 1200,
      'total_amount': 1200,
      'id_label': idLabel,
    },
    'payment_state': 'pending',
    'team_members': <Map<String, dynamic>>[],
    'team_summary': {'assigned_count': 1, 'total_required': 2},
    'client_contact': {
      'full_name': clientName,
      'email': 'jane@example.com',
      'phone': '555',
    },
  });
}

GoRouter _router(int projectId) {
  return GoRouter(
    initialLocation: '/details',
    routes: [
      GoRoute(
        path: '/details',
        builder: (_, _) =>
            UpcomingShootViewDetails(projectid: projectId),
      ),
    ],
  );
}

Future<_FakeDetailNotifier> _pump(
  WidgetTester tester, {
  int projectId = 42,
  UpcomingShootDetailState? seed,
}) async {
  final fake = _FakeDetailNotifier(seed: seed);
  await tester.pumpRouterApp(
    _router(projectId),
    overrides: [
      upcomingShootDetailProvider.overrideWith(() => fake),
    ],
  );
  tester.takeException();
  return fake;
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  testWidgets('renders client name + project ID label from seeded MyData',
      (tester) async {
    await _pump(
      tester,
      projectId: 42,
      seed: UpcomingShootDetailState(
        data: _seedData(clientName: 'Jane Director', idLabel: '#42'),
        isLoading: false,
      ),
    );

    expect(find.text('Jane Director'), findsWidgets);
    expect(find.text('ID: #42'), findsOneWidget);
  });

  testWidgets('shows loader when isLoading=true', (tester) async {
    await _pump(
      tester,
      projectId: 1,
      seed: const UpcomingShootDetailState(isLoading: true),
    );

    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('shows loader when isSubmitting=true', (tester) async {
    await _pump(
      tester,
      projectId: 1,
      seed: UpcomingShootDetailState(
        data: _seedData(),
        isSubmitting: true,
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);
  });
}
