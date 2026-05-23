import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import '../../app/colors.dart';
import '../app/route_names.dart';


class AppPreferences extends StatefulWidget {
  const AppPreferences({super.key});

  @override
  State<AppPreferences> createState() => _AppPreferencesState();
}

class _AppPreferencesState extends State<AppPreferences> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔙 BACK BUTTON
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 16),

              /// 🏷 TITLE
              Text(
                "App Preferences",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 20),


              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  /// 🌙 DARK MODE
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)
                    ),
                      color: AppColors.surfaceMid,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.moon,
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Dark Mode",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isDarkMode,
                          activeColor: AppColors.arcYellow,
                          onChanged: (value) {
                            setState(() {
                              isDarkMode = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),

                  /// 🗑 DELETE ACCOUNT
                  InkWell(
                    onTap: () {
                      context.pushNamed(
                        RouteNames.deleteAccount,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)
                      ),
                        color: AppColors.surfaceMid,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.delete,
                                height: 24,
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Delete Account",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            AppAssets.goto,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  /// ℹ APP VERSION
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)
                    ),
                      color: AppColors.surfaceMid,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.appversion,
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "App Version V1.0",
                          style: TextStyle(
                            color: AppColors.white24,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
