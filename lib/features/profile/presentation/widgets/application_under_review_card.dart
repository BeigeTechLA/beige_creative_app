import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';

/// Presentation card displaying the "Application Under Review" status.
///
/// Designed based on the Champagne Warm Gold design specification. Can be used
/// directly embedded on a screen or popped inside a modal dialog using
/// [ApplicationUnderReviewDialog.show].
class ApplicationUnderReviewCard extends StatelessWidget {
  final String? profileImageUrl;
  final VoidCallback? onRefreshStatus;
  final VoidCallback? onCompleteProfile;
  final bool showCompleteProfileButton;
  final String title;
  final String description;
  final String nextStepsTitle;
  final String nextStepsDescription;

  const ApplicationUnderReviewCard({
    super.key,
    this.profileImageUrl,
    this.onRefreshStatus,
    this.onCompleteProfile,
    this.showCompleteProfileButton = true,
    this.title = 'Application Under Review',
    this.description =
        'Welcome to the Beige collective. Our curation team is currently reviewing your portfolio and credentials. We maintain a high standard for our creators to ensure premium quality for our clients.',
    this.nextStepsTitle = 'NEXT STEPS',
    this.nextStepsDescription =
        'Reviews typically take 2–3 business days. You\'ll receive an email once your dashboard is fully activated.',
  });

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 52.0;
    const double avatarDiameter = avatarRadius * 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Outer Main Champagne Gold Card Container
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: avatarRadius),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                avatarRadius + AppSpacing.base,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8DBCA), Color(0xFFDCCBB5)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body20Medium.copyWith(
                      color: const Color(0xFF161513),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description Body
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body14.copyWith(
                      color: const Color(0xFF524D45),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Inner Next Steps Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EFEA),
                      borderRadius: AppRadii.lgAll,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nextStepsTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body15Strong.copyWith(
                            fontSize: 16,
                            color: const Color(0xFF161513),
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nextStepsDescription,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: const Color(0xFF524D45),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Refresh Status CTA Button
                        InkWell(
                          onTap: onRefreshStatus,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121212),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Refresh Status',
                              style: AppTextStyles.body14Medium.copyWith(
                                color: const Color(0xFFE5D4B9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Top Overlapping Circular Avatar with Halo Ring
            Positioned(
              top: 0,
              child: Container(
                width: avatarDiameter + 6,
                height: avatarDiameter + 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE5D4B9), Color(0xFF8A765A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: Container(
                    color: AppColors.surfaceDark,
                    child: _buildAvatarImage(avatarDiameter),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Optional Bottom Action Button (Complete Your Profile)
        if (showCompleteProfileButton) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onCompleteProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE7D8C4),
                foregroundColor: const Color(0xFF161513),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
              ),
              child: Text(
                'Complete Your Profile',
                style: AppTextStyles.body15Strong.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF161513),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarImage(double diameter) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      final fullUrl = profileImageUrl!.startsWith('http')
          ? profileImageUrl!
          : '${Env.imageUrl}$profileImageUrl';

      return CachedNetworkImage(
        imageUrl: fullUrl,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceWarm,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(diameter),
      );
    }

    return _buildPlaceholder(diameter);
  }

  Widget _buildPlaceholder(double diameter) {
    return SvgPicture.asset(
      AppAssets.userCircle,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
    );
  }
}

/// Modal Dialog Helper for popping the Under Review Card as a modal overlay.
class ApplicationUnderReviewDialog {
  ApplicationUnderReviewDialog._();

  static Future<T?> show<T>(
    BuildContext context, {
    String? profileImageUrl,
    FutureOr<void> Function()? onRefreshStatus,
    FutureOr<void> Function()? onCompleteProfile,
    bool showCompleteProfileButton = true,
    bool barrierDismissible = true,
    bool closeOnRefresh = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.black.withValues(alpha: 0.85),
      builder: (dialogContext) => PopScope(
        canPop: barrierDismissible,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: ApplicationUnderReviewCard(
              profileImageUrl: profileImageUrl,
              onRefreshStatus: () async {
                if (closeOnRefresh) {
                  Navigator.of(dialogContext).pop();
                }
                await onRefreshStatus?.call();
              },
              onCompleteProfile: () async {
                Navigator.of(dialogContext).pop();
                await onCompleteProfile?.call();
              },
              showCompleteProfileButton: showCompleteProfileButton,
            ),
          ),
        ),
      ),
    );
  }
}
