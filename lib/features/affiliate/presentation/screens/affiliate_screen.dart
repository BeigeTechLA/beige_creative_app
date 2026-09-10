import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/affiliate_notifier.dart';
import '../providers/affiliate_state.dart';
import '../widgets/affiliate_code_section.dart';
import '../widgets/affiliate_how_it_works.dart';
import '../widgets/affiliate_stats_grid.dart';
import '../widgets/affiliate_transaction_tile.dart';


class AffiliateScreen extends ConsumerStatefulWidget {
  const AffiliateScreen({super.key});

  @override
  ConsumerState<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends ConsumerState<AffiliateScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(affiliateNotifierProvider);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              AppMainToolbar(title: 'Affiliate'),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
          if (state.isLoading) const AppLoader(),

        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AffiliateState state,
  ) {
    final summary = state.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        // ── 1. Summary stats (Fixed at top) ───────────────────────────
        AffiliateStatsGrid(summary: summary),
        const SizedBox(height: AppSpacing.md),

        // ── 2. Scrollable Content (Your Code onwards) ─────────────────
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () =>
                ref.read(affiliateNotifierProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 2. Affiliate code / link ─────────────────────────────────
                        const _SectionHeader(title: 'Your Code'),
                        const SizedBox(height: AppSpacing.sm),
                        AffiliateCodeSection(summary: summary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 3. Referral Performance ───────────────────────────────────
                        const _SectionHeader(title: 'Recent Referrals'),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: AppRadii.lgAll,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.affiliateLedgerSurface,
                              borderRadius: AppRadii.lgAll,
                              border: Border.all(
                                color: AppColors.affiliateLedgerBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.transactions.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 36,
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.group_outlined,
                                          size: 40,
                                          color: AppColors.white38,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        Text(
                                          'No referrals yet. Share your code\nto start earning!',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.white60,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  const _ReferralLedgerHeader(),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.transactions.length,
                                    itemBuilder: (context, index) =>
                                        AffiliateTransactionTile(
                                      transaction: state.transactions[index],
                                      isLast:
                                          index == state.transactions.length - 1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 5. How It Works ───────────────────────────────────────────
                        const _SectionHeader(title: 'How To Earn'),
                        const SizedBox(height: AppSpacing.md),
                        const AffiliateHowItWorks(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

class _ReferralLedgerHeader extends StatelessWidget {
  const _ReferralLedgerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(color: AppColors.affiliateLedgerBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Booking Amount',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 14,
                fontFamily: AppAssets.fontOutfit,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Status',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontSize: 14,
              fontFamily: AppAssets.fontOutfit,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.displayLabel16.copyWith(
        fontFamily: AppAssets.fontUnbounded,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        height: 2.29,
      ),
    );
  }
}
