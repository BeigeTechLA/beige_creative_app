import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app/colors.dart';

class ViewDetailsScreen extends StatefulWidget {
  const ViewDetailsScreen({super.key});

  @override
  State<ViewDetailsScreen> createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
        
                /// 🔹 BACKGROUND HEADER
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.asset(
                      AppAssets.rectangle,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
        
                /// 🔹 BACK BUTTON
                Positioned(
                  top: 90,
                  left: 16,
                  child:  InkWell(
                    onTap: () => Navigator.pop(context),

                    child: SvgPicture.asset(
                      AppAssets.back, // change extension
                      height: 24,
                    ),
                  ),
                ),
                /// 🔹 TITLE (CENTERED)
                const Positioned(
                  top:90 ,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Shoot Details",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
        
                /// 🔹 PROFILE IMAGE (CUT INTO CURVE)
                Positioned(
                  bottom: -48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
        
                        /// 🔵 Main Circle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary, // gold light
                                AppColors.circleGradientBottom, // dark
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.onPrimary, // inside dark
                            ),
                            child: const Center(
                              child: Text(
                                "L#1",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Unbounded",
                                ),
                              ),
                            ),
                          ),
                        ),
        
                      /*  /// ✏ Edit Icon
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.black,
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
        
            SizedBox(height: 60,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Lana #123456",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
        
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                textAlign: TextAlign.center,
                style: TextStyle(
        
                  color: AppColors.white60,
                  fontSize: 14,
                  fontFamily: "Outfit",
                ),
              ),
            ),
        
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Post Production",
                style: TextStyle(
                  color: AppColors.purpleDeep,
                  fontSize: 13,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 18),
            Divider(
              color: AppColors.dividerDark,
              thickness: 0.8,
            ),
            SizedBox(height: 18),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerDark),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.black10,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        
                  /// 🔥 TITLE
                  Container(
        
                    child: const Text(
                      "Shoot Details",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Outfit",
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 18),
        
                  _buildDetailRow("Shoot Date", "Jan 16, 2026"),
                  _buildDetailRow("Time", "11:30 PM · 11 Hours"),
                  _buildDetailRow("Total Value", "\$14,400"),
                  _buildDetailRow("Payment Status", "Paid", isGreen: true),
                  _buildDetailRow("Folder Link", "http://fijejpfkmdjfief", isLink: true),
                  _buildDetailRow("Shoot Files", "200 Images & 50 Videos"),
                  _buildDetailRow("Location", "1234 Mockingbird Lane, CA 90000"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(
      String title,
      String value, {
        bool isGreen = false,
        bool isLink = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Left Title
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.white60,
                fontSize: 13,
                fontFamily: "Outfit",
              ),
            ),
          ),

          const Text(
            ":  ",
            style: TextStyle(color: AppColors.white60),
          ),

          /// Right Value
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isGreen
                    ? AppColors.greenAccent
                    : isLink
                    ? AppColors.borderGold
                    : AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration:
                isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }}
