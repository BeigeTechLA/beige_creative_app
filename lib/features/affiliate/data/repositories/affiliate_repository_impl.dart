import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/affiliate_summary.dart';
import '../models/affiliate_dashboard_model.dart';
import '../../domain/repositories/affiliate_repository.dart';

/// Concrete affiliate repository implementation using [DioClient].
class AffiliateRepositoryImpl implements AffiliateRepository {
  final DioClient? _client;

  const AffiliateRepositoryImpl([this._client]);

  // ── AffiliateRepository implementation ────────────────────────────────────

  @override
  Future<AffiliateDashboardData> fetchDashboard() async {
    if (_client != null) {
      final response =
          await _client.dio.get<dynamic>(ApiEndpoints.affiliateDashboard);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] == true) {
          throw Exception(
            data['message'] ?? 'Failed to load affiliate dashboard',
          );
        }
        return AffiliateDashboardData.fromJson(data);
      }
      throw Exception('Affiliate dashboard returned unexpected payload');
    }
    return const AffiliateDashboardData(
      summary: AffiliateSummary(),
      transactions: [],
    );
  }

  @override
  Future<bool> updateReferralCode({
    required int affiliateId,
    required String referralCode,
  }) async {
    if (_client != null) {
      final response = await _client.dio.put<dynamic>(
        ApiEndpoints.updateReferralCode,
        data: {
          'affiliate_id': affiliateId,
          'referral_code': referralCode,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] == true) {
          throw Exception(
            data['message'] ?? 'Failed to update referral code',
          );
        }
        return true;
      }
      throw Exception('Update referral code returned unexpected payload');
    }
    return true;
  }
}
