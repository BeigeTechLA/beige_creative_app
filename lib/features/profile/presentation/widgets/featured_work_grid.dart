import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import 'featured_work_card.dart';

/// Groups `featuredWorkFiles` by title and renders them as a vertical stack of
/// [FeaturedWorkCard]s. Empty input renders a centered "No Featured Work"
/// placeholder.
///
/// Pure presentation. Lifted from the orchestrator's inline `Builder` (lines
/// ~328-568) during 4.08 split. Group-by-title logic and ordering are
/// preserved verbatim.
class FeaturedWorkGrid extends StatelessWidget {
  final List<dynamic> featuredWorkFiles;
  final void Function(String title, List<dynamic> images) onEdit;
  final void Function(List<dynamic> images) onDelete;
  final void Function(String title, List<dynamic> images) onNavigate;

  const FeaturedWorkGrid({
    super.key,
    required this.featuredWorkFiles,
    required this.onEdit,
    required this.onDelete,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (featuredWorkFiles.isEmpty) {
      return Center(
        child: Text(
          'No Featured Work',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white24),
        ),
      );
    }

    final Map<String, List<dynamic>> grouped = {};
    for (final item in featuredWorkFiles) {
      final title = item.title as String;
      grouped.putIfAbsent(title, () => <dynamic>[]).add(item);
    }

    return SingleChildScrollView(
      child: Column(
        children: grouped.entries.map((entry) {
          final title = entry.key;
          final images = entry.value;
          return FeaturedWorkCard(
            title: title,
            images: images,
            onEdit: () => onEdit(title, images),
            onDelete: () => onDelete(images),
            onTap: () => onNavigate(title, images),
          );
        }).toList(),
      ),
    );
  }
}
