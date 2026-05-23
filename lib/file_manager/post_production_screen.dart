import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../app/colors.dart';


class PostProductionScreen extends StatefulWidget {
  const PostProductionScreen({super.key});

  @override
  State<PostProductionScreen> createState() =>
      _PostProductionScreenState();
}

class _PostProductionScreenState
    extends State<PostProductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            /// 🔝 HEADER
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: /*Image.asset(
                      "assets/icons/Reply.png",
                      height: 24,
                      color: AppColors.white,
                    ),*/
                    SvgPicture.asset(AppAssets.back)
                  ),
                  const Spacer(),
                  const Text(
                    "Lana #123456",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 45,
                padding:
                const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMid,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search,
                        color: AppColors.white54),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                            color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                              color: AppColors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📄 LIST
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return InkWell(
                    borderRadius:
                    BorderRadius.circular(22),
                    onTap: () {
                      context.pushNamed(
                        RouteNames.preProduction,
                      );
                    },
                    child: Container(
                      margin:
                      const EdgeInsets.only(bottom: 14),
                      padding:
                      const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMid,
                        borderRadius:
                        BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: const [
                              Icon(Icons.folder,
                                  color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                "Lana #123456",
                                style: TextStyle(
                                  color:
                                  AppColors.white,
                                  fontSize: 13,
                                  fontFamily:
                                  "Outfit",
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.more_vert,
                                  color:
                                  AppColors.white),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "02 Files",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontFamily: "Outfit",
                            ),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.circleGradientTop,
                              borderRadius:
                              BorderRadius.circular(
                                  20),
                            ),
                            child: const Text(
                              "Corporate Event",
                              style: TextStyle(
                                color:
                                AppColors.white,
                                fontSize: 12,
                                fontFamily:
                                "Outfit",
                              ),
                            ),
                          ),

                          const Divider(
                            color: AppColors.dividerDark,
                            thickness: 0.8,
                          ),

                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                AppColors.softLightBlue,
                                child: Text(
                                  "DP",
                                  style: TextStyle(
                                      color:
                                      AppColors.black),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Opened 2 hours ago",
                                style: TextStyle(
                                  color: AppColors.white30,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}