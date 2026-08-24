import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/push_token_sync_provider.dart';
import '../features/messages/presentation/providers/messages_repository_provider.dart';
import '../shared/widgets/connectivity_listener.dart';
import 'router.dart';
import 'theme.dart';

/// Root `ConsumerWidget`. `ProviderScope` is mounted in `startApp` (one level
/// up) so override values can flow in before the widget tree builds.
///
/// Auth boot branching (logged-in vs out) is owned by the router redirect
/// landed in Task 3.17 — the initial route stays `/splash` regardless of state.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mount chat socket lifecycle — connects on auth + real backend, disconnects
    // on logout. Provider has no value; the watch exists only to keep it alive.
    ref.watch(chatSocketLifecycleProvider);
    ref.watch(pushTokenSyncProvider);

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ConnectivityListener(child: child!),
        );
      },
    );
  }
}
