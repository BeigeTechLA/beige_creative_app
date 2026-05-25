import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../model_class/create_dashboard_details_model.dart';
import '../Model_Class/crewstatus_model.dart';
import '../Model_Class/dashboard_count_model.dart';
import '../Model_Class/upcoming_shoots_model.dart';
import '../Model_Class/myprofile_model.dart' as profile;

import '../Model_Class/myprofile_model.dart';

import '../app/route_names.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/shadows.dart';
import '../widgets/common_calendar.dart';
import '../widgets/date_time.dart';
import '../widgets/multi_arc_painter.dart';

class HomeScreen extends StatefulWidget {
  // final Function(int)? onTabChange;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int rejectedPhoto = 0;
  int rejectedVideo = 0;
  int requestPhoto = 0;
  int requestVideo = 0;

  String name = "";
  String email = "";
  String image = "";
  profile.Data? Myprofile_user;

  int photographyShoots = 0;
  int videographyShoots = 0;

  int acceptphotographyShoots = 0;
  int acceptvideographyShoots = 0;

  int categoryPhotoTotal = 0;
  int categoryVideoTotal = 0;

  int sucessfullshoots = 0;
  int pendingshoots = 0;
  int rejectedshoots = 0;
  int shootrequest = 0;

  int completedshoots = 0;
  int upcomingshoots = 0;
  int pendingrequests = 0;

  String getFilterValue() {
    if (selectedRange == "Week") {
      return "this_week";
    } else if (selectedRange == "Month") {
      return "this_month";
    } else {
      return "this_year";
    }
  }

  bool isloading = true;
  /*  Data? Myprofile_user;*/
  List<upcomingdatum> upcomingshootslist = [];
  List<PendingRequestCard> creatordashboarddetaillist = [];
  Map<DateTime, String> events = {};

  Future<void> fetchprofiledata() async {
    try {
      setState(() {
        isloading = true;
      });

      final rawResponse = await ApiService().postData(
        ApiEndpoints.profiledetails,
        {},
      );

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
      {"project_id": projectid, "crew_accept": crewid},
    );

    if (response["error"] == false) {
      debugPrint("Accept/Decline Success");

      /// 🔥 UI refresh (important)
      fetchcreatordashboarddetails();
      fetchdashboardcount();
    }
  }

