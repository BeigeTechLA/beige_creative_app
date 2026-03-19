import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/CustomDropdown.dart';
import '../../widgets/Custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

import 'add_availability_contoller.dart';

class AddAvailabilityScreen extends StatefulWidget {
  const AddAvailabilityScreen({super.key});

  @override
  State<AddAvailabilityScreen> createState() =>
      _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {
  String ?selectedType;
  String ?selectedRecurrence;

  final List abc=["Available", "Time Off", "Blocked"];
  final List recurence=["Daily", "Weekly", "Monthly", "None"];

  bool repeatEveryDay = true;
  bool includeWeekends = false;

  DateTime? untilDate;

  List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> selectedWeekDays = [];

  int repeatDayOfMonth = 1;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  final AddAvailabilityContoller controller = AddAvailabilityContoller();

  bool isAllDay = false;
  String selectedSkill = "Livestream Audio";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [

              /// 🔙 Back + Title
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset("assets/icons/back.png", height: 24,color: ColorCode.white,),
                  ),
                ],
              ),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Add Availability",
                  style: TextStyle(
                    color: ColorCode.white,
                    fontSize: 16,
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Set your availability, time off, or block time for shoots.",
                  style: TextStyle(
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 14,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
  SizedBox(height: 6,),
                      /// Select Type
                      CustomDropdown(

                        label: "Type",
                        value: selectedType,
                        items:abc.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,style: TextStyle(
                          color:  Colors.white,
                        ),)),).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedType = val.toString();
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      /// Add Date
                      CustomTextField(
                        label: "Add Date",
                        controller: controller.dateController,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white70,
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark(), // dark theme
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            controller.dateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      /// Start & End Time
                      /// Start & End Time (Hide if All Day)
                      if (!isAllDay) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Start Time",
                                controller: controller.startTimeController,
                                readOnly: true,
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedTime != null) {
                                    controller.startTimeController.text =
                                        pickedTime.format(context);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: CustomTextField(
                                label: "End Time",
                                controller: controller.endTimeController,
                                readOnly: true,
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedTime != null) {
                                    controller.endTimeController.text =
                                        pickedTime.format(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],



                      /// All Day Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: isAllDay,
                            activeColor: const Color(0xFFD6C19A),
                            onChanged: (value) {
                              setState(() {
                                isAllDay = value!;
                                if (isAllDay) {
                                  controller.startTimeController.clear();
                                  controller.endTimeController.clear();
                                }
                              });
                            },
                          ),
                          const Text(
                            "All Day",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// Recurrence
                      CustomDropdown(
                        label: "Recurrence",
                        value: selectedRecurrence,
                        items: recurence.map((e) => DropdownMenuItem(
                          value: e,
                            child: Text(e,style: TextStyle(
                              color: Colors.white
                            ),))).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedRecurrence = val.toString();
                          });
                        },
                      ),
    // CustomDropdown(
    //
    // label: "Type",
    // value: selectedType,
    // items:abc.map((e) => DropdownMenuItem(
    // value: e,
    // child: Text(e,style: TextStyle(
    // color:  Colors.white,//
    // ),)),).toList(),
    // onChanged: (val) {
    // setState(() {
    // selectedType = val.toString();
    // });
    // },
    // ),

                      const SizedBox(height: 18),
                      /// =============================
                      /// 🔁 RECURRENCE EXTRA OPTIONS
                      /// =============================
                      /// =============================
                      /// 🔁 RECURRENCE EXTRA OPTIONS
                      /// =============================

                      if (selectedRecurrence == "Daily") ...[
                        const SizedBox(height: 12),

                        Row(
                          children: const [
                            Icon(Icons.repeat, color: Colors.orange, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Repeat every day",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Checkbox(
                              value: includeWeekends,
                              activeColor: const Color(0xFFD6C19A),
                              onChanged: (val) {
                                setState(() {
                                  includeWeekends = val!;
                                });
                              },
                            ),
                            const Text(
                              "Include Weekends",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),

                        const SizedBox(height: 12),

                        CustomTextField(
                          label: "Until Date",
                          controller:controller.untilDateController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() {
                                controller.untilDateController.text =
                                "${picked.day}/${picked.month}/${picked.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      /// =============================
                      /// WEEKLY
                      /// =============================
                      if (selectedRecurrence == "Weekly") ...[
                        const SizedBox(height: 12),

                        const Row(
                          children: [
                            Icon(Icons.repeat, color: Colors.orange, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Repeat on specific weekdays",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: weekDays.map((day) {
                            final isSelected = selectedWeekDays.contains(day);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedWeekDays.remove(day);
                                  } else {
                                    selectedWeekDays.add(day);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 44,
                                width: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFFD6C19A)   // Selected color (gold)
                                      : const Color(0xFF1E1E1E), // Dark circle
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFD6C19A)
                                        : Colors.white12,
                                  ),
                                ),
                                child: Text(
                                  day.substring(0, 1), // Only first letter like M T W
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      /// =============================
                      /// MONTHLY
                      /// =============================
                      if (selectedRecurrence == "Monthly") ...[
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: "Repeat Day (1-31)",
                          controller: controller.repeatDayController,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 12),

                        CustomTextField(
                          label: "Until Date",
                          controller: controller.untilDateController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() {
                                controller.untilDateController.text =
                                "${picked.day}/${picked.month}/${picked.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      /// Notes
                      CustomTextField(
                        label: "Notes (optional)",
                        controller: controller.notesController,
                        maxLines: 5,
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              /// 🔘 Bottom Buttons
              Row(
                children: [

                  /// Cancel
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: ColorCode.white),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: ColorCode.white,
                          fontSize: 15,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// Save
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD6C19A),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: ColorCode.black,
                          fontSize: 15,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}