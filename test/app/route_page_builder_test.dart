import 'package:beige_creative_app/app/route_page_builder.dart';
import 'package:beige_creative_app/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Observer extends NavigatorObserver {
  final popped = <String?>[];
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popped.add(route.settings.name);
  }
}

Future<GoRouter> _pump(
  WidgetTester tester, {
  bool canPop = true,
  _Observer? observer,
}) async {
  final router = GoRouter(
    observers: [?observer],
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: appPageBuilder(
          (_, _) => const Scaffold(body: Text('Home')),
        ),
      ),
      GoRoute(
        path: '/details/:id',
        name: 'details',
        pageBuilder: appPageBuilder(
          (context, state) => Scaffold(
            body: PopScope(
              canPop: canPop,
              child: ListView(
                children: [
                  const Text('Details'),
                  Text(
                    'extra=${(GoRouterState.of(context).extra as Map?)?['source']}',
                  ),
                  TextButton(
                    onPressed: () => context.pop('saved'),
                    child: const Text('Return result'),
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);
  testWidgets(
    'completed edge swipe pops once with metadata and extras preserved',
    (tester) async {
      final observer = _Observer();
      final router = await _pump(tester, observer: observer);
      router.push('/details/42?from=shoots', extra: {'source': 'drawer'});
      await tester.pumpAndSettle();
      final page =
          ModalRoute.of(tester.element(find.text('Details')))!.settings
              as MaterialPage<void>;
      expect(page.name, 'details');
      expect(page.arguments, {'id': '42', 'from': 'shoots'});
      expect(page.restorationId, (page.key! as ValueKey<String>).value);
      expect(find.text('extra=drawer'), findsOneWidget);
      await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(observer.popped, ['details']);
      expect(router.canPop(), isFalse);
    },
    variant: ios,
  );

  testWidgets('cancelled edge swipe and vertical scroll keep the page', (
    tester,
  ) async {
    final observer = _Observer();
    final router = await _pump(tester, observer: observer);
    router.push('/details/42');
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    expect(observer.popped, isEmpty);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    expect(observer.popped, isEmpty);
  }, variant: ios);

  testWidgets('root page cannot swipe away and PopScope still blocks back', (
    tester,
  ) async {
    final router = await _pump(tester, canPop: false);
    await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    router.push('/details/42');
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(1, 300), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
  }, variant: ios);

  testWidgets(
    'button returns a typed navigation result',
    (tester) async {
      final router = await _pump(tester);
      final result = router.push<String>('/details/42');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Return result'));
      await tester.pumpAndSettle();
      expect(await result, 'saved');
      expect(find.text('Home'), findsOneWidget);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  testWidgets('Android system back pops the Material page', (tester) async {
    final router = await _pump(tester);
    router.push('/details/42');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
