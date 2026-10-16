import 'package:beige_creative_app/features/home/presentation/providers/home_notifier.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_state.dart';
import 'package:beige_creative_app/shared/layouts/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeHomeNotifier extends AutoDisposeNotifier<HomeState>
    implements HomeNotifier {
  @override
  HomeState build() => HomeState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      homeNotifierProvider.overrideWith(_FakeHomeNotifier.new),
    ],
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                name: 'home',
                builder: (_, _) => const _Counter('A'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                name: 'shoots',
                builder: (_, _) => const _Counter('B'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/c',
                name: 'files',
                builder: (_, _) => const _Counter('C'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/d',
                name: 'messages',
                builder: (_, _) => const _Counter('D'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/e',
                name: 'meetings',
                builder: (_, _) => const _Counter('E'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/f',
                name: 'manage_availability',
                builder: (_, _) => const _Counter('F'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/g',
                name: 'affiliate',
                builder: (_, _) => const _Counter('G'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/h',
                name: 'payouts',
                builder: (_, _) => const _Counter('H'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
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

  testWidgets('AppShell drawer item switches to future Payouts branch', (
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

    await tester.scrollUntilVisible(
      find.text('Payouts'),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Payouts'));
    await tester.pumpAndSettle();

    expect(find.text('H: 0'), findsOneWidget);
  });
}
