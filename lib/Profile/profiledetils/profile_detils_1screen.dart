import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../model_class/myprofile_model.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

class ProfileDetils1screen extends StatefulWidget {
  const ProfileDetils1screen({super.key});

  @override
  State<ProfileDetils1screen> createState() => _ProfileDetils1screenState();
}

class _ProfileDetils1screenState extends State<ProfileDetils1screen> {
  // String getPrimaryRole(String? role) {
  //   switch (role) {
  //     case "1": return "Videographer";
  //     case "2": return "Photographer";
  //     default: return "-";
  //   }
  // }

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchprofiledata();
  }
  String getPrimaryRole(String? role) {

    if (role == null || role.isEmpty) {
      return "-";
    }

    List<String> roles = [];

    /// ✅ VIDEOGRAPHER
    if (role.contains("1")) {
      roles.add("Videographer");
    }

    /// ✅ PHOTOGRAPHER
    if (role.contains("2")) {
      roles.add("Photographer");
    }

    if (roles.isEmpty) {
      return "-";
    }

    return roles.join(", ");
  }

  User? user;
  Data? profileData;
  Future<void> fetchprofiledata() async {
    try {
      setState(() {
        isLoading = true; // 🔥 START LOADER
      });

      final response = Myprofilemodel.fromJson(
        await ApiService().postData(ApiEndpoints.profiledetails, {}),
      );

      if (response.error == false) {
        setState(() {
          user = response.data.user;
          profileData = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error is::$e");
    } finally {
      setState(() {
        isLoading = false; // 🔥 STOP LOADER
      });
    }
  }


  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                /// 🔝 TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.smd,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child:SvgPicture.asset(
                    AppAssets.back,

                            height: 24),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Profile Details",
                            style: AppTextStyles.displayLabel16,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxl),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔘 TAB BAR
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxs,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.s5),
                  height: 53,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.xlAll,
                  ),
                  child: Row(
                    children: [
                      _buildTab("Personal", 0),
                      _buildTab("Professional", 1),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 👤 PROFILE CARD
                Expanded(
                  child: selectedTab == 0
                      ? _buildPersonalCard()
                      : _buildProfessionalCard(),
                ),
              ],
            ),
          ),
          if(isLoading)
            AppLoader()
        ],

      ),
    );
  }

  Widget _buildPersonalCard() {
    final nameParts = (user?.name ?? "").trim().split(" ");
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty ? nameParts.first : "No name";
    final lastName = nameParts.length > 1 && nameParts.last.isNotEmpty ? nameParts.last : "No Name";
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: AppSpacing.s50,
            left: AppSpacing.authCardCompactTop,
            right: AppSpacing.authCardCompactTop,
            bottom: AppSpacing.xl,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.profileCardTop,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.hugeAll,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
           Text(
                  "$firstName $lastName",
                  style: AppTextStyles.displayBold20,
                ),

                const SizedBox(height: 15),

                _editButton(),

                const SizedBox(height: 25),
                Container(
                  height: 1,
                  width: double.infinity,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.whiteTransparent,
                        AppColors.white10,
                        AppColors.white20,
                        AppColors.white10,
                        AppColors.whiteTransparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                  _buildInfoRow("First Name", firstName),
                  _buildInfoRow("Last Name", lastName),
                _buildInfoRow("Email", user?.email ?? "No Email Found"),
                // _buildInfoRow("Contact Number", user?.phoneNumber ?? "No mobile number found"),
                _buildInfoRow("Location", user?.location ?? "No location Found"),
               /* _buildInfoRow(
                  "Working Distance",
                  profileData?.workingDistance ?? "No found",
                )*/
              ],
            ),
          ),
        ),

        // ✅ Avatar with golden border
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.goldSoftSand,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              (profileData?.profileImageUrl ?? "").isNotEmpty
                  ? "${ApiService.imageURL}${profileData!.profileImageUrl}"
                  : "",
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return SvgPicture.asset(
                  AppAssets.User_Circle,
                  fit: BoxFit.cover,
                );
              },
            )
          )
        ),
      ],
    );
  }

  Widget _buildProfessionalCard() {
    final nameParts = (user?.name ?? "").trim().split(" ");
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty ? nameParts.first : "No name";
    final lastName = nameParts.length > 1 && nameParts.last.isNotEmpty ? nameParts.last : "No Name";
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin:  const EdgeInsets.only(
            top: AppSpacing.profileCardTop,
            left: AppSpacing.authCardCompactTop,
            right: AppSpacing.authCardCompactTop,
            bottom: AppSpacing.xl,
          ),
          padding:  const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.profileCardTop,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.hugeAll,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                  Center(
                  child: Text(
                    "$firstName $lastName",
                    style: AppTextStyles.displayBold20,
                  ),
                ),

                const SizedBox(height: 15),
                Center(child: _editButton()),

                const SizedBox(height: 25),
                Container(
                  height: 1,
                  width: double.infinity,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.whiteTransparent,
                        AppColors.white10,
                        AppColors.white20,
                        AppColors.white10,
                        AppColors.whiteTransparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// 🔥 FIXED (NO getPrimaryRole)
                _buildInfoRow(
                  "Primary Role",
                  getPrimaryRole(profileData?.primaryRole),
                ),

                /// 🔥 FIXED (use profileData)
                _buildInfoRow(
                  "Years of Experience",
                  profileData != null
                      ? "${profileData!.yearsOfExperience} Years"
                      : "-",
                ),

                /// 🔥 FIXED (use profileData)
                _buildInfoRow(
                  "Hourly Rate (\$)",
                  profileData != null && profileData!.hourlyRate.isNotEmpty
                      ? "\$${profileData!.hourlyRate}"
                      : "No Rate Found",
                ),

                const SizedBox(height: 15),

                const Text(
                  "Skills",
                  style: AppTextStyles.body14,
                ),

                const SizedBox(height: 8),

                /// 🔥 FIXED (dynamic skills)
                Wrap(
                  alignment: WrapAlignment.end,   // 🔥 ye add kar

                  spacing: 10,
                  runSpacing: 10,
                  children: profileData?.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.mld,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.smAll,

                        /// 🔥 GRADIENT BORDER EFFECT
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.08),
                          width: 1,
                        ),

                        /// 🔥 GLASS BACKGROUND
                        gradient: LinearGradient(
                          colors: [
                            AppColors.white10,
                            AppColors.white10,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),

                      child: Text(
                        skill.name,
                        style: AppTextStyles.bodyCompact.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    );
                  }).toList() ?? [],
                ),

                const SizedBox(height: 20),
                Container(
                  height: 1,
                  width: double.infinity,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.whiteTransparent,
                        AppColors.white10,
                        AppColors.white20,
                        AppColors.white10,
                        AppColors.whiteTransparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Bio / About",
                  style: AppTextStyles.body14,
                ),

                const SizedBox(height: 8),

                /// 🔥 FIXED (dynamic bio)
                Text(
                  profileData?.bio.isNotEmpty == true
                      ? profileData!.bio
                      : "-",
                  style: AppTextStyles.bodyCompact.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// AVATAR
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.goldSoftSand,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              (profileData?.profileImageUrl ?? "").isNotEmpty
                  ? "${ApiService.imageURL}${profileData!.profileImageUrl}"
                  : "",
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return SvgPicture.asset(
                  AppAssets.User_Circle,
                  fit: BoxFit.cover,
                );
              },
            )
          )
        ),
      ],
    );
  }

