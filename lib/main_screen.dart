

import 'dart:ui';

import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'home/home_screen.dart';
import 'model_class/myprofile_model.dart';

import 'shoots/shoots_screen.dart';
import 'messages/messages_screen.dart';
import 'manage_availability/manage_availability_screen.dart';
import 'app/route_names.dart';
import 'file_manager/file_manager_screen.dart';
import 'app/colors.dart';
import 'app/text_styles.dart';
import 'app/spacing.dart';
import 'app/radii.dart';
import 'app/shadows.dart';
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
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      // drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
          currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,

          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.white30,

          selectedFontSize: 10,
          unselectedFontSize: 10,

          iconSize: 26,
          elevation: 0,

          onTap: _onItemTapped,

          items: [
            BottomNavigationBarItem(
              icon: _buildInactiveIcon(
                AppAssets.inactiveDashboard,
              ),
              activeIcon: _buildActiveIcon(
                AppAssets.activeDashboard,
              ),
              label: "Dashboard",
            ),

            BottomNavigationBarItem(
              icon: _buildInactiveIcon(
                AppAssets.inactiveShoots,
              ),
              activeIcon: _buildActiveIcon(
                AppAssets.activeShoots,
                width: 46,
              ),
              label: "Shoots",
            ),

            BottomNavigationBarItem(
              icon: _buildInactiveIcon(
                AppAssets.inactiveFileManager,
              ),
              activeIcon: _buildActiveIcon(
                AppAssets.activeFileManager,
                width: 48,
              ),
              label: "Files",
            ),

            BottomNavigationBarItem(
              icon: _buildInactiveIcon(
                AppAssets.inactiveMessages,
              ),
              activeIcon: _buildActiveIcon(
                AppAssets.activeMessages,
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
            ? AppColors.white
            : AppColors.white30,
        BlendMode.srcIn,

      ),
    );
  }
  Widget _buildInactiveIcon(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: SizedBox(
        width: 44,
        height: 26,
        child: Center(
          child: SvgPicture.asset(
            path,
            height: 26,
            width: 26,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIcon(
      String path, {
        double? width,
        double? height,
      }) {
    final artWidth = width ?? 44;
    final artHeight = height ?? 44;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: SizedBox(
        width: artWidth,
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [

            /// glow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShadows.activeNavGlow,
              ),
            ),

            SvgPicture.asset(
              path,
              width: artWidth,
              height: artHeight,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
  // ================================
  // 🔥 Drawer
  // ================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surfaceAbyss,
      child: SafeArea(
        child: Column(
          children: [

            /// 🔹 Profile Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// ===================== Drawer Top Logo =====================

                      Image.asset(AppAssets.group_logo),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => context.pop(),
                      )
                    ],
                  ),
                  AppSpacing.verticalXl,

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
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.goldSandLight,
                        borderRadius: AppRadii.xxlAll,
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
                                ? SvgPicture.asset(AppAssets.User_Circle)
                                : null,
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Myprofile_user?.user.name ?? "User...",

                                  style: AppTextStyles.bodyLargeStrong.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AppSpacing.verticalXxs,
                                 Text(
                                   Myprofile_user?.user.email ?? "email...",
                                  style: AppTextStyles.bodySmallMedium.copyWith(
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.neutralGrey),

            /// 🔹 Menu Items

            Expanded(
              child: ListView(
                children: [

                  /// Bottom linked
                  _drawerBottomItem(
                    "Dashboard",
                    AppAssets.activeDashboard,
                    AppAssets.inactiveDashboard,
                    0,
                  ),

                  _drawerBottomItem(
                    "shoots",
                    AppAssets.activeShoots,
                    AppAssets.inactiveShoots,
                    1,
                  ),

                  _drawerBottomItem(
                    "File Manager",
                    AppAssets.activeFileManager,
                    AppAssets.inactiveFileManager,
                    2,
                  ),

                  _drawerBottomItem(
                    "messages",
                    AppAssets.activeMessages,
                    AppAssets.inactiveMessages,
                    3,
                  ),

                  _drawerBottomItem(
                    "Manage Availability",
                    AppAssets.activeManageAvailability,
                    AppAssets.inactiveManageAvailability,
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
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SvgPicture.asset(
            _selectedIndex == index
                ? activeIcon
                : inactiveIcon,

            width: _selectedIndex == index ? 28 : 24,
            height: _selectedIndex == index ? 28 : 24,

            fit: BoxFit.contain,

            colorFilter: ColorFilter.mode(
              _selectedIndex == index
                  ? AppColors.white
                  : AppColors.white30,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
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