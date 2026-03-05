import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';

import '../../auth/ProfileDetailsScreen .dart';
import '../../service/shared_service.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/custom_text_field.dart';
import '../AppPreferences/app_preferences.dart';
import '../Certificates/Certificates.dart';
import '../Featuredwork/featured_work_list.dart';
import '../ProfileDetils/profile_detils_1screen.dart';
import '../Resume/Resume.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  List<Map<String, String>> socialLinks = [];
  int selectedSocialIndex = -1;

  List<Map<String, String>> portfolioLinks = [];
  int selectedPortfolioIndex = -1;
  final List<String> socialNames = [
    "Facebook",
    "Instagram",
    "TikTok",
    "Behance",
    "Website",
  ];


  final List<String> socialIcons = [
    "assets/icons/facbook_iIcon.png",
    "assets/icons/ins_icon.png",
    "assets/icons/ticktok.png",
    "assets/icons/behance.png",
    "assets/icons/webside.png",
  ];

  final List<String> Portfoliolname  = [
    "Vimeo",
    "YouTube",
    "Google Drive",
  ];

  final List<String> Portfolioicons = [
    "assets/icons/vimeo-icon 1.png",
    "assets/icons/YouTube.png",
    "assets/icons/Google_Drive.png",
  ];

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
                          openSocialDialog();
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Portfolio Link",style: TextStyle(
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
                              "YouTube",
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
                          openPortfolioDialog();
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
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  FeaturedWorkList(),
                    ),
                  );
                }),
                _divider(),
                _menuRow("assets/profile/Icon_Frame.png", "Certificates",onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  Certificates(),
                    ),
                  );
                },),
                _divider(),
                _menuRow("assets/profile/Document_Text.png", "Resume",onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  Resume(),
                    ),
                  );
                },),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  AppPreferences(),
                        ),
                      );
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

  void openSocialDialog() {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ColorCode.bcakgroundcolor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// DRAG HANDLE
                      Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add Social Links",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          )
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Add links that showcase your work, recognition,\npersonality and more!",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 14,
                          fontFamily: "Outfit",
                        ),
                      ),

                      const SizedBox(height: 20),

                      Divider(color: ColorCode.kDividerWhite12),

                      const SizedBox(height: 20),

                      /// SOCIAL ICONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          socialIcons.length,
                              (index) => InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedSocialIndex = index;
                                nameController.text = socialNames[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedSocialIndex == index
                                    ? ColorCode.kButtonColor
                                    : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedSocialIndex == index
                                      ? ColorCode.kButtonColor
                                      : Colors.white12,
                                ),
                              ),
                              child: Image.asset(
                                socialIcons[index],
                                height: 26,
                                width: 26,
                                color: selectedSocialIndex == index
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// COUNTER
                      if (socialLinks.isNotEmpty)
                        Text(
                          "${socialLinks.length}/6",
                          style: const TextStyle(color: Colors.white60),
                        ),

                      const SizedBox(height: 10),

                      /// SAVED LINKS
                      Column(
                        children: List.generate(socialLinks.length, (index) {

                          final item = socialLinks[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorCode.k282828,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [

                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ColorCode.kButtonColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                    child: Image.asset(item["icon"]!, height: 22,color: ColorCode.black,),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ),

                                /// EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {

                                    nameController.text = item["name"]!;
                                    linkController.text = item["url"]!;

                                  },
                                ),

                                /// DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {

                                    setModalState(() {
                                      socialLinks.removeAt(index);
                                    });

                                  },
                                ),

                              ],
                            ),
                          );

                        }),
                      ),

                      const SizedBox(height: 20),

                      /// NAME FIELD
                      CustomTextField(
                        label: "Name of the Link",
                        controller: nameController,
                      ),

                      const SizedBox(height: 16),

                      /// LINK FIELD
                      CustomTextField(
                        label: "Link URL",
                        controller: linkController,
                      ),

                      const SizedBox(height: 16),

                      /// ADD ANOTHER LINK
                      Row(
                        children:  [
                          Container(
                            decoration: BoxDecoration(borderRadius: 
                            BorderRadius.circular(30),
                              color:  ColorCode.white,),

                              padding: const EdgeInsets.all(5),
                              child: Icon(Icons.add, color: ColorCode.black)),
                          SizedBox(width: 6),
                          Text(
                            "Add another link",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCode.kButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {

                            if (selectedSocialIndex == -1 ||
                                linkController.text.isEmpty) return;

                            setModalState(() {

                              socialLinks.add({
                                "name": nameController.text,
                                "url": linkController.text,
                                "icon": socialIcons[selectedSocialIndex],
                              });

                              nameController.clear();
                              linkController.clear();
                              selectedSocialIndex = -1;

                            });

                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 14,
                              color: ColorCode.kHeadingColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openPortfolioDialog() {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ColorCode.bcakgroundcolor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// DRAG HANDLE
                      Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add Portfolio Links",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          )
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Add YouTube, Vimeo, or Google Drive links to\nshowcase your portfolio.",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 14,
                          fontFamily: "Outfit",
                        ),
                      ),

                      const SizedBox(height: 20),

                      Divider(color: ColorCode.kDividerWhite12),

                      const SizedBox(height: 20),

                      /// SOCIAL ICONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          Portfolioicons.length,
                              (index) => InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedPortfolioIndex = index;
                                nameController.text = Portfoliolname[index];

                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedPortfolioIndex == index
                                    ? ColorCode.kButtonColor
                                    : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedPortfolioIndex == index
                                      ? ColorCode.kButtonColor
                                      : Colors.white12,
                                ),
                              ),
                              child: Image.asset(
                                Portfolioicons[index],
                                height: 26,
                                width: 26,
                                color: selectedPortfolioIndex == index
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// COUNTER
                      if (portfolioLinks.isNotEmpty)
                        Text(
                          "${portfolioLinks.length}/6",
                          style: const TextStyle(color: Colors.white60),
                        ),

                      const SizedBox(height: 10),

                      /// SAVED LINKS
                      Column(
                        children: List.generate(portfolioLinks.length, (index) {

                          final item = portfolioLinks[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorCode.k282828,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [

                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ColorCode.kButtonColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(item["icon"]!, height: 22,color: ColorCode.black,),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ),

                                /// EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {


                                    linkController.text = item["url"]!;

                                  },
                                ),

                                /// DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {

                                    setModalState(() {
                                      portfolioLinks.removeAt(index);
                                    });

                                  },
                                ),

                              ],
                            ),
                          );

                        }),
                      ),


                      /// NAME FIELD


                      const SizedBox(height: 16),

                      /// LINK FIELD
                      CustomTextField(
                        label: "Link URL",
                        controller: linkController,
                      ),

                      const SizedBox(height: 16),

                      /// ADD ANOTHER LINK
                      Row(
                        children:  [
                          Container(
                              decoration: BoxDecoration(borderRadius:
                              BorderRadius.circular(30),
                                color:  ColorCode.white,),

                              padding: const EdgeInsets.all(5),
                              child: Icon(Icons.add, color: ColorCode.black)),
                          SizedBox(width: 6),
                          Text(
                            "Add another link",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCode.kButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {

                            if (selectedPortfolioIndex == -1 ||
                                linkController.text.isEmpty) return;

                            setModalState(() {

                              portfolioLinks.add({
                                "name": nameController.text,
                                "url": linkController.text,
                                "icon": Portfolioicons[selectedPortfolioIndex],
                              });

                              nameController.clear();
                              linkController.clear();
                              selectedPortfolioIndex = -1;

                            });

                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 14,
                              color: ColorCode.kHeadingColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
