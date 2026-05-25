import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import 'view_details_screen.dart';

class PreProductionScreen extends StatefulWidget {
  const PreProductionScreen({super.key});

  @override
  State<PreProductionScreen> createState() => _PreProductionScreenState();
}

class _PreProductionScreenState extends State<PreProductionScreen> {
  /*
  final FileUploadController files_con = FileUploadController();
*/

  List<Map<String, dynamic>> files = [
    {"name": "Example.pdf", "isPdf": true},
    {"name": "Example.docx", "isPdf": false},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(AppAssets.back),
                  ),
                  const Spacer(),
                  const Text(
                    "Pre Production",
                    style: AppTextStyles.displayLabel16,
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMid,
                  borderRadius: AppRadii.lgAll,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white30),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final bool isPdf = index % 2 == 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: AppRadii.hugeAll,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔝 File Name Row
                        Row(
                          children: [
                            Icon(
                              isPdf ? Icons.picture_as_pdf : Icons.description,
                              color: isPdf
                                  ? AppColors.redAccent
                                  : AppColors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPdf ? "Example.pdf" : "Example.docx",
                              style: AppTextStyles.bodyCompactMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.more_vert, color: AppColors.white),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// 📄 Preview Box
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.circleGradientTop,
                            borderRadius: AppRadii.xxlAll,
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isPdf
                                    ? AppColors.redAccent
                                    : AppColors.blue,
                                borderRadius: AppRadii.mdAll,
                              ),
                              child: Text(
                                isPdf ? "Pdf" : "Doc",
                                style: AppTextStyles.bodyLargeStrong.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Divider(
                          color: AppColors.dividerDark,
                          thickness: 0.8,
                        ),

                        const SizedBox(height: 8),

                        /// 👤 Footer Row
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.softLightBlue,
                              child: Text(
                                "DP",
                                style: AppTextStyles.bodyCompactStrong.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Opened 2 hours ago",
                              style: AppTextStyles.bodyCompact.copyWith(
                                color: AppColors.white30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.smd, AppSpacing.base, AppSpacing.xl),
        decoration: const BoxDecoration(color: AppColors.background),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔝 View Shoot Details
            InkWell(
              borderRadius: AppRadii.smAll,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ViewDetailsScreen()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "View Shoot Details",
                    style: AppTextStyles.bodyCompact.copyWith(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// ⬇ Upload Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload, color: AppColors.black),
                label: const Text(
                  "Upload Files",
                  style: AppTextStyles.displayLabel14.copyWith(
                    color: AppColors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
                ),
                onPressed: () {
                  showUploadDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔝 Drag line
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white30,
                      borderRadius: AppRadii.mldAll,
                    ),
                  ),
                ),

                /// 🔝 Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upload Files",
                      style: AppTextStyles.displayLabel16,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  "Files will be uploaded to the folder Lana Guzman",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white30,
                  ),
                ),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: 20),

                /// 📂 Upload Box
                InkWell(
                  /*   onTap: () async {

                    final pickedFile = await files_con.pickFile();

                    if (pickedFile != null) {
                      setState(() {
                        files.add(pickedFile);
                      });
                    }


                  },*/
                  child: Container(
                    height: 230,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: AppRadii.xxlAll,
                      border: Border.all(color: AppColors.dividerDark),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 🔥 vertical center
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 🔥 horizontal center
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(AppAssets.iconUploadFilled, height: 40),

                          const SizedBox(height: 16),

                          RichText(
                            textAlign: TextAlign.center, // 🔥 text center
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "Drag your files here or ",
                                  style: AppTextStyles.bodyLargeMedium.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: "Browse",
                                  style: AppTextStyles.bodyLargeMedium.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// 🔘 Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Upload Files",
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
