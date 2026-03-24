import 'package:beige_creative_app/Shoots/shoot_detils_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utility/ColorCode.dart';
import '../utility/imges_icons.dart';
import 'shoot_cancelled_screen.dart';

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
                    child: SvgPicture.asset(AppImages.menu,height: 26,),

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
                GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                child: SvgPicture.asset(AppImages.filter,width: 26,height: 26,)),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 400),
                            pageBuilder: (_, __, ___) => const CancelScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween(
                                  begin: const Offset(0, 1), // 👈 bottom se start
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                )),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
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
  void _showFilterBottomSheet( BuildContext context) {
    String? selectedDate;
    String? selectedStatus;
    String? selectedCategory;
    String? selectedType;

    bool isDateExpanded = false;
    bool isStatusExpanded = false;
    bool isCategoryExpanded = true;
    bool isTypeExpanded = false;

    final DraggableScrollableController sheetController = DraggableScrollableController();

    final List<String> dateOptions = [
      "Today", "This Week", "Marketing Analytics", "This Month", "Custom Range"
    ];

    final List<String> statusOptions = [
      "Upcoming", "Active", "Completed", "Cancelled"
    ];

    final List<String> categoryOptions = [
      "Commercial & Advertising",
      "Wedding",
      "Corporate",
      "Podcast & Shows",
      "Private Events",
      "Social Content",
      "Music Videos",
    ];
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

                    // 0.4 se 0.95 ke beech rakho
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

                        /// DRAG HANDLE
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

                        /// HEADER
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

                        /// SCROLLABLE CONTENT
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
                              // physics: const ClampingScrollPhysics(), // 👈 add this

                              controller: scrollController,
                              child: Column(
                                children: [
                                  _filterSection(
                                    showDivider: true,
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


                                  /// FILTER BY DATE
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

                                  /// FILTER BY STATUS
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

                                  /// FILTER BY CATEGORY



                                  const SizedBox(height: 13),

                                  /// CLEAR ALL & APPLY BUTTONS
                                  Row(
                                    children: [

                                      /// CLEAR ALL
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

                                      /// APPLY
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
  Widget _filterSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
    bool showDivider=false,
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

                ?Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ):SizedBox(),
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
}
