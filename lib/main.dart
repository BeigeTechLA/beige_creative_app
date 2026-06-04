import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/assets.dart';
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
  // `ensureInitialized` and `runApp` must run in the SAME zone — Flutter
  // asserts this. So perform all init (including binding + Firebase) inside
  // `runZonedGuarded` and let async errors funnel to Crashlytics as fatal.
  await runZonedGuarded<Future<void>>(() async {
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

    // Warm Lottie composition so splash paints first frame in sync with native
    // launch screen handoff (no transparent gap during JSON parse).
    unawaited(AssetLottie(AppAssets.lottieSplash).load());

    runApp(
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
    );
  }, (error, stack) {
    CrashlyticsService.recordError(error, stack, fatal: true);
  });
}
