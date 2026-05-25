import 'package:flutter/material.dart';
import 'package:beige_creative_app/app/colors.dart';
import '../app/radii.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import 'package:go_router/go_router.dart';

import '../app/route_names.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';

class CancelScreen extends StatefulWidget {
  final int? projectId;
  const CancelScreen({super.key, this.projectId});

  @override
  State<CancelScreen> createState() => _CancelScreenState();
}

class _CancelScreenState extends State<CancelScreen> {
  Future<void> declineProject() async {

    try {

      final response =
      await ApiService().postData(

        ApiEndpoints.acceptdeclineproject,

        {
          "project_id":
          widget.projectId,

          "crew_accept": 2,
        },
      );

      if (response["error"] == false) {

        debugPrint(
          "Declined successfully ✅",
        );

        if (!mounted) return;

        context.goNamed(
          RouteNames.cancelShoot,
        );

      } else {

        debugPrint(
          "Error ❌: ${response["message"]}",
        );
      }

    } catch (e) {

      debugPrint(
        "DECLINE ERROR ❌ $e",
      );
    }
  }
  String selectedReason = "";
  bool isOtherSelected = false;
  bool isLoading = false;
  final TextEditingController commentController = TextEditingController();

  final List<String> reasons = [
    "Schedule conflict",
    "Equipment unavailable",
    "Location too far",
    "Rate too low",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black.withOpacity(0.4),
      resizeToAvoidBottomInset: true,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Drag Handle
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.white24,
                      borderRadius: AppRadii.hugeAll,
                    ),
                  ),
                ),

                AppSpacing.verticalXxl,

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Decline Shoot Request",
                      style: AppTextStyles.displayLabel16,
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),

                AppSpacing.verticalBase,

                const Text(
                  "Please let us know why you're declining this request.\nThis helps improve future matching.",
                  style: AppTextStyles.bodyCompact,
                ),

                const SizedBox(height: AppSpacing.lg),

                const Divider(
                  color: AppColors.dividerDark,
                  thickness: 0.8,
                ),

                const SizedBox(height: AppSpacing.lg),

                const Text(
                  "Reason for Declining",
                  style: AppTextStyles.body14Medium,
                ),

                AppSpacing.verticalMd,

                /// Reason List
                Expanded(
                  child: ListView(
                    children: [

                      ...reasons.map((reason) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedReason = reason;
                              isOtherSelected = reason == "Others";
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
                            child: Row(
                              children: [

                                /// Custom Radio
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedReason == reason
                                          ? AppColors.primary
                                          : AppColors.white24,
                                      width: 1.3,
                                    ),
                                  ),
                                  child: selectedReason == reason
                                      ? Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration:
                                      const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                        AppColors.primary,
                                      ),
                                    ),
                                  )
                                      : null,
                                ),

                                const SizedBox(width: AppSpacing.mld),

                                Text(
                                  reason,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      AnimatedSwitcher(
                        duration:
                        const Duration(milliseconds: 250),
                        child: isOtherSelected
                            ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.smd),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                            decoration: BoxDecoration(
                              borderRadius:
                              AppRadii.xlAll,
                              border: Border.all(
                                  color: AppColors.white24),
                              color: AppColors.black
                                  .withOpacity(0.2),
                            ),
                            child: TextField(
                              controller:
                              commentController,
                              maxLines: 3,
                              style: AppTextStyles.systemDefault,
                              decoration: const InputDecoration(
                                hintText:
                                "Any additional details...",
                                hintStyle: AppTextStyles.system13,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalBase,

                /// Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style:
                          OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.white24),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: () =>
                              context.pop(),
                          child: const Text(
                            "Cancel",
                            style: AppTextStyles.displayLabel14,
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.gapHBase,

                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.primary,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              AppRadii.xxlAll,
                            ),
                          ),
                          onPressed:
                          selectedReason.isEmpty ||
                              isLoading
                              ? null
                              : () async {

                            setState(() {
                              isLoading = true;
                            });

                            await declineProject();

                            if (mounted) {

                              setState(() {
                                isLoading = false;
                              });
                            }
                          },


                          child: const Text(
                            "Decline",
                            style: AppTextStyles.displayLabel14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpacing.verticalSmd,
              ],
            ),
          ),
        ),
      ),
    );
  }
}