import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../utility/date_time_utils.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_cupertino_time_picker.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/availability_providers.dart';

class AddAvailabilityScreen extends ConsumerStatefulWidget {
  const AddAvailabilityScreen({super.key});

  @override
  ConsumerState<AddAvailabilityScreen> createState() =>
      _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends ConsumerState<AddAvailabilityScreen> {
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _notesController = TextEditingController();
  final _untilDateController = TextEditingController();
  final _repeatDayController = TextEditingController();

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _notesController.dispose();
    _untilDateController.dispose();
    _repeatDayController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    TextEditingController controller, {
    bool monthFirst = false,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: '',
      builder: (ctx, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surfaceGradientDark,
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppColors.goldSand,
            onPrimary: AppColors.black,
            surface: AppColors.surfaceGradientDark,
            onSurface: AppColors.white,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.surfaceGradientDark,
            dividerColor: AppColors.dividerDark,
            headerBackgroundColor: AppColors.surfaceNearBlack,
            headerHeadlineStyle: AppTextStyles.inherit.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
            dayStyle: AppTextStyles.inherit.copyWith(color: AppColors.white),
            weekdayStyle: AppTextStyles.inherit.copyWith(
              color: AppColors.white70,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text = monthFirst
          ? DateTimeUtils.formatMonthFirstDateInput(picked)
          : DateTimeUtils.formatDatePickerInput(picked);
      setState(() {});
    }
  }

  Future<void> _pickStartTime() async {
    final initialTime =
        DateTimeUtils.parseTimeOfDay(_startTimeController.text) ??
        TimeOfDay.now();
    final picked = await showAppCupertinoTimePicker(
      context: context,
      initialTime: initialTime,
      title: 'Select Start Time',
    );
    if (picked != null) {
      final pickedStr = DateTimeUtils.formatTimeOfDay12Hour(picked);

      final parsedDate = DateTimeUtils.parseMonthFirstDateInput(
        _dateController.text,
      );
      if (parsedDate != null) {
        final now = DateTime.now();
        final isToday =
            parsedDate.year == now.year &&
            parsedDate.month == now.month &&
            parsedDate.day == now.day;
        if (isToday) {
          final currentMin = now.hour * 60 + now.minute;
          final startMin = picked.hour * 60 + picked.minute;
          if (startMin < currentMin) {
            if (mounted) {
              TopMessage.show(context, 'Start time cannot be in the past');
            }
            return;
          }
        }
      }

      _startTimeController.text = pickedStr;

      final endDiff = DateTimeUtils.timeDifferenceInMinutes(
        _startTimeController.text,
        _endTimeController.text,
      );
      if (endDiff == null || endDiff < 60) {
        final endHour = (picked.hour + 1) % 24;
        final autoEndTime = TimeOfDay(hour: endHour, minute: picked.minute);
        _endTimeController.text = DateTimeUtils.formatTimeOfDay12Hour(
          autoEndTime,
        );
      }

      setState(() {});
    }
  }

  Future<void> _pickEndTime() async {
    final startParsed = DateTimeUtils.parseTimeOfDay(_startTimeController.text);
    final initialTime =
        DateTimeUtils.parseTimeOfDay(_endTimeController.text) ??
        (startParsed != null
            ? TimeOfDay(
                hour: (startParsed.hour + 1) % 24,
                minute: startParsed.minute,
              )
            : TimeOfDay.now());

    final picked = await showAppCupertinoTimePicker(
      context: context,
      initialTime: initialTime,
      title: 'Select End Time',
    );
    if (picked != null) {
      final pickedStr = DateTimeUtils.formatTimeOfDay12Hour(picked);

      if (_startTimeController.text.isNotEmpty) {
        final diff = DateTimeUtils.timeDifferenceInMinutes(
          _startTimeController.text,
          pickedStr,
        );
        if (diff == null || diff <= 0) {
          if (mounted) {
            TopMessage.show(context, 'End time must be after start time');
          }
          return;
        }
        if (diff < 60) {
          if (mounted) {
            TopMessage.show(
              context,
              'Minimum duration between start and end time must be at least 1 hour',
            );
          }
          return;
        }
      }

      _endTimeController.text = pickedStr;
      setState(() {});
    }
  }

  String _ordinal(String dayStr) {
    final n = int.tryParse(dayStr);
    if (n == null) return dayStr;
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  Future<void> _onSavePressed() async {
    final notifier = ref.read(addAvailabilityNotifierProvider.notifier);

    String formattedDate = '';
    final parsedDate = DateTimeUtils.parseMonthFirstDateInput(
      _dateController.text,
    );
    if (parsedDate != null) {
      formattedDate = DateTimeUtils.formatApiDate(parsedDate);
    } else {
      formattedDate = _dateController.text;
    }

    String recurrenceUntil = '';
    if (_untilDateController.text.isNotEmpty) {
      final parsedUntil = DateTimeUtils.parseDatePickerInput(
        _untilDateController.text,
      );
      recurrenceUntil = parsedUntil != null
          ? DateTimeUtils.formatApiDate(parsedUntil)
          : '';
    }

    final ok = await notifier.submit(
      formattedDate: formattedDate,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      recurrenceUntil: recurrenceUntil,
      repeatDay: _repeatDayController.text.trim(),
      notes: _notesController.text,
    );
    if (ok && mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AddAvailabilityState>(addAvailabilityNotifierProvider, (
      prev,
      next,
    ) {
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        TopMessage.show(context, next.validationMessage!);
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    final state = ref.watch(addAvailabilityNotifierProvider);
    final notifier = ref.read(addAvailabilityNotifierProvider.notifier);

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            AppSpacing.verticalXl,
            Row(
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(AppAssets.back),
                ),
              ],
            ),
            AppSpacing.verticalCardCompact,
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Availability',
                style: AppTextStyles.displayLabel16,
              ),
            ),
            Text(
              'Set your availability, time off, or block time for shoots.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.verticalXxl,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    CustomDropdown(
                      label: 'Select Type*',
                      value: state.type == null
                          ? null
                          : (state.type == AvailabilityType.available
                                ? 'Available'
                                : 'Not Available'),
                      items: const ['Available', 'Not Available']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    key: ValueKey(
                                      e == 'Available'
                                          ? 'availability-type-dot-available'
                                          : 'availability-type-dot-not-available',
                                    ),
                                    width: AppSpacing.sm,
                                    height: AppSpacing.sm,
                                    decoration: BoxDecoration(
                                      color: e == 'Available'
                                          ? AppColors.success
                                          : AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  AppSpacing.gapHSm,
                                  Text(
                                    e,
                                    style: AppTextStyles.inherit.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        notifier.setType(
                          val == 'Available'
                              ? AvailabilityType.available
                              : AvailabilityType.notAvailable,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Add Date',
                      controller: _dateController,
                      readOnly: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(AppSpacing.smd),
                        child: SvgPicture.asset(AppAssets.icAddDate),
                      ),
                      onTap: () => _pickDate(_dateController, monthFirst: true),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (!state.isAllDay) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Start Time',
                              controller: _startTimeController,
                              readOnly: true,
                              onTap: _pickStartTime,
                            ),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: CustomTextField(
                              label: 'End Time',
                              controller: _endTimeController,
                              readOnly: true,
                              onTap: _pickEndTime,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalLg,
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => notifier.toggleAllDay(!state.isAllDay),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: state.isAllDay
                                      ? AppColors.goldSand
                                      : Colors.transparent,
                                  borderRadius: AppRadii.xsAll,
                                  border: Border.all(
                                    color: state.isAllDay
                                        ? AppColors.goldSand
                                        : AppColors.white
                                            .withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                                child: state.isAllDay
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.black,
                                      )
                                    : null,
                              ),
                              AppSpacing.gapHSm,
                              Text(
                                'All Day',
                                style: AppTextStyles.inherit.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomDropdown(
                      label: 'Recurrence',
                      value: switch (state.recurrence) {
                        RecurrenceKind.daily => 'Daily',
                        RecurrenceKind.weekly => 'Weekly',
                        RecurrenceKind.monthly => 'Monthly',
                        RecurrenceKind.doesNotRepeat => 'Does Not Repeat',
                        null => null,
                      },
                      items:
                          const [
                                'Daily',
                                'Weekly',
                                'Monthly',
                                'Does Not Repeat',
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: AppTextStyles.inherit.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        _untilDateController.clear();
                        _repeatDayController.clear();
                        notifier.setRecurrence(switch (val) {
                          'Daily' => RecurrenceKind.daily,
                          'Weekly' => RecurrenceKind.weekly,
                          'Monthly' => RecurrenceKind.monthly,
                          'Does Not Repeat' => RecurrenceKind.doesNotRepeat,
                          _ => null,
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecurrenceUI(state, notifier),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Notes (optional)',
                      controller: _notesController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 23),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.smd,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.lgAll,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.6),
                          width: 0.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.displayLabelW500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.gapHMd,
              Expanded(
                child: AppCtaButton(
                  label: 'Save',
                  height: 52,
                  isLoading: state.isSubmitting,
                  onPressed: _onSavePressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceUI(
    AddAvailabilityState state,
    AddAvailabilityNotifier notifier,
  ) {
    if (state.recurrence == RecurrenceKind.daily) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.infoFilled,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.orange,
                  BlendMode.srcIn,
                ),
              ),
              AppSpacing.gapHXs,
              Text(
                'Repeat every day',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () =>
                  notifier.toggleIncludeWeekends(!state.includeWeekends),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: state.includeWeekends
                            ? AppColors.goldSand
                            : Colors.transparent,
                        borderRadius: AppRadii.xsAll,
                        border: Border.all(
                          color: state.includeWeekends
                              ? AppColors.goldSand
                              : AppColors.white
                                  .withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: state.includeWeekends
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.black,
                            )
                          : null,
                    ),
                    AppSpacing.gapHSm,
                    Text(
                      'Include Weekends',
                      style: AppTextStyles.inherit.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildUntilDateField(),
          _buildSummaryLine(state),
        ],
      );
    }

    if (state.recurrence == RecurrenceKind.weekly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.infoFilled,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.orange,
                  BlendMode.srcIn,
                ),
              ),
              AppSpacing.gapHXs,
              Text(
                'Repeat on specific weekdays',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _weekDays.map((day) {
                final isSelected = state.selectedWeekDays.contains(day);
                return GestureDetector(
                  onTap: () => notifier.toggleWeekDay(day),
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.smd),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44,
                      width: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.goldSand
                            : AppColors.surfaceStats,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.goldSand
                              : AppColors.dividerDark,
                        ),
                      ),
                      child: Text(
                        day,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.black
                              : AppColors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          AppSpacing.verticalMd,
          _buildUntilDateField(),
          _buildSummaryLine(state),
        ],
      );
    }

    if (state.recurrence == RecurrenceKind.monthly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Repeat Day (1-31)',
            controller: _repeatDayController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              TextInputFormatter.withFunction((oldValue, newValue) {
                if (newValue.text.isEmpty) return newValue;
                final value = int.tryParse(newValue.text);
                if (value != null && value >= 1 && value <= 31) return newValue;
                return oldValue;
              }),
            ],
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.verticalMd,
          _buildUntilDateField(),
          _buildSummaryLine(state),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildUntilDateField() {
    return CustomTextField(
      label: 'Until Date*',
      controller: _untilDateController,
      readOnly: true,
      suffixIcon: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: SvgPicture.asset(AppAssets.icAddDate),
      ),
      onTap: () => _pickDate(_untilDateController),
    );
  }

  Widget _buildSummaryLine(AddAvailabilityState state) {
    if (state.recurrence == null) return const SizedBox();

    final untilDate = _untilDateController.text.trim();
    String formattedUntil = '';
    if (untilDate.isNotEmpty) {
      final parsed = DateTimeUtils.parseDatePickerInput(untilDate);
      if (parsed != null) {
        formattedUntil = DateTimeUtils.formatFullMonthDate(parsed);
      }
    }

    String summaryText = '';
    if (state.recurrence == RecurrenceKind.daily) {
      summaryText = formattedUntil.isNotEmpty
          ? 'Will repeat every day until $formattedUntil'
          : 'Will repeat every day';
    } else if (state.recurrence == RecurrenceKind.weekly) {
      if (state.selectedWeekDays.isEmpty) return const SizedBox();
      final days = state.selectedWeekDays.join(', ');
      summaryText = formattedUntil.isNotEmpty
          ? 'Will repeat every $days until $formattedUntil'
          : 'Will repeat every $days';
    } else if (state.recurrence == RecurrenceKind.monthly) {
      final day = _repeatDayController.text.trim();
      if (day.isEmpty) return const SizedBox();
      final suffix = _ordinal(day);
      summaryText = formattedUntil.isNotEmpty
          ? 'Will repeat on the $suffix of each month until $formattedUntil'
          : 'Will repeat on the $suffix of each month';
    }
    if (summaryText.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.infoFilled,
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.blueLightSky,
              BlendMode.srcIn,
            ),
          ),
          AppSpacing.gapHXs,
          Expanded(
            child: Text(
              summaryText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.blueLightSky,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
