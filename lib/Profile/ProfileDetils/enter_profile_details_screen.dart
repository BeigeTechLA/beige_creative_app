import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Model_Class/EditProfileModel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/Custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

class EnterProfileDetailsScreen extends StatefulWidget {
  const EnterProfileDetailsScreen({super.key});

  @override
  State<EnterProfileDetailsScreen> createState() =>
      _EnterProfileDetailsScreenState();
}

class _EnterProfileDetailsScreenState
    extends State<EnterProfileDetailsScreen> {

  EditProfileModel? mylist;

  final TextEditingController experienceController =
  TextEditingController();
  final TextEditingController rateController =
  TextEditingController();
  final TextEditingController bioController =
  TextEditingController();

  String selectedRole = "Photographer";
  String? selectedSkill;

  List<String> skillList = [];

  @override
  void initState() {
    super.initState();
    editpersonaldetails();
  }

  // 🔥 GET DATA
  Future<void> editpersonaldetails() async {
    try {
      final apiResponse =
      await ApiService().postData(ApiEndpoints.editprofile, {});

      final response = EditProfileResponse.fromJson(apiResponse);
      final data = response.data;

      setState(() {
        mylist = data;

        experienceController.text =
            data.yearsOfExperience.toString();
        rateController.text =
            data.hourlyRate.toString();
        bioController.text = data.bio;

        // ✅ Role mapping
        selectedRole = data.primaryRole == "1"
            ? "Videographer "
            : data.primaryRole == "2"
            ? "Photographer"
            : "Editor";

        // ✅ Dynamic skills
        skillList = data.skills.map((e) => e.name).toList();

        selectedSkill =
        skillList.isNotEmpty ? skillList.first : null;
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }



  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// 🔙 BACK
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
        AppImages.back, // make sure it's .svg file
        height: 24,
        colorFilter: ColorFilter.mode(
          ColorCode.white,
          BlendMode.srcIn,
        ),
      ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// TITLE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Edit Professional Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ROLE
              CustomDropdownField(
                label: "Primary Role ",
                value: selectedRole,
                items: const [
                  "Photographer",
                  "Videographer",
                  "Editor"
                ],
                onChanged: (val) {
                  setState(() {
                    selectedRole = val!;
                  });
                },
              ),

              const SizedBox(height: 22),

              /// EXPERIENCE
              CustomTextField(
                label: "Year of Experience",
                controller: experienceController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 22),

              /// RATE
              CustomTextField(
                label: "Hourly Rate",
                controller: rateController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 22),

              /// BIO
              CustomTextField(
                label: "Bio / About",
                controller: bioController,
                maxLines: 4,
              ),

              const SizedBox(height: 22),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Highlight your creative focus.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 12),

              /// SKILLS (dynamic)
              CustomDropdownField(
                label: "Skills",
                value: selectedSkill,
                items: skillList,
                onChanged: (val) {
                  setState(() {
                    selectedSkill = val!;
                  });
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      /// SAVE BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6C3A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),//
              ),
            ),
            onPressed:() {

            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}