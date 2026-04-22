import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Model_Class/EditProfileModel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/CustomDropdown.dart';
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
  List<String> selectedSkills = [];
  final TextEditingController experienceController =
  TextEditingController();
  final TextEditingController rateController =
  TextEditingController();
  final TextEditingController bioController =
  TextEditingController();
  String? primaryRole;
  String? experience;
  String? hourlyRate;
  String? skills;
  String? equipment;
  String? selectedSkill;
  List<String> skillList = [];
  bool loading = true;

  Map<String, int> skillMap = {};
  Map<String, int> equipmentMap = {};
  // 🔥 DATA
  List<String> roleList = [];
  Map<String, int> roleMap = {};

  List<String> allSkills = [];
  @override
  void initState() {
    super.initState();
    editpersonaldetails();
    fetchRoles();
    fetchSkills();
  }


  String _skillsDisplayText() {
    if (selectedSkills.isEmpty) {
      return "Select skills";
    }

    if (selectedSkills.length == 1) {
      return selectedSkills.first;
    }

    return "${selectedSkills.first} +${selectedSkills.length - 1}";
  }

  // 🔥 GET DATA
  Future<void> editpersonaldetails() async {
    try {
      final Response =
      await ApiService().postData(ApiEndpoints.editprofile, {});

      final response = EditProfileResponse.fromJson(Response);
      final data = response.data;

      setState(() {
        mylist = data;

        experienceController.text =
            data.yearsOfExperience.toString();
        rateController.text =
            data.hourlyRate.toString();
        bioController.text = data.bio;

        // ✅ Role mapping
        primaryRole = data.primaryRole == "1"
            ? "Videographer"
            : data.primaryRole == "2"
            ? "Photographer"
            : "Editor";

        // ✅ Dynamic skills
        skillList = data.skills.map((e) => e.name).toList();
        selectedSkills =
            data.skills.map((e) => e.name).toList();
       /* selectedSkill =
        skillList.isNotEmpty ? skillList.first : null;*/
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }


  Future<void> fetchRoles() async {
    try {
      loading = true;
      setState(() {});

      final response =
      await ApiService().fetchData(ApiEndpoints.register_roles);

      final List data = response['data'];

      final Map<String, int> tempMap = {};

      for (var item in data) {
        tempMap[item['role_name']] = item['role_id'];
      }

      setState(() {
        roleMap = tempMap;
        roleList = tempMap.keys.toList();
        loading = false;
      });
    } catch (e) {
      loading = false;
      setState(() {});
      print("ROLE ERROR: $e");
    }
  }

  Future<void> fetchSkills() async {
    try {
      loading = true;
      setState(() {});

      final response =
      await ApiService().fetchData(ApiEndpoints.register_Skill);

      final List data = response['data'];

      final Map<String, int> tempMap = {};

      for (var item in data) {
        tempMap[item['name']] = item['id'];
      }

      setState(() {
        skillMap = tempMap;
        allSkills = tempMap.keys.toList();
        loading = false;
      });
    } catch (e) {
      loading = false;
      setState(() {});
      print("SKILL ERROR: $e");
    }
  }
  Future<void> updateProfile() async {
    try {
      // ✅ ROLE VALIDATION
      if (primaryRole == null || primaryRole!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select role")),
        );
        return;
      }

      int? roleId = roleMap[primaryRole];

      if (roleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid role selected")),
        );
        return;
      }

      // ✅ EXPERIENCE VALIDATION
      if (experienceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter experience")),
        );
        return;
      }

      // ✅ RATE VALIDATION
      if (rateController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter hourly rate")),
        );
        return;
      }

      // ✅ SKILLS VALIDATION
      if (selectedSkills.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select skills")),
        );
        return;
      }

      // ✅ SKILL IDS
      List<int> skillIds = selectedSkills
          .map((skill) => skillMap[skill] ?? 0)
          .where((id) => id != 0)
          .toList();

      // ✅ BODY
      final body = {
        "primary_role": roleId.toString(),
        "years_of_experience": experienceController.text.trim(),
        "hourly_rate": rateController.text.trim(),
        "bio": bioController.text.trim(),
        "skills": skillIds,
      };

      print("📤 BODY: $body");

      final response = await ApiService().postData(
        ApiEndpoints.editprofile,
        body,
      );

      print("📥 RESPONSE: $response");

      if (response["error"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated")),
        );

        // 🔥 🔥 MOST IMPORTANT LINE
        Navigator.pop(context, true);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"])),
        );
      }

    } catch (e) {
      print("❌ ERROR: $e");
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
                    onTap: () => Navigator.pop(context,true),
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
              CustomDropdown(
                value: primaryRole,
                label:'Primary Role*',
                items: roleList
                    .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: (v) {
                  setState(() => primaryRole = v);
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

              GestureDetector(




                onTap: _openSkillsBottomSheet,
                child: AbsorbPointer(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),

                    decoration: _inputDecoration("Add Skills").copyWith(
                      hintText: _skillsDisplayText(),
                      hintStyle: const TextStyle(color: Colors.white),
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
        /*      /// SKILLS (dynamic)
              CustomDropdownField(
                label: "Edit Skills",
                value: selectedSkill,
                items: skillList,
                onChanged: (val) {
                  setState(() {
                    selectedSkill = val!;
                  });
                },
              ),*/

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
              updateProfile();
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
  void _openSkillsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔼 DRAG HANDLE
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  /// TITLE
                  Text(
                    "Select Skills",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// SKILLS LIST
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allSkills.length,
                      itemBuilder: (context, index) {
                        final skill = allSkills[index];
                        final isSelected =
                        selectedSkills.contains(skill);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: ColorCode.kButtonColor,
                          checkColor: Colors.black,
                          title: Text(
                            skill,
                            style:
                            const TextStyle(color: Colors.white),
                          ),
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked == true) {
                                selectedSkills.add(skill);
                              } else {
                                selectedSkills.remove(skill);
                              }
                            });

                            // update main UI also
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// OK BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.kButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: ColorCode.kHeadingColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  InputDecoration _inputDecoration(String title) {
    return InputDecoration(
      labelText: title,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(color: ColorCode.kWhiteOpacity70),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: ColorCode.kButtonColor, width: 1),
      ),
    );
  }

}