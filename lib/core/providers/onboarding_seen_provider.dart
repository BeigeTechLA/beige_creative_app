import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync mirror of `PrefsSessionStore.readOnboardingSeen()` for the GoRouter
/// `redirect:` callback (which is synchronous).
///
/// Bootstrapped in `startApp` by reading the prefs key once and using it as
/// the override value. The onboarding feature flips this provider when the
/// flow completes, AND persists via `SessionStore.writeOnboardingSeen(true)`
/// so the override takes effect across cold boots.
final onboardingSeenProvider = StateProvider<bool>((ref) => false);
