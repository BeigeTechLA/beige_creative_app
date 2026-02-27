import 'package:file_picker/file_picker.dart';

class FileUploadController {

  /// Pick Single File
  Future<Map<String, dynamic>?> pickFile() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles();

    if (result != null) {

      String fileName = result.files.single.name;

      return {
        "name": fileName,
        "isPdf": fileName.toLowerCase().endsWith(".pdf"),
      };
    }

    return null;
  }
}