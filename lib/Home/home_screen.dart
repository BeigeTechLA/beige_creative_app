import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utility/ColorCode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedDashboardIndex = 0;
  /// 🔥 Drawer UI Method (Same Class Me)
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(), // 👈 Yaha attach kiya
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TOP ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          /// 🔥 MENU BUTTON
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

                          const SizedBox(width: 12),

                          /// LOCATION
                          const Expanded(
                            child: Text(
                              "Welcome Back, Priya",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),

                          /// BELL
                          Image.asset(
                            "assets/home/notifiaction.png",
                            width: 22,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15),
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                            AssetImage("assets/home/Vector.png"), // add image
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Your Dashboard",
                        style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                        color: ColorCode.white,
                      ),),

                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: ColorCode.k282828,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [

                        _dashboardCard(
                          index: 0,
                          title: "Completed Shoots",
                          count: "24",
                          percent: "+3% from last month",
                          percentColor: Colors.green,
                          icon: Icons.videocam,
                        ),

                        const SizedBox(height: 18),

                        _dashboardCard(
                          index: 1,
                          title: "Upcoming Shoots",
                          count: "08",
                          percent: "+3% from last month",
                          percentColor: Colors.green,
                          icon: Icons.calendar_month,
                        ),

                        const SizedBox(height: 18),

                        _dashboardCard(
                          index: 2,
                          title: "Pending Requests",
                          count: "05",
                          percent: "-2% from last month",
                          percentColor: Colors.red,
                          icon: Icons.hourglass_bottom,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
     Divider(color: ColorCode.kDividerWhite12,),
                  SizedBox(height: 10),
                  Row(
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Availability",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                        ),
                      ),

                      /// + Add Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffE8D7B9), // beige color
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16, color: Colors.black),
                        label: const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorCode.k282828,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: DateTime.now(),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                        titleTextStyle: TextStyle(color: Colors.white),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.white70),
                        weekendStyle: TextStyle(color: Colors.white70),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        weekendTextStyle: const TextStyle(color: Colors.white),
                        todayDecoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xffE8D7B9),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _dashboardCard({
    required int index,
    required String title,
    required String count,
    required String percent,
    required Color percentColor,
    required IconData icon,
  }) {
    bool isSelected = selectedDashboardIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedDashboardIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ?  ColorCode.kButtonColor   // Selected Beige
              :  Colors.transparent, // Normal Dark
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  percent,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.green
                        : percentColor,
                  ),
                ),
              ],
            ),

            CircleAvatar(
              radius: 18,
              backgroundColor:
              isSelected ? Colors.black : const Color(0xFF2A2A2A),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            )
          ],
        ),
      ),
    );
  }
}
