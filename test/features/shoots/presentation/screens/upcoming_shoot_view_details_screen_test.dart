import 'package:beige_creative_app/app/route_page_builder.dart';
import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/app/theme.dart';
import 'package:beige_creative_app/features/shoots/presentation/routes/shoots_routes.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/shoots/presentation/providers/upcoming_shoot_providers.dart';
import 'package:beige_creative_app/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart';
import 'package:beige_creative_app/model_class/upcoming_shootview_model.dart';
import 'package:beige_creative_app/shared/widgets/loading.dart';
import 'package:beige_creative_app/features/shoots/presentation/widgets/shoot_details_header.dart';
import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

/// Widget smoke for UpcomingShootViewDetails. Subclasses
/// `UpcomingShootDetailNotifier` so build() skips the auto-microtask
/// refresh + Dio call. Seeded `MyData` drives on-screen text.

class _FakeDetailNotifier extends UpcomingShootDetailNotifier {
  _FakeDetailNotifier({this.seed}) : super(0);

  final UpcomingShootDetailState? seed;
  int refreshCalls = 0;

  @override
  UpcomingShootDetailState build() =>
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
  String projectName = 'Skyline',
}) {
  return MyData.fromJson({
    'project': {
      'project_id': projectId,
      'project_name': projectName,
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
        builder: (_, _) => UpcomingShootViewDetails(projectid: projectId),
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
    overrides: [upcomingShootDetailProvider.overrideWith2((arg) => fake)],
  );
  expect(tester.takeException(), isNull);
  return fake;
}

Future<GoRouter> _pumpProductionRoute(
  WidgetTester tester, {
  bool rootDetails = false,
  MyData? data,
}) async {
  final fake = _FakeDetailNotifier(
    seed: UpcomingShootDetailState(data: data ?? _seedData()),
  );
  final router = GoRouter(
    initialLocation: rootDetails ? Routes.upcomingShootDetails.path : '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: appPageBuilder(
          (_, _) => const Scaffold(body: Text('Caller')),
        ),
      ),
      GoRoute(
        path: Routes.shoots.path,
        name: Routes.shoots.name,
        pageBuilder: appPageBuilder(
          (_, _) => const Scaffold(body: Text('Shoots fallback')),
        ),
      ),
      ...shootsRoutes,
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpRouterApp(
    router,
    theme: AppTheme.dark(),
    overrides: [upcomingShootDetailProvider.overrideWith2((arg) => fake)],
  );
  await tester.pumpAndSettle();
  if (!rootDetails) {
    router.pushNamed(
      Routes.upcomingShootDetails.name,
      extra: {'projectId': 42},
    );
    await tester.pumpAndSettle();
  }
  return router;
}

Future<void> _collapseHeader(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -420));
  await tester.pumpAndSettle();
  expect(
    find.byKey(const ValueKey('shoot-details-toolbar-title')),
    findsOneWidget,
  );
  expect(find.byTooltip('Back').hitTestable(), findsOneWidget);
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  testWidgets('header handles notch, long name and large text on narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            padding: EdgeInsets.only(top: 59),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                ShootDetailsHeader(
                  project: _seedData(
                    projectName:
                        'An extremely long wedding project name that should wrap and truncate safely',
                  ).project,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 1200)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.byTooltip('Back')).dy,
      greaterThanOrEqualTo(59),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('shoot-details-toolbar-title')),
      findsOneWidget,
    );
    expect(find.byTooltip('Back').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing project uses Shoot Details in collapsed toolbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: CustomScrollView(
            slivers: [
              ShootDetailsHeader(project: null),
              SliverToBoxAdapter(child: SizedBox(height: 1200)),
            ],
          ),
        ),
      ),
    );
    await _collapseHeader(tester);
    expect(find.text('Shoot Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final collapsed in [false, true]) {
    testWidgets('back arrow returns to caller, collapsed=$collapsed', (
      tester,
    ) async {
      final router = await _pumpProductionRoute(tester);
      if (collapsed) await _collapseHeader(tester);
      final target = find.descendant(
        of: find.byTooltip('Back'),
        matching: find.byType(AppIconTapTarget),
      );
      expect(tester.getSize(target), const Size(48, 48));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Caller'), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('root back arrow opens Shoots, collapsed=$collapsed', (
      tester,
    ) async {
      await _pumpProductionRoute(tester, rootDetails: true);
      if (collapsed) await _collapseHeader(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Shoots fallback'), findsOneWidget);
    });
  }

  testWidgets('collapse retains back position and expand restores hero title', (
    tester,
  ) async {
    await _pumpProductionRoute(tester);
    final expandedBack = tester.getTopLeft(find.byTooltip('Back'));
    expect(
      find.byKey(const ValueKey('shoot-details-toolbar-title')),
      findsNothing,
    );
    await _collapseHeader(tester);
    expect(tester.getTopLeft(find.byTooltip('Back')), expandedBack);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('shoot-details-toolbar-title')),
      findsNothing,
    );
    expect(find.text('ID: #42').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed iOS swipe can cancel then complete', (tester) async {
    final router = await _pumpProductionRoute(tester);
    await _collapseHeader(tester);
    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    expect(tester.state<ScrollableState>(scrollable).position.pixels, before);
    await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(find.text('Caller'), findsOneWidget);
    expect(router.canPop(), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android system back returns after header collapse', (
    tester,
  ) async {
    await _pumpProductionRoute(tester);
    await _collapseHeader(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Caller'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('production shoot route edge swipe returns to the caller', (
    tester,
  ) async {
    final fake = _FakeDetailNotifier(
      seed: UpcomingShootDetailState(data: _seedData(), isLoading: false),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: appPageBuilder(
            (_, _) => const Scaffold(body: Text('Shoot list')),
          ),
        ),
        ...shootsRoutes,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(
      router,
      theme: AppTheme.dark(),
      overrides: [upcomingShootDetailProvider.overrideWith2((arg) => fake)],
    );
    await tester.pumpAndSettle();
    router.pushNamed(
      Routes.upcomingShootDetails.name,
      extra: {'projectId': 42},
    );
    await tester.pumpAndSettle();
    expect(find.text('ID: #42'), findsOneWidget);
    await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(find.text('Shoot list'), findsOneWidget);
    expect(router.canPop(), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('renders client name + project ID label from seeded MyData', (
    tester,
  ) async {
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
    for (final chipText in ['Editorial', 'Solo']) {
      final chip = tester.widget<Container>(
        find
            .ancestor(of: find.text(chipText), matching: find.byType(Container))
            .first,
      );
      final decoration = chip.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.surfaceChip);
      expect(decoration.border, isNull);
    }
    final dollarIcons = tester
        .widgetList<SvgPicture>(find.byType(SvgPicture))
        .where(
          (picture) =>
              picture.bytesLoader is SvgAssetLoader &&
              (picture.bytesLoader as SvgAssetLoader).assetName ==
                  AppAssets.icDoller,
        );
    expect(dollarIcons, hasLength(1));
    final clockIcons = tester
        .widgetList<SvgPicture>(find.byType(SvgPicture))
        .where(
          (picture) =>
              picture.bytesLoader is SvgAssetLoader &&
              (picture.bytesLoader as SvgAssetLoader).assetName ==
                  AppAssets.icClockCircle,
        );
    expect(clockIcons, hasLength(2));
    for (final assetName in [
      AppAssets.icShootDate,
      AppAssets.icShootLocation,
    ]) {
      final matchingIcons = tester
          .widgetList<SvgPicture>(find.byType(SvgPicture))
          .where(
            (picture) =>
                picture.bytesLoader is SvgAssetLoader &&
                (picture.bytesLoader as SvgAssetLoader).assetName == assetName,
          );
      expect(matchingIcons, hasLength(1));
    }
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
      seed: UpcomingShootDetailState(data: _seedData(), isSubmitting: true),
    );

    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('renders team members section from cp_profiles / team_members', (
    tester,
  ) async {
    final data = MyData.fromJson({
      'project': {
        'project_id': 42,
        'project_name': 'Skyline Shoot',
        'status': 'active',
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
        'id_label': '42',
      },
      'payment_state': 'pending',
      'cp_profiles': [
        {
          'id': 1,
          'name': 'Emma Hale',
          'role_name': 'Project Manager',
          'profile_image_url': '',
        },
        {
          'id': 2,
          'name': 'Adam Brooks',
          'role_name': 'Production Manager',
          'profile_image_url': '',
        },
      ],
      'team_summary': {'assigned_count': 2, 'total_required': 2},
      'client_contact': {
        'full_name': 'Jane Director',
        'email': 'jane@example.com',
        'phone': '555',
      },
    });

    await _pump(
      tester,
      projectId: 42,
      seed: UpcomingShootDetailState(data: data, isLoading: false),
    );

    expect(find.text('Team Members'), findsOneWidget);
    expect(find.text('(02/02)'), findsOneWidget);
    expect(find.text('Emma Hale'), findsOneWidget);
    expect(find.text('Project Manager'), findsOneWidget);
    expect(find.text('Adam Brooks'), findsOneWidget);
    expect(find.text('Production Manager'), findsOneWidget);
  });

  testWidgets(
    'clamps totalRequired count to assigned count when total_required is less than assigned members',
    (tester) async {
      final data = MyData.fromJson({
        'project': {
          'project_id': 42,
          'project_name': 'Skyline Shoot',
          'status': 'active',
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
          'id_label': '42',
        },
        'payment_state': 'pending',
        'cp_profiles': [
          {
            'id': 1,
            'name': 'Emma Hale',
            'role_name': 'Project Manager',
            'profile_image_url': '',
          },
          {
            'id': 2,
            'name': 'Adam Brooks',
            'role_name': 'Production Manager',
            'profile_image_url': '',
          },
        ],
        'team_summary': {'assigned_count': 2, 'total_required': 1},
        'client_contact': {
          'full_name': 'Jane Director',
          'email': 'jane@example.com',
          'phone': '555',
        },
      });

      await _pump(
        tester,
        projectId: 42,
        seed: UpcomingShootDetailState(data: data, isLoading: false),
      );

      expect(find.text('(02/02)'), findsOneWidget);
    },
  );
}
