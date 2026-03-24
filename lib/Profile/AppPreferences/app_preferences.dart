import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utility/ColorCode.dart';
import 'DeleteAccoun/delete_account.dart';


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
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  AppImages.back,
                  height: 24,
                  color: ColorCode.white,
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
                  color: ColorCode.white,
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
                      color: ColorCode.k282828,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppImages.chando,
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                ColorCode.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Dark Mode",
                              style: TextStyle(
                                color: ColorCode.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isDarkMode,
                          activeColor: Colors.amber,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DeleteAccount()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)
                      ),
                        color: ColorCode.k282828,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppImages.delete,
                                height: 24,
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                  ColorCode.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Delete Account",
                                style: TextStyle(
                                  color: ColorCode.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            AppImages.goto,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              ColorCode.white,
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
                      color: ColorCode.k282828,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppImages.appversion,
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            ColorCode.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "App Version V1.0",
                          style: TextStyle(
                            color: Colors.white70,
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
