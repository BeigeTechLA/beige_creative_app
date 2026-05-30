import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../providers/file_manager_providers.dart';

/// Folder/shoot detail surface reached via "View Shoot Details" inside
/// pre-production. Named with the feature prefix to avoid colliding with the
/// auth `ViewDetailsScreen` (which the router exposes under `viewDetails`).
class FileManagerViewDetailsScreen extends ConsumerWidget {
  final String folderId;
  const FileManagerViewDetailsScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(viewDetailsNotifierProvider(folderId));
    final folder = state.folder;

    return Scaffold(
      body: state.isLoading || folder == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: AppRadii.bottomHeader,
                          child: Image.asset(
                            AppAssets.rectangle,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 90,
                        left: AppSpacing.base,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(AppAssets.back, height: 24),
                        ),
                      ),
                      const Positioned(
                        top: 90,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'Shoot Details',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -48,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xxs),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.circleGradientBottom,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.onPrimary,
                              ),
                              child: const Center(
                                child: Text(
                                  'L#1',
                                  style: AppTextStyles.displayMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.bottomNavHeight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(folder.name, style: AppTextStyles.body20Medium),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sectionGapLg,
                    ),
                    child: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                      'sed do eiusmod tempor incididunt ut labore et dolore '
                      'magna aliqua.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.hugeAll,
                    ),
                    child: const Text(
                      'Post Production',
                      style: AppTextStyles.bodyCompactMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(
                    color: AppColors.dividerDark,
                    thickness: 0.8,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadii.massiveAll,
                      border: Border.all(color: AppColors.dividerDark),
                      boxShadow: AppShadows.viewerSheet,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shoot Details',
                          style: AppTextStyles.body15Strong,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        _DetailRow(title: 'Shoot Date', value: 'Jan 16, 2026'),
                        _DetailRow(
                          title: 'Time',
                          value: '11:30 PM · 11 Hours',
                        ),
                        _DetailRow(title: 'Total Value', value: '\$14,400'),
                        _DetailRow(
                          title: 'Payment Status',
                          value: 'Paid',
                          isGreen: true,
                        ),
                        _DetailRow(
                          title: 'Folder Link',
                          value: 'http://fijejpfkmdjfief',
                          isLink: true,
                        ),
                        _DetailRow(
                          title: 'Shoot Files',
                          value: '200 Images & 50 Videos',
                        ),
                        _DetailRow(
                          title: 'Location',
                          value: '1234 Mockingbird Lane, CA 90000',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isGreen;
  final bool isLink;

  const _DetailRow({
    required this.title,
    required this.value,
    this.isGreen = false,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.mld),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: AppTextStyles.bodyCompact),
          ),
          const Text(':  ', style: AppTextStyles.inherit),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.inherit13.copyWith(
                color: isGreen
                    ? AppColors.greenAccent
                    : isLink
                        ? AppColors.borderGold
                        : AppColors.white,
                fontWeight: FontWeight.w500,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
