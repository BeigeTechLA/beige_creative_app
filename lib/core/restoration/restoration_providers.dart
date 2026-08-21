import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'app_lifecycle_observer.dart';
import 'draft_store.dart';
import 'route_restoration_service.dart';
import 'splash_restorer.dart';

/// Long-lived [RouteRestorationService] backed by SharedPreferences.
final routeRestorationServiceProvider =
    Provider<RouteRestorationService>((ref) {
  final prefs = ref.watch(prefsProvider);
  return RouteRestorationService(prefs);
});

/// Long-lived [AppLifecycleObserver] — attached by `App` in `app.dart`.
final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  final service = ref.watch(routeRestorationServiceProvider);
  return AppLifecycleObserver(service);
});

/// Stateless decision helper for splash restore.
final splashRestorerProvider = Provider<SplashRestorer>((ref) {
  return const SplashRestorer();
});

/// JSON-backed draft store for the multi-step signup flow.
final draftStoreProvider = Provider<DraftStore>((ref) {
  final prefs = ref.watch(prefsProvider);
  return DraftStore(prefs);
});
