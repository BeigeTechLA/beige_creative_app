import 'dart:async';

import 'package:beige_creative_app/core/connectivity/connectivity_service.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity mockConn;
  late StreamController<List<ConnectivityResult>> sourceController;
  List<ConnectivityResult> currentSnapshot =
      const [ConnectivityResult.none];

  const fastDebounce = Duration(milliseconds: 10);

  setUp(() {
    mockConn = _MockConnectivity();
    sourceController = StreamController<List<ConnectivityResult>>.broadcast();
    currentSnapshot = const [ConnectivityResult.none];

    when(() => mockConn.onConnectivityChanged)
        .thenAnswer((_) => sourceController.stream);
    when(() => mockConn.checkConnectivity())
        .thenAnswer((_) async => currentSnapshot);
  });

  tearDown(() async {
    await sourceController.close();
  });

  test('emits online when transport is wifi and reachability succeeds',
      () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () async => true,
      debounce: fastDebounce,
    );

    final emissions = <ConnectivityStatus>[];
    final sub = service.watch().listen(emissions.add);

    sourceController.add(const [ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(emissions, [ConnectivityStatus.online]);
    await sub.cancel();
  });

  test('emits offline when transport list is all-none', () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () async => true,
      debounce: fastDebounce,
    );

    final emissions = <ConnectivityStatus>[];
    final sub = service.watch().listen(emissions.add);

    sourceController.add(const [ConnectivityResult.none]);
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(emissions, [ConnectivityStatus.offline]);
    await sub.cancel();
  });

  test('rapid flap collapses to a single online emission', () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () async => true,
      debounce: const Duration(milliseconds: 80),
    );

    final emissions = <ConnectivityStatus>[];
    final sub = service.watch().listen(emissions.add);

    sourceController.add(const [ConnectivityResult.wifi]);
    sourceController.add(const [ConnectivityResult.none]);
    sourceController.add(const [ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(emissions, [ConnectivityStatus.online]);
    await sub.cancel();
  });

  test('captive-portal: wifi but reachability fails → offline', () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () async => false,
      debounce: fastDebounce,
    );

    final emissions = <ConnectivityStatus>[];
    final sub = service.watch().listen(emissions.add);

    sourceController.add(const [ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(emissions, [ConnectivityStatus.offline]);
    await sub.cancel();
  });

  test('reachability probe timeout demotes to offline', () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () => Completer<bool>().future, // never resolves
      debounce: fastDebounce,
      probeTimeout: const Duration(milliseconds: 50),
    );

    final emissions = <ConnectivityStatus>[];
    final sub = service.watch().listen(emissions.add);

    sourceController.add(const [ConnectivityResult.mobile]);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(emissions, [ConnectivityStatus.offline]);
    await sub.cancel();
  });

  test('current() returns offline when transports report none', () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () async => true,
      debounce: fastDebounce,
    );

    currentSnapshot = const [ConnectivityResult.none];
    final snap = await service.current();
    expect(snap, ConnectivityStatus.offline);
  });

  test('current() returns online when transports up and probe succeeds',
      () async {
    final service = ConnectivityService(
      connectivity: mockConn,
      reachabilityProbe: () async => true,
      debounce: fastDebounce,
    );

    currentSnapshot = const [ConnectivityResult.mobile];
    final snap = await service.current();
    expect(snap, ConnectivityStatus.online);
  });
}
