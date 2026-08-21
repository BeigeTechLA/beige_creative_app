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
    useRootNavigator: true,
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

  bool _categoryOpen = true;
  bool _dateOpen = false;
  bool _statusOpen = false;

  static const _statusOrder = <MeetingStatus>[
    MeetingStatus.initiated,
    MeetingStatus.completed,
    MeetingStatus.revision,
  ];

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
          // Range fill in M3 date-range picker reads from
          // `secondaryContainer`; endpoints read from `primary`. Override
          // both with brand gold tokens so the picker matches the app theme
          // instead of the default M3 teal.
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.primary,
            onSecondary: AppColors.onPrimary,
            secondaryContainer: AppColors.primary.withValues(alpha: 0.25),
            onSecondaryContainer: AppColors.textPrimary,
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
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Text(
                    'Filter',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExpandableSection(
                      title: 'Filter By Category',
                      expanded: _categoryOpen,
                      onToggle: () =>
                          setState(() => _categoryOpen = !_categoryOpen),
                      children: [
                        for (final c in MeetingCategory.values)
                          _CheckboxRow(
                            label: c.label,
                            checked: _draft.categories.contains(c),
                            onTap: () => _toggleCategory(c),
                          ),
                      ],
                    ),
                    AppSpacing.verticalBase,
                    _ExpandableSection(
                      title: 'Filter By Date',
                      expanded: _dateOpen,
                      onToggle: () => setState(() => _dateOpen = !_dateOpen),
                      children: [
                        _DateRangeField(
                          range: _draft.dateRange,
                          onTap: _pickDateRange,
                          onClear: _clearDateRange,
                          formatter: _rangeFmt,
                        ),
                      ],
                    ),
                    AppSpacing.verticalBase,
                    _ExpandableSection(
                      title: 'Filter By Status',
                      expanded: _statusOpen,
                      onToggle: () =>
                          setState(() => _statusOpen = !_statusOpen),
                      children: [
                        for (final s in _statusOrder)
                          _CheckboxRow(
                            label: s.label,
                            checked: _draft.statuses.contains(s),
                            onTap: () => _toggleStatus(s),
                          ),
                      ],
                    ),
                    AppSpacing.verticalXl,
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Clear All',
                            variant: AppButtonVariant.outline,
                            onPressed: _draft.isEmpty
                                ? null
                                : () => setState(
                                      () => _draft = MeetingFilter.empty,
                                    ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadii.xlAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.base,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(color: AppColors.dividerDark, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: checked,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.smd,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _SquareCheckbox(checked: checked),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareCheckbox extends StatelessWidget {
  const _SquareCheckbox({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : AppColors.transparent,
        borderRadius: AppRadii.xsAll,
        border: Border.all(
          color: checked ? AppColors.primary : AppColors.textTertiary,
          width: 1.4,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
          : null,
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
          color: AppColors.background,
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
