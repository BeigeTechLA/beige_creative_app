import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';
import 'connectivity_status.dart';

/// App-wide singletons — no `.autoDispose` per `MIGRATION_RULES.md` §3.10.

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

final connectivityStreamProvider = StreamProvider<ConnectivityStatus>(
  (ref) => ref.watch(connectivityServiceProvider).watch(),
);

/// Sync handle into the latest status. Defaults to `unknown` until the first
/// stream emission so the router gate doesn't bounce navigation on cold start.
final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityStreamProvider).maybeWhen(
        data: (s) => s,
        orElse: () => ConnectivityStatus.unknown,
      );
});
