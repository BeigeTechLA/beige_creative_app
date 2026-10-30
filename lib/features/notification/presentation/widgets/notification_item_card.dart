import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../utility/date_time_utils.dart';
import '../../domain/models/notification_item.dart';

/// Dynamically resolves the notification card action button label based on notification type/category:
/// - Chat or messages: "View Message Details"
/// - Shoot updates, reschedule, or revision: "Review Changes"
/// - Booking, shoot, or meeting details: "View Details"
/// - Cancelled or non-actionable notifications: null (hidden)
String? resolveNotificationActionLabel(NotificationItem item) {
  final category = (item.category ?? '').toLowerCase().trim();
  final type = (item.type ?? '').toLowerCase().trim();
  final title = item.title.toLowerCase().trim();
  final message = item.message.toLowerCase().trim();

  // 1. Cancelled or non-actionable notifications: Hide the button (null).
  if (type.contains('cancel') ||
      title.contains('cancel') ||
      category.contains('cancel') ||
      message.contains('cancelled') ||
      message.contains('canceled') ||
      type == 'non_actionable' ||
      type == 'info_only') {
    return null;
  }

  // 2. Chat or messages: "View Message Details"
  if (category == 'messages' ||
      category == 'message' ||
      category == 'chat' ||
      type.contains('chat') ||
      type.contains('message') ||
      title.contains('message') ||
      title.contains('chat')) {
    return 'View Message Details';
  }

  // 3. Shoot updates, reschedule, or revision: "Review Changes"
  if (type.contains('reschedule') ||
      type.contains('revision') ||
      (type.contains('shoot') && type.contains('update')) ||
      type == 'shoot_updated' ||
      title.contains('reschedule') ||
      title.contains('revision') ||
      (title.contains('shoot') && title.contains('update')) ||
      message.contains('reschedule') ||
      message.contains('revision') ||
      (message.contains('shoot') && message.contains('update'))) {
    return 'Review Changes';
  }

  // 4. Booking, shoot, or meeting details: "View Details"
  if (category == 'shoots' ||
      category == 'shoot' ||
      category == 'booking' ||
      category == 'bookings' ||
      category == 'meetings' ||
      category == 'meeting' ||
      type.contains('booking') ||
      type.contains('shoot') ||
      type.contains('meeting') ||
      title.contains('booking') ||
      title.contains('shoot') ||
      title.contains('meeting')) {
    return 'View Details';
  }

  // Fallback to explicit actionLabel if provided
  if (item.actionLabel != null && item.actionLabel!.trim().isNotEmpty) {
    return item.actionLabel!.trim();
  }

  return null;
}

class NotificationItemCard extends StatefulWidget {
  const NotificationItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onActionTap,
    this.isBackCard = false,
  });

  final NotificationItem item;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
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
    final actionLabel = widget.isBackCard ? null : resolveNotificationActionLabel(widget.item);
    final cardBgColor = widget.isBackCard ? AppColors.surfaceDim : AppColors.surfaceMid;
    final avatarUrl = widget.item.avatarUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onTap != null
            ? (_) {
                _controller.reverse();
                widget.onTap!();
              }
            : null,
        onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
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
                            style: AppTextStyles.body14.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timestampText,
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white54,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Button Pill
                    if (actionLabel != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: widget.onActionTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            actionLabel,
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    color: AppColors.textHeading,
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
                          maxLines: widget.isBackCard ? 1 : null,
                          overflow: widget.isBackCard ? TextOverflow.ellipsis : null,
                          style: AppTextStyles.body13.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
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
                              style: AppTextStyles.body13.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: rest,
                              style: AppTextStyles.body13.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        maxLines: widget.isBackCard ? 1 : null,
                        overflow: widget.isBackCard ? TextOverflow.ellipsis : null,
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
