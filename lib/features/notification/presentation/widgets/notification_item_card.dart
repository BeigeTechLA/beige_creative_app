import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/notification_item.dart';

class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.isBackCard = false,
  });

  final NotificationItem item;
  final VoidCallback? onTap;
  final bool isBackCard;

  String _formatTimestamp(DateTime dt) {
    // Formats to string matching Figma exactly: "October 11 • 09:20AM"
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final hourInt = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$month $day • $hour:$minute$ampm';
  }

  Widget _buildFormattedMessage(String message) {
    final colonIndex = message.indexOf(':');
    if (colonIndex != -1) {
      final prefix = message.substring(0, colonIndex + 1);
      final body = message.substring(colonIndex + 1);
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: prefix,
              style: AppTextStyles.body12.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            TextSpan(
              text: body,
              style: AppTextStyles.body12.copyWith(
                color: AppColors.white70,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      message,
      style: AppTextStyles.body12.copyWith(
        color: AppColors.white70,
        height: 1.35,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final senderName = item.senderName ?? 'Angela Kia';
    final timestampText = _formatTimestamp(item.createdAt);
    final hasAction = item.actionLabel != null && item.actionLabel!.isNotEmpty;
    final cardBgColor = isBackCard ? AppColors.surfaceDim : AppColors.surfaceMid;
    final avatarUrl = item.avatarUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: GestureDetector(
        onTap: onTap,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timestampText,
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // "View Details" / Action Button Pill
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
                        item.actionLabel!,
                        style: AppTextStyles.body12.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
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
                  color: AppColors.surfaceInput,
                  borderRadius: AppRadii.mdAll,
                ),
                child: _buildFormattedMessage(item.message),
              ),
            ],
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
