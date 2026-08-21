import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Accessibility-friendly, semantic status pill.
/// Surfaces visual status indicators using both text labels and colored elements.
class FmStatusPill extends StatelessWidget {
  final String label;

  const FmStatusPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();

    final config = _getConfig(label);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.chipPaddingH,
        vertical: AppSpacing.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: AppRadii.fullAll,
        border: config.border != null ? Border.all(color: config.border!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.icon != null) ...[
            Icon(config.icon, size: 13, color: config.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: config.fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color fg, Color? border, IconData? icon}) _getConfig(String label) {
    final clean = label.trim().toLowerCase();
    if (clean == 'raw files uploaded') {
      return (
        bg: const Color(0x263B82F6), // Soft blue tint
        fg: const Color(0xFF60A5FA),
        border: null,
        icon: Icons.cloud_done_outlined,
      );
    } else if (clean == 'file selected for edits') {
      return (
        bg: const Color(0x268B5CF6), // Soft purple tint
        fg: const Color(0xFFC084FC),
        border: null,
        icon: Icons.edit_note_outlined,
      );
    } else if (clean == 'linked') {
      return (
        bg: const Color(0xFFD4FFE4),
        fg: const Color(0xFF16A34A),
        border: null,
        icon: Icons.link,
      );
    } else if (clean == 'unlinked') {
      return (
        bg: const Color(0xFFFFF1F2),
        fg: const Color(0xFFF43F5E),
        border: null,
        icon: Icons.link_off,
      );
    }

    // Default fallback (e.g. tag chips)
    return (
      bg: AppColors.surfaceStats,
      fg: AppColors.textPrimary,
      border: null,
      icon: null,
    );
  }
}
