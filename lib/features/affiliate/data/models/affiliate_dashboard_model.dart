import 'package:flutter/foundation.dart';

import '../../domain/models/affiliate_summary.dart';
import '../../domain/models/affiliate_transaction.dart';

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

/// Data class representing the parsed response of `GET /affiliates/dashboard`.
@immutable
class AffiliateDashboardData {
  const AffiliateDashboardData({
    required this.summary,
    required this.transactions,
  });

  final AffiliateSummary summary;
  final List<AffiliateTransaction> transactions;

  factory AffiliateDashboardData.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] as Map<String, dynamic>? ?? json;
    final affiliate = payload['affiliate'] as Map<String, dynamic>? ?? {};
    final stats = payload['stats'] as Map<String, dynamic>? ?? {};
    final earnings = payload['earnings'] as Map<String, dynamic>? ?? {};
    final recentReferrals = payload['recent_referrals'] as List<dynamic>? ?? [];

    final affiliateId = _parseInt(affiliate['affiliate_id']);
    final code = affiliate['referral_code']?.toString() ?? '';

    final summary = AffiliateSummary(
      affiliateId: affiliateId,
      totalClicks: 0,
      totalReferrals: _parseInt(stats['total_referrals']),
      successfulReferrals: _parseInt(stats['successful_referrals']),
      conversionRate: stats['conversion_rate']?.toString() ?? '',
      totalEarnings: _parseDouble(earnings['total_earnings']),
      pendingEarnings: _parseDouble(earnings['pending_earnings']),
      availableBalance: _parseDouble(earnings['paid_earnings']),
      affiliateCode: code,
      affiliateLink: affiliate['referral_link']?.toString() ?? '',
    );

    final transactions = recentReferrals
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final referralId = item['referral_id']?.toString() ?? '';
          final bookingAmount = _parseDouble(item['booking_amount']);
          final commissionAmount = item['commission_amount'] != null
              ? _parseDouble(item['commission_amount'])
              : null;
          final status = item['status']?.toString() ?? 'completed';
          final payoutStatus = item['payout_status']?.toString() ?? 'pending';
          final createdAtStr = item['created_at']?.toString();
          final payment = item['payment'] as Map<String, dynamic>?;
          final shootDateStr = payment?['shoot_date']?.toString();
          final dateStr = shootDateStr ?? createdAtStr ?? '';

          return AffiliateTransaction(
            id: referralId,
            date: DateTime.tryParse(dateStr) ?? DateTime.now(),
            amount: bookingAmount,
            status: status,
            commission: commissionAmount,
            payoutStatus: payoutStatus,
          );
        })
        .toList();

    return AffiliateDashboardData(
      summary: summary,
      transactions: transactions,
    );
  }
}
