import 'dart:math';

import 'package:beige_creative_app/ManageAvailability/AddAvailability/add_availability_screen.dart';
import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Model_Class/Creatordashboarddetailsmodel.dart';
import '../Model_Class/Crewstatusmodel.dart';
import '../Model_Class/Dashboardcountmodel.dart';
import '../Model_Class/Shootstatusmodel.dart';
import '../Model_Class/Upcomingshootsmodel.dart';
import '../Model_Class/Creatordashboarddetailsmodel.dart' as dashboard;
import '../Model_Class/myprofilemodel.dart' as profile;

import '../Model_Class/myprofilemodel.dart';
import '../Profile/MyProfile/MyProfile.dart';
import '../UpcomingShootViewdetils/upcoming_shoot_view_detils.dart';
import '../utility/ColorCode.dart';
import '../widgets/multi_arc_painter.dart';

class HomeScreen extends StatefulWidget {
  // final Function(int)? onTabChange;

  const HomeScreen({super.key, });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int rejectedPhoto = 0;
  int rejectedVideo = 0;
  int requestPhoto = 0;
  int requestVideo = 0;

  bool isloading =true;

  String name = "";
  String email = "";
  String image = "";
  profile.Data? Myprofile_user;

  int photographyShoots = 0;
  int videographyShoots = 0;

  int acceptphotographyShoots = 0;
  int acceptvideographyShoots = 0;


  String getFilterValue() {
    if (selectedRange == "Week") {
      return "this_week";
    } else if (selectedRange == "Month") {
      return "this_month";
    } else {
      return "this_year";
    }
  }
  int sucessfullshoots = 0;
  int pendingshoots = 0;
  int rejectedshoots = 0;
  int shootrequest = 0;

  int completedshoots = 0;
  int upcomingshoots = 0;
  int pendingrequests = 0;

/*  Data? Myprofile_user;*/
  List<upcomingdatum> upcomingshootslist = [];
  List<PendingRequestCard> creatordashboarddetaillist = [];
  Map<DateTime, String> events = {};
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

  Future<void> fetchacceptdecline(int projectid, int crewid) async {
    final response = await ApiService().postData(
      ApiEndpoints.acceptdeclineproject,
      {
        "project_id": projectid,
        "crew_accept": crewid
      },
    );

    if (response["error"] == false) {
      debugPrint("Accept/Decline Success");

      /// 🔥 UI refresh (important)
      fetchcreatordashboarddetails();
    }
  }

  String formatTimeRange(String? start, String? end) {
    if (start == null || end == null || start.isEmpty || end.isEmpty) return "";

    DateTime startTime;
    DateTime endTime;

    try {
      startTime = DateFormat("HH:mm:ss").parse(start);
    } catch (e) {
      startTime = DateFormat("HH:mm").parse(start);
    }

    try {
      endTime = DateFormat("HH:mm:ss").parse(end);
    } catch (e) {
      endTime = DateFormat("HH:mm").parse(end);
    }

    final formatter = DateFormat("hh:mm a");

    return "${formatter.format(startTime)} - ${formatter.format(endTime)}";
  }
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";

    DateTime parsedDate = DateTime.parse(date);

