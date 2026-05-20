import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../utility/imges_icons.dart';

class FeaturedWorkDetailsScreen extends StatelessWidget {
  final String title;
  final List<dynamic> images;

  const FeaturedWorkDetailsScreen({
    super.key,
    required this.title,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: ColorCode.backgroundColor,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: SvgPicture.asset(
            AppImages.back,
            height: 18,
            width: 18,
            color: ColorCode.white,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: ColorCode.white,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: ListView.builder(
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
              color: const Color(0xFF1F1F1F),
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

                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}