/*  Widget _editButton() {
    return InkWell(
      onTap: () {
        if (selectedTab == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditPersonalDetailsScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EnterProfileDetailsScreen(),
            ),
          );

        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s25,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadii.portfolioAll,
        ),
        child: const Text(
          "Edit Profile Details",
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }*/
  Widget _editButton() {
    return InkWell(
      onTap: () async {
        final result = await context.pushNamed(
          selectedTab == 0
              ? RouteNames.editPersonalDetails
              : RouteNames.enterProfessionalDetails,
        );

        // 🔥 BACK AANE KE BAAD REFRESH
        if (result == true) {
          fetchprofiledata(); // 👈 tera GET API
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s25,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadii.portfolioAll,
        ),
        child: const Text(
          "Edit Profile Details",
          style: AppTextStyles.body14Medium,
        ),
      ),
    );
  }
  Widget _buildTab(String title, int index) {
    bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.goldSoftSand
                : AppColors.transparent,
            borderRadius: AppRadii.mldAll,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.body14Medium.copyWith(
              color: isSelected
                  ? AppColors.textHeading
                  : AppColors.white30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.mld),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.body14.copyWith(color: AppColors.white),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body14.copyWith(color: AppColors.white60),
            ),
          ),
        ],
      ),
    );
  }
}