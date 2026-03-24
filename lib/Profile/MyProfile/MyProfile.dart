import 'package:beige_creative_app/auth/login/login.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // "assets/icons/facbook_iIcon.png",
    // "assets/icons/ins_icon.png",
    // "assets/icons/ticktok.png",
    // "assets/icons/behance.png",
    // "assets/icons/webside.png",
    AppImages.facebook,
    AppImages.insta,
    AppImages.tiktok,
    AppImages.be,
    "assets/svg/Ball.svg"
  ];

  final List<String> Portfoliolname  = [
    "Vimeo",
    "YouTube",
    "Google Drive",
  ];

  final List<String> Portfolioicons = [
    // "assets/icons/vimeo-icon 1.png",
    // "assets/icons/YouTube.png",
    // "assets/icons/Google_Drive.png",
    AppImages.v,
    AppImages.youtube,
    AppImages.googledrive,
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
                    child: SvgPicture.asset(
                      AppImages.back, // make sure it's .svg file
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        ColorCode.kHeadingColor,
                        BlendMode.srcIn,
                      ),
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
                                AppImages.profilepicture,
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
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              color: ColorCode.kGoldGradientLight,
                              shape: BoxShape.circle,
                            ),

                            child: SvgPicture.asset(AppImages.myprofileeditphoto,height: 16,width: 16,),
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
                        value: "\$${49}",
                        title: "Clients",
                        icon: AppImages.doller,
                      ),
                      infoCard(
                        icon: AppImages.medal,
                        value: "02 yrs",
                        title: "Experience",
                      ),
                      infoCard(
                        icon: AppImages.map,
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
                            color: Color(0xff1D1D1B),
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
                            color: Color(0xff1D1D1B),
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
                  AppImages.userid,
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


                _menuRow(AppImages.gallery, "Featured Works", onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  FeaturedWorkList(),
                    ),
                  );
                }),
                _divider(),
                _menuRow(AppImages.certificates, "Certificates",onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  Certificates(),
                    ),
                  );
                },),
                _divider(),
                _menuRow(AppImages.resume, "Resume",onTap: () {
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
                _menuRow("assets/svg/App.svg", "App Preferences",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  AppPreferences(),
                        ),
                      );
                    }),
                _divider(),
                _menuRow(AppImages.notificationsetting ,"Notifications Settings"),
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
                child: SvgPicture.asset(iconPath,width: 22,height: 22,color: ColorCode.white,)

                // Image.asset(
                //   iconPath,
                //   height: 22,
                //   width: 22,
                //   color: ColorCode.white,
                // ),
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
            // Image.asset(
            //   "assets/profile/path9429.png",
            //   height: 20,
            //   width: 20,
            //   color: ColorCode.white,
            // ),
          SvgPicture.asset(
            AppImages.back, // make sure it's .svg file
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(
              ColorCode.white,
              BlendMode.srcIn,
            ),
          )

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
    required String icon,
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
                  padding: EdgeInsets.all(8),
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D1AB),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: SvgPicture.asset(
                    icon,
                    // width: 16,
                    // height: 16,
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
    bool showForm = socialLinks.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: ColorCode.bcakgroundcolor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// DRAG INDICATOR
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
                          ),
                        ],
                      ),

                      const Text(
                        "Add links that showcase your work, recognition,\npersonality and more!",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 14,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: ColorCode.kDividerWhite12),
                      const SizedBox(height: 20),

                      /// SOCIAL ICONS ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          socialIcons.length,
                              (index) => InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setInnerState(() {
                                selectedSocialIndex = index;
                                nameController.text = socialNames[index];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: selectedSocialIndex == index
                                    ? ColorCode.kButtonColor.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedSocialIndex == index
                                      ? ColorCode.kButtonColor
                                      : Colors.white24,
                                  width: selectedSocialIndex == index ? 1.5 : 0.8,
                                ),
                                boxShadow: selectedSocialIndex == index
                                    ? [
                                  BoxShadow(
                                    color: ColorCode.kButtonColor.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                                    : [],
                              ),
                              child: Center(
                             child:  SvgPicture.asset(
                                  socialIcons[index],
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    selectedSocialIndex == index
                                        ? ColorCode.kButtonColor
                                        : Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),

                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SAVED LINKS LIST
                      if (socialLinks.isNotEmpty) ...[
                        Text(
                          "${socialLinks.length}/6",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontFamily: "Outfit",
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...socialLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                /// DRAG BOX
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.09,
                                  height: MediaQuery.of(context).size.width * 0.09,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159 / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      color: ColorCode.kButtonColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                /// ICON
                                // Image.asset(
                                //   item["icon"]!,
                                //   height: 20,
                                //   width: 20,
                                //   color: Colors.white,
                                // ),
                                SvgPicture.asset(item["icon"]!,width: 20,height: 20,color: Colors.white,),

                                const SizedBox(width: 10),

                                /// NAME
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ),

                                /// EDIT BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white, size: 16),
                                    onPressed: () {
                                      setInnerState(() {
                                        showForm = true;
                                        selectedSocialIndex =
                                            socialNames.indexOf(item["name"]!);
                                        nameController.text = item["name"]!;
                                        linkController.text = item["url"]!;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 7),

                                /// DELETE BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 16),
                                    onPressed: () {
                                      setInnerState(() {
                                        setState(() {
                                          socialLinks.removeAt(index);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 10),
                      ],

                      /// FORM FIELDS
                      if (showForm) ...[
                        CustomTextField(
                          label: "Name of the Link*",
                          controller: nameController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Link URL*",
                          controller: linkController,
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              if (selectedSocialIndex == -1 ||
                                  linkController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select platform and enter link"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final name = socialNames[selectedSocialIndex];
                              final icon = socialIcons[selectedSocialIndex];
                              final url = linkController.text.trim();

                              setInnerState(() {
                                setState(() {
                                  socialLinks.add({
                                    "name": name,
                                    "url": url,
                                    "icon": icon,
                                  });
                                });
                                showForm = false;
                                selectedSocialIndex = -1;
                                nameController.clear();
                                linkController.clear();
                              });
                            },
                            child: const Text(
                              "Save Link",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      /// ADD ANOTHER + SAVE
                      if (!showForm) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setInnerState(() {
                              showForm = true;
                              selectedSocialIndex = -1;
                              nameController.clear();
                              linkController.clear();
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.black, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Add another link",
                                style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
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
    bool showForm = portfolioLinks.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: ColorCode.bcakgroundcolor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// DRAG INDICATOR
                      Center(
                        child: Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 14),
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
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// PORTFOLIO ICONS ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          Portfolioicons.length,
                              (index) => InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedPortfolioIndex = index;
                                nameController.text = Portfoliolname[index];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selectedPortfolioIndex == index
                                      ? ColorCode.kButtonColor
                                      : Colors.white24,
                                ),
                                color: selectedPortfolioIndex == index
                                    ? ColorCode.kButtonColor.withOpacity(0.15)
                                    : Colors.transparent,
                              ),
                              child: Center(
                              child:   SvgPicture.asset(
                                  Portfolioicons[index],
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    selectedPortfolioIndex == index
                                        ? ColorCode.kButtonColor
                                        : Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SAVED PORTFOLIO LINKS LIST
                      if (portfolioLinks.isNotEmpty) ...[
                        Text(
                          "${portfolioLinks.length}/3",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontFamily: "Outfit",
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...portfolioLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [

                                /// DRAG BOX
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159 / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      size: 18,
                                      color: ColorCode.kButtonColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                /// PLATFORM ICON
                                // Image.asset(
                                //   item["icon"]!,
                                //   height: 20,
                                //   width: 20,
                                //   color: const Color(0xffE8D1AB),
                                // ),

                                SvgPicture.asset(item["icon"]!,height: 20,width: 20,color: const Color(0xffE8D1AB),),
                                const SizedBox(width: 10),

                                /// NAME
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ),

                                /// EDIT BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white, size: 16),
                                    onPressed: () {
                                      setModalState(() {
                                        showForm = true;
                                        selectedPortfolioIndex =
                                            Portfoliolname.indexOf(item["name"]!);
                                        nameController.text = item["name"]!;
                                        linkController.text = item["url"]!;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 7),

                                /// DELETE BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 16),
                                    onPressed: () {
                                      setModalState(() {
                                        setState(() {
                                          portfolioLinks.removeAt(index);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 10),
                      ],

                      /// FORM FIELDS
                      if (showForm) ...[
                        CustomTextField(
                          label: "Link URL",
                          controller: linkController,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              if (selectedPortfolioIndex == -1 ||
                                  linkController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Select platform & enter link"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setModalState(() {
                                setState(() {
                                  portfolioLinks.add({
                                    "name": Portfoliolname[selectedPortfolioIndex],
                                    "url": linkController.text.trim(),
                                    "icon": Portfolioicons[selectedPortfolioIndex],
                                  });
                                });
                                showForm = false;
                                selectedPortfolioIndex = -1;
                                nameController.clear();
                                linkController.clear();
                              });
                            },
                            child: const Text(
                              "Save Link",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      /// ADD ANOTHER + FINAL SAVE
                      if (!showForm) ...[
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () {
                            setModalState(() {
                              showForm = true;
                              selectedPortfolioIndex = -1;
                              linkController.clear();
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.black, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Add another link",
                                style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                    ],
                  ),
                ),//
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
