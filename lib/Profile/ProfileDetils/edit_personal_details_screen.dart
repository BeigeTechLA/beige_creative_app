import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:flutter/material.dart';

import '../../Model_Class/EditProfileModel.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/Custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';
import '../ChangePassword/change_password_screen.dart';

class EditPersonalDetailsScreen extends StatefulWidget {
  const EditPersonalDetailsScreen({super.key});

  @override
  State<EditPersonalDetailsScreen> createState() => _EditPersonalDetailsScreenState();
}

class _EditPersonalDetailsScreenState extends State<EditPersonalDetailsScreen> {

EditProfileModel?  mylist;
  Future<void>editpersonaldetails()async{
    try{
      final response= EditProfileModel.fromJson(await ApiService().postData(ApiEndpoints.editprofile,{}));

      setState(() {
        mylist=response;
      });

    }catch(e){
    }

  }

final TextEditingController firstnamecontroller =  TextEditingController();
final TextEditingController lastnamecontroller =  TextEditingController();
final TextEditingController emailcontroller =  TextEditingController();
final TextEditingController phonecontroller =  TextEditingController();
final TextEditingController locationcontroller =  TextEditingController();
final TextEditingController changepasswordcontroller =  TextEditingController();




final TextEditingController experienceController =  TextEditingController();

  final TextEditingController rateController =TextEditingController();

  final TextEditingController bioController  =TextEditingController();
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
                    "Edit Personal Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 30),


              SizedBox(height:12),
              /// 📅 YEAR OF EXPERIENCE
              CustomTextField(
                label: "First Name*",
                controller: firstnamecontroller,
              ),

              SizedBox(height:22),

              /// 💰 HOURLY RATE
              CustomTextField(
                label: "Last Name*",
                controller: lastnamecontroller,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height:22),

              /// 📝 BIO
              CustomTextField(
                label: "Email Address*",
                controller: bioController,

              ),
              SizedBox(height:22),
              CustomTextField(
                label: "Contact Number*",
                controller: bioController,

              ),
              SizedBox(height:22),
              CustomTextField(
                label: "Location*",
                controller: bioController,

              ),

              SizedBox(height:22),

              /// 🎨 SKILLS
              CustomDropdownField(
                label: "Working Distance*",
                value: selectedSkill,
                items: ["Livestream Audio", "Lighting", "Editing"],
                onChanged: (val) {
                  setState(() {
                    selectedSkill = val!;
                  });
                },
              ),

              const SizedBox(height: 22),
              CustomTextField(
                label: "Change Password*",
                controller: bioController,
                  suffixIcon: GestureDetector(
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangePasswordScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.edit,
                          color: ColorCode.kWhiteOpacity70,
                          size: 20,
                        ),
                      ),
              ),

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
      ),
    );
  }
}
