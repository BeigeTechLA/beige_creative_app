import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

/// Beige curved header + dark name strip, matching the profile-screen pattern
/// (`ProfileHeader`). Avatar straddles the boundary between the beige hero
/// and the dark body; room name renders below on the dark surface. Avatar
/// always shows initials derived from the room name (no contact image).
class DetailsHeroHeader extends StatelessWidget {
  const DetailsHeroHeader({
    super.key,
    required this.roomName,
    required this.onBack,
  });

  static const double _avatarDiameter = 112;
  static const double _avatarOverlap = 56;

  final String roomName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: AppRadii.bottomHeader,
                child: SvgPicture.asset(
                  AppAssets.rectangleProfile,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: topInset + AppSpacing.lg,
              left: AppSpacing.md,
              child: InkWell(
                onTap: onBack,
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textHeading,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Positioned(
              top: topInset + AppSpacing.lg,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Details',
                  style: AppTextStyles.displayLabel16.copyWith(
                    color: AppColors.textHeading,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -_avatarOverlap,
              left: 0,
              right: 0,
              child: Center(
                child: _Avatar(
                  diameter: _avatarDiameter,
                  name: roomName,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _avatarOverlap + AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Text(
            roomName,
            style: AppTextStyles.displayBold20.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.dividerDark,
          indent: AppSpacing.screenH,
          endIndent: AppSpacing.screenH,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.diameter, required this.name});

  final double diameter;
  final String name;

  String get _initials {
    final cleaned = name
        .replaceAll(RegExp(r'[_#]+'), ' ')
        .trim();
    if (cleaned.isEmpty) return '?';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMid,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.displayBold20.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
