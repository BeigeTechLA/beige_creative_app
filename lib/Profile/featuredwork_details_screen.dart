import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../widgets/Topmessgae.dart';
import '../widgets/app_loder.dart';
import '../app/colors.dart';
import 'package:beige_creative_app/app/assets.dart';

class FeaturedWorkDetailsScreen extends StatefulWidget {
  final String title;
  final List<dynamic> images;

  const FeaturedWorkDetailsScreen({
    super.key,
    required this.title,
    required this.images,
  });

  @override
  State<FeaturedWorkDetailsScreen> createState() =>
      _FeaturedWorkDetailsScreenState();
}

class _FeaturedWorkDetailsScreenState extends State<FeaturedWorkDetailsScreen> {
  late List<dynamic> images;
  bool isLoading = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    images = List<dynamic>.from(widget.images);
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);
  }

  Future<void> deleteImage(int index) async {
    final imageData = images[index];

    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService().deleteData(
        "${ApiEndpoints.delete_allfiles}/${imageData.crewFilesId}",
      );

      if (response != null && response["error"] == false) {
        setState(() {
          hasChanges = true;
          images.removeAt(index);
        });

        if (images.isEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showSnack(response?["message"] ?? "Delete Failed");
      }
    } catch (e) {
      debugPrint("Featured work image delete error: $e");
      _showSnack("Something went wrong");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, hasChanges);
            },

            icon: SvgPicture.asset(
              AppAssets.back,
              height: 18,
              width: 18,
              color: AppColors.white,
            ),
          ),

          title: Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.white,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),

        body: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: images.length,

              itemBuilder: (context, index) {
                final imageData = images[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 240,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.surfaceShadow,
                  ),

                  child: Stack(
                    children: [
                      /// IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: Image.network(
                          "${ApiService.imageURL}${imageData.filePath}",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// DELETE ICON
                      Positioned(
                        top: 12,
                        right: 12,

                        child: GestureDetector(
                          onTap: () => deleteImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.delete,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (isLoading) AppLoader(),
          ],
        ),
      ),
    );
  }
}
