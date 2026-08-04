import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../domain/models/notification_item.dart';
import 'notification_item_card.dart';

class NotificationStackedCards extends StatelessWidget {
  const NotificationStackedCards({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<NotificationItem> items;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final frontItem = items.first;
    final hasMultiple = items.length > 1;
    final hasThreeOrMore = items.length >= 3;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Backmost card layer peeking out from top (Layer 2)
            if (hasThreeOrMore)
              Positioned(
                top: -AppSpacing.base,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Container(
                  height: AppSpacing.huge,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim.withValues(alpha: 0.5),
                    borderRadius: AppRadii.hugeAll,
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
                  ),
                ),
              ),

            // Middle card layer peeking out from top (Layer 1)
            if (hasMultiple)
              Positioned(
                top: -AppSpacing.sm,
                left: AppSpacing.dropdownIconInset,
                right: AppSpacing.dropdownIconInset,
                child: Container(
                  height: AppSpacing.huge,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim.withValues(alpha: 0.8),
                    borderRadius: AppRadii.hugeAll,
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
                  ),
                ),
              ),

            // Front Main Notification Card
            NotificationItemCard(
              item: frontItem,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
