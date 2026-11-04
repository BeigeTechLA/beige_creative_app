import 'package:beige_creative_app/app/route_page_builder.dart';
import 'package:beige_creative_app/app/router.dart';
import 'package:beige_creative_app/app/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_notifier.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeHomeNotifier extends Notifier<HomeState> implements HomeNotifier {
  @override
  HomeState build() => HomeState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [homeNotifierProvider.overrideWith(_FakeHomeNotifier.new)],
    child: child,
  );
}

class _Counter extends StatefulWidget {
  final String label;
  const _Counter(this.label);

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${widget.label}: $count', key: ValueKey(widget.label)),
            ElevatedButton(
              onPressed: () => setState(() => count++),
              child: Text('bump-${widget.label}'),
            ),
          ],
        ),
      ),
    );
  }
}

GoRouter _harnessRouter() {
  return GoRouter(
    initialLocation: '/a',
    routes: [
      GoRoute(
        path: '/profile',
        name: Routes.myProfile.name,
        pageBuilder: appPageBuilder(
          (context, state) => Scaffold(
            body: Column(
              children: [
                const Text('Profile details'),
                TextButton(
                  onPressed: () => context.push('/profile-child'),
                  child: const Text('Edit profile'),
                ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/profile-child',
        pageBuilder: appPageBuilder(
          (_, _) => const Scaffold(body: Text('Profile child')),
        ),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: appRoutes
            .whereType<StatefulShellRoute>()
            .single
            .pageBuilder,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                name: 'home',
                pageBuilder: appPageBuilder((_, _) => const _Counter('A')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                name: 'shoots',
                pageBuilder: appPageBuilder((_, _) => const _Counter('B')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/c',
                name: 'files',
                pageBuilder: appPageBuilder((_, _) => const _Counter('C')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/d',
                name: 'messages',
                pageBuilder: appPageBuilder((_, _) => const _Counter('D')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/e',
                name: 'meetings',
                pageBuilder: appPageBuilder((_, _) => const _Counter('E')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/f',
                name: 'manage_availability',
                pageBuilder: appPageBuilder((_, _) => const _Counter('F')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/g',
                name: 'affiliate',
                pageBuilder: appPageBuilder((_, _) => const _Counter('G')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/h',
                name: 'payouts',
                pageBuilder: appPageBuilder((_, _) => const _Counter('H')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets(
    'drawer profile and nested swipe return to the originating branch',
    (tester) async {
      final router = _harnessRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(_wrap(MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      for (final branch in ['/a', '/b', '/c', '/d', '/e', '/f', '/g']) {
        router.go(branch);
        await tester.pumpAndSettle();
        final label = String.fromCharCode(
          'A'.codeUnitAt(0) + branch.codeUnitAt(1) - 'a'.codeUnitAt(0),
        );
        await tester.tap(find.text('bump-$label'));
        await tester.pumpAndSettle();
        final scaffold = tester.state<ScaffoldState>(
          find.byType(Scaffold).first,
        );
        scaffold.openDrawer();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Loading...').first);
        await tester.pumpAndSettle();
        expect(find.text('Profile details'), findsOneWidget);
        expect(scaffold.isDrawerOpen, isFalse);
        await tester.tap(find.text('Edit profile'));
        await tester.pumpAndSettle();
        await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
        await tester.pumpAndSettle();
        expect(find.text('Profile details'), findsOneWidget);
        await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
        await tester.pumpAndSettle();
        expect(find.text('$label: 1'), findsOneWidget);
        expect(scaffold.isDrawerOpen, isFalse);
        expect(router.canPop(), isFalse);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('every drawer item switches branch without adding back history', (
    tester,
  ) async {
    final router = _harnessRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_wrap(MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    const labels = [
      'Dashboard',
      'Shoots',
      'File Manager',
      'Messages',
      'Meetings',
      'Manage Availability',
      'Affiliate',
    ];
    for (var index = 0; index < labels.length; index++) {
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffold.openDrawer();
      await tester.pumpAndSettle();
      final target = find.descendant(
        of: find.byType(Drawer),
        matching: find.text(labels[index]),
      );
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(
        find.text('${String.fromCharCode(65 + index)}: 0'),
        findsOneWidget,
      );
      expect(scaffold.isDrawerOpen, isFalse);
      expect(router.canPop(), isFalse);
    }
  });

  testWidgets(
    'root edge drag opens drawer and dismissal preserves branch',
    (tester) async {
      final router = _harnessRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(_wrap(MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      await tester.dragFrom(const Offset(1, 300), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(scaffold.isDrawerOpen, isTrue);
      if (defaultTargetPlatform == TargetPlatform.android) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.dragFrom(const Offset(250, 300), const Offset(-500, 0));
      }
      await tester.pumpAndSettle();
      expect(scaffold.isDrawerOpen, isFalse);
      expect(find.text('A: 0'), findsOneWidget);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  testWidgets('AppShell preserves per-branch state across tab switches', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(MaterialApp.router(routerConfig: _harnessRouter())),
    );
    await tester.pumpAndSettle();

    expect(find.text('A: 0'), findsOneWidget);
    await tester.tap(find.text('bump-A'));
    await tester.pump();
    await tester.tap(find.text('bump-A'));
    await tester.pump();
    expect(find.text('A: 2'), findsOneWidget);

    // Switch to Shoots tab.
    await tester.tap(
      find.byIcon(Icons.search).hitTestable().evaluate().isEmpty
          ? find.text('Shoots')
          : find.text('Shoots'),
    );
    await tester.pumpAndSettle();
    expect(find.text('B: 0'), findsOneWidget);

    // File Manager is also available in the bottom navigation bar.
    await tester.tap(find.text('File Manager'));
    await tester.pumpAndSettle();
    expect(find.text('C: 0'), findsOneWidget);

    // Back to Dashboard.
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(
      find.text('A: 2'),
      findsOneWidget,
      reason: 'Dashboard branch state should be preserved by IndexedStack',
    );
  });

  testWidgets('AppShell drawer item switches to Manage Availability branch', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(MaterialApp.router(routerConfig: _harnessRouter())),
    );
    await tester.pumpAndSettle();

    final scaffoldState = tester.state<ScaffoldState>(
      find.byType(Scaffold).first,
    );
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage Availability'));
    await tester.pumpAndSettle();

    expect(find.text('F: 0'), findsOneWidget);
  });

  testWidgets('AppShell drawer exposes File Manager branch', (tester) async {
    await tester.pumpWidget(
      _wrap(MaterialApp.router(routerConfig: _harnessRouter())),
    );
    await tester.pumpAndSettle();

    final scaffoldState = tester.state<ScaffoldState>(
      find.byType(Scaffold).first,
    );
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('File Manager'), findsNWidgets(2));
    await tester.tap(find.text('File Manager').last);
    await tester.pumpAndSettle();

    expect(find.text('C: 0'), findsOneWidget);
  });

  testWidgets('AppShell drawer hides the unavailable Payouts branch', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(MaterialApp.router(routerConfig: _harnessRouter())),
    );
    await tester.pumpAndSettle();

    final scaffoldState = tester.state<ScaffoldState>(
      find.byType(Scaffold).first,
    );
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Payouts'), findsNothing);
    expect(find.text('A: 0'), findsOneWidget);
  });
}
