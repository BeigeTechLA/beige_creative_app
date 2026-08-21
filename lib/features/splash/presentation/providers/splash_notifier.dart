import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'splash_state.dart';

/// Single-event notifier for the splash boot sequence.
///
/// Animation lives in the widget (needs `vsync`); the notifier exists so the
/// screen can react to a state transition via `ref.listen` instead of a raw
/// callback chain. Keeps the screen presentation-only — navigation effects
/// fire from the listener.
class SplashNotifier extends AutoDisposeNotifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  void markAnimationComplete() {
    if (state.animationDone) return;
    state = state.copyWith(animationDone: true);
  }
}

final splashNotifierProvider =
    AutoDisposeNotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
