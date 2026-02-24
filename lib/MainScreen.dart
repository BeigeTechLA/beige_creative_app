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

      body: _pages[_selectedIndex],



      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ColorCode.bcakgroundcolor, // 🔥 background color
          /* boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],*/
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
}





/*
import 'package:beige/ChooseYourRole/choose_your_role_screen.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Booking/booking_all_screen.dart';
import 'Home/Specialities/specialities.dart';
import 'Home/home_screen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;

  /// 🔹 SERVICES / SPECIALITIES REMOVED
  final List<Widget> _pages = [
    HomeScreen(),          // 0
    Specialities(),
    BookingAllScreen(),    // 1 (Book Shoot / Booking)
    Center(child: Text("Message", style: TextStyle(fontSize: 22))),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: ColorCode.bcakgroundcolor,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.white,
          unselectedItemColor: ColorCode.kWhiteOpacity70,

          selectedLabelStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),


          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 0
                    ? "assets/Icons/home_10.png"
                    : "assets/Icons/inactive_home.png",
                height: 28,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 1
                    ? "assets/Icons/Group 2087328965.png"
                    : "assets/Icons/inactive_book_shoot.png",
                height: 28,
              ),
              label: "Book Shoot",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 2
                    ? "assets/Icons/Calendar4.png"
                    : "assets/Icons/inactive_booking.png",
                height: 28,
              ),
              label: "My Shoots",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/Icons/chat-1-line 1.png",
                height: 28,
              ),
              label: "Messages",
            ),
          ],
        ),
      ),
    );
  }
}
*/
