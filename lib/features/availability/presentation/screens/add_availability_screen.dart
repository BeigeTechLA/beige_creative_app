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
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/availability_providers.dart';

class AddAvailabilityScreen extends ConsumerStatefulWidget {
  const AddAvailabilityScreen({super.key});

  @override
  ConsumerState<AddAvailabilityScreen> createState() =>
      _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState
    extends ConsumerState<AddAvailabilityScreen> {
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

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: '',
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          useMaterial3: true,
          dialogBackgroundColor: AppColors.surfaceGradientDark,
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
            weekdayStyle:
                AppTextStyles.inherit.copyWith(color: AppColors.white70),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text = DateTimeUtils.formatDatePickerInput(picked);
      setState(() {});
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          dialogBackgroundColor: AppColors.surfaceGradientDark,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.goldSand,
            onPrimary: AppColors.white,
            surface: AppColors.surfaceStats,
            onSurface: AppColors.white,
          ),
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppColors.surfaceGradientDark,
            dialBackgroundColor: AppColors.surfaceGradientDark,
            dialHandColor: AppColors.white,
            dialTextColor: AppColors.neutralGrey,
            hourMinuteColor: AppColors.goldSand,
            hourMinuteTextColor: AppColors.black,
            dayPeriodColor: AppColors.goldSand,
            dayPeriodTextColor: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text = DateTimeUtils.formatTimeOfDay12Hour(picked);
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
    final parsedDate =
        DateTimeUtils.parseDatePickerInput(_dateController.text);
    if (parsedDate != null) {
      formattedDate = DateTimeUtils.formatApiDate(parsedDate);
    } else {
      formattedDate = _dateController.text;
    }

    String recurrenceUntil = '';
    if (_untilDateController.text.isNotEmpty) {
      final parsedUntil =
          DateTimeUtils.parseDatePickerInput(_untilDateController.text);
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
    ref.listen<AddAvailabilityState>(addAvailabilityNotifierProvider,
        (prev, next) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.validationMessage!)),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final state = ref.watch(addAvailabilityNotifierProvider);
    final notifier = ref.read(addAvailabilityNotifierProvider.notifier);

    return Scaffold(
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
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: AppTextStyles.inherit.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ))
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
                        child: SvgPicture.asset(AppAssets.calender),
                      ),
                      onTap: () => _pickDate(_dateController),
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
                              onTap: () => _pickTime(_startTimeController),
                            ),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: CustomTextField(
                              label: 'End Time',
                              controller: _endTimeController,
                              readOnly: true,
                              onTap: () => _pickTime(_endTimeController),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalLg,
                    ],
                    Row(
                      children: [
                        Checkbox(
                          activeColor: AppColors.goldSand,
                          side: BorderSide(
                            color: AppColors.white.withValues(alpha: 0.6),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.xsAll,
                          ),
                          value: state.isAllDay,
                          onChanged: (v) => notifier.toggleAllDay(v ?? false),
                        ),
                        Text(
                          'All Day',
                          style: AppTextStyles.inherit.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
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
                      items: const [
                        'Daily',
                        'Weekly',
                        'Monthly',
                        'Does Not Repeat',
                      ]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: AppTextStyles.inherit.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ))
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
                      label: 'Notes',
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
                child: SizedBox(
                  height: 52,
                  child: GestureDetector(
                    onTap: state.isSubmitting ? null : _onSavePressed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.lgAll,
                      ),
                      child: Center(
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.black,
                                  ),
                                ),
                              )
                            : const Text(
                                'Save',
                                style: AppTextStyles.displayLabelW500,
                              ),
                      ),
                    ),
                  ),
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
                AppAssets.info_svg,
                // ignore: deprecated_member_use
                color: AppColors.orangeBright,
              ),
              AppSpacing.gapHXs,
              Text(
                'Repeat every day',
                style: AppTextStyles.inherit.copyWith(color: AppColors.orange),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: state.includeWeekends,
                onChanged: (v) =>
                    notifier.toggleIncludeWeekends(v ?? false),
              ),
              Text(
                'Include Weekends',
                style:
                    AppTextStyles.inherit.copyWith(color: AppColors.white),
              ),
            ],
          ),
          _buildUntilDateField(),
          _buildSummaryLine(state),
        ],
      );
    }

    if (state.recurrence == RecurrenceKind.weekly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repeat on specific weekdays',
            style: AppTextStyles.inherit.copyWith(color: AppColors.orange),
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
                        style: AppTextStyles.inheritSemiBold.copyWith(
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
      label: 'Until Date',
      controller: _untilDateController,
      readOnly: true,
      suffixIcon: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: SvgPicture.asset(
          AppAssets.mycalender,
          width: 13,
          height: 13,
        ),
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
      child: Align(
        child: Text(
          summaryText,
          style: AppTextStyles.inherit.copyWith(
            color: AppColors.goldSand,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
