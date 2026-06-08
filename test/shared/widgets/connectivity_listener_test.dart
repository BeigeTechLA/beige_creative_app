import 'dart:async';

import 'package:beige_creative_app/app/navigator_key.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_providers.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_service.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_status.dart';
import 'package:beige_creative_app/shared/widgets/connectivity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivityService implements ConnectivityService {
  ConnectivityStatus next = ConnectivityStatus.offline;

  @override
  Future<ConnectivityStatus> current() async => next;

  @override
  Stream<ConnectivityStatus> watch() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(
  WidgetTester tester,
  StreamController<ConnectivityStatus> controller, {
  _FakeConnectivityService? service,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectivityStreamProvider.overrideWith((ref) => controller.stream),
        if (service != null)
          connectivityServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: const ConnectivityListener(
          child: Scaffold(body: Text('child')),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('online → offline shows No Internet dialog', (tester) async {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    addTearDown(controller.close);

    await _pump(tester, controller);
    controller.add(ConnectivityStatus.online);
    await tester.pump();

    controller.add(ConnectivityStatus.offline);
    await tester.pump(); // listener reacts
    await tester.pump(); // post-frame callback runs
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No Internet'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Drain dialog before teardown to keep rootNavigatorKey clean.
    controller.add(ConnectivityStatus.online);
    await tester.pumpAndSettle();
  });

  testWidgets('Retry while still offline keeps dialog visible', (tester) async {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    addTearDown(controller.close);
    final service = _FakeConnectivityService()
      ..next = ConnectivityStatus.offline;

    await _pump(tester, controller, service: service);
    controller.add(ConnectivityStatus.offline);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('No Internet'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Retry when online pops dialog', (tester) async {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    addTearDown(controller.close);
    final service = _FakeConnectivityService()
      ..next = ConnectivityStatus.online;

    await _pump(tester, controller, service: service);
    controller.add(ConnectivityStatus.offline);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No Internet'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump(); // setState _checking = true
    await tester.pump(); // microtask: await current()
    await tester.pump(); // pop
    await tester.pumpAndSettle();

    expect(find.text('No Internet'), findsNothing);
  });

  testWidgets('dialog wraps content in PopScope(canPop:false) so back is '
      'blocked', (tester) async {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    addTearDown(controller.close);

    await _pump(tester, controller);

    controller.add(ConnectivityStatus.offline);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final popScope = tester.widget<PopScope>(
      find.ancestor(
        of: find.text('No Internet'),
        matching: find.byType(PopScope),
      ),
    );
    expect(popScope.canPop, isFalse);
  });

  testWidgets('offline → online dismisses the dialog', (tester) async {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    addTearDown(controller.close);

    await _pump(tester, controller);

    controller.add(ConnectivityStatus.offline);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No Internet'), findsOneWidget);

    controller.add(ConnectivityStatus.online);
    await tester.pumpAndSettle();

    expect(find.text('No Internet'), findsNothing);
  });

  testWidgets('unknown status does not show a dialog', (tester) async {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    addTearDown(controller.close);

    await _pump(tester, controller);

    controller.add(ConnectivityStatus.unknown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No Internet'), findsNothing);
  });
}
