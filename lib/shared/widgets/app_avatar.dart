import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/text_styles.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }

/// Canonical user avatar. Renders the network image when [imageUrl] is set;
/// falls back to initials over a tinted surface.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.onTap,
  });

  double get _diameter {
    switch (size) {
      case AppAvatarSize.xs:
        return 24;
      case AppAvatarSize.sm:
        return 32;
      case AppAvatarSize.md:
        return 48;
      case AppAvatarSize.lg:
        return 64;
      case AppAvatarSize.xl:
        return 96;
    }
  }

  TextStyle get _initialsStyle {
    switch (size) {
      case AppAvatarSize.xs:
        return AppTextStyles.labelSmall;
      case AppAvatarSize.sm:
        return AppTextStyles.labelMedium;
      case AppAvatarSize.md:
        return AppTextStyles.bodyLarge;
      case AppAvatarSize.lg:
        return AppTextStyles.titleMedium;
      case AppAvatarSize.xl:
        return AppTextStyles.titleLarge;
    }
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initials = name == null || name!.isEmpty ? '?' : _initials(name!);

    final inner = ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _initialsAvatar(initials, diameter),
                errorWidget: (_, _, _) =>
                    _initialsAvatar(initials, diameter),
              )
            : _initialsAvatar(initials, diameter),
      ),
    );

    if (onTap == null) return inner;
    return GestureDetector(onTap: onTap, child: inner);
  }

  Widget _initialsAvatar(String initials, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: _initialsStyle.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
