import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../domain/models/notification_item.dart';
import 'notification_item_card.dart';

class NotificationStackedCards extends StatefulWidget {
  const NotificationStackedCards({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<NotificationItem> items;
  final VoidCallback? onTap;

  @override
  State<NotificationStackedCards> createState() =>
      _NotificationStackedCardsState();
}

class _NotificationStackedCardsState extends State<NotificationStackedCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final frontItem = widget.items.first;
    final hasMultiple = widget.items.length > 1;
    final hasThreeOrMore = widget.items.length >= 3;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) _controller.forward();
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          _controller.reverse();
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Backmost card layer peeking out from top (Layer 2)
              if (hasThreeOrMore)
                Positioned(
                  top: -AppSpacing.smd,
                  left: AppSpacing.base,
                  right: AppSpacing.base,
                  child: Container(
                    height: AppSpacing.huge,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim.withValues(alpha: 0.5),
                      borderRadius: AppRadii.lgAll,
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
                    ),
                  ),
                ),

              // Middle card layer peeking out from top (Layer 1)
              if (hasMultiple)
                Positioned(
                  top: -AppSpacing.xxs,
                  left: AppSpacing.dropdownIconInset,
                  right: AppSpacing.dropdownIconInset,
                  child: Container(
                    height: AppSpacing.huge,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim.withValues(alpha: 0.8),
                      borderRadius: AppRadii.lgAll,
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                ),

              // Front Main Notification Card (Disable inner tap to avoid double bounce)
              NotificationItemCard(
                item: frontItem,
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
