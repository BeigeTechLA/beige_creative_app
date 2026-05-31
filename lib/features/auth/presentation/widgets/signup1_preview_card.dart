import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class SignUp1PreviewCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final File? profileImage;
  final String location;
  final String workingDistance;
  final int completionPercent;

  const SignUp1PreviewCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImage,
    required this.location,
    required this.workingDistance,
    required this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.smd,
          ),
          margin: const EdgeInsets.all(AppSpacing.smd),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadii.xxlAll,
            boxShadow: AppShadows.cardHeavy,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.border,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
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
                          "${firstName.isEmpty ? '' : firstName} ${lastName.isEmpty ? '' : lastName}",
                          style: AppTextStyles.body15Strong.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.isEmpty ? "Your Email" : email,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.greyShade737,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed(
                          RouteNames.viewDetails,
                          extra: {
                            "firstName": firstName,
                            "lastName": lastName,
                            "email": email,
                            "profileImage": profileImage,
                            "location": location,
                            "workingDistance": workingDistance,
                            "primaryRole": "",
                            "experience": "",
                            "hourlyRate": "",
                            "bio": "",
                            "skills": "",
                            "equipments": "",
                            "featuredImages": <File>[],
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.hugeAll,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "View Details",
                          style: AppTextStyles.bodySmallMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: AppRadii.hugeAll,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$completionPercent% Completed",
                      style: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
