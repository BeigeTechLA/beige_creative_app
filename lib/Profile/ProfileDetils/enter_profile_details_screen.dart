import 'package:flutter/material.dart';

import '../../utility/ColorCode.dart';
import '../../widgets/Custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

class EnterProfileDetailsScreen extends StatefulWidget {
  const EnterProfileDetailsScreen({super.key});

  @override
  State<EnterProfileDetailsScreen> createState() => _EnterProfileDetailsScreenState();
}

class _EnterProfileDetailsScreenState extends State<EnterProfileDetailsScreen> {

  final TextEditingController experienceController =  TextEditingController();

  final TextEditingController rateController =TextEditingController();

  final TextEditingController bioController =  TextEditingController();

  String selectedRole = "Photographer";
  String selectedSkill = "Livestream Audio";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(

            children: [

              /// 🔙 BACK + TITLE
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset("assets/icons/back.png", height: 24,),
                  ),
                ],
              ),
              SizedBox(height:12),
              Row(
                children: [
                  Text(
                    "Edit Professional Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 30),

              /// 🎯 PRIMARY ROLE
              CustomDropdownField(
                label: "Primary Role",
                value: selectedRole,
                items: ["Photographer", "Videographer", "Editor"],
                onChanged: (val) {
                  setState(() {
                    selectedRole = val!;
                  });
                },
              ),

              SizedBox(height:12),
              /// 📅 YEAR OF EXPERIENCE
              CustomTextField(
                label: "Year of Experience",
                controller: experienceController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height:12),

              /// 💰 HOURLY RATE
              CustomTextField(
                label: "Hourly Rate",
                controller: rateController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height:12),

              /// 📝 BIO
              CustomTextField(
                label: "Bio / About",
                controller: bioController,
                maxLines: 4,
              ),
              SizedBox(height:5),


              Row(
                children: [
                   Text(
                    "Highlight your creative focus.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              SizedBox(height:12),

              /// 🎨 SKILLS
              CustomDropdownField(
                label: "Skills",
                value: selectedSkill,
                items: ["Livestream Audio", "Lighting", "Editing"],
                onChanged: (val) {
                  setState(() {
                    selectedSkill = val!;
                  });
                },
              ),

              const SizedBox(height: 40),

              /// 💾 SAVE BUTTON
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6C3A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),    );
  }

  /// 🔽 CUSTOM DROPDOWN DESIGN
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorCode.kWhiteOpacity70,
          width: 0.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1E1E1E),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white70),
          style: const TextStyle(
            color: Colors.white,
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }}