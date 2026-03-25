import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utility/ColorCode.dart';
import '../../../utility/imges_icons.dart';
import 'delete_account_otp_screen.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  bool isLoading = false;
  String? selectedReason;

  final List<String> reasons = [
    "What's the reason for deleting your account?",
    "Help us understand why you're leaving",
    "I'm not using the app anymore",
    "Others",
  ];





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Padding(
            padding:  EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                /// 🔙 BACK BUTTON
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    AppImages.back, // make sure it's .svg file
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      //ColorCode.kHeadingColor,
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🏷 TITLE
                Text(
                  "Delete Account",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorCode.white,
                  ),
                ),

                SizedBox(height: 20),


                Text(
                  "This action will permanently delete your account and all associated data. If you need help or have questions, please contact us at support@beige.com",
                  style: TextStyle(
                      fontSize: 14,
                      color: ColorCode.kWhiteOpacity70,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Outfit"
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),

                  decoration: BoxDecoration(color: ColorCode.k282828),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Why do you wish to leave Beige?",
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorCode.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Outfit"
                            ),),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Please let us know the reason for deleting your account.",
                        style: TextStyle(
                            fontSize: 12,
                            color: ColorCode.kWhiteOpacity70,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w400

                        ),
                      ),

                      ...reasons.map((reason) {
                        return _buildReasonOption(reason);
                      }).toList(),

                    ],
                  ),
                )
              ],
            ),
          )
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [

            const SizedBox(width: 16),

            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DeleteAccountOtpScreen()),
                    );
                  },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorCode.kHeadingColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );


  }

  Widget _buildReasonOption(String reason) {
    final bool isSelected = selectedReason == reason;

    return InkWell(
      onTap: () {
        setState(() {
          selectedReason = reason;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔘 CUSTOM RADIO
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ColorCode.kButtonColor
                      : ColorCode.kWhiteOpacity70,

                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorCode.kButtonColor,
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(width: 14),

            /// 📝 TEXT
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
