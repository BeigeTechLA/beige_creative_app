import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AppUtils {
  /// ===============================
  /// ✅ SHOW SNACKBAR
  /// ===============================
  static void showSnack(
      BuildContext context,
      String message, {
        Color color = Colors.red,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  /// ===============================
  /// ✅ DATE PICKER
  /// ===============================
  static Future<DateTime?> pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
  }

  /// ✅ FORMAT DATE
  static String formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  /// ===============================
  /// ✅ IMAGE PICKER (Gallery)
  /// ===============================
  static Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// ===============================
  /// ✅ IMAGE PICKER (Camera)
  /// ===============================
  static Future<File?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// ===============================
  /// ✅ LOADING DIALOG
  /// ===============================
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
