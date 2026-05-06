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

  final ManageAvailabilityController nexwController = ManageAvailabilityController();
  late AnimationController _controller;
  int _currentIndex = 0;

  // Calendar related
// Calendar related
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, String> _events = {};
  String _selectedEventFilter = "All Events";
  final List<String> _eventFilterList = ["All Events", "Available", "Shoot"];

  @override
  void initState() {
    super.initState();
    nexwController.addListener(_onControllerChanged);
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
    nexwController.removeListener(_onControllerChanged);
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
    const months = ["January","February","March","April","May","June",
      "July","August","September","October","November","December"];
    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

            // Auto Block Info
       /*     Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 20),
              decoration: BoxDecoration(
                color: const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SvgPicture.asset('assets/svg/infosvg.svg'),
                  const SizedBox(width: 8),
                  const Expanded(
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
            ),*/

            const SizedBox(height: 20),

            // CALENDAR SECTION - Using CommonCalendar
            /// 📅 Calendar Section - Replace purane GridView ke saath
            // CALENDAR SECTION - Exactly like HomeScreen
            // CALENDAR SECTION - Exactly like HomeScreen (no extra padding)
            Container(
              margin: EdgeInsetsGeometry.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xff282828),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 0.5, color: Color(0xff626262)),
              ),
              child: ClipRRect(
                borderRadius:BorderRadius.circular(20),
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
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
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
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedEventFilter,
                              isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black, size: 18),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontSize: 13),
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

                    const SizedBox(height: 10),  // 👈 HomeScreen mein bhi yahi height hai

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
                    svgIcon: AppImages.calender,
                    title: "Available Days",
                    value: "${_getAvailableDaysCount()}",
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    svgIcon: AppImages.book_video,
                    title: "Book Shoots",
                    value: "${_getShootCount()}",
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    svgIcon: AppImages.HourglasTime,
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
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Text(
                    "Share your availability link with production teams",
                    style: TextStyle(
                      color: Colors.white70,
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
                        color: ColorCode.kButtonColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

            const Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
            const SizedBox(height: 12),*/

            // Upcoming Shoots Section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Upcoming Shoots",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                      color: ColorCode.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Search and Filter Row
            Row(
              children: [
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
                    child: const Row(
                      children: [
                        Text(
                          "Filter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.filter_list, color: Colors.white54, size: 18),
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
            const Divider(color: ColorCode.kDividerWhite12, thickness: 0.8),
            const SizedBox(height: 25),

            // Add Availability Button
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAvailabilityScreen(),
                  ),
                ).then((_) {
                  fetchAvailability(); // Refresh on return
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: ColorCode.kButtonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add Availability",
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

  Widget _buildShootCard(Map<String, dynamic> data,
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
            child: Image.asset(
              data['image'],
              height: 169,
              width: 117,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 169,
                  width: 117,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image, color: Colors.white54),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    backgroundColor: ColorCode.kButtonColor.withOpacity(btnOpacity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpcomingShootViewDetils(),
                      ),
                    );
                  },
                  child: const Text("View Details",
                      style: TextStyle(color: Colors.black, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
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

    required String title,
    required String value,   required String svgIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4C),
              borderRadius: BorderRadius.circular(12),
            ),
            // child: Icon(icon, color: Colors.white70, size: 20),

      child: SvgPicture.asset(
        svgIcon,
        height: 20,
        width: 20,
        color: Colors.white70,
      ),
    ),

          const SizedBox(width: 14),
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
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD6C19A),
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
            color: ColorCode.kWhiteOpacity70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}