import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/onboarding_seen_provider.dart';
import 'onboarding_state.dart';

/// Owns onboarding page index + the "completed" flag.
///
/// The `PageController` itself stays in the widget (controllers belong with
/// their owning widget tree); the notifier holds the integer index so the
/// dot-indicator / button rows can rebuild without `setState`.
///
/// `markSeen()` persists via `SessionStore` AND flips
/// `onboardingSeenProvider` for the (sync) router redirect.
class OnboardingNotifier extends AutoDisposeNotifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void configurePageCount(int count) {
    if (state.pageCount == count) return;
    state = state.copyWith(pageCount: count);
  }

  void setPage(int index) {
    if (index < 0 || index >= state.pageCount) return;
    if (state.currentPage == index) return;
    state = state.copyWith(currentPage: index);
  }

  Future<void> markSeen() async {
    if (state.seen) return;
    state = state.copyWith(seen: true);
    ref.read(onboardingSeenProvider.notifier).state = true;
    final session = ref.read(sessionStoreProvider);
    await session.writeOnboardingSeen(true);
  }
}

final onboardingNotifierProvider =
    AutoDisposeNotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
