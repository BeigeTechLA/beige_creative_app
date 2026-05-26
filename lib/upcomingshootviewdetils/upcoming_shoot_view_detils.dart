import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/app/assets.dart';
import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../model_class/upcoming_shootview_model.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import '../utility/date_time_utils.dart';

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
                            AppColors.black.withValues(alpha: 0.3),
                            AppColors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),*/

                    /// 🔥 TOP ICON ROW
                    Positioned(
                      top: 50,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
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
                      bottom: AppSpacing.xl,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${mydata?.clientContact.fullName}",
                              style: AppTextStyles.displayLabel16.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            "ID: ${mydata?.project.idLabel}",
                            style: AppTextStyles.bodyMediumStrong.copyWith(
                              color: AppColors.primary,
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.mld),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.xxxlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 TITLE + ID
                const SizedBox(height: AppSpacing.lg),

                /// 📅 DATE
                _infoRow(
                  Icons.calendar_today,
                  DateTimeUtils.formatDate("${mydata?.project.eventDate}"),
                ),
                const SizedBox(height: AppSpacing.xs),

                /// ⏰ TIME
                _infoRow(
                  Icons.access_time,
                  "${DateTimeUtils.formatTime(mydata?.project.startTime ?? "")} - ${DateTimeUtils.formatTime(mydata?.project.endTime ?? "")}",
                ),
                const SizedBox(height: AppSpacing.xs),

                /// 📍 LOCATION
                _infoRow(
                  Icons.location_on_outlined,
                  "${mydata?.project.eventLocation}",
                ),

                const SizedBox(height: AppSpacing.mld),
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
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white30,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Booking Type",
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white30,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

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
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                /// 🔹 DASHED DIVIDER
                Divider(color: AppColors.dividerDark, thickness: 0.8),

                const SizedBox(height: AppSpacing.xl),

                /// 🔥 SHOOT STATUS BOX
                Container(
                  padding: const EdgeInsets.all(AppSpacing.mld),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOpacity70,
                    borderRadius: AppRadii.xlAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Shoot Status",
                        style: AppTextStyles.bodyMediumStrong.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Divider(
                        color: AppColors.dividerDark,
                        thickness: 0.8,
                      ),
                      const SizedBox(height: AppSpacing.mld),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Stage",
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white30,
                            ),
                          ),
                          Text(
                            "Pre Production",
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Last Updated",
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white30,
                            ),
                          ),
                          Text(
                            DateTimeUtils.formatReadableDateTime(
                              mydata?.project.lastUpdated?.toString(),
                            ),
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white,
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
          const SizedBox(height: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Time & Budget",
                style: AppTextStyles.displayLabel14Strong.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mld),
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

                const SizedBox(width: AppSpacing.xl),

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
          const SizedBox(height: AppSpacing.xs),

          /// 🔥 CLIENT CONTACT SECTION
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(borderRadius: AppRadii.r26All),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: AppSpacing.md),

                /// 🔹 TITLE
                const Text(
                  "Client Contact Information",
                  style: AppTextStyles.displayLabel14Strong,
                ),

                const SizedBox(height: AppSpacing.mld),

                _contactItem(
                  icon: SvgPicture.asset(AppAssets.person_icons),
                  title: "Contact Name",
                  value: "${mydata?.clientContact.fullName}",
                ),

                const SizedBox(height: AppSpacing.mld),

                _contactItem(
                  icon: SvgPicture.asset(AppAssets.Phone_Calling),
                  title: "Contact Number",
                  value: mydata?.clientContact.phone ?? 'No number found',
                ),

                const SizedBox(height: AppSpacing.mld),

                _contactItem(
                  icon: SvgPicture.asset(AppAssets.mail_icon),
                  title: "Email ID",
                  value: "${mydata?.clientContact.email}",
                ),

                const SizedBox(height: AppSpacing.xxl),

                /// 🔹 VIEW TIMELINE
                const SizedBox(height: AppSpacing.xxl),

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

        const SizedBox(width: AppSpacing.xs),

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
                style: AppTextStyles.body12.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.xxs),

              Text(
                value,
                style: AppTextStyles.body12.copyWith(
                  color: AppColors.white.withValues(alpha: 0.6),
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
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body12.copyWith(
              color: AppColors.white30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: AppRadii.portfolioAll,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.body12.copyWith(
          color: AppColors.primary,
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body11.copyWith(
              color: AppColors.white24,
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

        const SizedBox(width: AppSpacing.md),

        /// 🔹 TEXT SECTION
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white30,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: AppTextStyles.bodyMediumStrong.copyWith(
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
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

              const SizedBox(height: AppSpacing.xl),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Project Timeline",
                    style: AppTextStyles.displayLabel16,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
              const Divider(color: AppColors.white),

              const SizedBox(height: AppSpacing.xs),

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
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.white24, width: 2),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: AppSpacing.lg),

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
                    style: AppTextStyles.bodyMediumStrong.copyWith(
                      color: active ? AppColors.primary : AppColors.white,
                    ),
                  ),
                  const Text(
                    "Today, 10:34 AM",
                    style: AppTextStyles.body11,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              const Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                style: AppTextStyles.body12,
              ),

              const SizedBox(height: AppSpacing.xl),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
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

                  const SizedBox(height: AppSpacing.xl),

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cancel Shoot Request",
                        style: AppTextStyles.displayLabel16,
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: AppColors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Please let us know why you're declining this request. "
                    "This helps improve future matching.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white30,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s15),

                  Divider(color: AppColors.dividerDark),

                  const SizedBox(height: AppSpacing.xs),

                  /// REASON TITLE
                  const Text(
                    "Reason for Cancelling",
                    style: AppTextStyles.bodyMediumStrong,
                  ),

                  const SizedBox(height: AppSpacing.xs),

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
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.xlAll,
                              border: Border.all(color: AppColors.white24),
                            ),
                            child: TextField(
                              controller: commentController,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                              ),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Any additional details..",
                                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white24),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.xlAll,
                      border: Border.all(color: AppColors.white24),
                    ),
                    child: TextField(
                      controller: commentController,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Any additional details..",
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.mld),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white30),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.mld),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.mld),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.mld),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Decline",
                            style: AppTextStyles.bodyMediumStrong.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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

            const SizedBox(width: AppSpacing.mld),

            /// 📝 TEXT
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
