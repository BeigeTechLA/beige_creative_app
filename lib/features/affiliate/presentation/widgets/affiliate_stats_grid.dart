import 'package:flutter/material.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/spacing.dart';
import '../../../../../shared/widgets/app_count_card.dart';
import '../../domain/models/affiliate_summary.dart';

/// Horizontal summary stats cards shown at the top of the Affiliate screen.
class AffiliateStatsGrid extends StatelessWidget {
  const AffiliateStatsGrid({super.key, this.summary});

  final AffiliateSummary? summary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:  EdgeInsets.symmetric(
          horizontal: AppSpacing.mld,
        ),
        children: [
          AppCountCard(
            number: _formatAmount(summary?.totalEarnings ?? 0.0),
            title: 'Total Earnings',
            iconPath: AppAssets.affiliateTotalEarnings,
          ),
          AppCountCard(
            number: _formatAmount(summary?.pendingEarnings ?? 0.0),
            title: 'Pending Payouts',
            iconPath: AppAssets.affiliatePendingPayouts,
          ),
          AppCountCard(
            number: (summary?.totalReferrals ?? 0).toString().padLeft(2, '0'),
            title: 'Total Referrals',
            iconPath: AppAssets.affiliateTotalReferrals,
          ),
          AppCountCard(
            number: _formatRate(summary?.conversionRate),
            title: 'Conversion Rate',
            iconPath: AppAssets.affiliateConversionRate,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      final k = value / 1000;
      final formatted =
          k == k.roundToDouble() ? k.toInt().toString() : k.toStringAsFixed(1);
      return '\$${formatted}k';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatRate(String? rate) {
    if (rate == null || rate.isEmpty) return '100%';
    final numVal = double.tryParse(rate);
    if (numVal != null) {
      return '${numVal.toStringAsFixed(0)}%';
    }
    return '$rate%';
  }
}
