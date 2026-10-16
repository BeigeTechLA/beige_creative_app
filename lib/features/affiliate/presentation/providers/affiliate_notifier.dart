import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/affiliate_repository_impl.dart';
import '../../domain/repositories/affiliate_repository.dart';
import 'affiliate_state.dart';

/// Repository provider injecting [dioClientProvider] for live GET /affiliates/dashboard API calls.
final affiliateRepositoryProvider = Provider<AffiliateRepository>(
  (ref) => AffiliateRepositoryImpl(ref.read(dioClientProvider)),
);

final affiliateNotifierProvider =
    AutoDisposeNotifierProvider<AffiliateNotifier, AffiliateState>(
  AffiliateNotifier.new,
);



/// Orchestrates fetching and user actions for the Affiliate screen.
class AffiliateNotifier extends AutoDisposeNotifier<AffiliateState> {
  @override
  AffiliateState build() {
    Future.microtask(refresh);
    return const AffiliateState(isLoading: true);
  }

  AffiliateRepository get _repo => ref.read(affiliateRepositoryProvider);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches all affiliate data from `GET /affiliates/dashboard`.
  Future<void> refresh() async {
    final isFirstLoad = state.summary == null;
    if (isFirstLoad) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }

    try {
      final dashboard = await _repo.fetchDashboard();

      state = state.copyWith(
        isLoading: false,
        summary: dashboard.summary,
        transactions: dashboard.transactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load affiliate data. Please try again.',
      );
    }
  }

  /// Updates the user's custom affiliate code via API and updates local state on success.
  Future<bool> updateCode(String newCode) async {
    if (state.summary == null) return false;
    try {
      final success = await _repo.updateReferralCode(
        affiliateId: state.summary!.affiliateId,
        referralCode: newCode,
      );
      if (success) {
        final updatedSummary = state.summary!.copyWith(
          affiliateCode: newCode,
        );
        state = state.copyWith(summary: updatedSummary);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }


}
