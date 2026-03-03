import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';
import '../widgets/common_calendar.dart';
import 'AddAvailability/add_availability_screen.dart';
import 'manage_asvailability_conttoller.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {

  final ManageAvailabilityController  nexwController = ManageAvailabilityController();


  /// 🔥 Dummy Event Data (Later API se replace karna)
  final Map<DateTime, String> _events = {
    DateTime(2026, 1, 2): "Available",
    DateTime(2026, 1, 6): "Shoot",
    DateTime(2026, 1, 12): "Available",
  };
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
      
            /// 🔝 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
      
                  InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Image.asset(
                      "assets/home/menu-02.png",
                      width: 26,
                      color: Colors.white,
                    ),
                  ),
      
                  const Spacer(),
      
                  const Text(
                    "Manage Availability",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
      
                  const Spacer(),
                ],
              ),
            ),
      
            /// 🔵 Auto Block Info
            /*     Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.lightBlueAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your availability is automatically blocked for confirmed shoots",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),*/
      
            const SizedBox(height: 20),
      
            /// 📅 Calendar Section
            AnimatedBuilder(
              animation: nexwController,
              builder: (context, _) {
      
                final focused = nexwController.focusedDay;
      
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
      
                      /// 🔝 HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
      
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.white),
                                onPressed: () {
                                  nexwController.focusedDay =
                                      DateTime(focused.year, focused.month - 1);
                                  nexwController.notifyListeners();
                                },
                              ),
      
                              Text(
                                "${_monthName(focused.month)} ${focused.year}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
      
                              IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    color: Colors.white),
                                onPressed: () {
                                  nexwController.focusedDay =
                                      DateTime(focused.year, focused.month + 1);
                                  nexwController.notifyListeners();
                                },
                              ),
                            ],
                          ),
      
                          /// Dropdown Look Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:ColorCode.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Text("All Events",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.black, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
      
                      const SizedBox(height: 14),
      
                      /// WEEK DAYS
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _WeekText("Sun"),
                          _WeekText("Mon"),
                          _WeekText("Tue"),
                          _WeekText("Wed"),
                          _WeekText("Thu"),
                          _WeekText("Fri"),
                          _WeekText("Sat"),
                        ],
                      ),
      
                      const SizedBox(height: 12),
      
                      /// 🔥 CALENDAR GRID
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 42,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
      
                          DateTime firstDayOfMonth =
                          DateTime(focused.year, focused.month, 1);
      
                          int weekdayOffset = firstDayOfMonth.weekday % 7;
                          DateTime day =
                          firstDayOfMonth.add(Duration(days: index - weekdayOffset));
      
                          bool isCurrentMonth =
                              day.month == focused.month;
      
                          final event = nexwController.getEvent(day);
      
                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white10, width: 0.5),
                            ),
                            child: Stack(
                              children: [
      
                                /// Date Number
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Text(
                                    "${day.day}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentMonth
                                          ? Colors.white70
                                          : Colors.white24,
                                    ),
                                  ),
                                ),
      
                                /// Event Tag
                                if (event != null)
                                  Positioned(
                                    bottom: 6,
                                    left: 6,
                                    right: 6,
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                      decoration: BoxDecoration(
                                        color: nexwController
                                            .getEventColor(event)
                                            .withOpacity(0.2),
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        event,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: nexwController
                                              .getEventColor(event),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
      
                      const SizedBox(height: 16),
      
                      /// 🔵 LEGEND
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Legend(color: Colors.grey, text: "Disabled"),
                          _Legend(color: Colors.brown, text: "Today’s"),
                          _Legend(color: Colors.blue, text: "Shoots"),
                          _Legend(color: Colors.red, text: "Conflicts"),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      
            const SizedBox(height: 20),
      
            /// 🔵 Legend
      
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "This Month",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Outfit",
                    ),
                  ),
                  const SizedBox(height: 16),
      
                  _buildStatCard(
                    icon: Icons.calendar_today_outlined,
                    title: "Available Days",
                    value: "18",
                  ),
      
                  const SizedBox(height: 12),
      
                  _buildStatCard(
                    icon: Icons.videocam_outlined,
                    title: "Book Shoots",
                    value: "07",
                  ),
      
                  const SizedBox(height: 12),
      
                  _buildStatCard(
                    icon: Icons.hourglass_empty,
                    title: "Time Off",
                    value: "03 Days",
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
      
                  /// Title
                  const Text(
                    "Share Availability",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Outfit",
                    ),
                  ),
      
                  const SizedBox(height: 8),
      
                  /// Subtitle
                  const Text(
                    "Share your availability link with production teams",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: "Outfit",
                    ),
                  ),
      
                  const SizedBox(height: 20),
      
                  /// Copy Button
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // Copy logic here
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: ColorCode.kButtonColor, // Gold background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.copy_rounded,
                            color: ColorCode.kCircleGradientTop,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Copy Link",
                            style: TextStyle(
                              color: ColorCode.kCircleGradientTop,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Outfit",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
            Divider(
              color: ColorCode.kDividerWhite12,
              thickness: 0.8,
      
            ),
            const SizedBox(height: 12),
            /// 📷 Upcoming Shoot Card
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Upcoming Shoots",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                        ),),
      
      
      
      
                    ],
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 14),
      
            Row(
              children: [
      
                /// 🔍 SEARCH FIELD
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorCode.kWhiteOpacity70,
                        width: 1,
                      ),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        hintText: "Search events or crew...",
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(width: 12),
      
                /// ⚙️ FILTER BUTTON
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Filter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Image.asset(
                          "assets/home/Filter.png",
                          height: 18,
                          width: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 18),
      
            /// EVENT CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
      
                      /// IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          "assets/home/Mask_group.png", // add your image
                          height: 169,
                          width: 117,
      
                          fit: BoxFit.cover,
                        ),
                      ),
      
                      const SizedBox(width: 14),
      
                      /// DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
      
                            Text(
                              "Wedding Event 2024",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
      
                            SizedBox(height: 6),
      
                            Text(
                              "Jan 15, 2024 • 10:00 PM",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
      
                            SizedBox(height: 6),
      
                            Text(
                              "Los Angeles, CA",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
      
      
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.kButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "View Details",
                      style: TextStyle(color: Colors.black, fontSize: 11),
                    ),
                  )
                ],
              ),
      
            ),
      
            const SizedBox(height: 12),
            Divider(
              color: ColorCode.kDividerWhite12,
              thickness: 0.8,
      
            ),
            const SizedBox(height: 12),
      
      
            const SizedBox(height: 25),
      
            /// ➕ Add Availability Button
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  AddAvailabilityScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: ColorCode.kButtonColor, // Gold background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
      
                      Text(
                        " Add Availability",
                        style: TextStyle(
                          color: ColorCode.kCircleGradientTop,
                          fontSize: 16,
      
                          fontWeight: FontWeight.w600,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
          ),

          // Value
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD6C19A), // gold-ish color like image
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Outfit",
            ),
          ),
        ],
      ),
    );
  }
}
class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: ColorCode.kWhiteOpacity70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}class _WeekText extends StatelessWidget {
  final String text;
  const _WeekText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
    );
  }
}

String _monthName(int month) {
  const months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];
  return months[month - 1];
}