import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/file_type.dart';

/// Color-coded square badge per file type. Used both inline in `FmFileCard`
/// header and large inside the preview block. Size param picks both the
/// outer box dimensions and label scale.
class FmFileTypeIcon extends StatelessWidget {
  final FileType type;
  final double size;

  const FmFileTypeIcon({super.key, required this.type, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final palette = _palette(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      alignment: Alignment.center,
      child: Text(
        palette.label,
        style: AppTextStyles.labelMedium.copyWith(
          color: palette.fg,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _Palette _palette(FileType t) {
    switch (t) {
      case FileType.pdf:
        return _Palette(label: 'PDF', bg: const Color(0xFFF87171), fg: AppColors.white);
      case FileType.doc:
        return _Palette(label: 'DOC', bg: const Color(0xFF60A5FA), fg: AppColors.white);
      case FileType.sheet:
        return _Palette(label: 'XLS', bg: const Color(0xFF34D399), fg: AppColors.white);
      case FileType.image:
        return _Palette(label: 'IMG', bg: const Color(0xFFFBBF24), fg: AppColors.white);
      case FileType.video:
        return _Palette(label: 'MP4', bg: const Color(0xFFA78BFA), fg: AppColors.white);
      case FileType.audio:
        return _Palette(label: 'AUD', bg: const Color(0xFFF472B6), fg: AppColors.white);
      case FileType.zip:
        return _Palette(label: 'ZIP', bg: const Color(0xFF94A3B8), fg: AppColors.white);
      case FileType.other:
        return _Palette(label: 'FILE', bg: AppColors.surfaceMid, fg: AppColors.textSecondary);
    }
  }
}

class _Palette {
  final String label;
  final Color bg;
  final Color fg;
  const _Palette({required this.label, required this.bg, required this.fg});
}
