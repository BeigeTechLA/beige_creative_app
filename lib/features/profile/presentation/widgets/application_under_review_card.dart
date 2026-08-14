import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../home/presentation/providers/home_notifier.dart';

/// Curation outcome the card renders. Mirrors the backend `is_crew_verified`
/// flag: `0` -> under review, `1` -> accepted, `2` -> rejected.
enum ApplicationReviewStatus { underReview, accepted, rejected }

/// Maps a raw `is_crew_verified` value to an [ApplicationReviewStatus].
ApplicationReviewStatus applicationReviewStatusFromFlag(int? crewVerified) {
  switch (crewVerified) {
    case 1:
      return ApplicationReviewStatus.accepted;
    case 2:
      return ApplicationReviewStatus.rejected;
    default:
      return ApplicationReviewStatus.underReview;
  }
}

/// Presentation card displaying the application curation status.
///
/// Designed based on the Champagne Warm Gold design specification. Can be used
/// directly embedded on a screen or popped inside a modal dialog using
/// [ApplicationUnderReviewDialog.show].
///
/// The inner status pill and the bottom CTA morph with [status]:
/// - [ApplicationReviewStatus.underReview] -> "Refresh Status" pill +
///   "Complete Your Profile" CTA.
/// - [ApplicationReviewStatus.accepted] -> green "Profile Accepted" pill +
///   "Go To Dashboard" CTA.
/// - [ApplicationReviewStatus.rejected] -> maroon "Profile Rejected" pill +
///   "View Reason" CTA.
class ApplicationUnderReviewCard extends ConsumerWidget {
  final String? profileImageUrl;
  final ApplicationReviewStatus status;
  final bool isRefreshing;
  final VoidCallback? onRefreshStatus;
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onGoToDashboard;
  final VoidCallback? onViewReason;
  final bool showBottomButton;
  final String title;
  final String description;
  final String nextStepsTitle;
  final String nextStepsDescription;

