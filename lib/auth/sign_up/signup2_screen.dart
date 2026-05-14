import 'dart:io';
import 'dart:ui';

import 'package:beige_creative_app/widgets/custom_dropdown.dart';
import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:beige_creative_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/colorcode.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_multi_selectfield.dart';
import '../view_details_screen .dart';
import '../login/login.dart';
import 'signup3_screen.dart';

class SignUp2Screen extends StatefulWidget{
  final int ?crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final int step1Progress;
  final String? location;
  final String? workingDistance;
  const SignUp2Screen({super.key,
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,
    required this.step1Progress});

  @override
  State<SignUp2Screen> createState() =>
      SignUp2ScreenState();
}

class SignUp2ScreenState
    extends State<SignUp2Screen> {
  String? experience;
  String? hourlyRate;
  String? skills;
  String? equipment;

  final TextEditingController bioController = TextEditingController();
  final TextEditingController YearofExperienceController = TextEditingController();
  final TextEditingController equipmentController = TextEditingController();
  final TextEditingController HourlyRateController = TextEditingController();


  List<String> roleList = [];
  List<String> filteredEquipments = [];
  List<String> selectedEquipments = [];
  List<String> allSkills = [];
  List<String> selectedSkills = [];
  List<String> allEquipments = [];
  bool equipmentLoading = false;
  bool loading = true;

  String? selectedSkill;
  Map<String, int> roleMap = {};
  Map<String, int> skillMap = {};
  Map<String, int> equipmentMap = {};
  List<String> selectedRoles = [];
  int _calculateStep2Progress() {
    int totalFields = 6;
    int filled = 0;
    if (selectedRoles.isNotEmpty) filled++;
    if (YearofExperienceController.text.trim().isNotEmpty) filled++;
    if (HourlyRateController.text.trim().isNotEmpty) filled++;
    if (bioController.text.trim().isNotEmpty) filled++;
    if (selectedSkills.isNotEmpty) filled++;
    if (selectedEquipments.isNotEmpty) filled++;

    // Step 2 ka max = 40%
    double step2Percent = (filled / totalFields) * 40;

    return widget.step1Progress + step2Percent.toInt();
  }


  @override
  void initState() {
    super.initState();
    _fetchhome_roles();
    _fetchhome_Skills();

    YearofExperienceController.addListener(() => setState(() {}));
    HourlyRateController.addListener(() => setState(() {}));
    bioController.addListener(() => setState(() {}));
  }

  Future<void> _fetchhome_roles() async {
    try {
      final response =
      await ApiService().fetchData(ApiEndpoints.register_roles);

      if (response != null &&
          response['error'] == false &&
          response['data'] != null) {

        final List data = response['data'];

        final Set<String> roleSet = {};        // ✅ UNIQUE
        final Map<String, int> tempRoleMap = {};

        for (var item in data) {
          final String name = item['role_name'].toString();
          final int id = item['role_id']; // ⚠️ role_id (not id)

          if (!roleSet.contains(name)) {
            roleSet.add(name);
            tempRoleMap[name] = id; // ✅ keep FIRST id only
          }
        }

        setState(() {
          roleList = roleSet.toList();
          roleMap = tempRoleMap;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("ROLE ERROR: $e");
      setState(() => loading = false);
    }
  }
  void _openRolesBottomSheet() {
    FocusScope.of(context).unfocus();

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
                      color: ColorCode.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  /// TITLE
                  const Text(
                    "Select Roles",
                    style: TextStyle(
                      color: ColorCode.white,
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
                        final isSelected = selectedRoles.contains(role);

                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(
                            role,
                            style: const TextStyle(
                              color: ColorCode.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Outfit",
                            ),
                          ),

                          activeColor: ColorCode.kButtonColor,
                          checkColor: ColorCode.black,

                          side: BorderSide(
                            color: isSelected
                                ? ColorCode.kButtonColor
                                : ColorCode.grey,
                            width: 1.5,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),

                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                selectedRoles.add(role);
                              } else {
                                selectedRoles.remove(role);
                              }
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


  Future<void> _fetchhome_Skills() async{
    try {
      final response =
      await ApiService().fetchData(ApiEndpoints.register_Skill);

      if (response != null &&
          response['error'] == false &&
          response['data'] != null) {

        final List data = response['data'];

        final Set<String> skillSet = {};       // ✅ UNIQUE
        final Map<String, int> tempSkillMap = {};

        for (var item in data) {
          final String name = item['name'].toString();
          final int id = item['id'];

          if (!skillSet.contains(name)) {
            skillSet.add(name);
            tempSkillMap[name] = id; // ✅ first ID only
          }
        }

        setState(() {
          allSkills = skillSet.toList();
          skillMap = tempSkillMap;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("SKILL ERROR: $e");
      setState(() => loading = false);
    }
  }



  Future<void> _fetchhome_equipment(String query) async {
    if (query.isEmpty) {
      setState(() => filteredEquipments.clear());
      return;
    }

    try {
      setState(() => equipmentLoading = true);

      final response = await ApiService().fetchData(
        "${ApiEndpoints.register_equipment}?query=$query",
      );

      if (response != null &&
          response['error'] == false &&
          response['data'] != null) {

        final List data = response['data'];

        final List<String> equipments = [];
        final Map<String, int> tempEquipmentMap = {};

        for (var item in data) {
          final String name = item['equipment_name'].toString();
          final int id = item['equipment_id'];

          equipments.add(name);
          tempEquipmentMap[name] = id;
        }

        setState(() {
          filteredEquipments = equipments;
          equipmentMap.addAll(tempEquipmentMap); // 🔥 STORE IDS
        });
      }
    } catch (e) {
      debugPrint("EQUIPMENT ERROR: $e");
    } finally {
      setState(() => equipmentLoading = false);
    }
  }




  Future<void> _fetch_step2() async {
    try {
      setState(() => loading = true);

      debugPrint("🟢 STEP-2 BUTTON CLICKED");
      debugPrint("========== STEP-2 REQUEST ==========");

      /// 🔐 SAFE PARSING
      final int yearsOfExp =
          int.tryParse(YearofExperienceController.text.trim()) ?? 0;
      final int hourlyRate =
          int.tryParse(HourlyRateController.text.trim()) ?? 0;

      /// 🎯 PREPARED PAYLOAD
      final payload = {
        "crew_member_id": widget.crewMemberId,

        "primary_role": selectedRoles
            .map((e) => roleMap[e])
            .whereType<int>()
            .toList(),

        "years_of_experience":
        int.tryParse(YearofExperienceController.text.trim()) ?? 0,

        "hourly_rate":
        int.tryParse(HourlyRateController.text.trim()) ?? 0,

        "bio": bioController.text.trim(),

        "skills": selectedSkills
            .map((e) => skillMap[e])
            .whereType<int>()
            .toList(),

        "equipment_ownership": selectedEquipments
            .map((e) => equipmentMap[e])
            .whereType<int>()
            .toList(),
      };

      /// 🖨️ PRINT PAYLOAD
      payload.forEach((key, value) {
        debugPrint("$key : $value");
      });

      debugPrint("===================================");


      /// 🌐 API CALL
      final response = await ApiService()
          .postData(ApiEndpoints.register_step2, payload);

      /// 📥 PRINT RESPONSE
      debugPrint("🟢 STEP-2 RESPONSE:");
      debugPrint(response.toString());

      if (response != null && response['error'] == false) {
        debugPrint("✅ STEP-2 SUCCESS → Navigating to STEP-3");

        context.pushNamed(

          RouteNames.signupStep3,

          extra: {

            "crewMemberId":
            widget.crewMemberId,

            "profileImage":
            widget.profileImage,

            "email":
            widget.email,

            "firstName":
            widget.firstName,

            "lastName":
            widget.lastName,

            "location":
            widget.location,

            "workingDistance":
            widget.workingDistance,

            "primaryRole":
            selectedRoles.join(", "),

            "experience":
            YearofExperienceController.text.trim(),

            "hourlyRate":
            HourlyRateController.text.trim(),

            "bio":
            bioController.text.trim(),

            "skills":
            selectedSkills.join(", "),

            "equipments":
            selectedEquipments.join(", "),

            "step2Progress":
            _calculateStep2Progress(),
          },
        );
      /*  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignUp3Screen(
              crewMemberId: widget.crewMemberId,
              profileImage: widget.profileImage,
              email:widget.email,
              firstName: widget.firstName,
              lastName: widget.lastName,
              location: widget.location,
              workingDistance: widget.workingDistance,
              primaryRole: selectedRoles.join(", "),
              experience: YearofExperienceController.text.trim(),
              hourlyRate: HourlyRateController.text.trim(),
              bio: bioController.text.trim(),
              skills: selectedSkills.join(", "),
              equipments: selectedEquipments.join(", "),
              step2Progress: _calculateStep2Progress(),
            ),
          ),
        );*/
      } else {
        debugPrint("❌ STEP-2 FAILED MESSAGE: ${response?['message']}");
      }
    } catch (e, stack) {
      debugPrint("❌ STEP-2 EXCEPTION: $e");
      debugPrint("📛 STACKTRACE: $stack");
    } finally {
      setState(() => loading = false);
      debugPrint("🔚 STEP-2 LOADING STOPPED");
    }
  }
/*  bool get isPreviewVisible =>
      firstNameController.text.trim().isNotEmpty ||
          lastNameController.text.trim().isNotEmpty ||
          emailController.text.trim().isNotEmpty ||
          profileImage != null;*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                      children: [

                        /// 🔝 TOP IMAGE + TITLE SECTION
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.28,
                          child: Stack(
                            children: [

                              /// 🖼️ BACKGROUND IMAGE
                              Positioned.fill(
                                child: Image.asset(
                                  AppImages.rectangle,
                                  fit: BoxFit.fill,
                                ),
                              ),

                              /// 🔙 BACK BUTTON
                              Positioned(
                                top: 50,
                                left: 16,
                                right: 16,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    /// 🔙 BACK BUTTON
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: SvgPicture.asset(
                                        AppImages.back,
                                        fit: BoxFit.fill,
                                      ),
                                    ),

                                    /// 📄 STEP COUNT
                                    const Text(
                                      "2/3",
                                      style: TextStyle(
                                        color: ColorCode.white,
                                        fontSize: 14,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// 🏷️ TITLE + SUBTITLE (CENTER)
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:  [

                                    Text(
                                      "Professional Details",
                                      style: TextStyle(
                                        fontFamily: "Unbounded",
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ColorCode.white,
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      "Create your profile to get discovered by \nproduction teams.",

                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Outfit",
                                        fontSize: 14,
                                        color: ColorCode.kWhiteOpacity70,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        3,
                                            (index) => Container(
                                          width: 40,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: index <= 1
                                                ? ColorCode.kButtonColor
                                                : ColorCode.kSubtextColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        /// 📦 FORM CONTAINER (NICHE)
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [

                              /// 🧱 MAIN FORM CONTAINER
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: ColorCode.backgroundColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: ColorCode.white.withOpacity(0.06),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 50),
                                    //

                                    //           _dropdownField(
                                    //   "Primary Role*",
                                    //   primaryRole,
                                    //   roleList,
                                    //       (v) {
                                    //     setState(() => primaryRole = v);
                                    //   },
                                    // ),

                                    // CustomDropdown(
                                    //   value: primaryRole,
                                    //     label:'Primary Role*',
                                    //   items: roleList
                                    //       .map((e) => DropdownMenuItem<String>(
                                    //     value: e,
                                    //     child: Text(e,
                                    //         style: const TextStyle(color: ColorCode.white)),
                                    //   ))
                                    //       .toList(),
                                    //   onChanged: (v) {
                                    //     setState(() => primaryRole = v);
                                    //   },
                                    // ),
                                    // GestureDetector(
                                    //   onTap: _openRolesBottomSheet,
                                    //   child: AbsorbPointer(
                                    //     child: TextField(
                                    //       decoration: _inputDecoration("Primary Role*").copyWith(
                                    //         hintText: selectedRoles.isEmpty
                                    //             ? "Select roles"
                                    //             : "${selectedRoles.first} +${selectedRoles.length - 1}",
                                    //         suffixIcon: Icon(Icons.keyboard_arrow_down),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),

                                    CustomMultiSelectField(
                                      label: "Primary Role*",
                                      value: selectedRoles.join(", "),
                                      hasValue: selectedRoles.isNotEmpty,
                                      onTap: () async {
                                        _openRolesBottomSheet(); // ✅ must return Future
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // _textField(
                                    //   title: "Year sssssof Experience*",
                                    //   controller: YearofExperienceController,
                                    //   isNumber: true, // 🔥 numeric keyboard
                                    // ),

                                    CustomTextField(label:"Year of Experience*",
                                      controller: YearofExperienceController,
                                      keyboardType: TextInputType.number,
                                    ),

                                    const SizedBox(height: 20),

                                    // _textField(
                                    //   title: "Hourly Rate*",
                                    //   controller: HourlyRateController,
                                    //   isNumber: true, // 🔥 numeric keyboard
                                    // ),

                                    CustomTextField(label:"Hourly Rate*",
                                      controller: HourlyRateController,
                                      keyboardType: TextInputType.number,
                                    ),

                                    const SizedBox(height: 20),

                                    // BIO FIELD
                                    // _textField(
                                    //   title: "Bio / About",
                                    //
                                    //   controller: bioController,
                                    //   isMultiline: true, // 👈 NEW
                                    //
                                    //   maxLines: 4,
                                    // ),
                                    CustomTextField(label:"Bio / About",
                                      controller: bioController,
                                      maxLines:4,
                                      keyboardType: TextInputType.multiline,//
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text("  Highlight your creative focus.",style: TextStyle(color: ColorCode.k737373,fontFamily: "Outfit",fontSize: 12),)
                                      ],
                                    ),

                                    SizedBox(height: 20),
                                    /*     Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔽 SKILLS DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedSkill,
                      dropdownColor: const Color(0xFF1C1C1C),
                      icon: const Icon(Icons.keyboard_arrow_down, color: ColorCode.white),
                      style: const TextStyle(color: ColorCode.white),
                      decoration: _inputDecoration("Add Skills"),
                      items: allSkills.map((skill) {
                        return DropdownMenuItem(
                          value: skill,
                          child: Text(skill),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && !selectedSkills.contains(value)) {
                          setState(() {
                            selectedSkills.add(value); // ✅ ADD
                            selectedSkill = null;      // 🔥 RESET DROPDOWN
                          });
                        }
                      },
                    ),


                    const SizedBox(height: 12),

                    /// 🧩 SELECTED SKILLS CHIPS
                    if (selectedSkills.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSkills.map((skill) {
                          return Chip(
                            label: Text(
                              skill,
                              style:  TextStyle(color: ColorCode.white),
                            ),
                            backgroundColor:
                            ColorCode.kHeadingColor.withOpacity(0.9),
                            deleteIconColor: ColorCode.white,
                            onDeleted: () {
                              setState(() {
                                selectedSkills.remove(skill);
                              });
                            },
                          );
                        }).toList(),
                      ),//
                  ],
                ),*/


                                    // GestureDetector(
                                    //   onTap: _openSkillsBottomSheet,
                                    //   child: AbsorbPointer(
                                    //     child: TextField(
                                    //       style: const TextStyle(color: ColorCode.white),
                                    //       decoration: _inputDecoration("Add Skills").copyWith(
                                    //         hintText: _skillsDisplayText(),
                                    //         hintStyle: const TextStyle(color: ColorCode.white),
                                    //         suffixIcon: const Icon(
                                    //           Icons.keyboard_arrow_down,
                                    //           color: ColorCode.white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    CustomMultiSelectField(
                                      label: "Add Skills",
                                      value: selectedSkills.join(", "),
                                      hasValue: selectedSkills.isNotEmpty,
                                      onTap: () async {
                                        _openSkillsBottomSheet(); // ✅ important
                                      },
                                    ),



                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        /// 🔍 EQUIPMENT TEXT FIELD (TOP)
                                        CustomTextField(
                                          controller: equipmentController,
                                          label: 'Add Equipment',
                                          onChanged: (value) {
                                            _fetchhome_equipment(value);
                                          },
                                        ),


                                        /// ⏳ LOADING
                                        if (equipmentLoading)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 12),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: ColorCode.kButtonColor,
                                              ),
                                            ),
                                          ),


                                        /// 📜 AUTOCOMPLETE LIST
                                        if (filteredEquipments.isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(top: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1C1C1C),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: ColorCode.white24),
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: filteredEquipments.length,
                                              itemBuilder: (context, index) {
                                                final item = filteredEquipments[index];
                                                return ListTile(
                                                  title: Text(
                                                    item,
                                                    style: const TextStyle(color: ColorCode.white),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      if (!selectedEquipments.contains(item)) {
                                                        selectedEquipments.add(item);
                                                      }
                                                      equipmentController.clear();
                                                      filteredEquipments.clear();
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),

                                        /// 🧩 SELECTED EQUIPMENT CHIPS (NICHE)
                                        if (selectedEquipments.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: selectedEquipments.map((item) {
                                                return Chip(
                                                  label: Text(
                                                    item,
                                                    style: const TextStyle(color: ColorCode.white),
                                                  ),
                                                  backgroundColor:
                                                  ColorCode.kHeadingColor.withOpacity(0.9),
                                                  deleteIconColor: ColorCode.white,
                                                  onDeleted: () {
                                                    setState(() {
                                                      selectedEquipments.remove(item);
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                      ],
                                    ),




                                    const SizedBox(height: 30),

                                    /// NEXT BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed:_fetch_step2,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorCode.kButtonColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: const Text(
                                          "Next",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: ColorCode.kHeadingColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    /// LOGIN TEXT
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Already have an account? ",
                                          style: TextStyle(
                                            color: ColorCode.kWhiteOpacity60,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                           /* Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>  Login(),
                                              ),
                                            );*/
                                            context.pushNamed(RouteNames.login);
                                          },
                                          child: const Text(
                                            "Login",
                                            style: TextStyle(
                                              color: ColorCode.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                              /// 🏷️ FLOATING CHIP (BORDER PE STUCK)

                              Positioned(
                                top: -40,
                                left: 20,
                                right: 20,
                                child: _userPreviewCard(),
                              ),

                            ],
                          ),
                        )]
                  )
              ),
              if (loading)
                AppLoader()
            ]
        )
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
                      color: ColorCode.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  /// TITLE
                  Text(
                    "Select Skills",
                    style: TextStyle(
                      color: ColorCode.white,
                      fontSize: 16,
                      fontFamily: "Unbounded",
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
                          checkColor: ColorCode.black,
                          title: Text(
                            skill,
                            style:
                            const TextStyle(color: ColorCode.white,fontSize: 14,fontFamily: "Outfit"),

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
                          fontFamily: "Outfit"
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


  Widget _userPreviewCard() {
    final firstName = widget.firstName?.trim() ?? "";
    final lastName  = widget.lastName?.trim() ?? "";
    final email     = widget.email?.trim() ?? "";
    final image     = widget.profileImage;

    if (firstName.isEmpty &&
        lastName.isEmpty &&
        email.isEmpty &&
        image == null) {
      return const SizedBox();
    }

    return Container(
      //padding: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: ColorCode.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorCode.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [

          /// 🔹 TOP ROW (IMAGE + NAME + EMAIL)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: ColorCode.lightGrey,
                  backgroundImage:
                  image != null ? FileImage(image) : null,
                  child: image == null
                      ? const Icon(Icons.person,
                      size: 26, color: ColorCode.grey)
                      : null,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$firstName $lastName",
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorCode.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isEmpty ? "Your Email" : email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 12,
                          color: ColorCode.k282828,
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          ),


          /// 🔹 BOTTOM ROW (BUTTON + %)
          Row(
            children: [

              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      /*showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: ColorCode.transparent,
                        builder: (_) => ViewDetailsScreen(
                          firstName: widget.firstName ?? "",
                          lastName: widget.lastName ?? "",
                          email: widget.email ?? "",
                          profileImage: widget.profileImage,
                          location: widget.location ?? "",                 // ✅ FIXED
                          workingDistance: widget.workingDistance ?? "",
                          primaryRole: selectedRoles.join(", "),
                          experience: YearofExperienceController.text.trim(),
                          hourlyRate: HourlyRateController.text.trim(),
                          bio: bioController.text.trim(),
                          skills: selectedSkills.join(", "),
                          equipments: selectedEquipments.join(", "),
                        ),
                      );*/
                      context.pushNamed(

                        RouteNames.viewDetails,

                        extra: {

                          "firstName":
                          widget.firstName ?? "",

                          "lastName":
                          widget.lastName ?? "",

                          "email":
                          widget.email ?? "",

                          "profileImage":
                          widget.profileImage,

                          "location":
                          widget.location ?? "",

                          "workingDistance":
                          widget.workingDistance ?? "",

                          "primaryRole":
                          selectedRoles.join(", "),

                          "experience":
                          YearofExperienceController.text.trim(),

                          "hourlyRate":
                          HourlyRateController.text.trim(),

                          "bio":
                          bioController.text.trim(),

                          "skills":
                          selectedSkills.join(", "),

                          "equipments":
                          selectedEquipments.join(", "),

                          "featuredImages": [],
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorCode.kButtonColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    width:0.5,
                    color: ColorCode.lightGrey,
                  ),
                  color: ColorCode.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child:  Text(
                  "${_calculateStep2Progress()}% Completed",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorCode.black
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}