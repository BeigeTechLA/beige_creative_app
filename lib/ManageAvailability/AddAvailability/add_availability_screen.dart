import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/CustomDropdown.dart';
import '../../widgets/custom_text_field.dart';
import 'add_availability_contoller.dart';

class AddAvailabilityScreen extends StatefulWidget {
  const AddAvailabilityScreen({super.key});

  @override
  State<AddAvailabilityScreen> createState() =>
      _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {

  bool isLoading=false;

  Future<void> addAvailability() async {
    // ── Validation ──────────────────────────
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select type")),
      );
      return;
    }
    if (controller.dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date")),
      );
      return;
    }
    if (!isAllDay &&
        (controller.startTimeController.text.isEmpty ||
            controller.endTimeController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start & end time")),
      );
      return;
    }

    // ── Helpers ─────────────────────────────

    // "dd/MM/yyyy" → "yyyy-MM-dd"
    String formatDate(String date) {
      if (date.isEmpty) return "";
      final parts = date.split("/");
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }

    // "hh:mm a" → "HH:mm"
    String formatTime(String time) {
      if (time.isEmpty) return "";
      final parts  = time.split(" ");
      final hm     = parts[0].split(":");
      int hour     = int.parse(hm[0]);
      final minute = hm[1];
      final period = parts[1].toUpperCase();
      if (period == "AM" && hour == 12) hour = 0;
      if (period == "PM" && hour != 12) hour += 12;
      return "${hour.toString().padLeft(2, '0')}:$minute";
    }

    // ✅ Web se match kiya hua mapping
    int recurrenceInt() {
      switch (selectedRecurrence) {
        case "Daily":   return 2;
        case "Weekly":  return 3;
        case "Monthly": return 4; // 👈 test karke confirm karo
        default:        return 1; // Does Not Repeat
      }
    }

    // ── Body ────────────────────────────────
    final Map<String, dynamic> body = {
      "crew_member_id":    460, // 👈 apna actual user id daalo (SharedPrefs etc.)
      "date":              formatDate(controller.dateController.text),
      "availability_status": selectedType == "Available" ? 1 : 0,
      "is_full_day":       isAllDay ? 1 : 0,

      // ✅ null jaega "" nahi — web payload se match
      "start_time": isAllDay
          ? null
          : (controller.startTimeController.text.isNotEmpty
          ? formatTime(controller.startTimeController.text)
          : null),
      "end_time": isAllDay
          ? null
          : (controller.endTimeController.text.isNotEmpty
          ? formatTime(controller.endTimeController.text)
          : null),

      "recurrence":       recurrenceInt(),
      "notes":            controller.notesController.text.trim(),

      // ✅ null jaega empty string nahi
      "recurrence_until": controller.untilDateController.text.isNotEmpty
          ? formatDate(controller.untilDateController.text)
          : null,

      // ✅ Weekly = selected days, Daily = mon-fri, Monthly = null
      "recurrence_days": selectedRecurrence == "Weekly"
          ? selectedWeekDays.map((d) => d.toLowerCase()).toList()
          : selectedRecurrence == "Daily"
          ? (includeWeekends
          ? ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
          : ["mon", "tue", "wed", "thu", "fri"])
          : null,
    };

    print("📦 Body: $body"); // ✅ verify karo

    // ── API Call ─────────────────────────────
    try {
      setState(() => isLoading = true);

      //final res = await postData("your-endpoint", body);
      final response= await ApiService().postData(ApiEndpoints.add_availability, body);

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Availability saved!"),
          backgroundColor: Color(0xFFD6C19A),
        ),
      );
      Navigator.pop(context,true);

    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }




  Future<void> pickTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        controller.text = DateFormat("hh:mm a").format(dt);
      });
    }
  }

  String? selectedType;
  String? selectedRecurrence;

  final List abc = ["Available", "Not Available"];
  final List recurence = ["Daily", "Weekly", "Monthly", "Does Not Repeat"];

  bool includeWeekends = false;
  bool isAllDay = false;

  final AddAvailabilityContoller controller = AddAvailabilityContoller();

  List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> selectedWeekDays = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 🔥 COMMON DATE PICKER
  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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

    final untilDate = controller.untilDateController.text.trim();

    // Parse "dd/MM/yyyy" → "April 17, 2026"
    String formattedUntil = "";
    if (untilDate.isNotEmpty) {
      try {
        final parsed = DateFormat("dd/MM/yyyy").parse(untilDate);
        formattedUntil = DateFormat("MMMM d, yyyy").format(parsed);
      } catch (_) {}
    }

    String summaryText = "";

    if (selectedRecurrence == "Daily") {
      summaryText = formattedUntil.isNotEmpty
          ? "Will repeat every day until $formattedUntil"
          : "Will repeat every day";
    } else if (selectedRecurrence == "Weekly") {
      if (selectedWeekDays.isEmpty) return const SizedBox();
      final days = selectedWeekDays.join(", ");
      summaryText = formattedUntil.isNotEmpty
          ? "Will repeat every $days until $formattedUntil"
          : "Will repeat every $days";
    } else if (selectedRecurrence == "Monthly") {
      final day = controller.repeatDayController.text.trim();
      if (day.isEmpty) return const SizedBox();
      final suffix = _ordinal(day);
      summaryText = formattedUntil.isNotEmpty
          ? "Will repeat on the $suffix of each month until $formattedUntil"
          : "Will repeat on the $suffix of each month";
    }

    if (summaryText.isEmpty) return const SizedBox();

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
      controller: controller.untilDateController,
      readOnly: true,
      suffixIcon: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SvgPicture.asset('assets/svg/mycalender.svg',
            width: 13, height: 13),
      ),
      onTap: () => pickDate(controller.untilDateController),
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
            controller: controller.repeatDayController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}), // 👈 live update
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
                        controller: controller.dateController,
                        readOnly: true,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset('assets/svg/mycalender.svg'),
                        ),
                        onTap: () => pickDate(controller.dateController),
                      ),

                      const SizedBox(height: 18),

                      /// TIME
                      if (!isAllDay) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Start Time",
                                controller: controller.startTimeController,
                                readOnly: true,
                                // suffixIcon: const Padding(
                                //   padding: EdgeInsets.all(10.0),
                                //   child: Icon(Icons.access_time,
                                //       color: Colors.white, size: 18),
                                // ),
                                onTap: () =>
                                    pickTime(controller.startTimeController),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: CustomTextField(
                                label: "End Time",
                                controller: controller.endTimeController,
                                readOnly: true,
                                // suffixIcon: const Padding(
                                //   padding: EdgeInsets.all(10.0),
                                //   child: Icon(Icons.access_time,
                                //       color: Colors.white, size: 18),
                                // ),
                                onTap: () =>
                                    pickTime(controller.endTimeController),
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
                            controller.untilDateController.clear();
                            controller.repeatDayController.clear();
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
                        controller: controller.notesController,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 20),

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
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text(
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
                        ],
                      ),

                      const SizedBox(height: 23),
                    ],
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