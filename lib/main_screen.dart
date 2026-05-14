

import 'dart:ui';

import 'package:beige_creative_app/auth/login/login.dart';
import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/service/shared_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home/home_screen.dart';
import 'model_class/create_dashboard_details_model.dart' as profile;
import 'Model_Class/myprofile_model.dart';

import 'Profile/myprofile.dart';
import 'Shoots/shoots_screen.dart';
import 'Messages/messages_screen.dart';
import 'ManageAvailability/manage_availability_screen.dart';
import 'app/route_names.dart';
import 'file_manager/file_manager_screen.dart';
import 'utility/colorcode.dart';

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
                AppImages.activeDashboard,
                AppImages.inactiveDashboard,
                0,
              ),
              label: "Dashboard",
            ),

            BottomNavigationBarItem(
              icon: _navIcon(
                AppImages.activeShoots,
                AppImages.inactiveShoots,
                1,
              ),
              label: "shoots",
            ),

            BottomNavigationBarItem(
              icon: _navIcon(
                AppImages.activeFileManager,
                AppImages.inactiveFileManager,
                2,
              ),
              label: "File Manager",
            ),

            BottomNavigationBarItem(
              icon: _navIcon(
                AppImages.activeMessages,
                AppImages.inactiveMessages,
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
                      /// ===================== Drawer Top Logo =====================

                      Image.asset(AppImages.group_logo),
                      IconButton(
                        icon: const Icon(Icons.close, color: ColorCode.white),
                        onPressed: () => context.pop(),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () {
                  /*    Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Myprofile(),
                        ),
                      ).then((value) {
                        /// 🔥 BACK AATE HI API CALL
                        fetchprofiledata();
                      });*/
                      context.pushNamed(
                        RouteNames.myProfile,
                      ).then((value) {

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
                    AppImages.activeDashboard,
                    AppImages.inactiveDashboard,
                    0,
                  ),

                  _drawerBottomItem(
                    "shoots",
                    AppImages.activeShoots,
                    AppImages.inactiveShoots,
                    1,
                  ),

                  _drawerBottomItem(
                    "File Manager",
                    AppImages.activeFileManager,
                    AppImages.inactiveFileManager,
                    2,
                  ),

                  _drawerBottomItem(
                    "messages",
                    AppImages.activeMessages,
                    AppImages.inactiveMessages,
                    3,
                  ),

                  _drawerBottomItem(
                    "Manage Availability",
                    AppImages.activeManageAvailability,
                    AppImages.inactiveManageAvailability,
                    4,
                  ),
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