/// Onboarding presentation state. `pageCount` is fixed by the screen's page
/// list — held here so the notifier can validate `setPage` bounds without
/// the widget reaching back into a list literal.
class OnboardingState {
  final int currentPage;
  final int pageCount;
  final bool seen;

  const OnboardingState({
    this.currentPage = 0,
    this.pageCount = 1,
    this.seen = false,
  });

  bool get isLastPage => currentPage >= pageCount - 1;

  OnboardingState copyWith({
    int? currentPage,
    int? pageCount,
    bool? seen,
  }) =>
      OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        pageCount: pageCount ?? this.pageCount,
        seen: seen ?? this.seen,
      );
}