  Future<void> fetchShootCategories(String tab) async {
    try {
      final response = await ApiService().fetchData(
        "creator/shoot-categories?tab=$tab",
      );

      if (response["error"] == false) {
        final data = response["data"];
        final tabs = data["tabs"];

        setState(() {
          // ✅ Photo data
          categoryPhotoTotal = tabs["photo"]?["total"] ?? 0;
          acceptphotographyShoots = tabs["photo"]?["acceptedShoots"] ?? 0;
          rejectedPhoto = tabs["photo"]?["rejectedShoots"] ?? 0;
          requestPhoto = tabs["photo"]?["shootRequests"] ?? 0;

          // ✅ Video data
          categoryVideoTotal = tabs["video"]?["total"] ?? 0;
          acceptvideographyShoots = tabs["video"]?["acceptedShoots"] ?? 0;
          rejectedVideo = tabs["video"]?["rejectedShoots"] ?? 0;
          requestVideo = tabs["video"]?["shootRequests"] ?? 0;
        });

        debugPrint(
          "Photo Total: $categoryPhotoTotal | Video Total: $categoryVideoTotal",
        );
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

  Future<void> fetchavailability() async {
    try {
      final response = await ApiService().postData(
        ApiEndpoints.createavailability,
        {"month": _focusedDay.month, "year": _focusedDay.year},
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
        /// 👇 debug check
        for (var item in response.data.shoots) {
          debugPrint(
            "STATUS ::: ${item.status} | PROJECT ::: ${item.projectName}",
          );
        }

        setState(() {
          creatordashboarddetaillist = response.data.shoots
              .where(
                (e) => e.status.toString().trim().toLowerCase().contains(
                  "pending",
                ),
              )
              .toList();
        });

        debugPrint("✅ Pending Count ::: ${creatordashboarddetaillist.length}");
      }
    } catch (e) {
      debugPrint("ERROR ::: $e");
    }
  }

  Future<void> fetchupcomingshoots() async {
    try {
      final response = Upcomingshootsmodel.fromJson(
        await ApiService().fetchData(ApiEndpoints.upcomingshoots),
      );

      if (response.error == false) {
        debugPrint('Responsecheck  :: $response');
        setState(() {
          upcomingshootslist = response.data;
          // Reset current index if needed
          if (_currentIndex >= upcomingshootslist.length &&
              upcomingshootslist.isNotEmpty) {
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
      final response = Dashboardcountmodel.fromJson(
        await ApiService().fetchData(ApiEndpoints.dashboardcount),
      );
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCrewStats("this_month");
    fetchShootCategories("photo");

    fetchavailability();
    fetchcreatordashboarddetails();
    fetchdashboardcount();
    fetchupcomingshoots();
    fetchprofiledata();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          upcomingshootslist.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % upcomingshootslist.length;
        });
        _controller.reset();
      }
    });
  }

  late AnimationController _controller;
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
    return DateFormat('MMMM yyyy').format(date);
  }

  // Helper to convert upcomingdatum to a map for card display
  Map<String, dynamic> _cardFromDatum(upcomingdatum datum) {
    return {
      'image': datum.shootTypeImageUrl,
      'projectId': datum.projectId, // 👈 ye add karo

      'title': datum.projectName,
      'date': DateFormat('MMM dd, yyyy').format(datum.eventDate),
      'time': '${datum.startTime} - ${datum.endTime}',
      'location': datum.eventLocation,
    };
  }

  // Reusable card widget to avoid duplication
  Widget _buildCard(
    Map<String, dynamic> data, {
    bool isMain = false,
    bool isBack = false,
    bool isMiddle = false,
  }) {
    final bgColor = isMain
        ? AppColors.surfaceMid
        : isMiddle
        ? AppColors.surfaceDim
        : AppColors.surfaceMute;
    /* final titleColor = isMain || isMiddle ? AppColors.white : AppColors.white30;
    final dateColor = isMain ? AppColors.white30 : AppColors.white24;
    final btnOpacity = isMain ? 1.0 : (isMiddle ? 0.8 : 0.7);*/

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: AppColors.white.withOpacity(0.08)),
        borderRadius: AppRadii.xxxlAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: Image.network(
              ApiService().getImageURL(data['image'] ?? ""),
              height: 169,
              width: 117,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("IMAGE ERROR: ${data['image']}");
                return SvgPicture.asset(
                  AppAssets.image_holder, // 👈 your svg path
                  height: 169,
                  width: 117,
                  fit: BoxFit.cover,
                );
              },
            ),
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
                    color: AppColors.white,
                  ),
                ),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.calender, width: 14, height: 14),
                    const SizedBox(width: 5),
                    Text(
                      data['date'],
                      style: TextStyle(fontSize: 12, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.time, width: 14, height: 14),
                    const SizedBox(width: 5),
                    Text(
                      data['time'],
                      style: TextStyle(fontSize: 12, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.location, width: 14, height: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        data['location'],
                        style: TextStyle(fontSize: 12, color: AppColors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.hugeAll,
                          ),
                        ),
                        onPressed: () {
                          // Navigate to details screen (you can pass project ID if needed)
                          context.pushNamed(
                            RouteNames.upcomingShootDetails,
                            extra: {"projectId": data['projectId']},
                          );
                        },
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 11,
                          ),
                        ),
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

  void _goToNext() {
    if (!_controller.isAnimating && upcomingshootslist.isNotEmpty) {
      _controller.forward();
    }
  }

  void _goToPrevious() {
    if (!_controller.isAnimating && upcomingshootslist.isNotEmpty) {
      setState(() {
        _currentIndex =
            (_currentIndex - 1 + upcomingshootslist.length) %
            upcomingshootslist.length;
      });
    }
  }

  void _onCardTap() {
    if (!_controller.isAnimating && upcomingshootslist.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      sucessfullshoots,
      pendingshoots,
      rejectedshoots,
      shootrequest,
    ];

    final total = stats.fold(0, (sum, item) => sum + item);

    final arcValues = stats.map((e) {
      if (e == 0 || total == 0) {
        return 0.0;
      }

      return (e / total).clamp(0.0, 1.0);
    }).toList();

    final categoryStats = [
      selectedTab == 0 ? acceptphotographyShoots : acceptvideographyShoots,

      selectedTab == 0 ? 0 : acceptvideographyShoots,

      selectedTab == 0 ? rejectedPhoto : rejectedVideo,

      selectedTab == 0 ? requestPhoto : requestVideo,
    ];

    final categoryTotal = categoryStats.fold(0, (sum, item) => sum + item);

    final categoryArcValues = categoryStats.map((e) {
      if (e == 0 || categoryTotal == 0) {
        return 0.0;
      }

      return (e / categoryTotal).clamp(0.0, 1.0);
    }).toList();

    final data = creatordashboarddetaillist.isNotEmpty
        ? creatordashboarddetaillist.first
        : null;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), //

      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMid,
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
                            child: SvgPicture.asset(
                              AppAssets.menu,
                              width: 26,
                              colorFilter: ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Welcome Back, ${Myprofile_user?.firstName ?? 'User..'}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        SvgPicture.asset(
                          AppAssets.notificationbell,
                          width: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 15),
                        InkWell(
                          onTap: () async {
                            /*    final result = await Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (_) => Myprofile(),
                                   ),
                                 );

                                 if (result == true) {
                                   fetchprofiledata(); // 🔥 API call again
                                 }*/
                            context.pushNamed(RouteNames.myProfile).then((
                              value,
                            ) {
                              if (value == true) {
                                fetchprofiledata();
                              }
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                (Myprofile_user?.profileImageUrl ?? "")
                                    .isNotEmpty
                                ? NetworkImage(
                                    "${ApiService.imageURL}${Myprofile_user!.profileImageUrl}",
                                  )
                                : null,

                            child:
                                (Myprofile_user?.profileImageUrl ?? "").isEmpty
                                ? SvgPicture.asset(
                                    AppAssets.User_Circle,
                                    width: 20,
                                    height: 20,
                                  )
                                : null,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Your Dashboard",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.darkCharcoal,
                      width: 0.6,
                    ),
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.portfolioCompactAll,
                  ),
                  child: Column(
                    children: [
                      _dashboardCard(
                        index: 0,
                        title: "Completed shoots",
                        count: completedshoots,
                        // percent: "+3% from last month",
                        percentColor: AppColors.success,
                        iconPath: AppAssets.video_icon,
                      ),
                      const SizedBox(height: 12),
                      _dashboardCard(
                        index: 1,
                        title: "Upcoming shoots",
                        count: upcomingshoots,
                        // percent: "+3% from last month",
                        percentColor: AppColors.success,
                        iconPath: AppAssets.calendar_icon,
                      ),
                      const SizedBox(height: 12),
                      _dashboardCard(
                        index: 2,
                        title: "Pending Requests",
                        count: pendingrequests,
                        // percent: "-2% from last month",
                        percentColor: AppColors.error,
                        iconPath: AppAssets.clock_icon,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14),
                Divider(color: AppColors.dividerDark),
                SizedBox(height: 14),
                if (upcomingshootslist.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        "Upcoming Shoots ",

                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  /*    const SizedBox(),*/

                  /*  Row(
                     children: [
                       Text("Upcoming Shoots ",

                         style: TextStyle(
                           fontSize: 14,
                           fontFamily: "Unbounded",
                           fontWeight: FontWeight.w500,
                           color: AppColors.white,
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
                             color: AppColors.transparent,
                             borderRadius: AppRadii.lgAll,
                             border: Border.all(
                               color: AppColors.white30,
                               width: 1,
                             ),
                           ),
                           child: TextField(
                             style: TextStyle(color: AppColors.white),
                             decoration: InputDecoration(
                               prefixIcon: Padding(
                                 padding: const EdgeInsets.all(10), // control spacing
                                 child: SvgPicture.asset(
                                   AppAssets.search_icon,
                                   height: 20,   // now this will work
                                   width: 20,
                                 ),
                               ),
                               prefixIconConstraints: const BoxConstraints(
                                 minWidth: 30,
                                 minHeight: 30,
                               ),
                               hintText: "Search events or crew...",
                               hintStyle: TextStyle(
                                 fontFamily: "Outfit",
                                 color: AppColors.white30,
                                 fontSize: 12,
                               ),
                               border: InputBorder.none,
                             ),
                           )
                         ),
                       ),
                       const SizedBox(width: 12),
                       InkWell(
                         onTap: () {
                           _showFilterBottomSheet();
                         },
                         borderRadius: AppRadii.lgAll,
                         child: Container(
                           height: 52,
                           padding: const EdgeInsets.symmetric(horizontal: 18),
                           decoration: BoxDecoration(
                             color: AppColors.transparent,
                             borderRadius: AppRadii.lgAll,
                             border: Border.all(
                               color: AppColors.white24,
                               width: 1,
                             ),
                           ),
                           child: Row(
                             children: [
                               const Text(
                                 "Filter",
                                 style: TextStyle(
                                   color: AppColors.white,
                                   fontSize: 14,
                                 ),
                               ),
                               const SizedBox(width: 6),
                               SvgPicture.asset(AppAssets.filter,
                                 height: 18,
                                 width: 18,
                               )
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 55),*/

                  /*  // ==================== UPCOMING SHOOTS CARD STACK (DYNAMIC) ====================
                   if (upcomingshootslist.isEmpty)
                     Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: AppColors.surfaceMid,
                         borderRadius: AppRadii.xxxlAll,
                       ),
                       child: const Center(
                         child: Text(
                           "No upcoming shoots",
                           style: TextStyle(color: AppColors.white70),
                         ),
                       ),
                     )
                   else
                     GestureDetector(
                       onTap: _onCardTap,
                       onHorizontalDragEnd: (details) {
                         if (details.primaryVelocity == null) return;

                         // 👉 Swipe Right (previous)
                         if (details.primaryVelocity! > 0) {
                           _goToPrevious();
                         }

                         // 👉 Swipe Left (next)
                         else if (details.primaryVelocity! < 0) {
                           _goToNext();
                         }
                       },
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
       */
                  // ==================== UPCOMING SHOOTS CARD STACK (DYNAMIC) ====================
                  Builder(
                    builder: (context) {
                      final n = upcomingshootslist.length;

                      // ✅ 👉 ONLY 1 DATA → NO SWIPE, NO STACK
                      if (n == 1) {
                        final current = _cardFromDatum(upcomingshootslist[0]);
                        return _buildCard(current, isMain: true);
                      }

                      // ✅ 👉 MULTIPLE DATA → SWIPE + STACK
                      return GestureDetector(
                        onTap: _onCardTap,
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;

                          if (details.primaryVelocity! > 0) {
                            _goToPrevious();
                          } else if (details.primaryVelocity! < 0) {
                            _goToNext();
                          }
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;

                            final currentDatum =
                                upcomingshootslist[_currentIndex % n];
                            final nextDatum =
                                upcomingshootslist[(_currentIndex + 1) % n];
                            final next2Datum = n > 2
                                ? upcomingshootslist[(_currentIndex + 2) % n]
                                : null;

                            final current = _cardFromDatum(currentDatum);
                            final next = _cardFromDatum(nextDatum);
                            final next2 = next2Datum != null
                                ? _cardFromDatum(next2Datum)
                                : null;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // 👉 3rd card
                                if (next2 != null)
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    top: _controller.isAnimating ? -32 : -24,
                                    left: totalWidth * 0.07,
                                    right: totalWidth * 0.07,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      opacity: _controller.isAnimating
                                          ? 0.5
                                          : 1,
                                      child: _buildCard(next2, isBack: true),
                                    ),
                                  ),

                                // 👉 2nd card
                                if (n >= 2)
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    top: _controller.isAnimating ? -20 : -12,
                                    left: totalWidth * 0.035,
                                    right: totalWidth * 0.035,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      opacity: _controller.isAnimating
                                          ? 0.7
                                          : 1,
                                      child: _buildCard(
                                        next,
                                        isBack: true,
                                        isMiddle: true,
                                      ),
                                    ),
                                  ),

                                // 👉 MAIN CARD
                                AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        _controller.value * 200,
                                      ),
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
                      );
                    },
                  ),
                  const SizedBox(height: 17),
                  Divider(color: AppColors.dividerDark, thickness: 0.8),
                ],

                // ========================================================================
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Availability",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.roundAll,
                        ),
                      ),

                      /*   onPressed: () async {
                           final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddAvailabilityScreen()));
                           if (result == true) {
                             fetchavailability();
                           }
                         },*/
                      onPressed: () {
                        context.pushNamed(RouteNames.addAvailability).then((
                          value,
                        ) {
                          if (value == true) {
                            fetchavailability();
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.black,
                      ),
                      label: const Text(
                        "Add",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          color: AppColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                /*Container(
                     decoration: BoxDecoration(
                       color: AppColors.surfaceMid,
                       borderRadius: AppRadii.hugeAll,
                       border: Border.all(width: 0.5, color: AppColors.greyMid),
                     ),
                     child: ClipRRect(
                       borderRadius: AppRadii.hugeAll,
                       child: Column(
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Row(
                                 children: [
                                   IconButton(
                                     icon: const Icon(Icons.chevron_left, color: AppColors.white),
                                     onPressed: () {
                                       setState(() {
                                         _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                                       });
                                     },
                                   ),
                                   Text(
                                     getMonthYear(_focusedDay),
                                     style: const TextStyle(
                                       color: AppColors.white,
                                       fontSize: 18,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                                   IconButton(
                                     icon: const Icon(Icons.chevron_right, color: AppColors.white),
                                     onPressed: () {
                                       setState(() {
                                         _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                                       });
                                     },
                                   ),
                                 ],
                               ),
                               Container(
                                 margin: EdgeInsets.all(7),
                                 padding: const EdgeInsets.symmetric(horizontal: 19,),
                                 decoration: BoxDecoration(
                                   color: AppColors.white,
                                   borderRadius: AppRadii.smAll,
                                 ),
                                 child: DropdownButtonHideUnderline(
                                   child: DropdownButton<String>(
                                     value: selectedEvent,
                                     icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.black),
                                     dropdownColor: AppColors.white,
                                     style: const TextStyle(color: AppColors.black, fontSize: 12),
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
                      */
                /*     TableCalendar(
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
                                         color: AppColors.dividerDark,
                                         width: 1,
                                       ),
                                     ),
                                   ),
                                   child: Text(
                                     text,
                                     style: const TextStyle(
                                       color: AppColors.white,
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
                                     Text("${day.day}", style: const TextStyle(color: AppColors.white)),
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
                                 color: AppColors.dividerDark,
                                 width: 1,
                               ),
                               defaultTextStyle: const TextStyle(color: AppColors.white),
                               weekendTextStyle: const TextStyle(color: AppColors.white),
                               outsideTextStyle: const TextStyle(color: AppColors.white38),
                             ),
                             daysOfWeekStyle: const DaysOfWeekStyle(
                               weekdayStyle: TextStyle(color: AppColors.white70),
                               weekendStyle: TextStyle(color: AppColors.white70),
                             ),
                             onPageChanged: (focusedDay) {
                               setState(() {
                                 _focusedDay = focusedDay;
                                 fetchavailability();
                               });
                             },
                           ),
       */
                /*
                           CommonCalendar(
                             focusedDay: _focusedDay,
                             events: events,
                             selectedEvent: selectedEvent,
                             onPageChanged: (day) {
                               setState(() {
                                 _focusedDay = day;
                                 fetchavailability();
                               });
                             },
                           )
                         ],
                       ),
                     ),
                   ),*/
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.xxxlAll,
                    border: Border.all(
                      width: 0.6,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadii.xxxlAll,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // LEFT SIDE (month + arrows)
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.chevron_left,
                                      color: AppColors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month - 1,
                                        );
                                      });
                                    },
                                  ),

                                  // ✅ CENTER FEEL TEXT
                                  Expanded(
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          getMonthYear(_focusedDay),
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 16,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month + 1,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // RIGHT SIDE (dropdown)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: AppRadii.lgAll,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedEvent,
                                  isDense: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.black,
                                    size: 18,
                                  ),
                                  dropdownColor: AppColors.white,
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontSize: 12,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w500,
                                  ),
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
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Row(
                        //       children: [
                        //         IconButton(
                        //           icon: const Icon(Icons.chevron_left, color: AppColors.white),
                        //           onPressed: () {
                        //             setState(() {
                        //               _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                        //             });
                        //           },
                        //         ),
                        //         Text(
                        //           getMonthYear(_focusedDay),
                        //           style: const TextStyle(
                        //             color: AppColors.white,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.w600,
                        //           ),
                        //         ),
                        //         IconButton(
                        //           icon: const Icon(Icons.chevron_right, color: AppColors.white),
                        //           onPressed: () {
                        //             setState(() {
                        //               _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                        //             });
                        //           },
                        //         ),
                        //       ],
                        //     ),
                        //     Container(
                        //       margin: EdgeInsets.all(7),
                        //       padding: const EdgeInsets.symmetric(horizontal: 19,),
                        //       decoration: BoxDecoration(
                        //         color: AppColors.white,
                        //         borderRadius: AppRadii.smAll,
                        //       ),
                        //       child: DropdownButtonHideUnderline(
                        //         child: DropdownButton<String>(
                        //           value: selectedEvent,
                        //           icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.black),
                        //           dropdownColor: AppColors.white,
                        //           style: const TextStyle(color: AppColors.black, fontSize: 12),
                        //           items: eventList.map((String value) {
                        //             return DropdownMenuItem(
                        //               value: value,
                        //               child: Text(value),
                        //             );
                        //           }).toList(),
                        //           onChanged: (value) {
                        //             setState(() {
                        //               selectedEvent = value!;
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //     )
                        //   ],
                        // ),
                        const SizedBox(height: 10),
                        /*     TableCalendar(
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
                                         color: AppColors.dividerDark,
                                         width: 1,
                                       ),
                                     ),
                                   ),
                                   child: Text(
                                     text,
                                     style: const TextStyle(
                                       color: AppColors.white,
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
                                     Text("${day.day}", style: const TextStyle(color: AppColors.white)),
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
                                 color: AppColors.dividerDark,
                                 width: 1,
                               ),
                               defaultTextStyle: const TextStyle(color: AppColors.white),
                               weekendTextStyle: const TextStyle(color: AppColors.white),
                               outsideTextStyle: const TextStyle(color: AppColors.white38),
                             ),
                             daysOfWeekStyle: const DaysOfWeekStyle(
                               weekdayStyle: TextStyle(color: AppColors.white70),
                               weekendStyle: TextStyle(color: AppColors.white70),
                             ),
                             onPageChanged: (focusedDay) {
                               setState(() {
                                 _focusedDay = focusedDay;
                                 fetchavailability();
                               });
                             },
                           ),
       */
                        CommonCalendar(
                          focusedDay: _focusedDay,
                          events: events,
                          selectedEvent: selectedEvent,
                          onPageChanged: (day) {
                            setState(() {
                              _focusedDay = day;
                              fetchavailability();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: 12),
                if (creatordashboarddetaillist.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "shoots",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      /*  GestureDetector(
           onTap:
           () {

           Navigator.push(
           context,MaterialPageRoute(builder: (context) => ShootsScreen(),),
           );
           },

                      */
                      /* InkWell(
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => ShootsScreen(), // 👈 next screen
                             ),
                           );
                         },*/
                      /*
                         child: const Icon(
                           Icons.arrow_forward_ios,
                           color: AppColors.white70,
                           size: 16,
                         ),
                       ),*/
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: AppRadii.portfolioCompactAll,
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
                              child:
                                  data?.shootTypeImageUrl != null &&
                                      data!.shootTypeImageUrl.isNotEmpty
                                  ? Image.network(
                                      ApiService().getImageURL(
                                        data.shootTypeImageUrl,
                                      ),
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,

                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: SvgPicture.asset(
                                            AppAssets
                                                .image_holder, // 👈 your svg path
                                            height: 220,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: SvgPicture.asset(
                                        AppAssets.image_holder,
                                        height: 220,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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
                                      AppColors.surfaceMid,
                                      AppColors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            /*  Positioned(
                               top: 14,
                               left: 14,
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: AppColors.black.withOpacity(0.6),
                                   borderRadius: AppRadii.hugeAll,
                                 ),
                                 child: const Text(
                                   "10 mins Ago",
                                   style: TextStyle(
                                     color: AppColors.white,
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
                                   color: AppColors.white.withOpacity(0.2),
                                   shape: BoxShape.circle,
                                 ),
                                 child: const Icon(
                                   Icons.arrow_forward,
                                   color: AppColors.white,
                                   size: 18,
                                 ),
                               ),
                             ),*/
                            /* Positioned(
                                 bottom: 14,
                                 left: 14,
                                 child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                   decoration: BoxDecoration(
                                     color: AppColors.greenMintLight,
                                     borderRadius: AppRadii.hugeAll,
                                   ),
                                   child: Row(
                                     children:  [
                                       // Icon(Icons.check_circle, size: 14, color: AppColors.success),
                                       SizedBox(width: 6),
                                       Text(
                                         data?.status ?? "",
                                         style: TextStyle(
                                           color: AppColors.success,
                                           fontSize: 12,
                                           fontWeight: FontWeight.w600,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),*/
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      data?.projectName ?? "",
                                      style: TextStyle(
                                        fontFamily: "Outfit",
                                        color: AppColors.white, //
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    /*onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context) => UpcomingShootViewDetils(
                                       projectid: data?.projectId ?? 0,
                                     ))),*/
                                    onTap: () {
                                      context.pushNamed(
                                        RouteNames.upcomingShootDetails,
                                        extra: {"projectId": data?.projectId},
                                      );
                                    },
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: AppColors.dividerDark,
                                thickness: 0.8,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 14,
                                runSpacing: 8,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.calender,
                                        width: 14,
                                        height: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        DateTimeUtils.formatDate(
                                          data?.eventDate.toIso8601String(),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Outfit",
                                          color: AppColors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.time,
                                        width: 14,
                                        height: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "${DateTimeUtils.formatTime(data?.startTime)} - ${DateTimeUtils.formatTime(data?.endTime)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Outfit",
                                          color: AppColors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.location,
                                        width: 14,
                                        height: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        data?.eventLocation ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Outfit",
                                          color: AppColors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// ✅ LEFT SIDE (Avatar Stack)
                                  // _buildAvatarStack(
                                  // images: [
                                  // AppAssets.avtarstack,
                                  // AppAssets.avtarstack,
                                  // AppAssets.avtarstack,
                                  // AppAssets.avtarstack,
                                  // ],
                                  // extraCount: 3,
                                  // avatarSize: 20,
                                  // overlap: 10,
                                  // ),
                                  SizedBox(),

                                  if (data?.canTakeAction == true)
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.white,
                                          ),
                                          onPressed: () {
                                            if (data != null) {
                                              fetchacceptdecline(
                                                data.projectId,
                                                1,
                                              );
                                            }
                                          },
                                          child: Text(
                                            data?.cta?.primary.isNotEmpty ==
                                                    true
                                                ? data!.cta!.primary
                                                : "Accept",
                                            style: const TextStyle(
                                              color: AppColors.success,
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.white,
                                          ),
                                          onPressed: () async {
                                            context
                                                .pushNamed(
                                                  RouteNames.cancelShoot,
                                                  extra: {
                                                    "projectId":
                                                        data?.projectId,
                                                  },
                                                )
                                                .then((value) {
                                                  if (value == true) {
                                                    fetchcreatordashboarddetails();
                                                    fetchdashboardcount();
                                                  }
                                                });
                                          },
                                          child: Text(
                                            data?.cta?.secondary.isNotEmpty ==
                                                    true
                                                ? data!.cta!.secondary
                                                : "Reject",
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
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
                  Divider(color: AppColors.dividerDark, thickness: 0.8),
                ],
                SizedBox(height: 12),
                /*    Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         "Upcoming Meetings",
                         style: TextStyle(
                           fontSize: 16,
                           fontFamily: "Unbounded",
                           fontWeight: FontWeight.w500,
                           color: AppColors.white,
                         ),
                       ),
                       InkWell(
                         onTap: () {},
                         child: const Icon(
                           Icons.arrow_forward_ios,
                           color: AppColors.white70,
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
                               backgroundColor: AppColors.white.withOpacity(0.03),
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
                               backgroundColor: AppColors.white.withOpacity(0.05),
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
                               backgroundColor: AppColors.surfaceMid,
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 14),*/
                // Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Shoot Status",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Unbounded",
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.dashboardPanelDark,
                        borderRadius: AppRadii.roundAll,
                        border: Border.all(color: AppColors.darkCharcoal),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRange,
                          dropdownColor: AppColors.surfaceStats,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.white24,
                            size: 20,
                          ),
                          style: const TextStyle(
                            color: AppColors.white,
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  decoration: BoxDecoration(
                    color: AppColors.dashboardPanelDark,
                    borderRadius: AppRadii.massiveAll,
                    border: Border.all(
                      color: AppColors.darkCharcoal,
                      width: 0.6,
                    ),
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
                                size: const Size(700, 150),
                                painter: MultiArcPainter(
                                  values: arcValues,
                                  colors: const [
                                    AppColors.arcPurple,
                                    AppColors.arcBlue,
                                    AppColors.arcYellow,
                                    AppColors.arcGreen,
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${sucessfullshoots + pendingshoots + rejectedshoots + shootrequest}",
                                    style: const TextStyle(
                                      color: AppColors.goldCream,
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
                      const SizedBox(height: 28),
                      _statusItem(
                        "$sucessfullshoots",
                        "Successful shoots",
                        AppColors.arcPurple,
                      ),
                      _statusItem(
                        "$pendingshoots",
                        "Pending shoots",
                        AppColors.arcBlue,
                      ),
                      _statusItem(
                        "$rejectedshoots",
                        "Rejected shoots",
                        AppColors.arcYellow,
                      ),
                      _statusItem(
                        "$shootrequest",
                        "Shoot Requests",
                        AppColors.arcGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Shoot Categories",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Unbounded",
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.dashboardPanelDark,
                        borderRadius: AppRadii.roundAll,
                        border: Border.all(color: AppColors.darkCharcoal),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? AppColors.goldCream
                                    : AppColors.transparent,
                                borderRadius: AppRadii.portfolioAll,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Photo",
                                style: TextStyle(
                                  color: selectedTab == 0
                                      ? AppColors.black
                                      : AppColors.white30,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? AppColors.goldCream
                                    : AppColors.transparent,
                                borderRadius: AppRadii.portfolioAll,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Video",
                                style: TextStyle(
                                  color: selectedTab == 1
                                      ? AppColors.black
                                      : AppColors.white30,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Outfit",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: AppRadii.massiveAll,
                    border: Border.all(
                      color: AppColors.darkCharcoal,
                      width: 0.6,
                    ),
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
                                size: const Size(700, 150),
                                painter: MultiArcPainter(
                                  values: categoryArcValues,
                                  colors: const [
                                    AppColors.arcPurple,
                                    AppColors.arcBlue,
                                    AppColors.arcYellow,
                                    AppColors.arcGreen,
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedTab == 0
                                        ? categoryPhotoTotal.toString()
                                        : categoryVideoTotal.toString(),

                                    //      Text(
                                    //                                     selectedTab == 0?
                                    //                                     acceptphotographyShoots.toString()
                                    //                                     :.toString(),
                                    style: const TextStyle(
                                      color: AppColors.goldCream,
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
                      const SizedBox(height: 28),
                      _statusItem(
                        "$acceptphotographyShoots",
                        "Photography shoots",
                        AppColors.arcPurple,
                      ),

                      _statusItem(
                        "$acceptvideographyShoots",
                        "Videography shoots",
                        AppColors.arcBlue,
                      ),

                      _statusItem(
                        selectedTab == 0 ? "$rejectedPhoto" : "$rejectedVideo",
                        "Rejected shoots",
                        AppColors.arcYellow,
                      ),

                      _statusItem(
                        selectedTab == 0 ? "$requestPhoto" : "$requestVideo",
                        "Shoot Requests",
                        AppColors.arcGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        color: isAvailable ? AppColors.softMint : AppColors.blueIce,
        borderRadius: AppRadii.r3All,
      ),
      child: Text(
        textAlign: TextAlign.center,
        event,
        style: TextStyle(
          color: isAvailable ? AppColors.greenBright : AppColors.blueRoyal,
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

    final DraggableScrollableController sheetController =
        DraggableScrollableController();

    final List<String> dateOptions = [
      "Today",
      "This Week",
      "Marketing Analytics",
      "This Month",
      "Custom Range",
    ];
    final List<String> statusOptions = [
      "Upcoming",
      "Active",
      "Completed",
      "Cancelled",
    ];
    final List<String> categoryOptions = [];
    final List<String> typeOptions = ["All", "shoots", "Rental"];

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
                    final newSize =
                        currentSize -
                        (details.delta.dy / MediaQuery.of(context).size.height);
                    sheetController.jumpTo(newSize.clamp(0.4, 0.95));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMid,
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
                            color: AppColors.white,
                            borderRadius: AppRadii.xsAll,
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
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontFamily: "Unbounded",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          thickness: 0.5,
                          color: AppColors.white.withOpacity(0.3),
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
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isDateExpanded
                                        ? dateOptions
                                              .map(
                                                (label) => _radioOption(
                                                  label: label,
                                                  selected:
                                                      selectedDate == label,
                                                  onTap: () => setState(
                                                    () => selectedDate = label,
                                                  ),
                                                ),
                                              )
                                              .toList()
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
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isStatusExpanded
                                        ? statusOptions
                                              .map(
                                                (label) => _radioOption(
                                                  label: label,
                                                  selected:
                                                      selectedStatus == label,
                                                  onTap: () => setState(
                                                    () =>
                                                        selectedStatus = label,
                                                  ),
                                                ),
                                              )
                                              .toList()
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
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isCategoryExpanded
                                        ? categoryOptions
                                              .map(
                                                (label) => _radioOption(
                                                  label: label,
                                                  selected:
                                                      selectedCategory == label,
                                                  onTap: () => setState(
                                                    () => selectedCategory =
                                                        label,
                                                  ),
                                                ),
                                              )
                                              .toList()
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
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }),
                                    children: isTypeExpanded
                                        ? typeOptions
                                              .map(
                                                (label) => _radioOption(
                                                  label: label,
                                                  selected:
                                                      selectedType == label,
                                                  onTap: () => setState(
                                                    () => selectedType = label,
                                                  ),
                                                ),
                                              )
                                              .toList()
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
                                            margin: const EdgeInsets.only(
                                              left: 12,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              borderRadius: AppRadii.lgAll,
                                              border: Border.all(
                                                width: 0.5,
                                                color: AppColors.white
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Clear All',
                                                style: TextStyle(
                                                  color: AppColors.white,
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
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: AppRadii.lgAll,
                                              border: Border.all(
                                                width: 0.5,
                                                color: AppColors.white
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Apply',
                                                style: TextStyle(
                                                  fontFamily: 'Unbounded',
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.onPrimary,
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
          color: AppColors.onPrimary,
          borderRadius: AppRadii.xlAll,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: AppRadii.xlAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      size: 30,
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
            isExpanded && showDivider
                ? Divider(
                    thickness: 0.5,
                    color: AppColors.white.withOpacity(0.3),
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
                color: AppColors.white.withOpacity(0.8),
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
                  color: selected ? AppColors.border : AppColors.white24,
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
                          color: AppColors.primary,
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
      //  borderRadius: AppRadii.xxlAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: AppRadii.xxlAll,
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
                    fontSize: 12,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.black
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Outfit",
                    color: isSelected ? AppColors.black : AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                /*     Text(
                  percent,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? AppColors.success : percentColor,
                  ),
                ),*/
              ],
            ),
            CircleAvatar(
              radius: 17,
              backgroundColor: isSelected
                  ? AppColors.black
                  : AppColors.dashboardPanelDark,
              child: SvgPicture.asset(
                iconPath,
                width: 17,
                height: 17,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              // child: SvgPicture.asset(
              //   iconPath,
              //   width: 16,
              //   height: 16,
              //   color: isSelected ? AppColors.white : AppColors.white70,
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meetingCard({
    double opacity = 1,
    Color backgroundColor = AppColors.surfaceVariant,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadii.headerAll,
          boxShadow: AppShadows.heroOverlay,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.mldAll,
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Pre-Production Kickoff",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.white),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldHoney,
                    borderRadius: AppRadii.hugeAll,
                  ),
                  child: const Text(
                    "Initiated",
                    style: TextStyle(color: AppColors.orange, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.hugeAll,
                  ),
                  child: const Text(
                    "Google Meet",
                    style: TextStyle(color: AppColors.black, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.white24),
                SizedBox(width: 8),
                Text(
                  "16 Jun, 2024",
                  style: TextStyle(color: AppColors.white24, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.white24),
                SizedBox(width: 8),
                Text(
                  "10:00 PM to 13:00 PM",
                  style: TextStyle(color: AppColors.white24, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldCream,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.roundAll),
              ),
              onPressed: () {},
              child: const Text(
                "Join Meeting",
                style: TextStyle(
                  color: AppColors.black,
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
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              borderRadius: AppRadii.roundAll,
              border: Border.all(color: color.withOpacity(0.6), width: 1.5),
            ),
            child: Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Outfit",
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
