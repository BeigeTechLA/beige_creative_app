import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_status.dart';

/// Wraps `connectivity_plus` with two behaviours the raw stream lacks:
///
/// 1. **Debounce (300ms)** — collapses transport flaps (`wifi → none → wifi`)
///    into a single emission so the UI doesn't flash a dialog on transient
///    drops (e.g. handoff between cells).
/// 2. **Reachability probe** — on every transition to `online`, runs a DNS
///    lookup against a known-good host. If the lookup fails or times out the
///    emission is demoted to `offline`. Defeats captive-portal "connected but
///    not actually online" states which `connectivity_plus` alone can't see.
///
/// `Connectivity` injectable for tests; reachability probe is overridable for
/// the captive-portal test case.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    Future<bool> Function()? reachabilityProbe,
    Duration debounce = const Duration(milliseconds: 300),
    Duration probeTimeout = const Duration(seconds: 2),
  })  : _connectivity = connectivity ?? Connectivity(),
        _reachabilityProbe = reachabilityProbe ?? _defaultProbe,
        _debounce = debounce,
        _probeTimeout = probeTimeout;

  final Connectivity _connectivity;
  final Future<bool> Function() _reachabilityProbe;
  final Duration _debounce;
  final Duration _probeTimeout;

  static const String _probeHost = 'one.one.one.one';

  static Future<bool> _defaultProbe() async {
    try {
      final result = await InternetAddress.lookup(_probeHost);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /// Broadcast stream of debounced + reachability-verified statuses.
  Stream<ConnectivityStatus> watch() {
    final controller = StreamController<ConnectivityStatus>.broadcast();
    Timer? debounceTimer;
    StreamSubscription<List<ConnectivityResult>>? sub;
    ConnectivityStatus? lastEmitted;

    Future<void> emit(List<ConnectivityResult> results) async {
      final raw = _map(results);
      if (raw == ConnectivityStatus.offline) {
        if (lastEmitted != ConnectivityStatus.offline) {
          lastEmitted = ConnectivityStatus.offline;
          controller.add(ConnectivityStatus.offline);
        }
        return;
      }
      // raw == online — verify reachability.
      final reachable = await _reachabilityProbe()
          .timeout(_probeTimeout, onTimeout: () => false);
      final next = reachable
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline;
      if (lastEmitted != next) {
        lastEmitted = next;
        controller.add(next);
      }
    }

    void schedule(List<ConnectivityResult> results) {
      debounceTimer?.cancel();
      debounceTimer = Timer(_debounce, () => emit(results));
    }

    controller.onListen = () {
      sub = _connectivity.onConnectivityChanged.listen(schedule);
    };
    controller.onCancel = () async {
      debounceTimer?.cancel();
      await sub?.cancel();
    };

    return controller.stream;
  }

  /// One-shot snapshot. Useful for retry handlers that need the current
  /// status without subscribing.
  Future<ConnectivityStatus> current() async {
    final results = await _connectivity.checkConnectivity();
    final raw = _map(results);
    if (raw == ConnectivityStatus.offline) return ConnectivityStatus.offline;
    final reachable = await _reachabilityProbe()
        .timeout(_probeTimeout, onTimeout: () => false);
    return reachable ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  ConnectivityStatus _map(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityStatus.offline;
    final allNone = results.every((r) => r == ConnectivityResult.none);
    return allNone ? ConnectivityStatus.offline : ConnectivityStatus.online;
  }
}
