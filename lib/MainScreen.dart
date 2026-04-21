//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'FileManager/file_manager_screen.dart';
// import 'ManageAvailability/manage_availability_screen.dart';
// import 'Messages/messages_screen.dart';
// import 'Shoots/shoots_screen.dart';
// import 'utility/ColorCode.dart';
// import 'Home/home_screen.dart';
//
// class Mainscreen extends StatefulWidget {
//   const Mainscreen({super.key});
//
//   @override
//   State<Mainscreen> createState() => _MainscreenState();
// }
//
// class _MainscreenState extends State<Mainscreen> {
//   int _selectedIndex = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   final List<Widget> _pages = const [
//     HomeScreen(),          // 0
//     ShootsScreen(),        // 1
//     FileManagerScreen(),   // 2
//     MessagesScreen(),                   // 3
//     // ManageAvailabilityScreen(),
//   ];
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: ColorCode.bcakgroundcolor,
//       drawer: _buildDrawer(),
//
//       body: _pages[_selectedIndex],
//
//
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }
//
//   Widget _buildBottomBar() {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       // currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
//       backgroundColor: ColorCode.bcakgroundcolor,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: Colors.white,
//       unselectedItemColor: ColorCode.kWhiteOpacity70,
//       onTap: _onItemTapped,
//       items: [
//         BottomNavigationBarItem(
//           icon: SvgPicture.asset(
//             _selectedIndex == 0
//                 ? "assets/Active/Dashboard.svg"
//                 : "assets/NonActive/dashboard-square-02.svg",
//             height: 26,
//             colorFilter: ColorFilter.mode(
//               _selectedIndex == 0
//                   ? Colors.white
//                   : ColorCode.kWhiteOpacity70,
//               BlendMode.srcIn,
//             ),
//           ),
//           label: "Dashboard",
//         ),
//
//         BottomNavigationBarItem(
//           icon: SvgPicture.asset(
//             _selectedIndex == 1
//                 ? "assets/Active/Shoots.svg"
//                 : "assets/NonActive/Shoots(1).svg",
//             height: 26,
//             colorFilter: ColorFilter.mode(
//               _selectedIndex == 1
//                   ? Colors.white
//                   : ColorCode.kWhiteOpacity70,
//               BlendMode.srcIn,
//             ),
//           ),
//           label: "Shoots",
//         ),
//
//         BottomNavigationBarItem(
//           icon: SvgPicture.asset(
//             _selectedIndex == 2
//                 ? "assets/Active/FileManager.svg"
//                 : "assets/NonActive/FileManager(1).svg",
//             height: 26,
//             colorFilter: ColorFilter.mode(
//               _selectedIndex == 2  // ✅ FIXED
//               ? Colors.white
//                 : ColorCode.kWhiteOpacity70,
//             BlendMode.srcIn,
//             ),
//           ),
//           label: "File Manager",
//         ),
//
//         BottomNavigationBarItem(
//           icon: SvgPicture.asset(
//             _selectedIndex == 3
//                 ? "assets/Active/Messages.svg"
//                 : "assets/NonActive/Messages (1).svg",
//             height: 28,
//           ),
//           label: "Messages",
//         ),
//       ],
//     );
//   }
//   Widget _buildDrawer() {
//     return Drawer(
//       backgroundColor: const Color(0xFF111111),
//       child: SafeArea(
//         child: Column(
//           children: [
//
//             /// TOP SECTION
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                   /// LOGO + CLOSE
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       /// BELL
//                       Image.asset(
//                         "assets/home/Group.png",
//
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.white),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       )
//                     ],
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   /// PROFILE CARD
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFD6B98C),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Row(
//                       children: [
//
//                         const CircleAvatar(
//                           radius: 25,
//                           backgroundImage:
//                           AssetImage("assets/home/Vector.png"), // add image
//                         ),
//
//                         const SizedBox(width: 12),
//
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: const [
//                               Text(
//                                 "Priya Smith",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     fontFamily: "Outfit",
//                                     color: ColorCode.black
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 "priyasmith@gmail.com",
//                                 style: TextStyle(fontSize: 12,
//                                     fontFamily: "Outfit",
//                                     fontWeight: FontWeight.w500,
//                                     color: ColorCode.black
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const Icon(Icons.arrow_forward_ios, size: 16)
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const Divider(color: Colors.grey),
//
//             /// MENU ITEMS
//             Expanded(
//               child: ListView(
//                 children: [
//                   _drawerBottomNavItem("Dashboard", Icons.dashboard, 0),
//                   _drawerBottomNavItem("Shoots", Icons.camera_alt, 1),
//                   _drawerBottomNavItem("File Manager", Icons.folder, 2),
//                   _drawerBottomNavItem("Messages", Icons.message, 3),
//
//               /*    _drawerBottomNavItem(
//                     "Manage Availability",
//                     Icons.calendar_month,
//                     4,
//                   ),*/
//
//                   _drawerPushItem(
//                     "Manage Availability",
//                     Icons.calendar_month,
//                     const ManageAvailabilityScreen(),
//                   ),
//
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// 🔥 Drawer Item Method
//   /// 🔥 Bottom Nav Type Item
//   Widget _drawerBottomNavItem(String title, IconData icon, int index) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white70, size: 20),
//       title: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontFamily: "Outfit",
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//         Navigator.pop(context);
//       },
//     );
//   }
//
//   /// 🔥 Push New Screen Item
//   Widget _drawerPushItem(String title, IconData icon, Widget screen) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white70, size: 20),
//       title: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontFamily: "Outfit",
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => screen),
//         );
//       },
//     );
//   }
// }


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
import 'Profile/MyProfile/MyProfile.dart';
import 'Shoots/shoots_screen.dart';
import 'FileManager/file_manager_screen.dart';
import 'Messages/messages_screen.dart';
import 'ManageAvailability/manage_availability_screen.dart';
import 'utility/ColorCode.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {

bool isloading = true;

Data? Myprofile_user;

@override
  void initState() {
    super.initState();
    fetchprofiledata();
  }

  Future<void> fetchprofiledata() async {
    try {
      setState(() {
        isloading = true;
      });

      final rawResponse =
      await ApiService().postData(ApiEndpoints.profiledetails, {});

      debugPrint("📦 RAW API RESPONSE: $rawResponse");

      final response = Myprofilemodel.fromJson(rawResponse);

      debugPrint("✅ PARSED RESPONSE: ${response.data}");

      if (response.error == false) {

        /// ✅ SOCIAL LINKS

        /// ✅ PORTFOLIO LINKS
        final portfolio = response.data.crewMemberFiles
            .where((e) => e.fileType == "link")
            .toList();

        debugPrint("🎯 Portfolio Count: ${portfolio.length}");

        /// ✅ IMPORTANT CHANGE (USE NESTED USER)
        setState(() {
          Myprofile_user = response.data;
        });

      } else {
        debugPrint("❌ API ERROR: ${response.message}");
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }



  int _selectedIndex = 0;

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
      backgroundColor: ColorCode.bcakgroundcolor,
      drawer: _buildDrawer(),

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

  // ================================
  // 🔥 Bottom Navigation
  // ================================

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      // currentIndex: _selectedIndex,
      currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
      backgroundColor: ColorCode.bcakgroundcolor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
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
            "assets/Active/Shoots.svg",
            "assets/NonActive/Shoots(1).svg",
            1,
          ),
          label: "Shoots",
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
    );
  }

  Widget _navIcon(String active, String inactive, int index) {
    return SvgPicture.asset(
      _selectedIndex == index ? active : inactive,
      height: 26,
      colorFilter: ColorFilter.mode(
        _selectedIndex == index
            ? Colors.white
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  Myprofile(),
                        ),
                      );
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
                            backgroundImage: (Myprofile_user?.user.profileImageUrl ?? "").isNotEmpty
                                ? NetworkImage(
                              "${ApiService.imageURL}${Myprofile_user!.user.profileImageUrl}",
                            )
                                : null,
                            child: (Myprofile_user?.user.profileImageUrl ?? "").isEmpty
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
                    "Shoots",
                    "assets/Active/Shoots.svg",
                    "assets/NonActive/Shoots(1).svg",
                    1,
                  ),

                  _drawerBottomItem(
                    "File Manager",
                    "assets/Active/FileManager.svg",
                    "assets/NonActive/FileManager(1).svg",
                    2,
                  ),

                  _drawerBottomItem(
                    "Messages",
                    "assets/Active/Messages.svg",
                    "assets/NonActive/Messages (1).svg",
                    3,
                  ),
                  _drawerBottomItem(
                    "Manage Availability",
                    "assets/Active/Manage Availability.svg",
                    "assets/NonActive/ManageAvailability(2).svg",
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
        height: 22,
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