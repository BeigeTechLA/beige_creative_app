import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/link_state.dart';

/// Linked / Unlinked pill. Hidden when `state == null`.
///
/// Linked → mint surface + dark-green icon + text.
/// Unlinked → soft pink surface + deep-red icon + text.
class FmLinkedBadge extends StatelessWidget {
  final LinkState? state;
  final bool outline;

  const FmLinkedBadge({
    super.key,
    required this.state,
    this.outline = false,
  });

  // Hand-tuned to match the Figma palette. Not promoted to AppColors yet —
  // these only appear on this badge today.
  static const _linkedBg = Color(0xFFD4FFE4);
  static const _linkedFg = Color(0xFF16A34A);
  static const _unlinkedBg = Color(0xFFFFF1F2);
  static const _unlinkedFg = Color(0xFFF43F5E);

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s == null) return const SizedBox.shrink();

    final isLinked = s == LinkState.linked;
    final bg = isLinked ? _linkedBg : _unlinkedBg;
    final fg = isLinked ? _linkedFg : _unlinkedFg;
    final iconAsset = isLinked ? AppAssets.icLink : AppAssets.icUnlink;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.chipPaddingH,
        vertical: AppSpacing.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : bg,
        borderRadius: AppRadii.fullAll,
        border: outline ? Border.all(color: fg, width: 1.2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            s.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
