import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/chat_details.dart';

class DetailsHeroHeader extends StatelessWidget {
  const DetailsHeroHeader({
    super.key,
    required this.contact,
    required this.onBack,
  });

  final ContactInfo contact;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: AppRadii.bottomHeader,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Details',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppAvatar(
                name: contact.name,
                imageUrl: contact.avatarUrl,
                size: AppAvatarSize.xl,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                contact.name,
                style: AppTextStyles.displayBold20.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _MetaLine(email: contact.email, phone: contact.phone),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({this.email, this.phone});
  final String? email;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (email != null && email!.isNotEmpty) email!,
      if (phone != null && phone!.isNotEmpty) phone!,
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Text(
        parts.join(' · '),
        style: AppTextStyles.body12.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
