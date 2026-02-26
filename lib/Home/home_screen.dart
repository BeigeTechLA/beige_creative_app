import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Profile/MyProfile/MyProfile.dart' show Myprofile;
import '../utility/ColorCode.dart';
import '../widgets/multi_arc_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedDashboardIndex = 0;
  bool isExpanded = false;
  int currentIndex = 0;
  String selectedRange = "Month";
  int selectedTab = 0; // 0 = Photo, 1 = Video


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                          InkWell(
                            onTap: () {

                               Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  Myprofile(),
                        ),
                      );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                              AssetImage("assets/home/Vector.png"), // add image
                            ),
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
                        "Shoots",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                        ),
                      ),

                      /// + Add Button
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorCode.k282828,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔥 IMAGE SECTION
                        Stack(
                          children: [

                            /// Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                              child: Image.asset(
                                "assets/home/img.png",
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            /// Dark Gradient Overlay (Important for premium look)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(22),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// 10 mins ago badge
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "10 mins Ago",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),

                            /// Arrow Circle
                            Positioned(
                              bottom: 14,
                              right: 14,
                              child: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),

                            /// Confirmed Badge (overlay on image)
                            Positioned(
                              bottom: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xffC8F5D3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle,
                                        size: 14, color: Colors.green),
                                    SizedBox(width: 6),
                                    Text(
                                      "Confirmed",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// 🔥 DETAILS SECTION
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// Title + View Details
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children:  [
                                  Expanded(
                                    child: Text(
                                      "Annual Tech Conference 2026",
                                      style: TextStyle(
                                        fontFamily: "Outfit",
                                        color: ColorCode.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "View Details",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w600,
                                      color: ColorCode.kButtonColor,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: ColorCode.kDividerWhite12,
                                thickness: 0.8,

                              ),
                              const SizedBox(height: 12),

                              /// Date + Time + Location
                              Wrap(
                                spacing: 14,
                                runSpacing: 8,
                                children: const [

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14, color: Colors.white70),
                                      SizedBox(width: 6),
                                      Text(
                                        "Jan 06, 2026",
                                        style:TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "Outfit",
                                            color: ColorCode.kWhiteOpacity70, fontSize: 10),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 14, color: Colors.white70),
                                      SizedBox(width: 6),
                                      Text(
                                        "12:00 PM - 4:00 PM",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                          fontFamily: "Outfit",
                                            color: ColorCode.kWhiteOpacity70, fontSize: 10),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 14, color: Colors.white70),
                                      SizedBox(width: 6),
                                      Text(
                                        "Los Angeles, CA",
                                        style:TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "Outfit",
                                            color: ColorCode.kWhiteOpacity70, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              /// Buttons Row
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end
                                ,
                                children: [

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffC8F5D3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      "Accept",
                                      style:
                                      TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Outfit",
                                          color: ColorCode.green, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffF5C8C8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      "Decline",
                                      style:
                                      TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Outfit",
                                          color: ColorCode.red, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 0.8,
                  ),
                   SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Meetings",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                        ),
                      ),

                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),


                  SizedBox(
                    height: 330,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        /// CARD 3 (LAST BACK)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          top: currentIndex == 0 ? 50 : 20,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 500),
                            scale: currentIndex == 0 ? 0.85 : 0.95,
                            child: _meetingCard(
                              opacity: 0.3,
                              backgroundColor: Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ),

                        /// CARD 2 (MIDDLE)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          top: currentIndex == 0 ? 25 : 50,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 500),
                            scale: currentIndex == 0 ? 0.92 : 0.85,
                            child: _meetingCard(
                              opacity: 0.6,
                              backgroundColor: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),

                        /// FRONT CARD
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentIndex = currentIndex == 0 ? 1 : 0;
                            });
                          },
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 500),
                            offset: currentIndex == 0
                                ? const Offset(0, 0)
                                : const Offset(0, -0.05),
                            curve: Curves.easeInOut,
                            child: _meetingCard(
                              opacity: 1,
                              backgroundColor: ColorCode.k282828,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 0.8,

                  ),

                  const SizedBox(height: 14),


            Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Shoot Status",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: "Outfit",
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: ColorCode.k282828,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: ColorCode.kWhiteOpacity70,

                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRange,
                        dropdownColor: const Color(0xFF1E1E1E),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                          size: 20,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Outfit",
                        ),
                        items: ["Week", "Month", "Year"]
                            .map(
                              (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedRange = val!;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 35),

              /// 🔥 GAUGE CHART
              Center(
                child: SizedBox(
                  height: 160,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [

                      /// Gauge
                      CustomPaint(
                        size: const Size(500, 150),
                        painter: MultiArcPainter(
                          values: const [0.80, 0.70, 0.5, 0.60],
                          colors: const [
                            Color(0xFFA678F1),
                            Color(0xFF5CC4FF),
                            Color(0xFFFFC04F),
                            Color(0xFF2DC497),
                          ],
                        ),
                      ),

                      /// Center Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "4,289",
                            style: TextStyle(
                              color: Color(0xFFE8D7B9),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Outfit",
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              /// STATUS ITEMS
              _statusItem("987", "Successful Shoots", const Color(0xFFA678F1)),
              _statusItem("1,674", "Pending Shoots", const Color(0xFF5CC4FF)),
              _statusItem("1,073", "Rejected Shoots", const Color(0xFFFFC04F)),
              _statusItem("921", "Shoot Requests", const Color(0xFF2DC497)),
            ],
          ),
        ),


                  const SizedBox(height: 14),
                  Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 0.8,

                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Shoot Categories",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: "Outfit",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        height: 38,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// PHOTO TAB
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTab = 0;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                decoration: BoxDecoration(
                                  color: selectedTab == 0
                                      ? const Color(0xFFE8D7B9) // Beige active
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Photo",
                                  style: TextStyle(
                                    color: selectedTab == 0
                                        ? Colors.black
                                        : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ),
                            ),

                            /// VIDEO TAB
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTab = 1;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                decoration: BoxDecoration(
                                  color: selectedTab == 1
                                      ? const Color(0xFFE8D7B9)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Video",
                                  style: TextStyle(
                                    color: selectedTab == 1
                                        ? Colors.black
                                        : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [



                        /// 🔥 GAUGE CHART
                        Center(
                          child: SizedBox(
                            height: 160,
                            width: 300,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [

                                /// Gauge
                                CustomPaint(
                                  size: const Size(500, 150),
                                  painter: MultiArcPainter(
                                    values: const [0.80, 0.70, 0.5, 0.60],
                                    colors: const [
                                      Color(0xFFA678F1),
                                      Color(0xFF5CC4FF),
                                      Color(0xFFFFC04F),
                                      Color(0xFF2DC497),
                                    ],
                                  ),
                                ),

                                /// Center Text
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      "4,289",
                                      style: TextStyle(
                                        color: Color(0xFFE8D7B9),
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Outfit",
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// STATUS ITEMS
                        _statusItem("987", "Successful Shoots", const Color(0xFFA678F1)),
                        _statusItem("1,674", "Pending Shoots", const Color(0xFF5CC4FF)),
                        _statusItem("1,073", "Rejected Shoots", const Color(0xFFFFC04F)),
                        _statusItem("921", "Shoot Requests", const Color(0xFF2DC497)),
                      ],
                    ),
                  ),
                ],
              ),
            )

          ],
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



  Widget _meetingCard({
    double opacity = 1,
    Color backgroundColor = const Color(0xFF2A2A2A),
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Pre-Production Kickoff",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white12),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xffF5D6A5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Initiated",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Google Meet",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "16 Jun, 2024",
                  style:
                  TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "10:00 PM to 13:00 PM",
                  style:
                  TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE8D7B9),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Join Meeting",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _statusItem(String count, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 75,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: color.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Outfit",
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
class MultiArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 14.0;
    double spacing = 18.0;
    Offset center = Offset(size.width / 2, size.height); // Bottom center focus

    // Colors mapping
    List<Color> colors = [
      const Color(0xFFA678F1), // Purple
      const Color(0xFF5CC4FF), // Blue
      const Color(0xFFFFC04F), // Yellow/Orange
      const Color(0xFF2DC497), // Green
    ];

    // Values (Percentage of the half circle)
    List<double> values = [1.0, 0.75, 0.5, 0.45];

    for (int i = 0; i < 4; i++) {
      double radius = size.width / 2 - (i * spacing);

      // Background Arc (Dark grey)
      Paint bgPaint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.14, // Start from left (180 deg)
        3.14, // Sweep 180 deg
        false,
        bgPaint,
      );

      // Active Color Arc
      Paint activePaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.14 + (3.14 * (1 - values[i])), // Dynamic start based on value
        3.14 * values[i],
        false,
        activePaint,
      );
    }

    // Bottom Horizontal Line
    Paint linePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}*/
