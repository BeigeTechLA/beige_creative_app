import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../model_class/upcoming_shootview_model.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../widgets/date_time.dart';

class UpcomingShootViewDetils extends StatefulWidget {
  final int? projectid;
  const UpcomingShootViewDetils({super.key, this.projectid});

  @override
  State<UpcomingShootViewDetils> createState() =>
      _UpcomingShootViewDetilsState();
}

class _UpcomingShootViewDetilsState extends State<UpcomingShootViewDetils> {
  List<String> getProfileImageUrls() {
    if (mydata?.teamMembers == null) return [];

    return mydata!.teamMembers
        .map((e) => ApiService.imageURL + e.profileImageUrl)
        .where((url) => !url.endsWith("/")) // empty remove
        .toList();
  }

  bool isloading = false;

  MyData? mydata; //
  String selectedReason = "";
  bool isOtherSelected = false;
  TextEditingController commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchupcomingshootview();
    debugPrint("🔥 Project ID received: ${widget.projectid}");
  }

  Future<void> fetchupcomingshootview() async {
    try {
      if (mounted) {
        setState(() {
          isloading = true;
        });
      }

      final url = 'creator/project-details/${widget.projectid}';

      debugPrint("🔥 API URL => $url");

      final rawResponse = await ApiService().fetchData(url);

      debugPrint("🔥 API RESPONSE => $rawResponse");

      final response = Upcomingshootviewmodel.fromJson(rawResponse);

      if (response.error == false) {
        if (!mounted) return;

        setState(() {
          mydata = response.data;

          isloading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isloading = false;
        });
      }
    } catch (e) {
      debugPrint("UPCOMING DETAILS ERROR: $e");

      if (!mounted) return;

      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 TOP IMAGE SECTION
                Stack(
                  children: [
                    /// 🔥 IMAGE
                    SizedBox(
                      height: 330,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: AppRadii.noneAll, // optional
                        child: Image.network(
                          ApiService().getImageURL(
                            mydata?.project.imageUrl ?? "",
                          ),
                          fit: BoxFit.cover,

                          /// ❌ error → fallback
                          errorBuilder: (_, _, _) {
                            return SvgPicture.asset(
                              AppAssets.image_holder,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),

                    /// 🔥 DARK GRADIENT (Bottom Fade Effect)
                    /*        Container(
                      height: 330,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.black.withOpacity(0.3),
                            AppColors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),*/

                    /// 🔥 TOP ICON ROW
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 🔙 BACK BUTTON
                          InkWell(
                            onTap: () => context.pop(),
                            child: SvgPicture.asset(AppAssets.back),
                          ),
                        ],
                      ),
                    ),

                    /// 🔥 TITLE + ID
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${mydata?.clientContact.fullName}",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "ID: ${mydata?.project.idLabel}",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildInfoCard(),
              ],
            ),
          ),
          if (isloading) AppLoader(),
        ],
      ),
    );
  }

  /// -------------------- WIDGETS --------------------
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.xxxlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 TITLE + ID
                const SizedBox(height: 16),

                /// 📅 DATE
                _infoRow(
                  Icons.calendar_today,
                  DateTimeUtils.formatDate("${mydata?.project.eventDate}"),
                ),
                const SizedBox(height: 10),

                /// ⏰ TIME
                _infoRow(
                  Icons.access_time,
                  "${DateTimeUtils.formatTime(mydata?.project.startTime ?? "")} - ${DateTimeUtils.formatTime(mydata?.project.endTime ?? "")}",
                ),
                const SizedBox(height: 10),

                /// 📍 LOCATION
                _infoRow(
                  Icons.location_on_outlined,
                  "${mydata?.project.eventLocation}",
                ),

                const SizedBox(height: 18),
                Divider(color: AppColors.dividerDark, thickness: 0.8),

                /// 🔘 TYPE ROW
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 LABEL ROW (2 Equal Columns)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Shoot Type",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              color: AppColors.white30,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Booking Type",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              color: AppColors.white30,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// 🔹 CHIP ROW (2 Equal Columns)
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _chip("${mydata?.project.shootType}"),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _chip("${mydata?.project.bookingType}"),
                          ),
                        ),
                      ],
                    ),

                    /// 🔹 DASHED DIVIDER (Proper Style)
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔹 DASHED DIVIDER
                Divider(color: AppColors.dividerDark, thickness: 0.8),

                const SizedBox(height: 20),

                /// 🔥 SHOOT STATUS BOX
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOpacity70,
                    borderRadius: AppRadii.xlAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Shoot Status",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(
                        color: AppColors.dividerDark,
                        thickness: 0.8,
                      ),
                      const SizedBox(height: 14),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Stage",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              color: AppColors.white30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Pre Production",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Last Updated",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              color: AppColors.white30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            DateTimeUtils.formatDateTime(
                              mydata?.project.lastUpdated?.toString(),
                            ),
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
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
          const SizedBox(height: 20),
          Divider(color: AppColors.dividerDark, thickness: 0.8),

          /*     Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Team Members",style: TextStyle(color: AppColors.white,fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
              Text(
                "(${(mydata?.teamSummary.assignedCount ?? 0).toString().padLeft(2, '0')}/04)",
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
          ]
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 150, // 👈 important for horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mydata?.teamMembers.length ?? 0,
              itemBuilder: (context, index) {
                final member = mydata!.teamMembers[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildMember(
                    name: member.name ?? "",
                    role: member.roleName ?? "",
                    image: member.profileImageUrl ?? "",
                  ),
                  );
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //     ],
          //   ),
          // ),
          Divider(
            color: AppColors.dividerDark,
            thickness: 0.8,
          ),*/
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Time & Budget",
                style: TextStyle(
                  color: AppColors.white,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.portfolioCompactAll,
            ),
            child: Row(
              children: [
                /// 🔹 LEFT ITEM
                Expanded(
                  child: _budgetCardItem(
                    icon: Icons.attach_money,
                    title: "Event Budget",
                    value: "\$${mydata?.project.budget}",
                  ),
                ),

                const SizedBox(width: 20),

                /// 🔹 RIGHT ITEM
                Expanded(
                  child: _budgetCardItem(
                    icon: Icons.access_time,
                    title: "Total Time Duration",
                    value:
                        "${mydata?.project.totalTimeDurationHours ?? 0} hours",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          /// 🔥 CLIENT CONTACT SECTION
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(borderRadius: AppRadii.r26All),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                SizedBox(height: 12),

                /// 🔹 TITLE
                const Text(
                  "Client Contact Information",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 18),

                _contactItem(
                  icon: SvgPicture.asset(AppAssets.person_icons),
                  title: "Contact Name",
                  value: "${mydata?.clientContact.fullName}",
                ),

                const SizedBox(height: 14),

                _contactItem(
                  icon: SvgPicture.asset(AppAssets.Phone_Calling),
                  title: "Contact Number",
                  value: mydata?.clientContact.phone ?? 'No number found',
                ),

                const SizedBox(height: 14),

                _contactItem(
                  icon: SvgPicture.asset(AppAssets.mail_icon),
                  title: "Email ID",
                  value: "${mydata?.clientContact.email}",
                ),

                const SizedBox(height: 24),

                /// 🔹 VIEW TIMELINE
                const SizedBox(height: 24),

                /// 🔹 BUTTON ROW
                /*       Row(
                  children: [

                    /// CANCEL
                    Expanded(
                      child: InkWell(
                        borderRadius: AppRadii.xlAll,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (_, _, _) => const CancelScreen(),
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
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.pinkSoft,
                            borderRadius: AppRadii.xlAll,
                          ),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// ACCEPT
                    Expanded(
                      child: InkWell(
                        borderRadius: AppRadii.xlAll,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShootRequestAccepted(), // 👈 next screen
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadii.xlAll,
                          ),
                          child: const Center(
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetCardItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// ICON BOX
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadii.lgAll,
          ),
          child: Icon(icon, color: AppColors.black, size: 20),
        ),

        const SizedBox(width: 10),

        /// TEXT SECTION
        Expanded(
          // 🔥 VERY IMPORTANT
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1, // 🔥 Prevent overflow
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.white60),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: "Outfit",
              color: AppColors.white30,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: AppRadii.portfolioAll,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Outfit",
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMember({
    required String name,
    required String role,
    required String image,
  }) {
    return SizedBox(
      width: 90, // 👈 fixed width for horizontal scroll
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: image.isNotEmpty
                ? NetworkImage(
                    ApiService.imageURL + image,
                  ) // 👈 base url add kar
                : null,
            child: image.isEmpty
                ? Icon(Icons.person, color: AppColors.white)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: "Outfit",
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: "Outfit",
              color: AppColors.white24,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _contactItem({
    required Widget icon,

    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 BIGGER ICON CONTAINER
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.xxlAll,
          ),
          child: Center(child: icon),
        ),

        const SizedBox(width: 16),

        /// 🔹 TEXT SECTION
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white30,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showProjectTimelineDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCharcoal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              /// DRAG HANDLE
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: AppRadii.hugeAll,
                ),
              ),

              const SizedBox(height: 20),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Project Timeline",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.white),

              const SizedBox(height: 10),

              /// TIMELINE LIST
              Expanded(
                child: ListView(
                  children: [
                    timelineStaticItem(
                      icon: Icons.person_outline,
                      title: "Initiated",
                      active: true,
                    ),

                    timelineStaticItem(
                      icon: Icons.work_outline,
                      title: "Pre Production",
                    ),

                    timelineStaticItem(
                      icon: Icons.calendar_today_outlined,
                      title: "Post Production",
                    ),

                    timelineStaticItem(
                      icon: Icons.local_shipping_outlined,
                      title: "Delivered",
                    ),

                    timelineStaticItem(
                      icon: Icons.check_circle_outline,
                      title: "Completed",
                    ),

                    timelineStaticItem(
                      icon: Icons.cancel_outlined,
                      title: "Cancelled",
                      showLine: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget timelineStaticItem({
    required IconData icon,
    required String title,
    bool active = false,
    bool showLine = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT SIDE
        Column(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.primary : AppColors.surfaceVariant,
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? AppColors.black : AppColors.white54,
              ),
            ),

            if (showLine)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.white24, width: 2),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        /// RIGHT SIDE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: active ? AppColors.primary : AppColors.white,
                    ),
                  ),
                  const Text(
                    "Today, 10:34 AM",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 11,
                      color: AppColors.white54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 12,
                  color: AppColors.white54,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  void showCancelDialog(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCharcoal,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// DRAG HANDLE
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white24,
                        borderRadius: AppRadii.hugeAll,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cancel Shoot Request",
                        style: TextStyle(
                          fontFamily: "Unbounded",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: AppColors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Please let us know why you're declining this request. "
                    "This helps improve future matching.",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 13,
                      color: AppColors.white30,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Divider(color: AppColors.dividerDark),

                  const SizedBox(height: 10),

                  /// REASON TITLE
                  const Text(
                    "Reason for Cancelling",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// RADIO LIST
                  Expanded(
                    child: ListView(
                      children: [
                        _buildReasonTile("Schedule conflict"),
                        _buildReasonTile("Equipment unavailable"),
                        _buildReasonTile("Location too far"),
                        _buildReasonTile("Rate too low"),
                        _buildReasonTile("Others"),

                        /// 👇 SHOW TEXTFIELD ONLY IF OTHERS SELECTED
                        if (isOtherSelected) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.xlAll,
                              border: Border.all(color: AppColors.white24),
                            ),
                            child: TextField(
                              controller: commentController,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: "Any additional details..",
                                hintStyle: TextStyle(color: AppColors.white24),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  /// COMMENT FIELD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.xlAll,
                      border: Border.all(color: AppColors.white24),
                    ),
                    child: TextField(
                      controller: commentController,
                      style: const TextStyle(color: AppColors.white),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Any additional details..",
                        hintStyle: TextStyle(color: AppColors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Decline",
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );

            /// RADIO TILE FUNCTION
          },
        );
      },
    );
  }

  Widget _buildReasonTile(String title) {
    bool isSelected = selectedReason == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedReason = title;
          isOtherSelected = title == "Others";
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            /// 🔘 CUSTOM CIRCLE
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.white24,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            /// 📝 TEXT
            Text(
              title,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 14, // 👈 proper size
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
