import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'config/env.dart';
import 'core/firebase/crashlytics_service.dart';
import 'core/firebase/firebase_service.dart';
import 'core/providers/auth_state_provider.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/onboarding_seen_provider.dart';
import 'core/session/prefs_session_store.dart';
import 'core/session/secure_session_store.dart';
import 'core/session/session_migration.dart';
import 'core/session/session_store.dart';
import 'service/prefs_service.dart';

Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.init(environment);

  // Boot Firebase first so any subsequent crash inside startup itself is
  // captured by Crashlytics. Tolerant of missing config (dev pre-flutterfire).
  await FirebaseService.initialize(environment);

  await PrefsService.init();

  // Wire SessionStore + run one-time legacy-token migration before any
  // network call so AuthInterceptor sees a consistent token source.
  final prefs = await SharedPreferences.getInstance();
  final SessionStore session = CompositeSessionStore(
    secure: SecureSessionStore(),
    prefs: PrefsSessionStore(prefs),
  );
  await SessionMigration.runOnce(prefs: prefs, session: session);

  final initialAuth = PrefsService.isLoggedIn;
  final initialOnboardingSeen =
      prefs.getBool(PrefsSessionStore.onboardingSeenKey) ?? false;

  // Wrap `runApp` (and only `runApp`) so async errors that escape
  // `PlatformDispatcher.onError` are still funneled to Crashlytics as fatal.
  // Keep all init calls above OUTSIDE the zone — if Firebase init itself
  // fails, we don't want the zone-guard reporting back into a half-booted
  // Firebase.
  runZonedGuarded(
    () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((_) async => prefs),
          prefsProvider.overrideWithValue(prefs),
          sessionStoreProvider.overrideWithValue(session),
          authStateProvider.overrideWith(
            () => AuthStateNotifier(initial: initialAuth),
          ),
          onboardingSeenProvider.overrideWith((_) => initialOnboardingSeen),
        ],
        child: const App(),
      ),
    ),
    (error, stack) {
      CrashlyticsService.recordError(error, stack, fatal: true);
    },
  );
}
