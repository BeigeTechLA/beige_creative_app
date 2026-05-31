import 'dart:io';
import '../../app/colors.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class CommonFileViewer {
  static void open({
    required BuildContext context,
    required String filePath,
    bool isNetwork = true,
  }) async {
    final ext = filePath.split('.').last.toLowerCase();

    /// 📸 IMAGE
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);

    if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: AppColors.black,
            appBar: AppBar(
              backgroundColor: AppColors.black,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon:SvgPicture.asset(AppAssets.back)
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                child: isNetwork
                    ? CachedNetworkImage(
                        imageUrl: filePath,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) {
                          return SvgPicture.asset(
                            AppAssets.image_holder,
                            height: 150,
                          );
                        },
                      )
                    : Image.file(File(filePath)),
              ),
            ),
          ),
        ),
      );
    } else {
      /// 📄 FILE (PDF / DOC)

      if (isNetwork) {
        try {
          debugPrint("⬇️ Downloading file...");

          final dir = await getTemporaryDirectory();
          final fileName = filePath.split('/').last;
          final savePath = "${dir.path}/$fileName";

          await Dio().download(filePath, savePath);

          debugPrint("✅ Downloaded: $savePath");

          OpenFile.open(savePath);
        } catch (e) {
          debugPrint("❌ Download error: $e");

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to open file"),
            ),
          );
        }
      } else {
        OpenFile.open(filePath);
      }
    }
  }
}
