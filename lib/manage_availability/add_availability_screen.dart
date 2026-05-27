import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../utility/date_time_utils.dart';
import '../app/colors.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import '../app/radii.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';



class AddAvailabilityScreen extends StatefulWidget {
  const AddAvailabilityScreen({super.key});

  @override
  State<AddAvailabilityScreen> createState() =>
      _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {

  bool isLoading=false;
  List<String>? getRecurrenceDays() {

    /// Weekly selected days
    if (selectedRecurrence == "Weekly") {
      return selectedWeekDays
          .map((d) => d.toLowerCase())
          .toList();
    }

    /// Daily
    if (selectedRecurrence == "Daily") {

      /// Include weekends
      if (includeWeekends) {
        return [
          "mon",
          "tue",
          "wed",
          "thu",
          "fri",
          "sat",
          "sun",
        ];
      }

      /// Only weekdays
      return [
        "mon",
        "tue",
        "wed",
        "thu",
        "fri",
      ];
    }

    /// Monthly / Does Not Repeat
    return null;
  }
  int recurrenceInt() {
    switch (selectedRecurrence) {
      case "Daily":   return 2;
      case "Weekly":  return 3;
      case "Monthly": return 4; //
      default:        return 1; //
    }
  }
  Future<void> addAvailability() async {

    /// VALIDATION
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select type"),
        ),
      );
      return;
    }

    if (dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date"),
        ),
      );
      return;
    }

    if (!isAllDay) {
      if (startTimeController.text.isEmpty ||
          endTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select time"),
          ),
        );
        return;
      }
    }

    try {

      setState(() {
        isLoading = true;
      });

      /// DATE FORMAT
      String formattedDate = "";

      final parsedDate = DateTimeUtils.parseDatePickerInput(dateController.text);
      if (parsedDate != null) {
        formattedDate = DateTimeUtils.formatApiDate(parsedDate);
      } else {
        formattedDate = dateController.text;
      }

      /// UNTIL DATE FORMAT
      String recurrenceUntil = "";

      if (untilDateController.text.isNotEmpty) {
        final parsedUntil =
            DateTimeUtils.parseDatePickerInput(untilDateController.text);
        recurrenceUntil = parsedUntil != null
            ? DateTimeUtils.formatApiDate(parsedUntil)
            : "";
      }

      /// PAYLOAD
      Map<String, dynamic> payload = {

        "date": formattedDate,

        "availability_status":
        selectedType == "Available" ? 1 : 2,

        "is_full_day": isAllDay ? 1 : 0,

        "start_time":
        isAllDay ? "" : startTimeController.text,

        "end_time":
        isAllDay ? "" : endTimeController.text,

        "recurrence": recurrenceInt(),

        "notes": notesController.text.trim(),

        "recurrence_until": recurrenceUntil,

        "recurrence_days": getRecurrenceDays(),
      };

      debugPrint("PAYLOAD => $payload");

      /// API CALL
      final response = await ApiService().postData(
        ApiEndpoints.add_availability,
        payload,
      );

      debugPrint("RESPONSE => $response");

      if (mounted) {

        setState(() {
          isLoading = false;
        });

      /*  ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Availability Saved Successfully"),
            backgroundColor: AppColors.success,
          ),
        );*/

        context.pop(true);
      }

    } catch (e) {

      debugPrint("ERROR => $e");

      if (mounted) {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }



  Future<void> pickTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: AppColors.surfaceGradientDark,

            colorScheme: const ColorScheme.dark(
              primary: AppColors.goldSand, // 🔥 main golden
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
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateTimeUtils.formatTimeOfDay12Hour(picked);
      });
    }
  }

  String? selectedType;
  String? selectedRecurrence;
  bool includeWeekends = false;
  bool isAllDay = false;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController untilDateController = TextEditingController();
  final TextEditingController repeatDayController = TextEditingController();

  List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> selectedWeekDays = [];
  final List<String> abc = [
    "Available",
    "Not Available",
  ];

  final List<String> recurence = [
    "Daily",
    "Weekly",
    "Monthly",
    "Does Not Repeat",
  ];




  /// 🔥 COMMON DATE PICKER
   Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),

      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: "",

      builder: (context, child) {
        return Theme(
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
              weekdayStyle: AppTextStyles.inherit.copyWith(color: AppColors.white70),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateTimeUtils.formatDatePickerInput(picked);
      });
    }
  }
  /// 🔥 ORDINAL SUFFIX: 1 -> "1st", 28 -> "28th"
  String _ordinal(String dayStr) {
    final n = int.tryParse(dayStr);
    if (n == null) return dayStr;
    if (n >= 11 && n <= 13) return "${n}th";
    switch (n % 10) {
      case 1:
        return "${n}st";
      case 2:
        return "${n}nd";
      case 3:
        return "${n}rd";
      default:
        return "${n}th";
    }
  }

  /// 🔥 SUMMARY LINE BUILDER
  Widget buildSummaryLine() {
    if (selectedRecurrence == null) return const SizedBox();

    final untilDate = untilDateController.text.trim();

    String formattedUntil = "";

    if (untilDate.isNotEmpty) {
      final parsed = DateTimeUtils.parseDatePickerInput(untilDate);
      if (parsed != null) {
        formattedUntil = DateTimeUtils.formatFullMonthDate(parsed);
      }
    }

    String summaryText = "";

    if (selectedRecurrence == "Daily") {

      summaryText = formattedUntil.isNotEmpty
          ? "Will repeat every day until $formattedUntil"
          : "Will repeat every day";

    } else if (selectedRecurrence == "Weekly") {

      if (selectedWeekDays.isEmpty) {
        return const SizedBox();
      }

      final days = selectedWeekDays.join(", ");

      summaryText = formattedUntil.isNotEmpty
          ? "Will repeat every $days until $formattedUntil"
          : "Will repeat every $days";

    } else if (selectedRecurrence == "Monthly") {

      final day = repeatDayController.text.trim();

      if (day.isEmpty) {
        return const SizedBox();
      }

      final suffix = _ordinal(day);

      summaryText = formattedUntil.isNotEmpty
          ? "Will repeat on the $suffix of each month until $formattedUntil"
          : "Will repeat on the $suffix of each month";
    }

    if (summaryText.isEmpty) {
      return const SizedBox();
    }

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

  /// 🔥 REUSABLE UNTIL DATE FIELD
  Widget buildUntilDateField() {
    return CustomTextField(
      label: "Until Date",
      controller: untilDateController,
      readOnly: true,
      suffixIcon: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: SvgPicture.asset(
          AppAssets.mycalender,
          width: 13,
          height: 13,
        ),
      ),
      onTap: () => pickDate(untilDateController),
    );
  }

  /// 🔥 WEEK DAYS
  Widget buildWeekDays() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weekDays.map((day) {
          final isSelected = selectedWeekDays.contains(day);

          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? selectedWeekDays.remove(day)
                    : selectedWeekDays.add(day);
              });
            },
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
                    color: isSelected ? AppColors.black : AppColors.white70,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 🔥 RECURRENCE UI
  Widget buildRecurrenceUI() {
    if (selectedRecurrence == "Daily") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppAssets.info_svg,
                  color: AppColors.orangeBright),
              AppSpacing.gapHXs,
              Text("Repeat every day",
                  style: AppTextStyles.inherit.copyWith(color: AppColors.orange)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: includeWeekends,
                onChanged: (val) {
                  setState(() {
                    includeWeekends = val!;
                  });
                },
              ),
              Text("Include Weekends",
                  style: AppTextStyles.inherit.copyWith(color: AppColors.white)),
            ],
          ),
          buildUntilDateField(),
          buildSummaryLine(), // 👈
        ],
      );
    }

    if (selectedRecurrence == "Weekly") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Repeat on specific weekdays",
              style: AppTextStyles.inherit.copyWith(color: AppColors.orange)),
          AppSpacing.verticalMd,
          buildWeekDays(),
          AppSpacing.verticalMd,
          buildUntilDateField(),
          buildSummaryLine(), // 👈
        ],
      );
    }

    if (selectedRecurrence == "Monthly") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        CustomTextField(
        label: "Repeat Day (1-31)",
          controller: repeatDayController,
        keyboardType: TextInputType.number,

        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) {
              return newValue;
            }

            final int? value = int.tryParse(newValue.text);

            // only allow 1 to 31
            if (value != null && value >= 1 && value <= 31) {
              return newValue;
            }

            return oldValue;
          }),
        ],

        onChanged: (_) => setState(() {}),
      ),
          AppSpacing.verticalMd,
          buildUntilDateField(),
          buildSummaryLine(), // 👈
        ],
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
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
                "Add Availability",
                style: AppTextStyles.displayLabel16,
              ),
            ),

            Text('Set your availability, time off, or block time for shoots.',
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

                    /// TYPE
                    CustomDropdown(
                      label: "Select Type*",
                      value: selectedType,
                      items: abc
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
                        setState(() {
                          selectedType = val.toString();
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// DATE
                    CustomTextField(
                      label: "Add Date",
                      controller: dateController,
                      readOnly: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(AppSpacing.smd),
                        child: SvgPicture.asset(
                            AppAssets.calender,
                        ),
                      ),
                      onTap: () => pickDate(dateController),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// TIME
                    if (!isAllDay) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: "Start Time",
                              controller: startTimeController,
                              readOnly: true,
                              // suffixIcon: const Padding(
                              //   padding: EdgeInsets.all(10.0),
                              //   child: Icon(Icons.access_time,
                              //       color: AppColors.white, size: 18),
                              // ),
                              onTap: () =>
                                  pickTime(startTimeController),
                            ),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: CustomTextField(
                              label: "End Time",
                              controller: endTimeController,
                              readOnly: true,
                              // suffixIcon: const Padding(
                              //   padding: EdgeInsets.all(10.0),
                              //   child: Icon(Icons.access_time,
                              //       color: AppColors.white, size: 18),
                              // ),
                              onTap: () =>
                                  pickTime(endTimeController),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalLg,
                    ],

                    /// ALL DAY
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
                          value: isAllDay,
                          onChanged: (val) {
                            setState(() {
                              isAllDay = val!;
                            });
                          },
                        ),
                        Text("All Day",
                            style: AppTextStyles.inherit.copyWith(color: AppColors.white)),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// RECURRENCE
                    CustomDropdown(
                      label: "Recurrence",
                      value: selectedRecurrence,
                      items: recurence
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
                        setState(() {
                          selectedRecurrence = val.toString();
                          // Reset on recurrence change
                          selectedWeekDays.clear();
                          untilDateController.clear();
                          repeatDayController.clear();
                          includeWeekends = false;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// RECURRENCE UI
                    buildRecurrenceUI(),

                    const SizedBox(height: 20),

                    /// NOTES
                    CustomTextField(
                      label: "Notes",
                      controller: notesController,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),
/*

                    Row(
                      children: [
                        /// CANCEL BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: AppRadii.lgAll,
                                border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.6),
                                  width: 0.5,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily: "Unbounded",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// SAVE BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: isLoading ? null : addAvailability, // 👈 direct call
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadii.lgAll,
                              ),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontFamily: "Unbounded",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
*/

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
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.smd, AppSpacing.lg, AppSpacing.xl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// CANCEL BUTTON
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: GestureDetector(
                    onTap: () =>context.pop(),
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
                          "Cancel",
                          style: AppTextStyles.displayLabelW500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              AppSpacing.gapHMd,

              /// SAVE BUTTON
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: GestureDetector(
                    onTap: isLoading ? null : addAvailability,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.lgAll,
                      ),
                      child: const Center(
                        child: Text(
                          "Save",
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
}