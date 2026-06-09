import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:flutter/material.dart' as material show DateTimeRange;
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/meeting_category.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_status.dart';

Future<MeetingFilter?> showMeetingFilterSheet(
  BuildContext context, {
  required MeetingFilter current,
}) {
  return showModalBottomSheet<MeetingFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.topSheet),
    builder: (_) => MeetingFilterSheet(current: current),
  );
}

class MeetingFilterSheet extends StatefulWidget {
  const MeetingFilterSheet({super.key, required this.current});

  final MeetingFilter current;

  @override
  State<MeetingFilterSheet> createState() => _MeetingFilterSheetState();
}

class _MeetingFilterSheetState extends State<MeetingFilterSheet> {
  late MeetingFilter _draft = widget.current;
  static final _rangeFmt = DateFormat('dd MMM yyyy');

  bool get _hasChanges =>
      _draft.categories != widget.current.categories ||
      _draft.statuses != widget.current.statuses ||
      _draft.dateRange != widget.current.dateRange;

  void _toggleCategory(MeetingCategory c) {
    setState(() {
      final next = Set<MeetingCategory>.from(_draft.categories);
      next.contains(c) ? next.remove(c) : next.add(c);
      _draft = _draft.copyWith(categories: next);
    });
  }

  void _toggleStatus(MeetingStatus s) {
    setState(() {
      final next = Set<MeetingStatus>.from(_draft.statuses);
      next.contains(s) ? next.remove(s) : next.add(s);
      _draft = _draft.copyWith(statuses: next);
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = _draft.dateRange == null
        ? null
        : material.DateTimeRange(
            start: _draft.dateRange!.start,
            end: _draft.dateRange!.end,
          );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initial,
      helpText: 'Select date range',
      builder: (ctx, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surfaceGradientDark,
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surfaceGradientDark,
            onSurface: AppColors.white,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null) return;
    setState(() {
      _draft = _draft.copyWith(
        dateRange: DateTimeRange(start: picked.start, end: picked.end),
      );
    });
  }

  void _clearDateRange() {
    setState(() => _draft = _draft.copyWith(clearDateRange: true));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalMd,
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerDark,
                borderRadius: AppRadii.fullAll,
              ),
            ),
            AppSpacing.verticalBase,
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Text('Filter', style: AppTextStyles.titleMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Filter By Category'),
                    AppSpacing.verticalMd,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final c in MeetingCategory.values)
                          _SelectableChip(
                            label: c.label,
                            isSelected: _draft.categories.contains(c),
                            onTap: () => _toggleCategory(c),
                          ),
                      ],
                    ),
                    AppSpacing.verticalXxl,
                    _SectionLabel('Filter By Date'),
                    AppSpacing.verticalMd,
                    _DateRangeField(
                      range: _draft.dateRange,
                      onTap: _pickDateRange,
                      onClear: _clearDateRange,
                      formatter: _rangeFmt,
                    ),
                    AppSpacing.verticalXxl,
                    _SectionLabel('Filter By Status'),
                    AppSpacing.verticalMd,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final s in const [
                          MeetingStatus.initiated,
                          MeetingStatus.reviewer,
                          MeetingStatus.completed,
                        ])
                          _SelectableChip(
                            label: s.label,
                            isSelected: _draft.statuses.contains(s),
                            onTap: () => _toggleStatus(s),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.base,
                AppSpacing.xl,
                AppSpacing.base,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Clear All',
                      variant: AppButtonVariant.outline,
                      onPressed: _draft.isEmpty
                          ? null
                          : () => setState(() => _draft = MeetingFilter.empty),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Apply',
                      onPressed: _hasChanges
                          ? () => Navigator.of(context).pop(_draft)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body14Medium.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadii.smAll,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.dividerDark,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body14.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateRangeField extends StatelessWidget {
  const _DateRangeField({
    required this.range,
    required this.onTap,
    required this.onClear,
    required this.formatter,
  });

  final DateTimeRange? range;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    final hasRange = range != null;
    final label = hasRange
        ? '${formatter.format(range!.start)} – ${formatter.format(range!.end)}'
        : 'Select date range';
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.mld,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.mdAll,
          border: Border.all(color: AppColors.dividerDark),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body14.copyWith(
                  color: hasRange
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (hasRange)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
