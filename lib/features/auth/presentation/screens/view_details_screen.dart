import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class ViewDetailsScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String location;
  final File? profileImage;
  final String workingDistance;

  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;
  final List<File> featuredImages;

  const ViewDetailsScreen({
    super.key,
    this.firstName = "",
    this.lastName = "",
    this.email = "",
    this.location = "",
    this.profileImage,
    this.workingDistance = "",
    this.primaryRole = "",
    this.experience = "",
    this.hourlyRate = "",
    this.bio = "",
    this.skills = "",
    this.equipments = "",
    this.featuredImages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: AppTextStyles.inherit.copyWith(decoration: TextDecoration.none),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(borderRadius: AppRadii.topSheet),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: AppRadii.mldAll,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile Details",
                    style: AppTextStyles.display14.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  AppIconTapTarget(
                    semanticLabel: 'Close',
                    onTap: () => context.pop(),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Divider(color: AppColors.dividerDark),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: AppRadii.xxxlAll,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.border,
                                  backgroundImage: profileImage != null
                                      ? FileImage(profileImage!)
                                      : null,
                                  child: profileImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: AppColors.lavenderGrey,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    "$firstName $lastName",
                                    style: AppTextStyles.bodyLargeStrong
                                        .copyWith(color: AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _infoText(email),
                            _infoText(location),
                            _infoText(workingDistance),
                            const SizedBox(height: 20),
                            _sectionTitle("Professional Details"),
                            _infoRow("Primary Role", primaryRole),
                            _infoRow(
                              "Experience",
                              experience.isEmpty ? "" : "$experience Years",
                            ),
                            _infoRow(
                              "Hourly Rate",
                              hourlyRate.isEmpty ? "" : "₹ $hourlyRate",
                            ),
                            const SizedBox(height: 20),
                            if (bio.isNotEmpty) ...[
                              _sectionTitle("Bio"),
                              const SizedBox(height: 6),
                              Text(
                                bio,
                                style: AppTextStyles.body13.copyWith(
                                  color: AppColors.white24,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (skills.isNotEmpty) ...[
                              _sectionTitle("Skills"),
                              const SizedBox(height: 6),
                              Text(
                                skills,
                                style: AppTextStyles.body13.copyWith(
                                  color: AppColors.white30,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (equipments.isNotEmpty) ...[
                              _sectionTitle("Equipments"),
                              const SizedBox(height: 6),
                              Text(
                                equipments,
                                style: AppTextStyles.body13.copyWith(
                                  color: AppColors.white30,
                                ),
                              ),
                            ],
                            if (featuredImages.isNotEmpty) ...[
                              _sectionTitle("Featured Work"),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(
                                        right: AppSpacing.md,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: AppRadii.xlAll,
                                        child: Image.file(
                                          featuredImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMediumStrong.copyWith(color: AppColors.white),
    );
  }

  Widget _infoRow(String title, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: AppTextStyles.bodyCompactMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body13.copyWith(color: AppColors.white30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        value,
        style: AppTextStyles.body13.copyWith(color: AppColors.white30),
      ),
    );
  }
}
