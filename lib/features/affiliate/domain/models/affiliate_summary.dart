import 'package:flutter/foundation.dart';

/// Aggregate summary for the affiliate dashboard header stats
/// and earnings/balance section.
@immutable
class AffiliateSummary {
  const AffiliateSummary({
    this.affiliateId = 0,
    this.totalClicks = 0,
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.conversionRate = '',
    this.totalEarnings = 0.0,
    this.pendingEarnings = 0.0,
    this.availableBalance = 0.0,
    this.affiliateCode = '',
    this.affiliateLink = '',
  });

  final int affiliateId;
  final int totalClicks;
  final int totalReferrals;
  final int successfulReferrals;
  final String conversionRate;
  final double totalEarnings;
  final double pendingEarnings;
  final double availableBalance;
  final String affiliateCode;
  final String affiliateLink;

  factory AffiliateSummary.fromJson(Map<String, dynamic> json) {
    return AffiliateSummary(
      affiliateId: (json['affiliate_id'] as num?)?.toInt() ?? 0,
      totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
      totalReferrals: (json['total_referrals'] as num?)?.toInt() ?? 0,
      successfulReferrals: (json['successful_referrals'] as num?)?.toInt() ?? 0,
      conversionRate: json['conversion_rate']?.toString() ?? '100.0',
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      pendingEarnings: (json['pending_earnings'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
      affiliateCode: json['affiliate_code'] as String? ?? '',
      affiliateLink: json['affiliate_link'] as String? ?? '',
    );
  }

  AffiliateSummary copyWith({
    int? affiliateId,
    int? totalClicks,
    int? totalReferrals,
    int? successfulReferrals,
    String? conversionRate,
    double? totalEarnings,
    double? pendingEarnings,
    double? availableBalance,
    String? affiliateCode,
    String? affiliateLink,
  }) {
    return AffiliateSummary(
      affiliateId: affiliateId ?? this.affiliateId,
      totalClicks: totalClicks ?? this.totalClicks,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      successfulReferrals: successfulReferrals ?? this.successfulReferrals,
      conversionRate: conversionRate ?? this.conversionRate,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      availableBalance: availableBalance ?? this.availableBalance,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      affiliateLink: affiliateLink ?? this.affiliateLink,
    );
  }
}
