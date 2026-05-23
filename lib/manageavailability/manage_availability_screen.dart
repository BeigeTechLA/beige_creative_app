import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../app/colors.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../widgets/common_calendar.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() =>
      _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen>
    with SingleTickerProviderStateMixin {
  // final ManageAvailabilityController nexwController = ManageAvailabilityController();
  late AnimationController _controller;
  final int _currentIndex = 0;

  // Calendar related
  // Calendar related
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, String> _events = {};
  String _selectedEventFilter = "All Events";
  final List<String> _eventFilterList = ["All Events", "Available", "Shoot"];

  @override
  void initState() {
    super.initState();
    // nexwController.addListener(_onControllerChanged);
    fetchAvailability();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    // nexwController.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchAvailability() async {
    try {
      final response = await ApiService().postData(
        ApiEndpoints.createavailability,
        {"month": _focusedDay.month, "year": _focusedDay.year},
      );

      if (response["error"] == false) {
        final availability = response["data"]["availability"];
        _prepareEvents(availability);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _prepareEvents(Map<String, dynamic> availability) {
    _events.clear();
    availability.forEach((dateString, value) {
      final date = DateTime.parse(dateString);
      final cleanDate = DateTime(date.year, date.month, date.day);

      // 🔥 API response ke according logic
      final isAssigned = value["projectAssigned"] == true;
      final isAvailable = value["available"] == true;

      if (isAssigned) {
        // Project assigned hai → Shoot dikhao
        _events[cleanDate] = "Shoot";
      } else if (isAvailable) {
        // Available hai → Available dikhao
        _events[cleanDate] = "Available";
      }
      // Agar dono false hai → kuch mat dikhao
    });
    setState(() {});
  }

  String _getMonthYear(DateTime date) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: SvgPicture.asset(AppAssets.menu, width: 26),
                  ),
                  const Spacer(),
                  const Text(
                    "Manage Availability",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Auto Block Info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              // padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blueWash,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 0.5),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppAssets.info),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Your availability is automatically blocked for confirmed shoots",
                      style: TextStyle(
                        fontFamily: 'outfit',
                        color: AppColors.blueAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  width: 0.6,
                  color: AppColors.darkCharcoal,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row - BILKUL WAISA HI JAISE HOMESCREEN MEIN THA
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
                                  fetchAvailability();
                                },
                              ),
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _getMonthYear(_focusedDay),
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
                                  fetchAvailability();
                                },
                              ),
                            ],
                          ),
                        ),

                        // RIGHT SIDE dropdown
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedEventFilter,
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
                              items: _eventFilterList.map((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEventFilter = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10), //
                    // CommonCalendar - BINA KISI EXTRA PADDING/MARGIN KE
                    CommonCalendar(
                      focusedDay: _focusedDay,
                      events: _events,
                      selectedEvent: _selectedEventFilter,
                      onPageChanged: (day) {
                        setState(() {
                          _focusedDay = day;
                        });
                        fetchAvailability();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // This Month Stats Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSlate,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "This Month",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Outfit",
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildStatCard(
                    svgIcon: AppAssets.calender,
                    title: "Available Days",
                    value: "${_getAvailableDaysCount()}",
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    svgIcon: AppAssets.book_video,
                    title: "Book shoots",
                    value: "${_getShootCount()}",
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    svgIcon: AppAssets.HourglasTime,
                    title: "Time Off",
                    value: "${_getTimeOffCount()}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Share Availability Section
            /*  Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSlate,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Share Availability",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Outfit",
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Share your availability link with production teams",
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 14,
                        fontFamily: "Outfit",
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Copy logic here
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              color: AppColors.circleGradientTop,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Copy Link",
                              style: TextStyle(
                                color: AppColors.circleGradientTop,
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
        
              const Divider(color: AppColors.dividerDark, thickness: 0.8),
              const SizedBox(height: 12),*/

            // Upcoming Shoots Section
            /* const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Upcoming Shoots",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),*/
            const SizedBox(height: 14),
            /*
              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.white30,
                          width: 1,
                        ),
                      ),
                      child: const TextField(
                        style: TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.white54,
                          ),
                          hintText: "Search events or crew...",
                          hintStyle: TextStyle(
                            color: AppColors.white54,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.white24,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            "Filter",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.filter_list, color: AppColors.white54, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 50),
        
              // Upcoming Shoots Cards - Dynamic
              if (nexwController.cardDataList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(18),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final list = nexwController.cardDataList;
                      final current = list[_currentIndex % list.length];
                      final next = list[(_currentIndex + 1) % list.length];
                      final next2 = list[(_currentIndex + 2) % list.length];
        
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 3rd card (back most)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            top: _controller.isAnimating ? -32 : -24,
                            left: totalWidth * 0.07,
                            right: totalWidth * 0.07,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _controller.isAnimating ? 0.5 : 1,
                              child: _buildShootCard(next2, isMain: false, isBack: true),
                            ),
                          ),
                          // 2nd card (middle)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            top: _controller.isAnimating ? -20 : -12,
                            left: totalWidth * 0.035,
                            right: totalWidth * 0.035,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _controller.isAnimating ? 0.7 : 1,
                              child: _buildShootCard(next, isMain: false, isMiddle: true),
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
                            child: _buildShootCard(current, isMain: true),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        
              const SizedBox(height: 12),
              const Divider(color: AppColors.dividerDark, thickness: 0.8),
              const SizedBox(height: 25),*/

            // Add Availability Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAvailabilityScreen(),
                      ),
                    ).then((_) {
                      fetchAvailability();
                    });*/
                  context.pushNamed(RouteNames.addAvailability).then((value) {
                    if (value == true) {
                      fetchAvailability();
                    }
                  });
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Add Availability",
                      style: TextStyle(
                        color: AppColors.circleGradientTop,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Unbounded",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getAvailableDaysCount() {
    int count = 0;
    _events.forEach((date, event) {
      if (date.year == _focusedDay.year && date.month == _focusedDay.month) {
        if (event.toLowerCase() == "available") count++;
      }
    });
    return count;
  }

  int _getShootCount() {
    int count = 0;
    _events.forEach((date, event) {
      if (date.year == _focusedDay.year && date.month == _focusedDay.month) {
        if (event.toLowerCase() == "shoot") count++;
      }
    });
    return count;
  }

  int _getTimeOffCount() {
    // You can implement logic for time off here
    return 0;
  }

  Widget _buildShootCard(
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
    final titleColor = isMain || isMiddle ? AppColors.white : AppColors.white70;
    final dateColor = isMain ? AppColors.white70 : AppColors.white54;
    final btnOpacity = isMain ? 1.0 : (isMiddle ? 0.8 : 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: AppColors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              data['image'],
              height: 169,
              width: 117,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 169,
                  width: 117,
                  color: AppColors.greyShade800,
                  child: const Icon(Icons.image, color: AppColors.white54),
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
                    color: titleColor,
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
                      style: TextStyle(fontSize: 12, color: dateColor),
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
                      style: TextStyle(fontSize: 12, color: dateColor),
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
                        style: TextStyle(fontSize: 12, color: dateColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    backgroundColor: AppColors.primary.withOpacity(
                      btnOpacity,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    context.pushNamed(RouteNames.upcomingShootDetails);
                  },
                  child: const Text(
                    "View Details",
                    style: TextStyle(color: AppColors.black, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /*

  void _onCardTap() async {
    if (_controller.isAnimating) return;
    await _controller.forward();
    setState(() {
      final listLength = nexwController.cardDataList.length;
      _currentIndex = (_currentIndex + 1) % listLength;
    });
    _controller.reset();
  }
*/

  Widget _buildStatCard({
    required String title,
    required String value,
    required String svgIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAsh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceFog,
              borderRadius: BorderRadius.circular(12),
            ),

            // child: Icon(icon, color: AppColors.white70, size: 20),
            child: SvgPicture.asset(
              svgIcon,
              height: 20,
              width: 20,
              color: AppColors.white70,
            ),
          ),

          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.goldSand,
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

// Legend Widget
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
            color: AppColors.white30,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
