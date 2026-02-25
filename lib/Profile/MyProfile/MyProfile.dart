import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';

import '../../auth/ProfileDetailsScreen .dart';
import '../../service/shared_service.dart';
import '../../utility/ColorCode.dart';
import '../ProfileDetils/profile_detils_1screen.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [

            ///  HEADER SECTION
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
                      "assets/profile/Rectangle_49.png",
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
                    child: Image.asset("assets/icons/back.png", height: 24,color: ColorCode.kHeadingColor,),
                  ),
                ),
                /// 🔹 TITLE (CENTERED)
                const Positioned(
                  top:90 ,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: ColorCode.kHeadingColor,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
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
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: Image.asset(
                                "assets/home/Vector.png",
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),


                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: ColorCode.black
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),



            const SizedBox(height: 60),

            /// 🔹 USER INFO
            Text(
             "Priya Smith",
              style: TextStyle(
                fontFamily: "Outfit",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
            "priyasmith4545@gmail.com | Los Angles, USA",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 14),

            /// 🔹 EDIT BUTTON
            /*InkWell(
              onTap: () {
              *//*  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  EditProfile(),
                  ),
                );*//*
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color:  ColorCode.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: "Outfit",
                    color: ColorCode.kHeadingColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),*/
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:  Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoCard(
                        icon: Icons.group_outlined,
                        value: "\$${49}",
                        title: "Clients",
                      ),
                      infoCard(
                        icon: Icons.verified_outlined,
                        value: "02 yrs",
                        title: "Experience",
                      ),
                      infoCard(
                        icon: Icons.star_border,
                        value: "05-10 Km",
                        title: "Ratings",
                      ),
                    ],
                  ),
                  Padding(
                    padding:  EdgeInsets.all(12),
                    child: Divider(color: ColorCode.kDividerWhite12,),
                  ),
                  Row(
                    children: [
                      Text("Social Link",style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// 🔹 BEHANCE BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Bē",
                              style: TextStyle(
                                color: Color(0xFFE8D1AB),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Behance",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Outfit",
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 EDIT BUTTON (Right Side)
                      InkWell(
                        onTap: () {
                          // Edit social link
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(

                         padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorCode.kButtonColor, // beige
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child:  Image.asset(
                            color: ColorCode.k282828,
                            "assets/profile/SquarePen.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ),






            _profileMenuCard(),


            const SizedBox(height: 30),
          ],
        ),

      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        color: ColorCode.bcakgroundcolor,
        child: InkWell(
          onTap: _showLogoutBottomSheet,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: ColorCode.kButtonColor, // beige color
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "Logout",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorCode.kHeadingColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("My Account",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow(
                  "assets/profile/User_Id.png",
                  "Profile Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  ProfileDetils1screen(),
                      ),
                    );
                  },
                ),

       /*         Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Portfolio & Credentials",style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                ),
                _divider(),
                _menuRow("assets/profile/Gallery_Wide.png", "Featured Works", onTap: () {
                *//*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  BookingHistoryScreen(),
                    ),
                  );*//*
                }),
                _divider(),
                _menuRow("assets/profile/Icon_Frame.png", "Certificates"),
                _divider(),
                _menuRow("assets/profile/Document_Text.png", "Resume"),*/
              ],
            ),
          ),



          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Portfolio & Credentials",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [


                _menuRow("assets/profile/Gallery_Wide.png", "Featured Works", onTap: () {
                  /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  BookingHistoryScreen(),
                    ),
                  );*/
                }),
                _divider(),
                _menuRow("assets/profile/Icon_Frame.png", "Certificates"),
                _divider(),
                _menuRow("assets/profile/Document_Text.png", "Resume"),
              ],
            ),
          ),

          SizedBox(height: 10,),
          Padding(
            padding:  EdgeInsets.all(12),
            child: Divider(color: ColorCode.kDividerWhite12,),
          ),



          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Settings",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          SizedBox(height: 10,),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow("assets/profile/mobile-navigator-01.png", "App Preferences",
                    onTap: () {
                     /* Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  AppPreferences(),
                        ),
                      );*/
                    }),
                _divider(),
                _menuRow("assets/profile/Settings Minimalistic.png" ,"Notifications Settings"),
                _divider(),
        /*        _menuRow(
                  "assets/Icons/Exit.png",
                  "Logout",
                  onTap: _showLogoutBottomSheet,
                ),*/

              ],
            ),
          ),
        ],
      ),
    );


  }

  Widget _menuRow(String iconPath, String title, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  height: 22,
                  width: 22,
                  color: ColorCode.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
            Image.asset(
              "assets/profile/path9429.png",
              height: 20,
              width: 20,
              color: ColorCode.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.white12,
      ),
    );
  }
  Widget infoCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      width: 105,
      height: 120,

      /// 🌈 GRADIENT BORDER
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8D1AB).withOpacity(0.40),
            const Color(0xFFE8D1AB).withOpacity(0.04),
            const Color(0xFFE8D1AB).withOpacity(0.28),
          ],
        ),
      ),

      /// 🔥 INNER DARK CONTAINER
      child: Padding(
        padding: const EdgeInsets.all(0.6), // 👈 border thickness (0.5px feel)
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              /// 🔝 TOP ICON TAB
              Positioned(
                top: -1,
                child: Container(
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D1AB),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),

              /// 🧾 TEXT CONTENT
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// DRAG INDICATOR
              Container(
                height: 5,
                width: 30,
                margin:  EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ColorCode.kWhiteOpacity70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),


              Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontFamily: "Outfit",
                ),
              ),
              SizedBox(height: 14),

              Divider(
                height: 1,
                color: ColorCode.kDividerWhite12,
              ),

              SizedBox(height: 10),



              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side:  BorderSide(color: ColorCode.kWhiteOpacity60),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// LOGOUT
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SharedService.logout(); // 🔥 clear all prefs

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => Login()),
                              (route) => false,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:  ColorCode.kButtonColor,
                        padding:  EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "Yes, Logout",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorCode.kHeadingColor,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
