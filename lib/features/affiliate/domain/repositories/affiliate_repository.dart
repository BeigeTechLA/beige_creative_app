import '../../data/models/affiliate_dashboard_model.dart';

/// Contract for the affiliate feature data layer.
abstract class AffiliateRepository {
  /// Fetches the affiliate dashboard payload containing summary & recent referrals from `GET /affiliates/dashboard`.
  Future<AffiliateDashboardData> fetchDashboard();

  /// Updates the affiliate referral code via `PUT /affiliates/update/referral`.
  Future<bool> updateReferralCode({
    required int affiliateId,
    required String referralCode,
  });
}
