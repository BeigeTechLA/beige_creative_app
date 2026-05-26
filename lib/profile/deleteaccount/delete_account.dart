import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';

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


  Future<void> _deleteAccount() async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select delete reason"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().postData(
        ApiEndpoints.accountDeleted,
        {
          "delete_reason": selectedReason,
        },
      );

      debugPrint("DELETE ACCOUNT RESPONSE => $response");

      if (response.error == false) {

        /// OTP SCREEN OPEN
        context.pushNamed(
          RouteNames.deleteAccountOtp,
          extra: {
            "reason": selectedReason,
          },
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Something went wrong"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                /// 🔙 BACK BUTTON
                GestureDetector(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    AppAssets.back, // make sure it's .svg file
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      //AppColors.textHeading,
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🏷 TITLE
                Text(
                  "Delete Account",
                  style: AppTextStyles.displayStrong16w600.copyWith(
                    color: AppColors.white,
                  ),
                ),

                SizedBox(height: 20),


                Text(
                  "This action will permanently delete your account and all associated data. If you need help or have questions, please contact us at support@beige.com",
                  style: AppTextStyles.body14LineRelaxed.copyWith(
                    color: AppColors.white30,
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),

                  decoration: BoxDecoration(color: AppColors.surfaceMid),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Why do you wish to leave Beige?",
                            style: AppTextStyles.body14Medium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Please let us know the reason for deleting your account.",
                        style: AppTextStyles.body12.copyWith(
                          color: AppColors.white30,
                        ),
                      ),

                      ...reasons.map((reason) {
                        return _buildReasonOption(reason);
                      }),

                    ],
                  ),
                )
              ],
            ),
          )
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          // color:  AppColors.surfaceStats,
        ),
        child: Row(
          children: [

            const SizedBox(width: 16),

            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    _deleteAccount();
                  },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: AppTextStyles.displayLabel14.copyWith(
                      color: AppColors.textHeading,
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
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
                      ? AppColors.primary
                      : AppColors.white30,

                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
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
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.white30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
