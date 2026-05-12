/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Global ScaffoldMessenger key — kept temporarily for pre-GoRouter screens
/// that show snackbars outside of a widget context.
/// Will be removed in Batch 14 cleanup.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Root application widget.
/// ProviderScope wraps this in main.dart (not here) so that
/// SharedPreferences can be injected before the widget tree builds.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: AppTheme.dark(),
      // routerConfig: goRouter,
    );
  }
}
*/
