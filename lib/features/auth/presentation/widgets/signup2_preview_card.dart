import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/signup_args.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class SignUp2PreviewCard extends StatelessWidget {
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
  final int completionPercent;

  const SignUp2PreviewCard({
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
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
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
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: AppTextStyles.body15Strong
                              .copyWith(color: AppColors.black),
                          children: [
                            const TextSpan(
                              text: 'Name : ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: '$firstName $lastName'.trim(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isEmpty ? 'Email ID: Your Email' : 'Email ID: $email',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body12
                            .copyWith(color: AppColors.surfaceMid),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFEEEEEE), height: 16, thickness: 1),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => context.pushNamed(
                      Routes.viewDetails.name,
                      extra: ViewDetailsArgs(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        profileImage: profileImage,
                        location: location,
                        workingDistance: workingDistance,
                        primaryRole: primaryRole,
                        experience: experience,
                        hourlyRate: hourlyRate,
                        bio: bio,
                        skills: skills,
                        equipments: equipments,
                      ).toExtra(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.hugeAll,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View Details',
                      style: AppTextStyles.bodySmallMedium
                          .copyWith(color: AppColors.goldPaleCream),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.hugeAll,
                    border: Border.all(
                      color: const Color(0xFFD0D0D0),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$completionPercent% Completed',
                    style: AppTextStyles.bodySmallStrong.copyWith(
                      color: const Color(0xFFC59553),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
