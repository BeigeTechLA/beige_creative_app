import 'package:beige_creative_app/Shoots/shoot_detils_screen.dart';
import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';

class ShootsScreen extends StatelessWidget {
  const ShootsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          /// 🔥 TOP BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [

                /// MENU
                Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Image.asset(
                      "assets/home/menu-02.png",
                      width: 26,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                /// TITLE
                const Text(
                  "Shoots",
                  style: TextStyle(
                    color: ColorCode.white,
                    fontSize: 16,
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                /// FILTER
                Image.asset(
                  "assets/icons/Filter.png",
                  width: 26,
                  color: Colors.white,
                )
              ],
            ),
          ),

          /// 🔥 COUNT CARDS
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _countCard("24", "Pending Shoots"),
                _countCard("05", "Confirmed Shoots"),
                _countCard("02", "Completed"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// 🔥 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: "Search events or crew...",
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 LIST SECTION
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _shootCard(context);
              },
            ),
          )
        ],
      ),
    );
  }

  /// 🔥 COUNT CARD
  Widget _countCard(String number, String title) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFFD6B98C),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 SHOOT CARD
  Widget _shootCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color:ColorCode.k282828,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: Image.asset(
              "assets/home/img.png", // add your image
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      "ID: #12456",
                      style: TextStyle(
                        color: ColorCode.kButtonColor,
                        fontSize: 12,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                      ),),
                       InkWell(
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => ShootDetilsScreen(),
                             ),
                           );
                         },
                         child: Text(
                           "View Details",
                           style: TextStyle(
                             color: ColorCode.kButtonColor,
                             fontSize: 12,
                             fontFamily: "Outfit",
                             fontWeight: FontWeight.w600,
                             decoration: TextDecoration.underline,
                             decorationColor: ColorCode.kButtonColor,
                             decorationThickness: 1.5,
                           ),
                         ),
                       ),
                  ],
                ),
                const Text(
                  "Annual Tech Conference 2026",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),
                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                    const SizedBox(width: 6),
                    const Text(
                      "Jan 06, 2026",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),

                    const SizedBox(width: 14),

                    Icon(Icons.access_time, size: 14, color: Colors.white54),
                    const SizedBox(width: 6),
                    const Text(
                      "12:00 PM - 4:00 PM",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),

                    const SizedBox(width: 14),

                    Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "Los Angeles, CA",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.kSoftMint,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Accept" ,style: TextStyle(
    color: ColorCode.green,
    fontSize: 12,
    fontFamily: "Outfit",
    fontWeight: FontWeight.w600,
    ),)
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.kSoftPeach,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Decline",
                        style: TextStyle(
                          color: ColorCode.red,
                          fontSize: 12,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w600,
                        ),)
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}