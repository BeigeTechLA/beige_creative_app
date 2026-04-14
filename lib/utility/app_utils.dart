import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  /// ✅ IMAGE PICKER (ONLY GALLERY)
  /// ===============================
  static Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// ===============================
  /// ✅ FILE PICKER (ALL FILES)
  /// ===============================
  static Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// ===============================
  /// ✅ IMAGE + FILE OPTION (BOTTOM SHEET)
  /// ===============================
  static Future<File?> showPicker(BuildContext context) async {
    File? selectedFile;

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Gallery Image"),
                onTap: () async {
                  selectedFile = await pickImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_file),
                title: Text("Choose File"),
                onTap: () async {
                  selectedFile = await pickFile();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );

    return selectedFile;
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