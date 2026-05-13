import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../Model_Class/upcoming_shootview_model.dart';
import '../utility/colorcode.dart';

class UpcomingShootViewDetils extends StatefulWidget {
  final int? projectid;
  const UpcomingShootViewDetils({super.key,  this.projectid});

  @override
  State<UpcomingShootViewDetils> createState() => _UpcomingShootViewDetilsState();
}

class _UpcomingShootViewDetilsState extends State<UpcomingShootViewDetils> {

  List<String> getProfileImageUrls() {
    if (mydata?.teamMembers == null) return [];

    return mydata!.teamMembers!
        .map((e) => ApiService.imageURL + (e.profileImageUrl ?? ""))
        .where((url) => !url.endsWith("/")) // empty remove
        .toList();
  }
  bool isloading=false;

  String formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime).toLocal(); // 👈 important
      return DateFormat("MMM d, yyyy h:mm a").format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }
  String formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(parsedTime);
    } catch (e) {
      return time; // fallback
    }
  }
  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (e) {
      return rawDate;
    }
  }


MyData? mydata;//

  Future<void> fetchupcomingshootview() async {

    setState(() {
      isloading = true;
    });

    /// 🔥 URL PRINT
    final url = 'creator/project-details/${widget.projectid}';

    debugPrint("🔥 API URL => $url");

    /// 🔥 API CALL
    final rawResponse =
    await ApiService().fetchData(url);

    /// 🔥 FULL RESPONSE PRINT
    debugPrint("🔥 API RESPONSE => $rawResponse");

    final response =
    Upcomingshootviewmodel.fromJson(rawResponse);

    if (response.error == false) {

      /// 🔥 IMAGE URL PRINT
      final imageUrl = ApiService().getImageURL(
        response.data.project.imageUrl ?? "",
      );

      debugPrint("🔥 IMAGE URL => $imageUrl");

      setState(() {
        mydata = response.data;
        isloading = false;
      });

    } else {

      setState(() {
        isloading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchupcomingshootview();
    debugPrint("🔥 Project ID received: ${widget.projectid}");

  }

  String selectedReason = "";
  bool isOtherSelected = false;
  TextEditingController commentController = TextEditingController();

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
                        borderRadius: BorderRadius.circular(0), // optional
                        child: Image.network(
                          ApiService().getImageURL(mydata?.project.imageUrl ?? ""),
                          fit: BoxFit.cover,

                          /// ❌ error → fallback
                          errorBuilder: (_, __, ___) {
                            return SvgPicture.asset(
                              // "assets/svg/image_holder.svg",
                              AppImages.image_holder,
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
                          ColorCode: [
                            ColorCode.black.withOpacity(0.3),
                            ColorCode.black.withOpacity(0.8),
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
                            onTap: () => Navigator.pop(context),
                            // child: Image.asset("assets/icons/Reply.png", height: 24,color: ColorCode.white,),
                            child: SvgPicture.asset(AppImages.back),
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
                        children:  [
                          Expanded(
                            child: Text(
                              "${mydata?.clientContact.fullName}",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                color: ColorCode.white,
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
                              color: ColorCode.kButtonColor,
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
          if(isloading)
            AppLoader()
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
              color: ColorCode.k282828,
              borderRadius: BorderRadius.circular(18),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔥 TITLE + ID


                const SizedBox(height: 16),

                /// 📅 DATE
                _infoRow(Icons.calendar_today, formatDate("${mydata?.project.eventDate}")),
                const SizedBox(height: 10),

                /// ⏰ TIME
                _infoRow(
                  Icons.access_time,
                  "${formatTime(mydata?.project.startTime ?? "")} - ${formatTime(mydata?.project.endTime ?? "")}",
                ),                const SizedBox(height: 10),

                /// 📍 LOCATION
                _infoRow(Icons.location_on_outlined,
                    "${mydata?.project.eventLocation}"),

                const SizedBox(height: 18),
                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,

                ),
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
                              color: ColorCode.kWhiteOpacity70,
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
                              color: ColorCode.kWhiteOpacity70,
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
                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,

                ),

                const SizedBox(height: 20),

                /// 🔥 SHOOT STATUS BOX
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorCode.k1D1D1B_Opacity70,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Shoot Status",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 14,
                          color: ColorCode.kButtonColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(
                        color: ColorCode.kDividerWhite12,
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
                              color: ColorCode.kWhiteOpacity70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Pre Production",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              color: ColorCode.white,
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
                              color: ColorCode.kWhiteOpacity70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            formatDateTime(mydata?.project.lastUpdated ?? ""),
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              color: ColorCode.white,
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
          Divider(
            color: ColorCode.kDividerWhite12,
            thickness: 0.8,
          ),

     /*     Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Team Members",style: TextStyle(color: ColorCode.white,fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
              Text(
                "(${(mydata?.teamSummary.assignedCount ?? 0).toString().padLeft(2, '0')}/04)",
                style: TextStyle(
                  color: ColorCode.kButtonColor,
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
          //       _buildMember(
          //         name: "Emma Hale",
          //         role: "Project Manager",
          //         image: "assets/images/shoot1.png",
          //       ),
          //       _buildMember(
          //         name: "Adam Brooks",
          //         role: "Production Manager",
          //         image: "assets/images/shoot2.png",
          //       ),
          //       _buildMember(
          //         name: "Nora Blake",
          //         role: "Sales Representative",
          //         image: "assets/images/shoot3.png",
          //       ),
          //     ],
          //   ),
          // ),
          Divider(
            color: ColorCode.kDividerWhite12,
            thickness: 0.8,
          ),*/
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Time & Budget",style: TextStyle(color: ColorCode.white,fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),

            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: ColorCode.k282828,
              borderRadius: BorderRadius.circular(22),
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
                    value: "${(mydata?.project.totalTimeDurationHours ?? 0).toString().padLeft(2, '0')} hours",

                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          /// 🔥 CLIENT CONTACT SECTION
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,
                ),
                SizedBox(height: 12,),

                /// 🔹 TITLE
                const Text(
                  "Client Contact Information",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorCode.white,
                  ),
                ),

                const SizedBox(height: 18),

                _contactItem(
                  icon: SvgPicture.asset(
                    AppImages.person_icons,

                  ),
                  title: "Contact Name",
                  value: "${mydata?.clientContact.fullName}",
                ),

                const SizedBox(height: 14),

                _contactItem(
                  icon: SvgPicture.asset(
                    AppImages.Phone_Calling,

                  ),
                  title: "Contact Number",
                  value: mydata?.clientContact.phone ?? 'No number found',                ),

                const SizedBox(height: 14),

                _contactItem(
                  icon: SvgPicture.asset(
                    AppImages.mail_icon,

                  ),
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
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
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
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAC5C5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorCode.red,
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
                        borderRadius: BorderRadius.circular(14),
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
                            color: ColorCode.kButtonColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorCode.black,
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
            color: ColorCode.kButtonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: ColorCode.black,
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        /// TEXT SECTION
        Expanded(   // 🔥 VERY IMPORTANT
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                maxLines: 1,                 // 🔥 Prevent overflow
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorCode.white,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorCode.white.withOpacity(0.6),
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
        Icon(icon, size: 16, color: ColorCode.white60),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: "Outfit",
              color: ColorCode.kWhiteOpacity70,
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
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: ColorCode.kButtonColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Outfit",
          color: ColorCode.kButtonColor,
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
                ? NetworkImage(ApiService.imageURL + image) // 👈 base url add kar
                : null,
            child: image.isEmpty
                ? Icon(Icons.person, color: ColorCode.white)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: "Outfit",
              color: ColorCode.white,
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
              color: ColorCode.white24,
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
            color: ColorCode.k282828,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: icon,
          ),
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
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorCode.white,
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
      backgroundColor: ColorCode.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFF1B1B1B),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [

              /// DRAG HANDLE
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: ColorCode.white24,
                  borderRadius: BorderRadius.circular(20),
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
                      color: ColorCode.white,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: ColorCode.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(color: ColorCode.white),

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
                color: active
                    ? ColorCode.kButtonColor
                    : const Color(0xFF2A2A2A),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? ColorCode.black : ColorCode.white54,
              ),
            ),

            if (showLine)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: ColorCode.white24,
                      width: 2,
                    ),
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
                      color: active
                          ? ColorCode.kButtonColor
                          : ColorCode.white,
                    ),
                  ),
                  const Text(
                    "Today, 10:34 AM",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 11,
                      color: ColorCode.white54,
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
                  color: ColorCode.white54,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  void showCancelDialog( context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorCode.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1B1B1B),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
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
                        color: ColorCode.white24,
                        borderRadius: BorderRadius.circular(20),
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
                          color: ColorCode.white,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: ColorCode.white),
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
                      color: ColorCode.kWhiteOpacity70,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Divider(color: ColorCode.white12),

                  const SizedBox(height: 10),

                  /// REASON TITLE
                  const Text(
                    "Reason for Cancelling",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorCode.white,
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
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ColorCode.white24),
                            ),
                            child: TextField(
                              controller: commentController,
                              style: const TextStyle(color: ColorCode.white, fontSize: 14),
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: "Any additional details..",
                                hintStyle: TextStyle(color: ColorCode.white24),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),

                  /// COMMENT FIELD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ColorCode.white24),
                    ),
                    child: TextField(
                      controller: commentController,
                      style: const TextStyle(color: ColorCode.white),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Any additional details..",
                        hintStyle: TextStyle(color: ColorCode.white24),
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
                            side: const BorderSide(color: ColorCode.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: ColorCode.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8D1AB),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Decline",
                            style: TextStyle(
                              color: ColorCode.black,
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
                  color: isSelected
                      ? ColorCode.kChampagneGold
                      : ColorCode.white24,
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
                    color: Color(0xFFE8D1AB),
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
                color: ColorCode.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
