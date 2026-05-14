import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utility/colorcode.dart';
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

      try {
        final parsedDate =
        DateFormat("dd/MM/yyyy").parse(dateController.text);

        formattedDate =
            DateFormat("yyyy-MM-dd").format(parsedDate);

      } catch (e) {
        formattedDate = dateController.text;
      }

      /// UNTIL DATE FORMAT
      String recurrenceUntil = "";

      if (untilDateController.text.isNotEmpty) {
        try {
          final parsedUntil =
          DateFormat("dd/MM/yyyy")
              .parse(untilDateController.text);

          recurrenceUntil =
              DateFormat("yyyy-MM-dd").format(parsedUntil);

        } catch (e) {
          recurrenceUntil = "";
        }
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
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
            dialogBackgroundColor: const Color(0xFF121212),

            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD6C19A), // 🔥 main golden
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),

            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF121212),
              dialBackgroundColor: Color(0xFF121212),

              dialHandColor: Colors.white,
              dialTextColor: Colors.grey,

              hourMinuteColor: Color(0xFFD6C19A),
              hourMinuteTextColor: Colors.black,

              dayPeriodColor: Color(0xFFD6C19A),
              dayPeriodTextColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {//
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      setState(() {
        controller.text = DateFormat("hh:mm a").format(dt);
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
            dialogBackgroundColor: const Color(0xFF121212),

            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD6C19A),
              onPrimary: Colors.black,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ),

            datePickerTheme: DatePickerThemeData(
              backgroundColor: Color(0xFF121212),
              dividerColor: Colors.white12,

              headerBackgroundColor: Color(0xFF0E0E0E),

              headerHeadlineStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),

              dayStyle: TextStyle(color: Colors.white),
              weekdayStyle: TextStyle(color: Colors.white70),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat("dd/MM/yyyy").format(picked);
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
      try {
        final parsed =
        DateFormat("dd/MM/yyyy").parse(untilDate);

        formattedUntil =
            DateFormat("MMMM d, yyyy").format(parsed);

      } catch (_) {}
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
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          summaryText,
          style: const TextStyle(
            color: Color(0xFFD6C19A),
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
        padding: const EdgeInsets.all(10.0),
        child: SvgPicture.asset(
          'assets/svg/mycalender.svg',
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
              margin: const EdgeInsets.only(right: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFD6C19A)
                      : const Color(0xFF1E1E1E),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD6C19A)
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w600,
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
              SvgPicture.asset('assets/svg/Info.svg',
                  color: const Color(0xffFF9D25)),
              const SizedBox(width: 6),
              const Text("Repeat every day",
                  style: TextStyle(color: Colors.orange)),
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
              const Text("Include Weekends",
                  style: TextStyle(color: Colors.white)),
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
          const Text("Repeat on specific weekdays",
              style: TextStyle(color: Colors.orange)),
          const SizedBox(height: 12),
          buildWeekDays(),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Row(
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(AppImages.back),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add Availability",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 16,
                  fontFamily: "Unbounded",
                ),
              ),
            ),

            Text('Set your availability, time off, or block time for shoots.',style: TextStyle(
              fontFamily:'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.6),

            ),),


            const SizedBox(height: 24),

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
                        child: Text(e,
                            style: const TextStyle(
                                color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedType = val.toString();
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    /// DATE
                    CustomTextField(
                      label: "Add Date",
                      controller: dateController,
                      readOnly: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                            AppImages.calender,
                        ),
                      ),
                      onTap: () => pickDate(dateController),
                    ),

                    const SizedBox(height: 18),

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
                              //       color: Colors.white, size: 18),
                              // ),
                              onTap: () =>
                                  pickTime(startTimeController),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: "End Time",
                              controller: endTimeController,
                              readOnly: true,
                              // suffixIcon: const Padding(
                              //   padding: EdgeInsets.all(10.0),
                              //   child: Icon(Icons.access_time,
                              //       color: Colors.white, size: 18),
                              // ),
                              onTap: () =>
                                  pickTime(endTimeController),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],

                    /// ALL DAY
                    Row(
                      children: [
                        Checkbox(
                          activeColor: const Color(0xFFD6C19A),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.6),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          value: isAllDay,
                          onChanged: (val) {
                            setState(() {
                              isAllDay = val!;
                            });
                          },
                        ),
                        const Text("All Day",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// RECURRENCE
                    CustomDropdown(
                      label: "Recurrence",
                      value: selectedRecurrence,
                      items: recurence
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: const TextStyle(
                                color: Colors.white)),
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

                    const SizedBox(height: 18),

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
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 0.5,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.white,
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
                                color: const Color(0xffE8D1AB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: ColorCode.black,
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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 0.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// SAVE BUTTON
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: GestureDetector(
                    onTap: isLoading ? null : addAvailability,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffE8D1AB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500,
                          ),
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