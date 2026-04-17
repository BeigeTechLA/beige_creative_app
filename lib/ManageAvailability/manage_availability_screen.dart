import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../UpcomingShootViewdetils/upcoming_shoot_view_detils.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../utility/imges_icons.dart';
import '../widgets/common_calendar.dart';
import 'AddAvailability/add_availability_screen.dart';
import 'manage_asvailability_conttoller.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen>
    with SingleTickerProviderStateMixin {
  Future<void> fetchAvailability() async {
    try {
      final response = await ApiService().postData(
        ApiEndpoints.createavailability,
        {
          "month": nexwController.focusedDay.month,
          "year": nexwController.focusedDay.year
        },
      );

      if (response["error"] == false) {
        final availability = response["data"]["availability"];

        nexwController.setAvailability(availability); // 🔥 MAIN
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
  String selectedEvent = "All Events"; // 👈 top pe define kar


  final ManageAvailabilityController  nexwController = ManageAvailabilityController();


  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchAvailability();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
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
                    child: SvgPicture.asset(
                      AppImages.menu,
                      width: 26,
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
                Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.only(left: 12,top: 12,bottom: 12,right: 20),
                decoration: BoxDecoration(
                  color: const Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Row(
                  children: [
                   SvgPicture.asset('assets/svg/infosvg.svg'),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your availability is automatically blocked for confirmed shoots",
                        style: TextStyle(
                          fontFamily: 'outfit',
                          color: Color(0xff3B82F6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      
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

                                    fetchAvailability(); // 🔥 ADD THIS
                                  }
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

                                    fetchAvailability(); // 🔥 ADD THIS
                                  }
                              ),
                            ],
                          ),


                Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                color: ColorCode.white,
                borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                value: selectedEvent,
                icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xff2A2622),
                size: 18,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(
                fontFamily: 'Outfit',
                color: Color(0xff2A2622),
                fontSize: 12,
                ),
                items: ["All Events", "Shoot", "Available"]
                    .map((value) => DropdownMenuItem(
                value: value,
                child: Text(value),
                ))
                    .toList(),
                onChanged: (value) {
                setState(() {
                  nexwController.changeFilter(value!);
                });//
                },
                ),
                ),
                )
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
                                if (event != null && nexwController.shouldShowEvent(event))
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
                    value: "${nexwController.availableCount}",

                  ),
      
                  const SizedBox(height: 12),
      
                  _buildStatCard(
                    icon: Icons.videocam_outlined,
                    title: "Book Shoots",
                    value: "${nexwController.shootCount}",
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
      
            const SizedBox(height: 50),
      
            /// EVENT CARD
            GestureDetector(
              onTap: _onCardTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double totalWidth = constraints.maxWidth;
                  final list = nexwController.cardDataList;
                  final current = list[_currentIndex];
                  final next = list[(_currentIndex + 1) % list.length];
                  final next2 = list[(_currentIndex + 2) % list.length];


                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 3rd card (back most) - Full container with image and data
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        top: _controller.isAnimating ? -32 : -24,
                        left: totalWidth * 0.07,
                        right: totalWidth * 0.07,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _controller.isAnimating ? 0.5 : 1,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF303030),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    next2['image'],
                                    height: 169,
                                    width: 117,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        next2['title'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        SvgPicture.asset(AppImages.calender, width: 14, height: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          next2['date'],
                                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                                        ),
                                      ]),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        SvgPicture.asset(AppImages.time, width: 14, height: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          next2['time'],
                                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                                        ),
                                      ]),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        SvgPicture.asset(AppImages.location, width: 14, height: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          next2['location'],
                                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                                        ),
                                      ]),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: ColorCode.kButtonColor.withOpacity(0.7),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed: () {},
                                              child: const Text("View Details",
                                                  style: TextStyle(color: Colors.black, fontSize: 11)),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                      /*    _buildAvatarStack(
                                            images: [
                                              AppImages.avtarstack,
                                              AppImages.avtarstack,
                                              AppImages.avtarstack,
                                              AppImages.avtarstack,
                                            ],
                                            extraCount: 3,
                                            avatarSize: 20,
                                            overlap: 10,
                                          ),*/
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 2nd card (middle) - Full container with image and data
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        top: _controller.isAnimating ? -20 : -12,
                        left: totalWidth * 0.035,
                        right: totalWidth * 0.035,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _controller.isAnimating ? 0.7 : 1,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2E2E),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    next['image'],
                                    height: 169,
                                    width: 117,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        next['title'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        SvgPicture.asset(AppImages.calender, width: 14, height: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          next['date'],
                                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                      ]),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        SvgPicture.asset(AppImages.time, width: 14, height: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          next['time'],
                                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                      ]),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        SvgPicture.asset(AppImages.location, width: 14, height: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          next['location'],
                                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                      ]),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: ColorCode.kButtonColor.withOpacity(0.8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed: () {},
                                              child: const Text("View Details",
                                                  style: TextStyle(color: Colors.black, fontSize: 11)),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                         /* _buildAvatarStack(
                                            images: [
                                              AppImages.avtarstack,
                                              AppImages.avtarstack,
                                              AppImages.avtarstack,
                                              AppImages.avtarstack,
                                            ],
                                            extraCount: 3,
                                            avatarSize: 20,
                                            overlap: 10,
                                          ),*/
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Main card with slide out animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _controller.value * 200),
                            child: Opacity(
                              opacity: 1 - _controller.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ColorCode.k282828,
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  current['image'],
                                  height: 169,
                                  width: 117,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      current['title'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      SvgPicture.asset(AppImages.calender, width: 14, height: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        current['date'],
                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    ]),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      SvgPicture.asset(AppImages.time, width: 14, height: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        current['time'],
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      ),
                                    ]),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      SvgPicture.asset(AppImages.location, width: 14, height: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        current['location'],
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      ),
                                    ]),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              backgroundColor: ColorCode.kButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UpcomingShootViewDetils(),
                                                ),
                                              );
                                            },
                                            child: const Text("View Details",
                                                style: TextStyle(color: Colors.black, fontSize: 11)),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                     /*   _buildAvatarStack(
                                          images: [
                                            AppImages.avtarstack,
                                            AppImages.avtarstack,
                                            AppImages.avtarstack,
                                            AppImages.avtarstack,
                                          ],
                                          extraCount: 3,
                                          avatarSize: 20,
                                          overlap: 10,
                                        ),*/
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
  void _onCardTap() async {
    if (_controller.isAnimating) return;

    await _controller.forward();

    setState(() {
      final listLength = nexwController.cardDataList.length;
      _currentIndex = (_currentIndex + 1) % listLength;
    });

    _controller.reset();
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

String _monthName(int month) {
  const months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];
  return months[month - 1];
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


}


class _WeekText extends StatelessWidget {
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
