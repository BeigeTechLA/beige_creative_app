import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Model_Class/myprofilemodel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../utility/imges_icons.dart';
import 'edit_personal_details_screen.dart';
import 'enter_profile_details_screen.dart';

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


  @override
  void initState() {
    super.initState();
    fetchprofiledata();
  }
  String getPrimaryRole(String? role) {
    if (role == null || role.isEmpty) return "-";

    if (role.contains("1")) return "Videographer";
    if (role.contains("2")) return "Photographer";

    return "-";
  }


  User? user;
  Data? profileData;
  Future<void>fetchprofiledata()async{

    try{
      final response=Myprofilemodel.fromJson(await ApiService().postData(ApiEndpoints.profiledetails,{}));

      debugPrint('API Response is :$response');

      if(response.error==false){
        setState(() {
          user=response.data.user;
          profileData = response.data; // ✅ ADD THIS

        });
      }else{

        debugPrint('error is:${response.message}');
      }


    }catch(e){
      debugPrint("Error is::$e");
    }finally{

    }
  }


  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            /// 🔝 TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset("assets/icons/back.png", height: 24),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Profile Details",
                        style: TextStyle(
                          fontFamily: "Unbounded",
                          color: ColorCode.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 🔘 TAB BAR
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              padding: const EdgeInsets.all(5),
              height: 53,
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.circular(14),
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
            top: 50,
            left: 13,
            right: 13,
            bottom: 20,
          ),
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorCode.k282828,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                 Text(
                  "$firstName $lastName",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Unbounded"
                  ),
                ),

                const SizedBox(height: 15),

                _editButton(),

                const SizedBox(height: 25),
                const Divider(color: Colors.white24),
                const SizedBox(height: 15),

                  _buildInfoRow("First Name", firstName),
                  _buildInfoRow("Last Name", lastName),
                _buildInfoRow("Email", user?.email ?? "No Email Found"),
                _buildInfoRow("Contact Number", user?.phoneNumber ?? "No mobile number found"),
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
              color: const Color(0xFFD6C3A1),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              ApiService().getImageURL(user?.profileImageUrl ?? ""),
              fit: BoxFit.cover,


              /// ❌ ERROR → SVG SHOW
              errorBuilder: (_, __, ___) {
                return SvgPicture.asset(
                  AppImages.User_Circle, // ✅ SVG fallback

                  fit: BoxFit.cover,
                );
              },
            ),
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
          margin:  EdgeInsets.only(
            top: 50,
            left: 13,
            right: 13,
            bottom: 20,
          ),
          padding:  EdgeInsets.fromLTRB(20, 70, 20, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorCode.k282828,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                 Center(
                  child: Text(
                    "$firstName $lastName",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                Center(child: _editButton()),

                const SizedBox(height: 25),
                const Divider(color: Colors.white24),
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
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔥 FIXED (dynamic skills)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profileData?.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skill.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList() ??
                      [],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Bio / About",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔥 FIXED (dynamic bio)
                Text(
                  profileData?.bio.isNotEmpty == true
                      ? profileData!.bio
                      : "-",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
              color: const Color(0xFFD6C3A1),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              ApiService().getImageURL(user?.profileImageUrl ?? ""),

              fit: BoxFit.cover,


              /// ❌ ERROR → SVG SHOW
              errorBuilder: (_, __, ___) {
                return SvgPicture.asset(
                  AppImages.User_Circle, //
                  fit: BoxFit.cover,
                );
              },
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: ColorCode.kButtonColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          "Edit Profile Details",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "Outfit",
            color: ColorCode.k282828,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }*/
  Widget _editButton() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => selectedTab == 0
                ? const EditPersonalDetailsScreen()
                : const EnterProfileDetailsScreen(),
          ),
        );

        // 🔥 BACK AANE KE BAAD REFRESH
        if (result == true) {
          fetchprofiledata(); // 👈 tera GET API
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: ColorCode.kButtonColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          "Edit Profile Details",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "Outfit",
            color: ColorCode.k282828,
            fontWeight: FontWeight.w500,
          ),
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
                ? const Color(0xFFD6C3A1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Outfit",
              fontSize: 14,
              color: isSelected
                  ? ColorCode.kHeadingColor
                  : ColorCode.kWhiteOpacity70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}