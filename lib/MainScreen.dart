

import 'dart:ui';

import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/service/shared_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home/home_screen.dart';
import 'Model_Class/Creatordashboarddetailsmodel.dart' as profile;
import 'Model_Class/myprofilemodel.dart';
import 'Profile/MyProfile/myprofile.dart';
import 'Shoots/shoots_screen.dart';
import 'Messages/messages_screen.dart';
import 'ManageAvailability/manage_availability_screen.dart';
import 'file_manager/file_manager_screen.dart';
import 'utility/ColorCode.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {

bool isloading = true;
int _selectedIndex = 0;

Data? Myprofile_user;
// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
@override
  void initState() {
    super.initState();
    fetchprofiledata();
   /* WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
    });*/
  }

Future<void> fetchprofiledata() async {
  try {
    debugPrint("🚀 API CALL STARTED");

    setState(() {
      isloading = true;
    });

    final rawResponse =
    await ApiService().postData(ApiEndpoints.profiledetails, {});

    debugPrint("📦 RAW RESPONSE 👉 $rawResponse");

    final response = Myprofilemodel.fromJson(rawResponse);

    if (response.error == false) {
      debugPrint("✅ API SUCCESS");

      debugPrint("👤 NAME 👉 ${response.data.user.name}");
      debugPrint("📧 EMAIL 👉 ${response.data.user.email}");
      debugPrint("🖼 IMAGE 👉 ${response.data.user.profileImageUrl}");

      setState(() {
        Myprofile_user = response.data;
      });
    } else {
      debugPrint("❌ API ERROR 👉 ${response.message}");
    }
  } catch (e) {
    debugPrint("❌ EXCEPTION 👉 $e");
  } finally {
    setState(() {
      isloading = false;
    });

    debugPrint("🏁 API CALL END");
  }
}


  /// 🔥 Bottom Navigation Pages
  late final List<Widget> _pages = [
    // HomeScreen(onTabChange: _onItemTapped), //
    const HomeScreen(),
    const ShootsScreen(),
    const FileManagerScreen(),
    const MessagesScreen(),
    const ManageAvailabilityScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.backgroundColor,
      drawer: _buildDrawer(),
      // drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,

      /// 🔥 IndexedStack = state safe
  /*    body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
*/
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ================================ Bottom Navigation ================================

  //

  Widget _buildBottomBar() {
    return ClipRect(

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 70),
        child: BottomNavigationBar(
          // currentIndex: _selectedIndex,
          currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,

          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorCode.white,
          unselectedItemColor: ColorCode.kWhiteOpacity70,

          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: _navIcon(
                "assets/Active/Dashboard.svg",
                "assets/NonActive/dashboard-square-02.svg",
                0,
              ),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                "assets/Active/shoots.svg",
                "assets/NonActive/shoots(1).svg",
                1,
              ),
              label: "shoots",
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                "assets/Active/FileManager.svg",
                "assets/NonActive/FileManager(1).svg",
                2,
              ),
              label: "File Manager",
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                "assets/Active/Messages.svg",
                "assets/NonActive/Messages (1).svg",
                3,
              ),
              label: "Messages",
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(String active, String inactive, int index) {
    return SvgPicture.asset(
      _selectedIndex == index ? active : inactive,
      height: 24,
      width: 24,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        _selectedIndex == index
            ? ColorCode.white
            : ColorCode.kWhiteOpacity70,
        BlendMode.srcIn,

      ),
    );
  }

  // ================================
  // 🔥 Drawer
  // ================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: SafeArea(
        child: Column(
          children: [

            /// 🔹 Profile Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/home/Group.png"),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Myprofile(),
                        ),
                      ).then((value) {
                        /// 🔥 BACK AATE HI API CALL
                        fetchprofiledata();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6B98C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: (Myprofile_user?.profileImageUrl ?? "").isNotEmpty
                                ? NetworkImage(
                              "${ApiService.imageURL}${Myprofile_user!.profileImageUrl}",
                            )
                                : null,
                            child: (Myprofile_user?.profileImageUrl ?? "").isEmpty
                                ? SvgPicture.asset(AppImages.User_Circle)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Myprofile_user?.user.name ?? "User...",

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: "Outfit",
                                    color: ColorCode.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                 Text(
                                   Myprofile_user?.user.email ?? "email...",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w500,
                                    color: ColorCode.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: ColorCode.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            /// 🔹 Menu Items
            Expanded(
              child: ListView(
                children: [

                  /// Bottom linked
                  _drawerBottomItem(
                    "Dashboard",
                    "assets/Active/Dashboard.svg",
                    "assets/NonActive/dashboard-square-02.svg",
                    0,
                  ),

                  _drawerBottomItem(
                    "shoots",
                    "assets/Active/shoots.svg",
                    "assets/NonActive/shoots(1).svg",
                    1,
                  ),

                  _drawerBottomItem(
                    "File Manager",
                    "assets/Active/FileManager.svg",
                    "assets/NonActive/FileManager(1).svg",
                    2,
                  ),

                  _drawerBottomItem(
                    "messages",
                    "assets/Active/messages.svg",
                    "assets/NonActive/messages (1).svg",
                    3,
                  ),
                  _drawerBottomItem(
                    "Manage Availability",
                    "assets/Active/Manage Availability.svg",
                    "assets/NonActive/manageavailability(2).svg",
                    4,
                  ),

                /*  _drawerBottomItem(
                    "Manage Availability",
                    Icons.calendar_month,
                    4, // index of page
                  ),*/
                  /// Push type screen
                /*  _drawerPushItem(
                    "Manage Availability",
                    Icons.calendar_month,
                    const ManageAvailabilityScreen(),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Drawer Bottom Linked
  Widget _drawerBottomItem(
      String title,
      String activeIcon,
      String inactiveIcon,
      int index,
      ) {
    return ListTile(
      leading: SvgPicture.asset(
        _selectedIndex == index ? activeIcon : inactiveIcon,
        height: 24,
        width: 24,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          _selectedIndex == index
              ? Colors.white
              : ColorCode.kWhiteOpacity70,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: "Outfit",
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

}