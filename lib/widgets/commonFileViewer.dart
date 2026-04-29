import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';

class CommonFileViewer {

  static void open({
    required BuildContext context,
    required String filePath,
    bool isNetwork = true,
  }) {

    final ext = filePath.split('.').last.toLowerCase();

    /// 📸 IMAGE TYPES
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);

    if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold( // ✅ proper context use
            backgroundColor: Colors.black,

            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,

              /// 🔥 CUSTOM BACK BUTTON
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context); // ✅ correct context
                },
                icon: Image.asset(
                  "assets/icons/back.png",
                  color: Colors.white,
                  height: 20,
                ),
              ),
            ),

            body: Center(
              child: InteractiveViewer(
                child: isNetwork
                    ? Image.network(
                  filePath,
                  fit: BoxFit.contain,

                  /// ✅ ERROR HANDLING
                  errorBuilder: (_, __, ___) {
                    return SvgPicture.asset(
                      "assets/svg/image_holder.svg",
                      height: 150,
                    );
                  },
                )
                    : Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      /// 📄 PDF / DOC / FILE
      if (!isNetwork) {
        OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cannot open network file directly"),
          ),
        );
      }
    }
  }
}