/*
import 'package:beige_creative_app/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'Home/home_screen.dart';



class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    Center(child: Text("Book Shoot")),
    Center(child: Text("Booking")),
    Center(child: Text("Chat")),
  ];
  /// 🔐 LOGOUT DIALOG
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: ColorCode.bcakgroundcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                debugPrint("User Logged Out");
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: _pages[_selectedIndex],


      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ColorCode.bcakgroundcolor, // 🔥 background color
          */
/* boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],*//*

        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.white,
          unselectedItemColor: ColorCode.kWhiteOpacity70,

          /// 🔹 SELECTED TEXT STYLE
          selectedLabelStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),

          /// 🔹 UNSELECTED TEXT STYLE
          unselectedLabelStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),

          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },

          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 0
                    ? "assets/Active/Dashboard.svg"
                    : "assets/NonActive/dashboard-square-02.svg",
                height: 28,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0
                      ? Colors.white
                      : ColorCode.kWhiteOpacity70,
                  BlendMode.srcIn,
                ),
              ),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 1
                    ? "assets/Active/Shoots.svg"
                    : "assets/NonActive/Shoots(1).svg",
                height: 28,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1
                      ? Colors.white
                      : ColorCode.kWhiteOpacity70,
                  BlendMode.srcIn,
                ),
              ),
              label: "Shoot",
            ),
            BottomNavigationBarItem(
              icon:SvgPicture.asset(
                _selectedIndex == 2
                    ? "assets/Active/FileManager.svg"
                    : "assets/NonActive/FileManager(1).svg",
                height: 28,
              ),
              label: "File Manager",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 3
                    ? "assets/Active/Messages.svg"
                    : "assets/NonActive/Messages (1).svg",
                height: 28,
              ),
              label: "Messages",
            ),
          ],
        ),

      ),

    );
  }
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: SafeArea(
        child: Column(
          children: [

            /// TOP SECTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// LOGO + CLOSE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// BELL
                      Image.asset(
                        "assets/home/Group.png",

                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// PROFILE CARD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6B98C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [

                        const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                          AssetImage("assets/home/Vector.png"), // add image
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Priya Smith",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: "Outfit",
                                    color: ColorCode.black
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "priyasmith@gmail.com",
                                style: TextStyle(fontSize: 12,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w500,
                                    color: ColorCode.black
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios, size: 16)
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey),

            /// MENU ITEMS
            Expanded(
              child: ListView(
                children: [
                  _drawerItem("Dashboard", Icons.dashboard),
                  _drawerItem("Shoots", Icons.camera_alt),
                  _drawerItem("Manage Availability", Icons.calendar_month),
                  _drawerItem("File Manager", Icons.folder),
                  _drawerItem("Meetings", Icons.video_call),
                  _drawerItem("Messages", Icons.message),
                  _drawerItem("Payouts", Icons.currency_rupee),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Drawer Item Method
  Widget _drawerItem(String title, IconData icon) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: Colors.white70, size: 20),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => Navigator.pop(context),
        ),
        Divider(
          color: ColorCode.kDividerWhite12,
          thickness: 0.8,

        )
      ],
    );
  }

}


*/
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'ManageAvailability/manage_availability_screen.dart';
import 'Shoots/shoots_screen.dart';
import 'utility/ColorCode.dart';
import 'Home/home_screen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = const [
    HomeScreen(),
    ShootsScreen(),

    Center(child: Text("File Manager", style: TextStyle(color: Colors.white))),
    Center(child: Text("Messages", style: TextStyle(color: Colors.white))),
    ManageAvailabilityScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorCode.bcakgroundcolor,
      drawer: _buildDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: ColorCode.bcakgroundcolor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: ColorCode.kWhiteOpacity70,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            _selectedIndex == 0
                ? "assets/Active/Dashboard.svg"
                : "assets/NonActive/dashboard-square-02.svg",
            height: 26,
            colorFilter: ColorFilter.mode(
              _selectedIndex == 0
                  ? Colors.white
                  : ColorCode.kWhiteOpacity70,
              BlendMode.srcIn,
            ),
          ),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            _selectedIndex == 1
                ? "assets/Active/Shoots.svg"
                : "assets/NonActive/Shoots(1).svg",
            height: 26,
            colorFilter: ColorFilter.mode(
              _selectedIndex == 1
                  ? Colors.white
                  : ColorCode.kWhiteOpacity70,
              BlendMode.srcIn,
            ),
          ),
          label: "Shoots",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: "File Manager",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: "Messages",
        ),
      ],
    );
  }
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: SafeArea(
        child: Column(
          children: [

            /// TOP SECTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// LOGO + CLOSE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// BELL
                      Image.asset(
                        "assets/home/Group.png",

                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// PROFILE CARD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6B98C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [

                        const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                          AssetImage("assets/home/Vector.png"), // add image
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Priya Smith",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: "Outfit",
                                    color: ColorCode.black
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "priyasmith@gmail.com",
                                style: TextStyle(fontSize: 12,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w500,
                                    color: ColorCode.black
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios, size: 16)
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey),

            /// MENU ITEMS
            Expanded(
              child: ListView(
                children: [
                  _drawerItem("Dashboard", Icons.dashboard, 0),
                  _drawerItem("Shoots", Icons.camera_alt, 1),
                  _drawerItem("File Manager", Icons.folder, 2),
                  _drawerItem("Messages", Icons.message, 3),

                  _drawerItem("Manage Availability", Icons.currency_rupee,4),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Drawer Item Method
  Widget _drawerItem(String title, IconData icon, int index) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: Colors.white70, size: 20),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedIndex = index;   // 👈 THIS IS IMPORTANT
            });
            Navigator.pop(context);     // drawer close
          },
        ),
        Divider(
          color: ColorCode.kDividerWhite12,
          thickness: 0.8,
        )
      ],
    );
  }

}