import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../utility/date_time_utils.dart';
import '../../domain/models/affiliate_transaction.dart';

class AffiliateTransactionTile extends StatefulWidget {
  const AffiliateTransactionTile({
    super.key,
    required this.transaction,
    this.isLast = false,
  });

  final AffiliateTransaction transaction;
  final bool isLast;

  @override
  State<AffiliateTransactionTile> createState() =>
      _AffiliateTransactionTileState();
}

class _AffiliateTransactionTileState extends State<AffiliateTransactionTile> {
  bool _expanded = false;

  AffiliateTransaction get transaction => widget.transaction;

  @override
  Widget build(BuildContext context) {
    final tileColor = _expanded
        ? AppColors.surfaceShadow
        : AppColors.affiliateLedgerSurface;

    return Container(
      color: tileColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Collapsed row: chevron + amount + status pill ──────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: _expanded
                          ? AppColors.affiliateChevronBgExpanded
                          : AppColors.affiliateLedgerIconSurface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 0.50,
                          color: _expanded
                              ? AppColors.primary
                              : AppColors.affiliateDashedLine,
                        ),
                        borderRadius: AppRadii.fullAll,
                      ),
                    ),
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _expanded
                          ? AppColors.primary
                          : AppColors.white70,
                      size: 16,
                    ),
                  ),
                  AppSpacing.gapHSmd,
                  Expanded(
                    child: Text(
                      '\$${NumberFormat('#,##0.00').format(transaction.amount)}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: AppAssets.fontOutfit,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ),
                  _StatusPill(
                    isCompleted: _isCompleted(transaction.status),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded details ────────────────────────────────────────────
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                top: AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: 'Booking Date',
                    value: DateTimeUtils.formatFullMonthDate(transaction.date),
                  ),
                  AppSpacing.verticalSm,
                  _DetailRow(
                    label: 'Commission',
                    value: '\$${NumberFormat('#,##0.00').format(transaction.effectiveCommission)}',
                  ),
                  AppSpacing.verticalSm,
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Payout',
                          style: TextStyle(
                            color: AppColors.affiliateDetailText,
                            fontSize: 12,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      _StatusPill(
                        isCompleted: _isCompleted(transaction.effectivePayoutStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isCompleted(String status) => status.toLowerCase() == 'completed';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.affiliateDetailText,
              fontSize: 12,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.affiliateDetailValue,
            fontSize: 14,
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.isCompleted,
  });

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 92,
        height: 28,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: AppColors.affiliateCompletedBackground,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.pillAll,
          ),
        ),
        child: const Text(
          'Completed',
          style: TextStyle(
            color: AppColors.affiliateCompletedForeground,
            fontSize: 12,
            fontFamily: AppAssets.fontOutfit,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      width: 73,
      height: 32,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: AppColors.meetingPendingBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 0.50,
            color: AppColors.meetingPendingFg,
          ),
          borderRadius: AppRadii.fullAll,
        ),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          color: AppColors.meetingPendingFg,
          fontSize: 12,
          fontFamily: 'Instrument Sans',
          fontWeight: FontWeight.w500,
          height: 1.50,
          letterSpacing: -0.50,
        ),
      ),
    );
  }
}
