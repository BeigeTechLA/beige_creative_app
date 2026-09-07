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
    final hasBio = bio.trim().isNotEmpty;
    final hasSkills = skills.trim().isNotEmpty;
    final hasEquipments = equipments.trim().isNotEmpty;
    final hasFeatured = featuredImages.isNotEmpty;

    return DefaultTextStyle(
      style: AppTextStyles.inherit.copyWith(decoration: TextDecoration.none),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadii.topMassive,
        ),
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: AppRadii.xsAll,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile Details",
                    style: AppTextStyles.displayLabel16.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  AppIconTapTarget(
                    semanticLabel: 'Close',
                    onTap: () => context.pop(),
                    icon: const Icon(Icons.close, color: AppColors.white, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.dividerDark, height: 1),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Hero Card
                    _buildProfileHeroCard(),

                    const SizedBox(height: 16),

                    // Professional Details Section
                    _buildProfessionalCard(),

                    if (hasBio) ...[
                      const SizedBox(height: 16),
                      _buildBioCard(),
                    ],

                    if (hasSkills) ...[
                      const SizedBox(height: 16),
                      _buildChipsSection("Skills", skills),
                    ],

                    if (hasEquipments) ...[
                      const SizedBox(height: 16),
                      _buildChipsSection("Equipments", equipments),
                    ],

                    if (hasFeatured) ...[
                      const SizedBox(height: 16),
                      _buildFeaturedWorkSection(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeroCard() {
    final name = "$firstName $lastName".trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldPaleCream.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.black,
                  backgroundImage:
                      profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.lavenderGrey,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? "User Profile" : name,
                      style: AppTextStyles.bodyLargeStrong.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    if (primaryRole.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldPaleCream.withValues(alpha: 0.15),
                          borderRadius: AppRadii.xsAll,
                        ),
                        child: Text(
                          primaryRole,
                          style: AppTextStyles.bodyCompactMedium.copyWith(
                            color: AppColors.goldPaleCream,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (email.isNotEmpty || location.isNotEmpty || workingDistance.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.white10, height: 1),
            const SizedBox(height: 12),
          ],

          if (email.isNotEmpty)
            _buildMetaRow(Icons.email_outlined, email),

          if (location.isNotEmpty)
            _buildMetaRow(Icons.location_on_outlined, location),

          if (workingDistance.isNotEmpty)
            _buildMetaRow(Icons.directions_car_outlined, "Within $workingDistance"),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.goldPaleCream.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body13.copyWith(
                color: AppColors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard() {
    final hasRole = primaryRole.isNotEmpty;
    final hasExp = experience.trim().isNotEmpty;
    final hasRate = hourlyRate.trim().isNotEmpty;

    if (!hasRole && !hasExp && !hasRate) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.work_outline, "Professional Details"),
          const SizedBox(height: 12),
          if (hasRole)
            _buildDetailRow("Primary Role", primaryRole),
          if (hasExp)
            _buildDetailRow("Experience", "$experience Years"),
          if (hasRate)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hourly Rate",
                    style: AppTextStyles.body13.copyWith(
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldPaleCream.withValues(alpha: 0.12),
                      borderRadius: AppRadii.mldAll,
                      border: Border.all(
                        color: AppColors.goldPaleCream.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      "₹ $hourlyRate/hr",
                      style: AppTextStyles.bodyCompactStrong.copyWith(
                        color: AppColors.goldPaleCream,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body13.copyWith(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyCompactStrong.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.description_outlined, "Bio"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.3),
              borderRadius: AppRadii.lgAll,
              border: Border(
                left: BorderSide(
                  color: AppColors.goldPaleCream.withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              bio,
              style: AppTextStyles.body13.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsSection(String title, String rawContent) {
    final items = rawContent
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (items.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title == "Skills" ? Icons.stars_outlined : Icons.build_circle_outlined,
            title,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.4),
                  borderRadius: AppRadii.pillAll,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  item,
                  style: AppTextStyles.bodyCompactMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedWorkSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(Icons.photo_library_outlined, "Featured Work"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: AppRadii.xsAll,
                ),
                child: Text(
                  "${featuredImages.length} ${featuredImages.length == 1 ? 'Item' : 'Items'}",
                  style: AppTextStyles.bodyCompactMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: featuredImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.xlAll,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.12),
                    ),
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
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.goldPaleCream,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyMediumStrong.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

}
