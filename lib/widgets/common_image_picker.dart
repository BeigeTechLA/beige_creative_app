import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CommonImagePicker {
  static final ImagePicker _picker = ImagePicker();

  /// MULTI IMAGE PICK
  static Future<List<File>> pickMultiImage() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    return images.map((e) => File(e.path)).toList();
  }

  /// SINGLE IMAGE PICK
  static Future<File?> pickSingleImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }
}