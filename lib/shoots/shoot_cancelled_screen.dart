import 'package:flutter/material.dart';
import 'package:beige_creative_app/app/colors.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Decline Shoot Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  "Please let us know why you're declining this request.\nThis helps improve future matching.",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Outfit",
                    color: AppColors.white60,
                  ),
                ),

                const SizedBox(height: 18),

                const Divider(
                  color: AppColors.dividerDark,
                  thickness: 0.8,
                ),

                const SizedBox(height: 18),

                const Text(
                  "Reason for Declining",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Outfit",
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 12),

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
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
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

                                const SizedBox(width: 14),

                                Text(
                                  reason,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      /// Others TextField
                      AnimatedSwitcher(
                        duration:
                        const Duration(milliseconds: 250),
                        child: isOtherSelected
                            ? Padding(
                          padding:
                          const EdgeInsets.only(top: 10),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.white24),
                              color: AppColors.black
                                  .withOpacity(0.2),
                            ),
                            child: TextField(
                              controller:
                              commentController,
                              maxLines: 3,
                              style: const TextStyle(
                                  color: AppColors.white),
                              decoration:
                              const InputDecoration(
                                hintText:
                                "Any additional details...",
                                hintStyle: TextStyle(
                                  color: AppColors.white24,
                                  fontSize: 13,
                                ),
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

                const SizedBox(height: 16),

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
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () =>
                              context.pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Unbounded",
                              fontWeight:
                              FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

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
                              BorderRadius.circular(16),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Unbounded",
                              fontWeight:
                              FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}