    return DateFormat("MMM dd, yyyy").format(parsedDate);
  }

  Future<void> fetchShootCategories(String tab) async {
    try {
      final response = await ApiService().fetchData(
        "creator/shoot-categories?tab=$tab",
      );

      if (response["error"] == false) {
        final data = response["data"];

        /// 🔥 tabs data (IMPORTANT)
        final tabs = data["tabs"];

        setState(() {
          photographyShoots = tabs["photo"]["total"] ?? 0;
          videographyShoots = tabs["video"]["total"] ?? 0;

          rejectedPhoto = tabs["photo"]["rejectedShoots"] ?? 0;
          rejectedVideo = tabs["video"]["rejectedShoots"] ?? 0;

          acceptphotographyShoots=tabs["photo"]["acceptedShoots"]??0;
          acceptvideographyShoots=tabs["video"]["acceptedShoots"]??0;


          // ❌ OLD (गलत)
          // requestPhoto = tabs["photo"]["requests"] ?? 0;

          // ✅ NEW (सही)
          requestPhoto = tabs["photo"]["shootRequests"] ?? 0;
          requestVideo = tabs["video"]["shootRequests"] ?? 0;
        });

        /// 🔥 DEBUG (optional)
        debugPrint("Photo Total: ${tabs["photo"]["total"]}");
        debugPrint("Video Total: ${tabs["video"]["total"]}");
      } else {
        debugPrint("API Error: ${response["message"]}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }


  Future<void> fetchCrewStats(String filter) async {
    try {
      final response = CrewStatsModel.fromJson(
        await ApiService().fetchData(ApiEndpoints.crewStats(filter)),
      );

      if (response.error == false) {
        debugPrint("Stats 👉 ${response.message}");

        setState(() {
          sucessfullshoots = response.data.completedShoots;
          pendingshoots = response.data.pendingShoots;
          rejectedshoots = response.data.rejectedShoots;
          shootrequest = response.data.shootRequests;

          photographyShoots = response.data.photographyShoots;
          videographyShoots = response.data.videographyShoots;
        });
      } else {
        debugPrint("API Error::: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error is:::::$e");
    }
  }







  void prepareAvailabilityEvents(Map<String, dynamic> availability) {
    events.clear();
    availability.forEach((dateString, value) {
      final date = DateTime.parse(dateString);
      final cleanDate = DateTime(date.year, date.month, date.day);
      final isAvailable = value["available"] == true;
      final isAssigned = value["projectAssigned"] == true;
      if (isAssigned) {
        events[cleanDate] = "Shoot";
      } else if (isAvailable) {
        events[cleanDate] = "Available";
      }
    });
  }

  Future<void> fetchavailability() async {
    try {
      final response = await ApiService().postData(
        ApiEndpoints.createavailability,
        {
          "month": _focusedDay.month,
          "year": _focusedDay.year
        },
      );
      if (response["error"] == false) {
        final availability = response["data"]["availability"];
        prepareAvailabilityEvents(availability);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error is: $e");
    }
  }


  Future<void> fetchcreatordashboarddetails() async {
    try {
      final response = Creatordashboarddetailsmodel.fromJson(
        await ApiService().fetchData(ApiEndpoints.creatordashboarddetails),
      );

      if (response.error == false) {
        debugPrint("DATA LENGTH 👉 ${response.data.pendingRequestCards.length}");

        setState(() {
          creatordashboarddetaillist = response.data.pendingRequestCards;
        });
      }
    } catch (e) {
      debugPrint("Error is:::::$e");
    }
  }


  Future<void> fetchupcomingshoots() async {
    try {
      final response = Upcomingshootsmodel.fromJson(await ApiService().fetchData(ApiEndpoints.upcomingshoots));

      if (response.error == false) {

        debugPrint('Responsecheck  :: ${response}');
        setState(() {
          upcomingshootslist = response.data;
          // Reset current index if needed
          if (_currentIndex >= upcomingshootslist.length && upcomingshootslist.isNotEmpty) {
            _currentIndex = 0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error is:::::$e");
    }
  }

  Future<void> fetchdashboardcount() async {
    try {
      final response = Dashboardcountmodel.fromJson(await ApiService().fetchData(ApiEndpoints.dashboardcount));
      if (response.error == false) {
        debugPrint('Response is::::::::::::::::: $response');
        setState(() {
          completedshoots = response.data.completedShoots;
          upcomingshoots = response.data.upcomingShoots;
          pendingrequests = response.data.pendingRequests;
        });
      }
    } catch (e) {
      debugPrint("error is::::$e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCrewStats("this_month"); // default
    fetchShootCategories("photo"); // default tab
    fetchavailability();
    fetchcreatordashboarddetails();
    fetchdashboardcount();
    fetchupcomingshoots();
    fetchprofiledata();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && upcomingshootslist.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % upcomingshootslist.length;
        });
        _controller.reset();
      }
    });
  }

  late AnimationController _controller;
  late Animation<Offset> _slideOut;
  int _currentIndex = 0;

  int selectedDashboardIndex = 0;
  bool isExpanded = false;
  int currentIndex = 0;
  String selectedRange = "Month";
  int selectedTab = 0;
  String selectedEvent = "All Events";
  List<String> eventList = ["All Events", "Available", "Shoot"];
  DateTime _focusedDay = DateTime.now();

  String getMonthYear(DateTime date) {
    return "${DateFormat('MMMM yyyy').format(date)}";
  }

  // Helper to convert upcomingdatum to a map for card display
  Map<String, dynamic> _cardFromDatum(upcomingdatum datum) {
    return {
      'image':datum.shootTypeImageUrl,
      'projectId': datum.projectId, // 👈 ye add karo

      'title': datum.projectName,
      'date': DateFormat('MMM dd, yyyy').format(datum.eventDate),
      'time': '${datum.startTime} - ${datum.endTime}',
      'location': datum.eventLocation,
    //  'image': 'assets/home/img.png', // placeholder image
    };
  }

  // Reusable card widget to avoid duplication
  Widget _buildCard(Map<String, dynamic> data,
      {bool isMain = false, bool isBack = false, bool isMiddle = false}) {
    final bgColor = isMain
        ? ColorCode.k282828
        : isMiddle
        ? const Color(0xFF2E2E2E)
        : const Color(0xFF303030);
    final titleColor = isMain || isMiddle ? Colors.white : Colors.white70;
    final dateColor = isMain ? Colors.white70 : Colors.white54;
    final btnOpacity = isMain ? 1.0 : (isMiddle ? 0.8 : 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child:Image.network(
              ApiService().getImageURL(data['image'] ?? ""),
              height: 169,
              width: 117,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("IMAGE ERROR: ${data['image']}");
                return Image.asset(
                  "assets/home/Mask_group.png",
                  height: 169,
                  width: 117,
                  fit: BoxFit.cover,
                );
              },
            )
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
                const SizedBox(height: 6),
                Row(children: [
                  SvgPicture.asset(AppImages.calender, width: 14, height: 14),
                  const SizedBox(width: 5),
                  Text(data['date'], style: TextStyle(fontSize: 12, color: dateColor)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  SvgPicture.asset(AppImages.time, width: 14, height: 14),
                  const SizedBox(width: 5),
                  Text(data['time'], style: TextStyle(fontSize: 12, color: dateColor)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  SvgPicture.asset(AppImages.location, width: 14, height: 14),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      data['location'],
                      style: TextStyle(fontSize: 12, color: dateColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: ColorCode.kButtonColor.withOpacity(btnOpacity),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to details screen (you can pass project ID if needed)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpcomingShootViewDetils(
                                projectid: data['projectId'],
                              ),
                            ),
                          );
                        },
                        child: const Text("View Details",
                            style: TextStyle(color: Colors.black, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 6),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCardTap() {
    if (!_controller.isAnimating && upcomingshootslist.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = creatordashboarddetaillist.isNotEmpty
        ? creatordashboarddetaillist.first
        : null;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: SvgPicture.asset(AppImages.menu,
                            width: 26,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Welcome Back, ${Myprofile_user?.firstName?? 'User..'}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            color: ColorCode.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SvgPicture.asset(
                        AppImages.notificationbell,
                        width: 22,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 15),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Myprofile(),
                              ),
                            );
                          },
                          child:CircleAvatar(
                            radius: 20,
                            backgroundImage: (Myprofile_user?.user.profileImageUrl ?? "").isNotEmpty
                                ? NetworkImage(
                              "${ApiService.imageURL}${Myprofile_user!.user.profileImageUrl}",
                            )
                                : null, // 🔥 important

                            child: (Myprofile_user?.user.profileImageUrl ?? "").isEmpty
                                ? SvgPicture.asset(
                              AppImages.User_Circle,
                              width: 20,
                              height: 20,
                            )
                                : null,
                          )
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
            ),
          ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xff014FFFFFF),
              width: 0.5,//
            ),
            color: ColorCode.k282828,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              _dashboardCard(
                index: 0,
                title: "Completed Shoots",
                count: completedshoots,
                // percent: "+3% from last month",
                percentColor: Colors.green,
                iconPath: "assets/images/svideo.png",
              ),
              const SizedBox(height: 18),
              _dashboardCard(
                index: 1,
                title: "Upcoming Shoots",
                count: upcomingshoots,
                // percent: "+3% from last month",
                percentColor: Colors.green,
                iconPath: "assets/images/scalender.png",
              ),
              const SizedBox(height: 18),
              _dashboardCard(
                index: 2,
                title: "Pending Requests",
                count: pendingrequests,
                // percent: "-2% from last month",
                percentColor: Colors.red,
                iconPath: "assets/images/stime.png",
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Divider(color: ColorCode.kDividerWhite12),
        SizedBox(height: 10),
        Row(
          children: [
            Text("Upcoming Shoots ",

              style: TextStyle(
                fontSize: 14,
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                color: ColorCode.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    contentPadding: EdgeInsetsGeometry.symmetric(vertical: 12, horizontal: 0),
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
            InkWell(
              onTap: () {
                _showFilterBottomSheet();
              },
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
                    SvgPicture.asset(AppImages.filter,
                      height: 18,
                      width: 18,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 55),

        // ==================== UPCOMING SHOOTS CARD STACK (DYNAMIC) ====================
        if (upcomingshootslist.isEmpty)
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorCode.k282828,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          "No upcoming shoots",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    )
    else
    GestureDetector(
    onTap: _onCardTap,
    child: LayoutBuilder(
    builder: (context, constraints) {
    final n = upcomingshootslist.length;
    final totalWidth = constraints.maxWidth;

    final currentDatum = upcomingshootslist[_currentIndex % n];
    final nextDatum = upcomingshootslist[(_currentIndex + 1) % n];
    final next2Datum = n > 2 ? upcomingshootslist[(_currentIndex + 2) % n] : null;

    final current = _cardFromDatum(currentDatum);
    final next = _cardFromDatum(nextDatum);
    final next2 = next2Datum != null ? _cardFromDatum(next2Datum) : null;

    return Stack(
    clipBehavior: Clip.none,
    children: [
    // Third card (back most) – only if n >= 3
    if (next2 != null)
    AnimatedPositioned(
    duration: const Duration(milliseconds: 300),
    top: _controller.isAnimating ? -32 : -24,
    left: totalWidth * 0.07,
    right: totalWidth * 0.07,
    child: AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: _controller.isAnimating ? 0.5 : 1,
    child: _buildCard(next2, isBack: true),
    ),
    ),

    // Second card (middle) – only if n >= 2
    if (n >= 2)
    AnimatedPositioned(
    duration: const Duration(milliseconds: 300),
    top: _controller.isAnimating ? -20 : -12,
    left: totalWidth * 0.035,
    right: totalWidth * 0.035,
    child: AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: _controller.isAnimating ? 0.7 : 1,
    child: _buildCard(next, isBack: true, isMiddle: true),
    ),
    ),

    // Main card
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
    child: _buildCard(current, isMain: true),
    ),
    ],
    );
    },
    ),
    ),
    // ========================================================================

    const SizedBox(height: 17),
    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
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
    ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
    backgroundColor: ColorCode.kButtonColor,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    ),
    ),
    onPressed: () async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddAvailabilityScreen()));
    if (result == true) {
    fetchavailability();
    }
    },
    icon: const Icon(Icons.add, size: 18, color: ColorCode.black),
    label: const Text(
    "Add",
    style: TextStyle(
    fontFamily: "Outfit",
    color: ColorCode.black,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 12),
    Container(
    decoration: BoxDecoration(
    color: ColorCode.k282828,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(width: 0.5, color: Color(0xff626262)),
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    IconButton(
    icon: const Icon(Icons.chevron_left, color: Colors.white),
    onPressed: () {
    setState(() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
    },
    ),
    Text(
    getMonthYear(_focusedDay),
    style: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    ),
    ),
    IconButton(
    icon: const Icon(Icons.chevron_right, color: Colors.white),
    onPressed: () {
    setState(() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
    },
    ),
    ],
    ),
    Container(
    margin: EdgeInsets.all(6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
    color: ColorCode.white,
    borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
    value: selectedEvent,
    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
    dropdownColor: Colors.white,
    style: const TextStyle(color: Colors.black, fontSize: 12),
    items: eventList.map((String value) {
    return DropdownMenuItem(
    value: value,
    child: Text(value),
    );
    }).toList(),
    onChanged: (value) {
    setState(() {
    selectedEvent = value!;
    });
    },
    ),
    ),
    )
    ],
    ),
    const SizedBox(height: 10),
    TableCalendar(
    daysOfWeekHeight: 70,
    calendarBuilders: CalendarBuilders(
    dowBuilder: (context, day) {
    final text = DateFormat.E().format(day);
    return Container(
    height: 45,
    alignment: Alignment.center,
    decoration: BoxDecoration(
    border: Border(
    bottom: BorderSide(
    color: ColorCode.kDividerWhite12,
    width: 1,
    ),
    ),
    ),
    child: Text(
    text,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    ),
    ),
    );
    },
    defaultBuilder: (context, day, focusedDay) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final event = events[dateKey];
    bool showEvent = false;
    if (selectedEvent == "All Events") {
    showEvent = true;
    } else if (selectedEvent == "Available" && event == "Available") {
    showEvent = true;
    } else if (selectedEvent == "Shoot" && event == "Shoot") {
    showEvent = true;
    }
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text("${day.day}", style: const TextStyle(color: Colors.white)),
    const SizedBox(height: 4),
    if (event != null && showEvent) eventLabel(event),
    ],
    );
    },
    ),
    firstDay: DateTime(2020),
    lastDay: DateTime(2050),
    focusedDay: _focusedDay,
    headerVisible: false,
    rowHeight: 85,
    calendarStyle: CalendarStyle(
    tableBorder: TableBorder.all(
    color: ColorCode.kDividerWhite12,
    width: 1,
    ),
    defaultTextStyle: const TextStyle(color: Colors.white),
    weekendTextStyle: const TextStyle(color: Colors.white),
    outsideTextStyle: const TextStyle(color: Colors.white38),
    ),
    daysOfWeekStyle: const DaysOfWeekStyle(
    weekdayStyle: TextStyle(color: Colors.white70),
    weekendStyle: TextStyle(color: Colors.white70),
    ),
    onPageChanged: (focusedDay) {
    setState(() {
    _focusedDay = focusedDay;
    fetchavailability();
    });
    },
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 12),
    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
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
    InkWell(
    /*   onTap: () {
                        widget.onTabChange?.call(1); // 👈 Shoots tab
                      },*/
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
    Stack(
    children: [
    ClipRRect(
    borderRadius: const BorderRadius.vertical(
    top: Radius.circular(22),
    ),
    child:Image.network(
      ApiService().getImageURL(data?.shootTypeImageUrl ?? ""),
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,



      /// error fallback
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/home/img.png",
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    )
    ),
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
    Positioned(
    top: 14,
    left: 14,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    Positioned(
    bottom: 14,
    left: 14,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
    color: const Color(0xffC8F5D3),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    children:  [
    Icon(Icons.check_circle, size: 14, color: Colors.green),
    SizedBox(width: 6),
    Text(
    data?.status ?? "",
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
    Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Expanded(
    child: Text(
    data?.projectName ?? "",
    style: TextStyle(
    fontFamily: "Outfit",
    color: ColorCode.white,//
    fontSize: 15,
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    SizedBox(width: 8),
    GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context) => UpcomingShootViewDetils(
    projectid: data?.projectId ?? 0,
    ))),
    child: Text(
    "View Details",
    style: TextStyle(
    fontFamily: "Outfit",
    fontWeight: FontWeight.w600,
    color: ColorCode.kButtonColor,
    fontSize: 12,
    decoration: TextDecoration.underline,
    ),
    ),
    ),
    ],
    ),
    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
    const SizedBox(height: 12),
    Wrap(
    spacing: 14,
    runSpacing: 8,
    children:  [
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.calendar_today, size: 14, color: Colors.white70),
    SizedBox(width: 6),
    Text(
    formatDate(data?.eventDate.toString()),
    style: TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: "Outfit",
    color: ColorCode.kWhiteOpacity70,
    fontSize: 10),
    ),
    ],
    ),
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.access_time, size: 14, color: Colors.white70),
    SizedBox(width: 6),
    Text(
    formatTimeRange(
    data?.startTime,
    data?.endTime,
    ),
    style: TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: "Outfit",
    color: ColorCode.kWhiteOpacity70,
    fontSize: 10),
    ),
    ],
    ),
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.location_on, size: 14, color: Colors.white70),
    SizedBox(width: 6),
    Text(
    data?.eventLocation ?? "",
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: "Outfit",
    color: ColorCode.kWhiteOpacity70,
    fontSize: 10,
    ),
    )
    ],
    ),
    ],
    ),
    const SizedBox(height: 18),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

    /// ✅ LEFT SIDE (Avatar Stack)
    // _buildAvatarStack(
    // images: [
    // AppImages.avtarstack,
    // AppImages.avtarstack,
    // AppImages.avtarstack,
    // AppImages.avtarstack,
    // ],
    // extraCount: 3,
    // avatarSize: 20,
    // overlap: 10,
    // ),
      SizedBox(),

    /// ✅ RIGHT SIDE (Your SAME Buttons - untouched)
    Row(
    children: [
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xffD8FDE6),
    ),
    onPressed: () {
    if (data != null) {
    fetchacceptdecline(data!.projectId, 1);
    }
    },
    child: const Text(
    "Accept",
    style: TextStyle(
    color: Color(0xff1DAA23),
    ),
    ),
    ),
    const SizedBox(width: 10),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xffEECCC9),
    ),
    onPressed: () {
    if (data != null) {
    fetchacceptdecline(data!.projectId, 2);
    }
    },
    child: const Text(
    "Decline",
    style: TextStyle(
    color: Color(0xffD33732),
    ),
    ),
    ),
    ],
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
    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
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
    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
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

    // 👇 yaha lagao
    fetchCrewStats(getFilterValue());

    },
    ),
    ),
    )
    ],
    ),
    const SizedBox(height: 35),
    Center(
    child: SizedBox(
    height: 160,
    width: 300,
    child: Stack(
    alignment: Alignment.bottomCenter,
    children: [
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
    Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Text(
    "${sucessfullshoots+pendingshoots+rejectedshoots+shootrequest}",
    style: const TextStyle(
    color: Color(0xFFE8D7B9),
    fontSize: 26,
    fontWeight: FontWeight.bold,
    fontFamily: "Outfit",
    ),
    ),
    const SizedBox(height: 4),
    ],
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 35),
    _statusItem("${sucessfullshoots}", "Successful Shoots", const Color(0xFFA678F1)),
    _statusItem("${pendingshoots}", "Pending Shoots", const Color(0xFF5CC4FF)),
    _statusItem("${rejectedshoots}", "Rejected Shoots", const Color(0xFFFFC04F)),
    _statusItem("${shootrequest}", "Shoot Requests", const Color(0xFF2DC497)),
    ],
    ),
    ),
    const SizedBox(height: 14),
    Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
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
    GestureDetector(
    onTap: () {
    setState(() {
    selectedTab = 0;

    });
    fetchShootCategories("photo"); // 🔥 ADD
    },
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
    color: selectedTab == 0
    ? const Color(0xFFE8D7B9)
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
    GestureDetector(
    onTap: () {
    setState(() {
    selectedTab = 1;
    });
    fetchShootCategories("video"); // 🔥 ADD
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
                    Center(
                      child: SizedBox(
                        height: 160,
                        width: 300,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedTab == 0?
                                  photographyShoots.toString()
                                      :videographyShoots.toString(),
                                  //      Text(
                                  //                                     selectedTab == 0?
                                  //                                     acceptphotographyShoots.toString()
                                  //                                     :.toString(),

                                  style: const TextStyle(
                                    color: Color(0xFFE8D7B9),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    selectedTab == 0
                        ? _statusItem("$acceptphotographyShoots", "Photography Shoots", const Color(0xFFA678F1))
                        : _statusItem("$acceptvideographyShoots", "Videography Shoots", const Color(0xFF5CC4FF)),

                    _statusItem(
                      selectedTab == 0
                          ? "$rejectedPhoto"
                          : "$rejectedVideo",
                      "Rejected Shoots",
                      const Color(0xFFFFC04F),
                    ),

                    _statusItem(
                      selectedTab == 0
                          ? "$requestPhoto"
                          : "$requestVideo",
                      "Shoot Requests",
                      const Color(0xFF2DC497),
                    ),

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

  Widget eventLabel(String event) {
    final isAvailable = event == "Available";
    return Container(
      width: double.infinity,
      margin: EdgeInsetsGeometry.all(3),
      padding: EdgeInsetsGeometry.all(3),
      decoration: BoxDecoration(
        color: isAvailable
            ? const Color(0xFFD8FDE6)
            : const Color(0xFFE0E7F8),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        textAlign: TextAlign.center,
        event,
        style: TextStyle(
          color: isAvailable
              ? const Color(0xFF1DAA23)
              : const Color(0xFF2D66D2),
          fontSize: 7.79,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    String? selectedDate;
    String? selectedStatus;
    String? selectedCategory;
    String? selectedType;

    bool isDateExpanded = true;
    bool isStatusExpanded = false;
    bool isCategoryExpanded = false;
    bool isTypeExpanded = false;

    final DraggableScrollableController sheetController = DraggableScrollableController();

    final List<String> dateOptions = [
      "Today", "This Week", "Marketing Analytics", "This Month", "Custom Range"
    ];
    final List<String> statusOptions = [
      "Upcoming", "Active", "Completed", "Cancelled"
    ];
    final List<String> categoryOptions = [];
    final List<String> typeOptions = [
      "All", "Shoots", "Rental",
    ];

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              controller: sheetController,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return GestureDetector(
                  onVerticalDragUpdate: (details) {
                    final currentSize = sheetController.size;
                    final newSize = currentSize - (details.delta.dy / MediaQuery.of(context).size.height);
                    sheetController.jumpTo(newSize.clamp(0.4, 0.95));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff282828),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Filter",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: "Unbounded",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          thickness: 0.5,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification &&
                                  notification.scrollDelta != null &&
                                  notification.scrollDelta! < 0) {
                                if (sheetController.size < 0.95) {
                                  sheetController.animateTo(
                                    0.95,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  _filterSection(
                                    showDivider: true,
                                    title: "Filter By Date",
                                    isExpanded: isDateExpanded,
                                    onTap: () => setState(() {
                                      isDateExpanded = !isDateExpanded;
                                      if (isDateExpanded) {
                                        sheetController.animateTo(
                                          0.95,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isDateExpanded
                                        ? dateOptions.map((label) => _radioOption(
                                      label: label,
                                      selected: selectedDate == label,
                                      onTap: () => setState(() => selectedDate = label),
                                    )).toList()
                                        : [],
                                  ),
                                  _filterSection(
                                    showDivider: true,
                                    title: "Filter By Status",
                                    isExpanded: isStatusExpanded,
                                    onTap: () => setState(() {
                                      isStatusExpanded = !isStatusExpanded;
                                      if (isStatusExpanded) {
                                        sheetController.animateTo(
                                          0.95,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isStatusExpanded
                                        ? statusOptions.map((label) => _radioOption(
                                      label: label,
                                      selected: selectedStatus == label,
                                      onTap: () => setState(() => selectedStatus = label),
                                    )).toList()
                                        : [],
                                  ),
                                  _filterSection(
                                    showDivider: false,
                                    title: "Filter By Category",
                                    isExpanded: isCategoryExpanded,
                                    onTap: () => setState(() {
                                      isCategoryExpanded = !isCategoryExpanded;
                                      if (isCategoryExpanded) {
                                        sheetController.animateTo(
                                          0.95,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isCategoryExpanded
                                        ? categoryOptions.map((label) => _radioOption(
                                      label: label,
                                      selected: selectedCategory == label,
                                      onTap: () => setState(() => selectedCategory = label),
                                    )).toList()
                                        : [],
                                  ),
                                  _filterSection(
                                    showDivider: false,
                                    title: "Filter By Type",
                                    isExpanded: isTypeExpanded,
                                    onTap: () => setState(() {
                                      isTypeExpanded = !isTypeExpanded;
                                      if (isTypeExpanded) {
                                        sheetController.animateTo(
                                          0.95,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isTypeExpanded
                                        ? typeOptions.map((label) => _radioOption(
                                      label: label,
                                      selected: selectedType == label,
                                      onTap: () => setState(() => selectedType = label),
                                    )).toList()
                                        : [],
                                  ),
                                  const SizedBox(height: 13),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedType = '';
                                              selectedCategory = '';
                                              selectedStatus = '';
                                              selectedDate = '';
                                              isDateExpanded = false;
                                              isStatusExpanded = false;
                                              isCategoryExpanded = false;
                                              isTypeExpanded = false;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                width: 0.5,
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Clear All',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Unbounded',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffE8D1AB),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                width: 0.5,
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Apply',
                                                style: TextStyle(
                                                  fontFamily: 'Unbounded',
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff1D1D1B),
                                                ),
                                              ),
                                            ),
                                          ),
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
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarStack({
    required List<String> images,
    int extraCount = 0,
    double avatarSize = 20,
    double overlap = 10,
  }) {
    final int totalItems = images.length + (extraCount > 0 ? 1 : 0);
    final double totalWidth = avatarSize + (totalItems - 1) * overlap;
    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...List.generate(images.length, (index) {
            return Positioned(
              left: index * overlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: ClipOval(
                  child: Image.asset(
                    images[index],
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
          if (extraCount > 0)
            Positioned(
              left: images.length * overlap,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    "+$extraCount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: avatarSize * 0.35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
    bool showDivider = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(size: 30,
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            isExpanded && showDivider
                ? Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            )
                : SizedBox(),
            if (children.isNotEmpty) ...children,
            if (children.isNotEmpty) const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _radioOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xffDDDDDD) : Colors.white38,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8D1AB),
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required int index,
    required String title,
    required int count,
    // required String percent,
    required Color percentColor,
    required String iconPath,
  }) {
    bool isSelected = selectedDashboardIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDashboardIndex = index;
        });
      },
      //  borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ColorCode.kButtonColor : Colors.transparent,
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
                  count.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                /*     Text(
                  percent,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.green : percentColor,
                  ),
                ),*/
              ],
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: isSelected ? Colors.black : const Color(0xff171717),
              child: Image.asset(iconPath,width: 18,height: 18,),
              // child: SvgPicture.asset(
              //   iconPath,
              //   width: 16,
              //   height: 16,
              //   color: isSelected ? Colors.white : Colors.white70,
              // ),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.white, size: 18),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "16 Jun, 2024",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "10:00 PM to 13:00 PM",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
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