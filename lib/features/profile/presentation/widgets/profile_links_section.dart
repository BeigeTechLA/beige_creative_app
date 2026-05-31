import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// "Social Link" section: heading + list of saved entries + edit-affordance.
class ProfileSocialLinksList extends StatelessWidget {
  final List<Map<String, String>> socialLinks;
  final void Function(int index, Map<String, String> item) onEdit;
  final void Function(int index) onDelete;
  final VoidCallback onAdd;

  const ProfileSocialLinksList({
    super.key,
    required this.socialLinks,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Social Link',
              style: AppTextStyles.displayLabel14
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (socialLinks.isEmpty)
          const Text(
            'No social links added',
            style: AppTextStyles.inherit,
          )
        else
          Column(
            children: socialLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _SocialRow(
                item: item,
                onEdit: () => onEdit(index, item),
                onDelete: () => onDelete(index),
              );
            }).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_EditAffordance(onTap: onAdd)],
        ),
      ],
    );
  }
}

/// "Portfolio Link" section: heading + list of saved entries + edit-affordance.
class ProfilePortfolioLinksList extends StatelessWidget {
  final List<Map<String, String>> portfolioLinks;
  final void Function(int index, Map<String, String> item) onEdit;
  final Future<void> Function(int id) onDelete;
  final VoidCallback onAdd;

  const ProfilePortfolioLinksList({
    super.key,
    required this.portfolioLinks,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Portfolio Link',
              style: AppTextStyles.displayLabel14
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (portfolioLinks.isEmpty)
          const Text(
            'No portfolio links added',
            style: AppTextStyles.inherit,
          )
        else
          Column(
            children: portfolioLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _PortfolioRow(
                item: item,
                onEdit: () => onEdit(index, item),
                onDelete: () async {
                  final id = int.parse(item['id'].toString());
                  await onDelete(id);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_EditAffordance(onTap: onAdd)],
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SocialRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.smd),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white24),
        color: AppColors.surfaceMid,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            item['icon']!,
            height: 20,
            width: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  item['url']!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.white24),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _PortfolioRow extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const _PortfolioRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.smd),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white24),
        color: AppColors.surfaceVariant,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            item['icon']!,
            height: 20,
            width: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  item['url']!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.white24),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
            onPressed: () async => onDelete(),
          ),
        ],
      ),
    );
  }
}

class _EditAffordance extends StatelessWidget {
  final VoidCallback onTap;

  const _EditAffordance({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.lgAll,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadii.compactCardAll,
        ),
        child: SvgPicture.asset(AppAssets.myprofile_edit),
      ),
    );
  }
}
