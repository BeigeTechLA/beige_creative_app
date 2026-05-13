  import 'package:auto_skeleton/auto_skeleton.dart';
  import 'package:beige_creative_app/service/api_endpoints.dart';
  import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/widgets/app_loder.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
  import '../Model_Class/shoot_count_model.dart';
  import '../Model_Class/shoots_model.dart';
  import '../UpcomingShootViewdetils/upcoming_shoot_view_detils.dart';
  import '../app/route_names.dart';
import '../utility/colorcode.dart';
  import '../utility/imges_icons.dart';
  import '../widgets/date_time.dart';
import 'shoot_cancelled_screen.dart';

  class ShootsScreen extends StatefulWidget {
    const
    ShootsScreen({super.key});

    @override
    State<ShootsScreen> createState() => _ShootsScreenState();
  }

  class _ShootsScreenState extends State<ShootsScreen> {

    bool  isLoading = true;
    @override
    void initState() {
      super.initState();
      fetchshootmodel();
      fetchshootcount();
    }

    int mycompletedShoots=0;
    int mypendingRequests=0;
    int myconfirmedRequests=0;
    int myrejectedRequests=0;

    ShootsModel? shoots;
    List<Shoot> mylist = [];
    List<Shoot> allShoots = [];

    TextEditingController searchController = TextEditingController();
    List<Shoot> filteredList = [];
    Future<void>fetchacceptdecline(int projectid,int crewid)async{
      final response= await ApiService().postData(
          ApiEndpoints.acceptdeclineproject,
          {
            "project_id": projectid,
            "crew_accept": crewid
          }
          );

      if(response["error"]==false){
        debugPrint('Sucessfully hiT Accept& Decline API');
      }


    }


    Future<void>fetchshootcount()async{

      try {
        final response= Shootcountmodel.fromJson(await ApiService().fetchData(ApiEndpoints.myshootcount));

        if(response.error==false){
          if (!mounted) return;

          setState(() {

            mycompletedShoots =
                response.data.completedShoots;

            mypendingRequests =
                response.data.pendingRequests;

            myconfirmedRequests =
                response.data.confirmedRequests;

            myrejectedRequests =
                response.data.rejectedRequests;
          });

        }
      } on Exception catch (e) {

      }


    }


    Future<void> fetchshootmodel() async {
      setState(() => isLoading = true);

      /// 🔥 STEP 1: RAW API CALL
      final rawResponse =
      await ApiService().fetchData(ApiEndpoints.creatordashboarddetails);

      /// 🔥 ONLY RESPONSE PRINT (JSON)
      print("🔥 API RESPONSE 👉 $rawResponse");

      /// STEP 2: Convert to Model
      final response = ShootsModel.fromJson(rawResponse);

      if (response.error == false) {
        setState(() {
          mylist = response.data.shoots;
          allShoots = response.data.shoots;
          isLoading = false;

        });
      } else {
        setState(() => isLoading = false);
      }
    }

    void searchShoots(String query) {

      /// ✅ agar search empty ho
      if (query.trim().isEmpty) {
        setState(() {
          mylist = List.from(allShoots);
        });
        return;
      }

      final lowerQuery = query.toLowerCase();

      final filtered = allShoots.where((shoot) {

        final projectName =
        (shoot.projectName ?? "").toLowerCase();

        final contentType =
        (shoot.contentType ?? "").toLowerCase();

        return projectName.contains(lowerQuery) ||
            contentType.contains(lowerQuery);

      }).toList();

      setState(() {
        mylist = filtered;
      });
    }
    @override
    Widget build(BuildContext context) {


      return SafeArea(
        child: Stack(
          children: [
            Column(
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
                        "shoots",
                        style: TextStyle(
                          color: ColorCode.white,
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
        
                      const Spacer(),
        
                      /// FILTER
                    /*  GestureDetector(
                          onTap: () => _showFilterBottomSheet(context),
                          child: SvgPicture.asset(AppImages.filter,width: 26,height: 26,)),*/
                    ],
                  ),
                ),
        
                /// 🔥 COUNT CARDS
                SizedBox(
                  height: 70, // 👈 compact height
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _countCard(
                        "$mypendingRequests",
                        "Pending shoots",
                        AppImages.clock_icon,
                      ),
        
                      _countCard(
                        "$myconfirmedRequests",
                        "Confirmed shoots",
                        AppImages.video_icon,
                      ),
        
                      _countCard(
                        "$mycompletedShoots",
                        "Completed",
                        AppImages.photo_icon,
                      ),
        
                      _countCard(
                        "$myrejectedRequests",
                        "Declined",
                        AppImages.declined_icon,
                      ),
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
                      controller: searchController,
                      onChanged: searchShoots,
                      style: const TextStyle(
                        color: ColorCode.white,
                        fontSize: 14,
                      ),
                      cursorColor: ColorCode.white,
                      decoration: InputDecoration(
                        hintText: "Search events or crew...",
                        hintStyle: const TextStyle(
                            color: ColorCode.white24,
                            fontFamily: "Outfit"
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: ColorCode.white24,
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
                    itemCount:mylist.length,
                    itemBuilder: (context, index) {
                      final shoot=mylist[index];
                      return _shootCard(context, shoot);
                    },
                  ),
                )
              ],
            ),
            if(isLoading)
              AppLoader()
          ],
        
        ),
      );
    }


    Widget _countCard(String number, String title, String iconPath) {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              ColorCode.k2A2A2A,
              ColorCode.kPrimaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ColorCode.white,
          ),),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// LEFT TEXT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFFD6B98C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),

            /// RIGHT SVG ICON
            SvgPicture.asset(
              iconPath,

            ),
          ],
        ),
      );
    }

    /// 🔥 SHOOT CARD
    Widget _shootCard(BuildContext context, Shoot shoot) {

      String formattedDate = DateTimeUtils.formatDate(
        shoot.eventDate.toIso8601String(),
      );
      String formattedTime =
          "${DateTimeUtils.formatTime(shoot.startTime)} - ${DateTimeUtils.formatTime(shoot.endTime)}";
     /* try {
        /// ✅ DATE FIX (NO PARSE)
        if (project?.eventDate != null) {
          formattedDate =
              DateFormat('MMM dd, yyyy').format(project!.eventDate);
        }

        /// ✅ TIME FIX (same rahega)
        if (project?.startTime != null && project?.endTime != null) {
          final start = DateFormat("HH:mm:ss").parse(project!.startTime!);
          final end = DateFormat("HH:mm:ss").parse(project.endTime!);

          formattedTime =
          "${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}";
        }
      } catch (e) {
        debugPrint("Date format error: $e");
      }*/

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: ColorCode.k282828,
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
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: shoot.shootTypeImageUrl.isNotEmpty
                    ? Image.network(
                  ApiService().getImageURL(
                    shoot.shootTypeImageUrl,
                  ),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,

                )

                /// IMAGE EMPTY
                    : Container(
                  color: const Color(0xFF1E1E1E),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppImages.image_holder,
                    height: 60,
                    colorFilter: const ColorFilter.mode(
                      ColorCode.white24,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ID + DETAILS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ID: ${shoot.id}",
                        style: TextStyle(
                          color: ColorCode.kButtonColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.pushNamed(
                            RouteNames.upcomingShootDetails,

                            extra: {
                              "projectId": shoot.projectId,
                            },
                          );
                        },
                        child: Text(
                          "View Details",
                          style: TextStyle(
                            color: ColorCode.kButtonColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// TITLE
                  Text(
                    shoot?.projectName ?? "No Title",
                    style: const TextStyle(
                      color: ColorCode.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Divider(color: ColorCode.kDividerWhite12),

                  /// ✅ DATE + TIME + LOCATION (FIXED)
                  Row(
                    children: [
                      SvgPicture.asset(AppImages.calender, width: 14, height: 14),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate, // ✅ FIX
                        style: const TextStyle(color: ColorCode.whiteOpacity20, fontSize: 12),
                      ),

                      const SizedBox(width: 14),

                      SvgPicture.asset(AppImages.time, width: 14, height: 14),
                      const SizedBox(width: 6),
                      Text(
                        formattedTime, // ✅ FIX
                        style: const TextStyle(color: ColorCode.kWhiteOpacity70, fontSize: 12),
                      ),

                      const SizedBox(width: 14),

                      SvgPicture.asset(AppImages.location, width: 14, height: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shoot?.eventLocation ?? "No Location",
                          style: const TextStyle(color: ColorCode.kWhiteOpacity70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     SizedBox(),
                      /// ✅ LEFT SIDE (Avatar Stack)
                      // _buildAvatarStack(
                      //   images: [
                      //     AppImages.avtarstack,
                      //     AppImages.avtarstack,
                      //     AppImages.avtarstack,
                      //     AppImages.avtarstack,
                      //   ],
                      //   extraCount: 3,
                      //   avatarSize: 20,
                      //   overlap: 10,
                      // ),

                      /// ✅ RIGHT SIDE (Your SAME Buttons - untouched)
                      if (shoot.status.toLowerCase() == "pending")
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffD8FDE6),
                              ),
                              onPressed: () {
                                fetchacceptdecline(shoot.projectId, 1);
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
                                backgroundColor: const Color(0xffEECCC9),
                              ),
                              onPressed: () {
                              /*  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CancelScreen(projectId: shoot.projectId),
                                  ),
                                );*/
                                context.pushNamed(
                                  RouteNames.shootCancel,

                                  extra: {
                                    "projectId":
                                    shoot.projectId,
                                  },
                                );
                              },
                              child: const Text(
                                "Decline",
                                style: TextStyle(
                                  color: Color(0xffD33732),
                                ),
                              ),
                            ),
                          ],
                        )
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
        "All", "shoots", "Rental",
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
                              color: ColorCode.white,
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
                                    color: ColorCode.white,
                                    fontSize: 18,
                                    fontFamily: "Unbounded",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(Icons.close, color: ColorCode.white),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Divider(
                            thickness: 0.5,
                            color: ColorCode.white.withOpacity(0.3),
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
                                                  color: ColorCode.white.withOpacity(0.6),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Clear All',
                                                  style: TextStyle(
                                                    color: ColorCode.white,
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
                                                  color: ColorCode.white.withOpacity(0.6),
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
                    border: Border.all(color: ColorCode.black, width: 1),
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

            /// +3 circle
            if (extraCount > 0)
              Positioned(
                left: images.length * overlap,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: ColorCode.lightGrey,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorCode.black, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "+$extraCount",
                      style: TextStyle(
                        color: ColorCode.white,
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
                          color: ColorCode.white,
                          fontSize: 14,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(size: 30,
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: ColorCode.white,
                      ),
                    ],
                  ),
                ),
              ),

              isExpanded && showDivider

                  ?Divider(
                thickness: 0.5,
                color: ColorCode.white.withOpacity(0.3),
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
                  color: ColorCode.white.withOpacity(0.8),
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
                    color: selected ? const Color(0xffDDDDDD) : ColorCode.kWhiteOpacity70,
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