  const ApplicationUnderReviewCard({
    super.key,
    this.profileImageUrl,
    this.status = ApplicationReviewStatus.underReview,
    this.isRefreshing = false,
    this.onRefreshStatus,
    this.onCompleteProfile,
    this.onGoToDashboard,
    this.onViewReason,
    this.showBottomButton = true,
    this.title = 'Application Under Review',
    this.description =
        'Welcome to the Beige collective. Our curation team is currently reviewing your portfolio and credentials. We maintain a high standard for our creators to ensure premium quality for our clients.',
    this.nextStepsTitle = 'NEXT STEPS',
    this.nextStepsDescription =
        'Reviews typically take 2–3 business days. You\'ll receive an email once your dashboard is fully activated.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double avatarRadius = 52.0;
    const double avatarDiameter = avatarRadius * 2;

    final homeProfileUrl = ref.watch(
      homeNotifierProvider.select((s) => s.profileData?.profileImageUrl),
    );
    final sessionUser = ref.watch(currentSessionUserProvider);

    final effectiveImageUrl =
        (homeProfileUrl != null && homeProfileUrl.isNotEmpty)
            ? homeProfileUrl
            : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                ? profileImageUrl
                : sessionUser?.profileImageUrl;

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

                        // Status pill (Refresh Status / Accepted / Rejected).
                        _buildStatusPill(),
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
                    child: _buildAvatarImage(avatarDiameter, effectiveImageUrl),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Optional Bottom Action Button (morphs with status).
        if (showBottomButton) ...[
          const SizedBox(height: 24),
          _buildBottomButton(),
        ],
      ],
    );
  }

  /// Inner pill inside the "Next Steps" panel.
  Widget _buildStatusPill() {
    switch (status) {
      case ApplicationReviewStatus.accepted:
        return _statusPillDisplay(
          label: 'Profile Accepted',
          background: AppColors.greenForest,
          textColor: AppColors.white,
        );
      case ApplicationReviewStatus.rejected:
        return _statusPillDisplay(
          label: 'Profile Rejected',
          background: const Color(0xFF9E332B),
          textColor: AppColors.white,
        );
      case ApplicationReviewStatus.underReview:
        return InkWell(
          onTap: isRefreshing ? null : onRefreshStatus,
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
            child: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE5D4B9),
                    ),
                  )
                : Text(
                    'Refresh Status',
                    style: AppTextStyles.body14Medium.copyWith(
                      color: const Color(0xFFE5D4B9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
    }
  }

  Widget _statusPillDisplay({
    required String label,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: AppTextStyles.body14Medium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final String label;
    final VoidCallback? onPressed;
    switch (status) {
      case ApplicationReviewStatus.accepted:
        label = 'Go To Dashboard';
        onPressed = onGoToDashboard;
        break;
      case ApplicationReviewStatus.rejected:
        label = 'View Reason';
        onPressed = onViewReason;
        break;
      case ApplicationReviewStatus.underReview:
        label = 'Complete Your Profile';
        onPressed = onCompleteProfile;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE7D8C4),
          foregroundColor: const Color(0xFF161513),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        ),
        child: Text(
          label,
          style: AppTextStyles.body15Strong.copyWith(
            fontSize: 16,
            color: const Color(0xFF161513),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(double diameter, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${Env.imageUrl}$imageUrl';

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
///
/// The dialog is stateful: tapping "Refresh Status" calls [onRefresh], which
/// must re-fetch `creator/get-profile-detail` and return the fresh
/// `is_crew_verified` flag. The card then morphs in place:
/// - `1` (accepted)  -> green pill + "Go To Dashboard".
/// - `2` (rejected)  -> maroon pill + "View Reason".
/// - anything else   -> stays on the under-review state.
class ApplicationUnderReviewDialog {
  ApplicationUnderReviewDialog._();

  static Future<T?> show<T>(
    BuildContext context, {
    String? profileImageUrl,
    int? initialCrewVerified,
    Future<int?> Function()? onRefresh,
    FutureOr<void> Function()? onCompleteProfile,
    FutureOr<void> Function()? onGoToDashboard,
    FutureOr<void> Function()? onViewReason,
    bool showBottomButton = true,
    bool barrierDismissible = true,
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
            child: _ReviewDialogBody(
              profileImageUrl: profileImageUrl,
              initialCrewVerified: initialCrewVerified,
              onRefresh: onRefresh,
              onCompleteProfile: onCompleteProfile,
              onGoToDashboard: onGoToDashboard,
              onViewReason: onViewReason,
              showBottomButton: showBottomButton,
            ),
          ),
        ),
      ),
    );
  }

  /// Displays the Rejection Reason bottom sheet matching the dark Champagne theme.
  static Future<void> showRejectionReasonBottomSheet(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161513),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.of(sheetContext).padding.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Red warning icon container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF9E332B).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9E332B).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 40,
                color: Color(0xFFE56B6F),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'An Update on Your Application',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingOutfitLg.copyWith(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 14),

            // Description body
            Text(
              'Thank you for taking the time to apply to join Beige as a Creator Partner. After reviewing your application, we\'re unable to approve it at this time.\n\nThis decision does not diminish your experience or creative work. If you believe we missed something, or you would like guidance before applying again, our support team is here to help.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.white70,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),

            // Contact Support Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _contactSupport(sheetContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7D8C4),
                  foregroundColor: const Color(0xFF161513),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  elevation: 0,
                ),
                child: Text(
                  'Contact Support',
                  style: AppTextStyles.body15Strong.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF161513),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await ref.read(authStateProvider.notifier).logout();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                ),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _contactSupport(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@beige.app',
      queryParameters: {'subject': 'CP Application Status Inquiry'},
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          TopMessage.show(
            context,
            'Please email support@beige.app for assistance.',
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        TopMessage.show(
          context,
          'Please email support@beige.app for assistance.',
        );
      }
    }
  }
}

/// Stateful body owning the curation status so the refresh action can morph the
/// card in place without popping/re-showing the dialog.
class _ReviewDialogBody extends StatefulWidget {
  final String? profileImageUrl;
  final int? initialCrewVerified;
  final Future<int?> Function()? onRefresh;
  final FutureOr<void> Function()? onCompleteProfile;
  final FutureOr<void> Function()? onGoToDashboard;
  final FutureOr<void> Function()? onViewReason;
  final bool showBottomButton;

  const _ReviewDialogBody({
    this.profileImageUrl,
    this.initialCrewVerified,
    this.onRefresh,
    this.onCompleteProfile,
    this.onGoToDashboard,
    this.onViewReason,
    this.showBottomButton = true,
  });

  @override
  State<_ReviewDialogBody> createState() => _ReviewDialogBodyState();
}

class _ReviewDialogBodyState extends State<_ReviewDialogBody> {
  late ApplicationReviewStatus _status;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _status = applicationReviewStatusFromFlag(widget.initialCrewVerified);
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    int? crewVerified;
    try {
      crewVerified = await widget.onRefresh?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _status = applicationReviewStatusFromFlag(crewVerified);
        });
      }
    }
  }

  void _dismiss() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApplicationUnderReviewCard(
      profileImageUrl: widget.profileImageUrl,
      status: _status,
      isRefreshing: _isRefreshing,
      showBottomButton: widget.showBottomButton,
      onRefreshStatus: _handleRefresh,
      onCompleteProfile: () async {
        _dismiss();
        await widget.onCompleteProfile?.call();
      },
      onGoToDashboard: () async {
        _dismiss();
        await widget.onGoToDashboard?.call();
      },
      onViewReason: widget.onViewReason == null
          ? null
          : () async {
              await widget.onViewReason?.call();
            },
    );
  }
}
