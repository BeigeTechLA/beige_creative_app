import 'package:flutter/material.dart';

class AddAvailabilityContoller {

  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController untilDateController = TextEditingController();
  final TextEditingController repeatDayController = TextEditingController();
  void dispose() {
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    notesController.dispose();
  }
}