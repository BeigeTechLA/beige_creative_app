import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CommonUploader {
  static final ImagePicker _picker = ImagePicker();

  /// CAMERA
  static Future<File?> pickFromCamera() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// GALLERY
  static Future<File?> pickFromGallery() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// FILES
  static Future<File?> pickFile() async {
    final result = await FilePicker.pickFiles();

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }
}