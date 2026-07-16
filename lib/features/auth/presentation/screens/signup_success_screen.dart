import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../providers/signup_notifier.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import 'view_details_screen.dart';

class SignUpSuccessScreen extends ConsumerWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupNotifierProvider);
    final featuredFiles = state.featuredProjects.expand((p) => p).toList();

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success Beige Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadii.xxxlAll,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Inner Dark Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppRadii.xxlAll,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar + Info + View Details Button
                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.border,
                                    backgroundImage: state.profileImage != null
                                        ? FileImage(state.profileImage!)
                                        : null,
                                    child: state.profileImage == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 28,
                                            color: AppColors.lavenderGrey,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.online,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.background,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${state.firstName} ${state.lastName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body15Strong
                                          .copyWith(color: AppColors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      state.location.isEmpty
                                          ? 'Your Location'
                                          : state.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body12.copyWith(
                                        color: AppColors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // View Details Capsule Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: AppColors.transparent,
                                    builder: (_) => ViewDetailsScreen(
                                      firstName: state.firstName,
                                      lastName: state.lastName,
                                      email: state.email,
                                      location: state.location,
                                      workingDistance: state.workingDistance,
                                      profileImage: state.profileImage,
                                      primaryRole: state.primaryRoleDisplay,
                                      experience: state.experienceDisplay,
                                      hourlyRate: state.hourlyRateDisplay,
                                      bio: state.bioDisplay,
                                      skills: state.skillsDisplay,
                                      equipments: state.equipmentsDisplay,
                                      featuredImages: featuredFiles,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.flash_on,
                                  size: 14,
                                  color: AppColors.background,
                                ),
                                label: Text(
                                  'View Details',
                                  style: AppTextStyles.bodySmallStrong.copyWith(
                                    color: AppColors.background,
                                    fontSize: 11,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.hugeAll,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rate & Experience
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: state.hourlyRateDisplay.isEmpty
                                              ? '₹0'
                                              : '₹${state.hourlyRateDisplay}',
                                          style: AppTextStyles.displayLabel16
                                              .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' /Hour',
                                          style: AppTextStyles
                                              .body11MediumLetter02
                                              .copyWith(
                                            color: AppColors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.experienceDisplay.isEmpty
                                        ? '0 Years'
                                        : '${state.experienceDisplay} Years',
                                    style: AppTextStyles.displayLabel16.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Experience',
                                    style: AppTextStyles.body11MediumLetter02
                                        .copyWith(
                                      color: AppColors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Social Badges
                          if (state.savedSocialLinks.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.savedSocialLinks.map((link) {
                                final name = link['name'] ?? '';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWarm,
                                    borderRadius: AppRadii.mdAll,
                                    border: Border.all(
                                      color: AppColors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        name.toString().toLowerCase() ==
                                                'linkedin'
                                            ? Icons.business
                                            : Icons.link,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        name,
                                        style: AppTextStyles.body11MediumLetter02
                                            .copyWith(color: AppColors.white),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Bio
                          if (state.bioDisplay.isNotEmpty) ...[
                            Text(
                              state.bioDisplay,
                              style: AppTextStyles.body13.copyWith(
                                color: AppColors.white70,
                              ),
                            ),
                          ],
                          // Featured Images Grid (up to 2 side-by-side)
                          if (featuredFiles.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: featuredFiles.take(2).map((file) {
                                return Expanded(
                                  child: Container(
                                    height: 100,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadii.xlAll,
                                      image: DecorationImage(
                                        image: FileImage(file),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Completed Headers
                    Text(
                      'Profile Completed',
                      style: AppTextStyles.displayStrong16.copyWith(
                        color: AppColors.textHeading,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your profile to get discovered by production teams.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body12.copyWith(
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Go to Dashboard Button
              AppCtaButton(
                label: 'Go to Dashboard',
                height: 55,
                onPressed: () {
                  ref.read(signupNotifierProvider.notifier).reset();
                  context.go(Routes.login.path);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
