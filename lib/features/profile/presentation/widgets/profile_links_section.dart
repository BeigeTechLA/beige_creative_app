import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

const int _maxVisibleChips = 2;

/// "Social Link" section: heading + chip row (first 2 + "+N") + edit affordance.
class ProfileSocialLinksList extends StatelessWidget {
  final List<Map<String, String>> socialLinks;
  final VoidCallback onOpen;

  const ProfileSocialLinksList({
    super.key,
    required this.socialLinks,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _LinksChipSection(
      title: 'Social Link',
      emptyLabel: 'No social links added',
      links: socialLinks,
      iconTint: AppColors.white,
      onOpen: onOpen,
    );
  }
}

/// "Portfolio Link" section: heading + chip row (first 2 + "+N") + edit affordance.
class ProfilePortfolioLinksList extends StatelessWidget {
  final List<Map<String, String>> portfolioLinks;
  final VoidCallback onOpen;

  const ProfilePortfolioLinksList({
    super.key,
    required this.portfolioLinks,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _LinksChipSection(
      title: 'Portfolio Links',
      emptyLabel: 'No portfolio links added',
      links: portfolioLinks,
      iconTint: AppColors.primary,
      onOpen: onOpen,
    );
  }
}

class _LinksChipSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<Map<String, String>> links;
  final Color iconTint;
  final VoidCallback onOpen;

  const _LinksChipSection({
    required this.title,
    required this.emptyLabel,
    required this.links,
    required this.iconTint,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final visible = links.take(_maxVisibleChips).toList();
    final overflow = links.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.displayLabel14.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: links.isEmpty
                  ? const Text(
                      'No links added',
                      style: AppTextStyles.inherit,
                    )
                  : Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final item in visible)
                          _LinkChip(
                            item: item,
                            iconTint: iconTint,
                            onTap: () => _openExternalLink(
                              context,
                              item['url'],
                              fallback: onOpen,
                            ),
                          ),
                        if (overflow > 0)
                          _LinkChip.overflow(
                            count: overflow,
                            onTap: onOpen,
                          ),
                      ],
                    ),
            ),
            const SizedBox(width: AppSpacing.smd),
            _EditAffordance(onTap: onOpen),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  final Map<String, String>? item;
  final Color iconTint;
  final int? overflowCount;
  final VoidCallback onTap;

  const _LinkChip({
    required this.item,
    required this.iconTint,
    required this.onTap,
  }) : overflowCount = null;

  const _LinkChip.overflow({
    required int count,
    required this.onTap,
  })  : item = null,
        iconTint = AppColors.white,
        overflowCount = count;

  @override
  Widget build(BuildContext context) {
    final isOverflow = overflowCount != null;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.dropdownIconInset,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: AppRadii.mdAll,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isOverflow && item?['icon'] != null) ...[
              SvgPicture.asset(
                item!['icon']!,
                height: 14,
                width: 14,
                colorFilter: ColorFilter.mode(iconTint, BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              isOverflow ? '+$overflowCount' : (item?['name'] ?? ''),
              style: AppTextStyles.body12.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openExternalLink(
  BuildContext context,
  String? rawUrl, {
  required VoidCallback fallback,
}) async {
  final uri = _parseExternalUri(rawUrl);
  if (uri == null) {
    fallback();
    return;
  }
  final messenger = ScaffoldMessenger.maybeOf(context);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && messenger != null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open link')),
    );
  }
}

Uri? _parseExternalUri(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final withScheme =
      trimmed.startsWith(RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://'))
          ? trimmed
          : 'https://$trimmed';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty) return null;
  return uri;
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
        child: SvgPicture.asset(AppAssets.myProfileEdit),
      ),
    );
  }
}
