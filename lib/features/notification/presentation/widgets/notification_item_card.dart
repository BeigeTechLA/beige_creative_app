import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../utility/date_time_utils.dart';
import '../../domain/models/notification_item.dart';

class NotificationItemCard extends StatefulWidget {
  const NotificationItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.isBackCard = false,
  });

  final NotificationItem item;
  final VoidCallback? onTap;
  final bool isBackCard;

  @override
  State<NotificationItemCard> createState() => _NotificationItemCardState();
}

class _NotificationItemCardState extends State<NotificationItemCard>
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
    String senderFallback = 'Notification';
    if (widget.item.title.isNotEmpty) {
      senderFallback = widget.item.title;
    } else if (widget.item.category != null && widget.item.category!.isNotEmpty) {
      final t = widget.item.category!;
      senderFallback = t[0].toUpperCase() + t.substring(1);
    }
    
    final senderName = widget.item.senderName ?? senderFallback;
    final timestampText = DateTimeUtils.formatNotificationDate(widget.item.createdAt);
    // final hasAction = widget.item.actionLabel != null && widget.item.actionLabel!.isNotEmpty;
    final cardBgColor = widget.isBackCard ? AppColors.surfaceDim : AppColors.surfaceMid;
    final avatarUrl = widget.item.avatarUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: GestureDetector(
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
          child: Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top User Info & Action Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Avatar Container
                    Container(
                      width: AppSpacing.huge,
                      height: AppSpacing.huge,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary20,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => _buildFallbackInitial(senderName),
                            )
                          : _buildFallbackInitial(senderName),
                    ),
                    AppSpacing.gapHSm,
                    // Sender Name & Timestamp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            senderName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                              height: 1.75,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timestampText,
                            style: AppTextStyles.body10.copyWith(
                              color: AppColors.white54,
                              height: 2.10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Button Pill (Hidden as requested)
                    /*
                    if (hasAction) ...[
                      AppSpacing.gapHSm,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.smd,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadii.mdAll,
                        ),
                        child: Text(
                          widget.item.actionLabel!,
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    */
                  ],
                ),
                AppSpacing.verticalSm,

                // Inner Dark Message Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.smd,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E2E3).withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      final msg = widget.item.message;
                      final colonIndex = msg.indexOf(':');
                      
                      if (colonIndex == -1) {
                        return Text(
                          msg,
                          style: AppTextStyles.body10.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        );
                      }

                      final prefix = msg.substring(0, colonIndex + 1);
                      final rest = msg.substring(colonIndex + 1);

                      return Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: prefix,
                              style: AppTextStyles.body10.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: rest,
                              style: AppTextStyles.body10.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(height: 1.35),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackInitial(String senderName) {
    return Center(
      child: Text(
        senderName.isNotEmpty ? senderName[0].toUpperCase() : 'A',
        style: AppTextStyles.body14.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
