import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../screens/view_details_screen.dart';

class SignUp3PreviewCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final File? profileImage;
  final String location;
  final String workingDistance;
  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;
  final List<File> featuredImages;
  final int completionPercent;

  const SignUp3PreviewCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImage,
    required this.location,
    required this.workingDistance,
    required this.primaryRole,
    required this.experience,
    required this.hourlyRate,
    required this.bio,
    required this.skills,
    required this.equipments,
    required this.featuredImages,
    required this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    if (firstName.isEmpty &&
        lastName.isEmpty &&
        email.isEmpty &&
        profileImage == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.smd,
      ),
      margin: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.xxlAll,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.border,
            backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
            child: profileImage == null
                ? const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.lavenderGrey,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body15Strong
                      .copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? 'Your Email' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body12
                      .copyWith(color: AppColors.surfaceMid),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.transparent,
                            builder: (_) => ViewDetailsScreen(
                              firstName: firstName,
                              lastName: lastName,
                              email: email,
                              location: location,
                              workingDistance: workingDistance,
                              profileImage: profileImage,
                              primaryRole: primaryRole,
                              experience: experience,
                              hourlyRate: hourlyRate,
                              bio: bio,
                              skills: skills,
                              equipments: equipments,
                              featuredImages: featuredImages,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.black,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.hugeAll,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'View Details',
                            style: AppTextStyles.bodySmallMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppRadii.hugeAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$completionPercent%Completed',
                        style: AppTextStyles.bodySmallStrong
                            .copyWith(color: AppColors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
