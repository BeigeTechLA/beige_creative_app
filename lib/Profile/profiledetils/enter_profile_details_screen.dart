import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../model_class/edit_profile_model.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../widgets/custom_multi_selectfield.dart' show CustomMultiSelectField;
import '../../widgets/custom_text_field.dart';

class EnterProfileDetailsScreen extends StatefulWidget {
  const EnterProfileDetailsScreen({super.key});

  @override
  State<EnterProfileDetailsScreen> createState() =>
      _EnterProfileDetailsScreenState();
}

class _EnterProfileDetailsScreenState
    extends State<EnterProfileDetailsScreen> {
  List<String> selectedRoles = [];

  EditProfileModel? mylist;
  List<String> selectedSkills = [];
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController rateController =TextEditingController();
  final TextEditingController bioController =TextEditingController();

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

      print("🚀 API CALL START");

      final rawResponse =
      await ApiService().postData(
        ApiEndpoints.editprofile,
        {},
      );

      print("📦 RAW RESPONSE 👉 $rawResponse");

      final response =
      EditProfileResponse.fromJson(
        rawResponse,
      );

      final data = response.data;

      if (!mounted) return;

      setState(() {

        mylist = data;

        /// ✅ TEXTFIELDS
        experienceController.text =
            data.yearsOfExperience.toString();

        rateController.text =
            data.hourlyRate.toString();

        bioController.text =
            data.bio;

        /// =========================
        /// ✅ PRIMARY ROLE FIX
        /// =========================

        selectedRoles.clear();

        if (data.primaryRole.isNotEmpty) {

          try {

            List<String> roleIds = [];


            if (data.primaryRole.startsWith("[")) {

              final decoded =
              jsonDecode(data.primaryRole);

              roleIds =
              List<String>.from(
                decoded.map(
                      (e) => e.toString(),
                ),
              );

            } else {

              roleIds =
                  data.primaryRole
                      .split(",")

                      .map(
                        (e) => e.trim(),
                  )

                      .toList();
            }

            for (var id in roleIds) {

              int roleId =
                  int.tryParse(id) ?? 0;

              final matchedRole =
              roleMap.entries.firstWhere(

                    (e) =>
                e.value == roleId,

                orElse: () =>
                const MapEntry("", 0),
              );

              if (matchedRole
                  .key
                  .isNotEmpty) {

                selectedRoles.add(
                  matchedRole.key,
                );
              }
            }

            print(
              "✅ SELECTED ROLES => $selectedRoles",
            );

          } catch (e) {

            print(
              "❌ ROLE PARSE ERROR 👉 $e",
            );
          }
        }

        /// =========================
        /// ✅ SKILLS
        /// =========================

        if (data.skills.isNotEmpty) {

          skillList =
              data.skills
                  .map((e) => e.name)
                  .toList();

          selectedSkills =
          List<String>.from(skillList);
        }
      });

    } catch (e) {

      print("❌ ERROR: $e");
    }
  }
  Future<void> fetchRoles() async {

    try {

      if (mounted) {

        setState(() {
          loading = true;
        });
      }

      final response =
      await ApiService().fetchData(
        ApiEndpoints.register_roles,
      );

      final List data = response['data'];

      final Map<String, int> tempMap = {};

      for (var item in data) {

        tempMap[item['role_name']] =
        item['role_id'];
      }

      if (!mounted) return;

      setState(() {

        roleMap = tempMap;

        roleList =
            tempMap.keys.toList();

        loading = false;
      });

    } catch (e) {

      if (mounted) {

        setState(() {
          loading = false;
        });
      }

      print("ROLE ERROR: $e");
    }
  }






  Future<void> fetchSkills() async {

    try {

      if (mounted) {

        setState(() {
          loading = true;
        });
      }

      final response =
      await ApiService().fetchData(
        ApiEndpoints.register_Skill,
      );

      final List data = response['data'];

      final Map<String, int> tempMap = {};

      for (var item in data) {

        tempMap[item['name']] =
        item['id'];
      }

      if (!mounted) return;

      setState(() {

        skillMap = tempMap;

        allSkills =
            tempMap.keys.toList();

        loading = false;
      });

    } catch (e) {

      if (mounted) {

        setState(() {
          loading = false;
        });
      }

      print("SKILL ERROR: $e");
    }
  }
  Future<void> updateProfile() async {

    try {

      /// =========================
      /// ✅ ROLE VALIDATION
      /// =========================

      if (selectedRoles.isEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Please select role",
            ),
          ),
        );

        return;
      }

      /// =========================
      /// ✅ ROLE IDS
      /// =========================

      List<int> roleIds =
      selectedRoles
          .map(
            (role) =>
        roleMap[role] ?? 0,
      )
          .where((id) => id != 0)
          .toList();

      if (roleIds.isEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid role selected",
            ),
          ),
        );

        return;
      }

      /// =========================
      /// ✅ EXPERIENCE
      /// =========================

      if (experienceController.text
          .trim()
          .isEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Enter experience",
            ),
          ),
        );

        return;
      }

      /// =========================
      /// ✅ RATE
      /// =========================

      if (rateController.text
          .trim()
          .isEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Enter hourly rate",
            ),
          ),
        );

        return;
      }

      /// =========================
      /// ✅ SKILLS
      /// =========================

      if (selectedSkills.isEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Select skills",
            ),
          ),
        );

        return;
      }

      /// =========================
      /// ✅ SKILL IDS
      /// =========================

      List<int> skillIds =
      selectedSkills
          .map(
            (skill) =>
        skillMap[skill] ?? 0,
      )
          .where((id) => id != 0)
          .toList();

      /// =========================
      /// ✅ BODY
      /// =========================

      final body = {

        "primary_role": roleIds,

        "years_of_experience":
        experienceController.text
            .trim(),

        "hourly_rate":
        rateController.text
            .trim(),

        "bio":
        bioController.text
            .trim(),

        "skills": skillIds,
      };

      print("📤 BODY => $body");

      /// =========================
      /// ✅ API CALL
      /// =========================

      final response =
      await ApiService().postData(
        ApiEndpoints.editprofile,
        body,
      );

      print("📥 RESPONSE => $response");

      /// =========================
      /// ✅ SUCCESS
      /// =========================

      if (response["error"] == false) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Profile Updated",
            ),
          ),
        );

        if (mounted) {

          context.pop(true);
        }

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response["message"]
                  .toString(),
            ),
          ),
        );
      }

    } catch (e) {

      print("❌ UPDATE ERROR => $e");
    }
  }
  String getPrimaryRole(String? role) {
    if (role == null || role.isEmpty) return "-";

    if (role.contains("1")) return "Videographer";
    if (role.contains("2")) return "Photographer";

    return "-";
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
                    onTap: () => context.pop(true),
                        child: SvgPicture.asset(
        AppAssets.back, // make sure it's .svg file
        height: 24,
        colorFilter: ColorFilter.mode(
          AppColors.white,
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
                    color: AppColors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ROLE
              CustomMultiSelectField(
                label: "Primary Role*",

                value: selectedRoles.join(", "),

                hasValue: selectedRoles.isNotEmpty,

                prefixIcon: SvgPicture.asset(
                  AppAssets.dropdown,
                ),

                onTap: () async {
                  _openRolesBottomSheet();
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
                  style: TextStyle(color: AppColors.lavenderGrey),
                ),
              ),

              const SizedBox(height: 12),

     /*         GestureDetector(

                onTap: _openSkillsBottomSheet,
                child: AbsorbPointer(
                  child: TextField(
                    style: const TextStyle(color: AppColors.white),

                    decoration: _inputDecoration("Add Skills").copyWith(
                      hintText: _skillsDisplayText(),
                      hintStyle: const TextStyle(color: AppColors.white),
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),*/

              CustomMultiSelectField(
                label: "Edit Skills",
                value: selectedSkills.join(", "),
                hasValue: selectedSkills.isNotEmpty,
                onTap: () async {
                  _openSkillsBottomSheet(); // ✅ important
                },
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
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.xlAll,//
              ),
            ),
            onPressed:() {
              updateProfile();
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _openRolesBottomSheet() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor:  AppColors.background,
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
                      color: AppColors.white24,
                      borderRadius: AppRadii.xsAll,
                    ),
                  ),

                  /// TITLE
                  const Text(
                    "Select Roles",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 📜 ROLE LIST
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: roleList.map((role) {

                        final isSelected =
                        selectedRoles.contains(role);

                        return CheckboxListTile(

                          value: isSelected,

                          title: Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Outfit",
                            ),
                          ),

                          activeColor: AppColors.primary,
                          checkColor: AppColors.black,

                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.lavenderGrey,
                            width: 1.5,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.smAll,
                          ),

                          onChanged: (val) {

                            setModalState(() {

                              if (val == true) {

                                if (!selectedRoles.contains(role)) {

                                  selectedRoles.add(role);
                                }

                              } else {

                                selectedRoles.remove(role);
                              }

                              print(
                                "✅ SELECTED ROLES => $selectedRoles",
                              );
                            });

                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✅ DONE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: AppColors.textHeading,
                          fontSize: 15,
                          fontFamily: "Outfit",
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
  void _openSkillsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCropSheet,
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
                      color: AppColors.white24,
                      borderRadius: AppRadii.xsAll,
                    ),
                  ),

                  /// TITLE
                  Text(
                    "Select Skills",
                    style: TextStyle(
                      color: AppColors.white,
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
                          activeColor: AppColors.primary,
                          checkColor: AppColors.black,
                          title: Text(
                            skill,
                            style:
                            const TextStyle(color: AppColors.white),
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
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: AppColors.textHeading,
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
      labelStyle: const TextStyle(color: AppColors.white30),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.lgAll,
        borderSide:
        const BorderSide(color: AppColors.white30, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.lgAll,
        borderSide:
        const BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }

}