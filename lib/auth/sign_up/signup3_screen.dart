import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:beige_creative_app/app/assets.dart';
import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/shadows.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/commonFileViewer.dart';
import '../../widgets/common_uploader.dart';
import '../../widgets/custom_text_field.dart';
import '../view_details_screen .dart';

class SignUp3Screen extends StatefulWidget {
  final int? crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? location; // ✅ ADD
  final String? workingDistance;
  final int step2Progress;

  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;

  const SignUp3Screen({
    super.key,
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,

    this.primaryRole = "",
    this.experience = "",
    this.hourlyRate = "",
    this.bio = "",
    this.skills = "",
    this.equipments = "",
    required this.step2Progress,
  });

  @override
  State<SignUp3Screen> createState() => SignUp3ScreenState();
}

class SignUp3ScreenState extends State<SignUp3Screen> {
  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  final TextEditingController enter_work_titleController =
      TextEditingController();
  int? editingProjectIndex;
  int selectedPortfolioIndex = -1;
  int? editingPortfolioIndex;

  final TextEditingController portfolioNameController = TextEditingController();
  final TextEditingController portfolioLinkController = TextEditingController();

  List<Map<String, dynamic>> savedPortfolioLinks = [];

  int selectedSocialIndex = -1;
  int? editingIndex;

  List<String> selectedTags = [];
  List<String> featuredProjectsTitles = [];
  String? fileType; // image / video

  File? featuredFile;
  bool isVideo = false;

  bool isLoggingIn = false;

  File? documentFile;
  File? portfolioFile;

  IconData? selectedIcon;
  Color? selectedColor;
  File? selectedFile;

  List<Map<String, dynamic>> savedLinks = [];
  List<PlatformFile> featuredFiles = [];
  List<bool> featuredIsVideo = [];
  List<File> featuredImages = [];
  bool isSubmitting = false;
  // List<File> tempFeaturedImages = [];
  List<List<File>> featuredProjects = []; // 🔥 each project = list of images
  List<File> tempFeaturedImages = [];
  bool isPicking = false;
  List<File> certificateFiles = [];

  final List<String> Portfoliolname = ["Vimeo", "YouTube", "Google Drive"];

  final List<String> Portfolioicons = [
    AppAssets.v,
    AppAssets.youtube,
    AppAssets.googledrive,
  ];

  final List<String> socialNames = [
    "Facebook",
    "Instagram",
    "TikTok",
    "Behance",
    "Website",
  ];

  final List<String> socialIcons = [
    AppAssets.facebook,
    AppAssets.insta,
    AppAssets.tiktok,
    AppAssets.be,
    AppAssets.Ball,
  ];

  String getSocialPlatformKey(String name) {
    switch (name.toLowerCase()) {
      case "facebook":
        return "facebook";
      case "instagram":
        return "instagram";
      case "tiktok":
        return "tiktok";
      case "behance":
        return "behance";
      case "website":
        return "website";
      default:
        return name.toLowerCase();
    }
  }

  String getPortfolioPlatformKey(String name) {
    switch (name.toLowerCase()) {
      case "vimeo":
        return "vimeo";
      case "youtube":
        return "youtube";
      case "google drive":
        return "google_drive";
      default:
        return name.toLowerCase();
    }
  }

  List<File> get flattenedFeaturedImages {
    return featuredProjects.expand((project) => project).toList();
  }

  List<int> get flattenedFeaturedImageIndexes {
    final indexes = <int>[];
    for (
      int projectIndex = 0;
      projectIndex < featuredProjects.length;
      projectIndex++
    ) {
      indexes.addAll(
        List.filled(featuredProjects[projectIndex].length, projectIndex),
      );
    }
    return indexes;
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        certificateFiles.add(File(result.files.single.path!));
      });
    }
  }

  Future<void> pickFeaturedImages(Function setModalState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setModalState(() {
        tempFeaturedImages = result.paths
            .where((e) => e != null)
            .map((e) => File(e!))
            .toList();
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        documentFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _fetchSingup3() async {
    setState(() => isLoggingIn = true);

    try {
      final recentWorkFiles = flattenedFeaturedImages;
      final recentWorkIndexes = flattenedFeaturedImageIndexes;

      final Map<String, dynamic> payload = {
        "crew_member_id": widget.crewMemberId.toString(),

        /// 🔹 JSON FIELDS (STRINGIFIED)
        "certifications": jsonEncode(
          certificateFiles.map((e) => e.path.split('/').last).toList(),
        ),

        "social_media_links": jsonEncode(
          savedLinks
              .map(
                (e) => {
                  "platform": getSocialPlatformKey(e['name'].toString()),
                  "url": normalizeUrl(e['url']),
                },
              )
              .toList(),
        ),

        "portfolio_links": jsonEncode(
          savedPortfolioLinks
              .map(
                (e) => {
                  "platform": getPortfolioPlatformKey(e['name'].toString()),
                  "url": normalizeUrl(e['url']),
                },
              )
              .toList(),
        ),

        "featured_work": jsonEncode(
          List.generate(featuredProjects.length, (index) {
            return {
              "work_title": (index < featuredProjectsTitles.length)
                  ? featuredProjectsTitles[index]
                  : "",
              "tags": selectedTags,
            };
          }),
        ),
      };

      /// 🔹 FILE MAP
      final Map<String, List<File>> files = {
        "certifications": certificateFiles,
        "recent_work_media": recentWorkFiles,
      };

      /// 🔹 SINGLE FILES
      if (documentFile != null) {
        files["resume"] = [documentFile!];
      }

      if (portfolioFile != null) {
        files["portfolio"] = [portfolioFile!];
      }

      debugPrint("📤 STEP-3 PAYLOAD => $payload");
      debugPrint("📂 FILE COUNT => ${files.length}");
      debugPrint("🖼️ RECENT WORK COUNT => ${recentWorkFiles.length}");
      debugPrint("🧭 RECENT WORK INDEXES => $recentWorkIndexes");

      final response = await ApiService().postMultipartStep3(
        ApiService().baseUrl + ApiEndpoints.register_step3, // ✅ FULL URL
        fields: payload.map((k, v) => MapEntry(k, v.toString())),

        resume: documentFile,
        portfolio: portfolioFile,

        certificates: certificateFiles,
        recentWorks: recentWorkFiles,
        recentWorkIndexes: recentWorkIndexes,
      );

      debugPrint("📥 STEP-3 RESPONSE => $response");

      if (response != null && response['error'] == false) {
        context.goNamed(RouteNames.login);
      } else {
        _showSnack(response?['message'] ?? "Submission failed");
      }
    } catch (e) {
      debugPrint("❌ STEP-3 ERROR => $e");
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoggingIn = false);
    }
  }

  Future<void> _pickPortfolio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      setState(() {
        portfolioFile = File(result.files.single.path!);
      });
    }
  }

  String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);
  }

  int _calculateStep3Progress() {
    int totalFields = 5;
    int filled = 0;

    if (savedLinks.isNotEmpty) filled++;
    if (featuredProjects.isNotEmpty) filled++;
    if (certificateFiles.isNotEmpty) filled++;
    if (documentFile != null) filled++;
    if (portfolioFile != null || savedPortfolioLinks.isNotEmpty) filled++;

    double step3Percent = (filled / totalFields) * 30;

    return widget.step2Progress + step3Percent.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          AppAssets.rectangle,
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// 🔙 BACK + STEP COUNT ROW
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
                                context.pop();
                              },
                              child: SvgPicture.asset(
                                AppAssets.back,
                                height: 24,
                                color: AppColors.white,
                              ),
                            ),

                            /// 📄 STEP COUNT
                            Text(
                              "3/3",
                              style: AppTextStyles.body14Medium.copyWith(
                                color: AppColors.white,
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
                          children: [
                            Text(
                              "Social Engagement",
                              style: AppTextStyles.displayStrong16.copyWith(
                                color: AppColors.white,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "Complete your profile and connect with \ntop studios and filmmakers.",

                              textAlign: TextAlign.center,
                              style: AppTextStyles.body14.copyWith(
                                color: AppColors.white30,
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index <= 2
                                        ? AppColors.primary
                                        : AppColors.textSubtle,
                                    borderRadius: AppRadii.hugeAll,
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
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          100,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadii.massiveAll,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 20), //
                            if (savedLinks.isNotEmpty)
                              Column(
                                children: savedLinks.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.all(
                                      AppSpacing.microInset,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadii.xxlAll,
                                      border: Border.all(
                                        color: Color(
                                          0xffE8D1AB80,
                                        ).withValues(alpha: 0.5),
                                        width: 0.5,
                                      ),
                                      color: AppColors.black,
                                    ),
                                    child: Row(
                                      children: [
                                        /// ICON
                                        Container(
                                          // height: 20,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            //color: AppColors.primary.withValues(alpha: 0.15),
                                            // borderRadius: AppRadii.lgAll,
                                          ),
                                          child:
                                              item['icon'].toString().endsWith(
                                                '.svg',
                                              )
                                              ? SvgPicture.asset(
                                                  item['icon'],
                                                  height: 20,
                                                  width: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    AppColors.primary,
                                                    BlendMode.srcIn,
                                                  ),
                                                )
                                              : Image.asset(
                                                  item['icon'],
                                                  height: 15,
                                                  width: 15,
                                                  color: AppColors.primary,
                                                ),
                                        ),

                                        const SizedBox(width: 12),

                                        /// NAME
                                        Expanded(
                                          child: Text(
                                            item['name'],
                                            style: AppTextStyles.inheritSemiBold
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                        ),

                                        /// ✏️ EDIT
                                        IconButton(
                                          icon: SvgPicture.asset(
                                            AppAssets.Pencil,
                                            width: 18,
                                            height: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              editingIndex = index;
                                              selectedSocialIndex = socialNames
                                                  .indexOf(item['name']);
                                              nameLinkController.text =
                                                  item['name'];
                                              linkController.text = item['url'];
                                            });

                                            _openSocialSheet();
                                          },
                                        ),

                                        /// 🗑 DELETE
                                        IconButton(
                                          icon: SvgPicture.asset(
                                            AppAssets.delete,
                                            width: 18,
                                            height: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              savedLinks.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                            _buildAddTile(
                              title: "Add Social Links",
                              onTap: _openSocialSheet,
                            ),
                            const SizedBox(height: 20),
                            if (savedPortfolioLinks.isNotEmpty)
                              Column(
                                children: savedPortfolioLinks.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.all(
                                      AppSpacing.microInset,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadii.xxlAll,
                                      border: Border.all(
                                        color: Color(
                                          0xffE8D1AB80,
                                        ).withValues(alpha: 0.5),
                                        width: 0.5,
                                      ),
                                      color: AppColors.textSubtle,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          // height: 20,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            //color: AppColors.primary.withValues(alpha: 0.15),
                                            // borderRadius: AppRadii.lgAll,
                                          ),
                                          child:
                                              item['icon'].toString().endsWith(
                                                '.svg',
                                              )
                                              ? SvgPicture.asset(
                                                  item['icon'],
                                                  height: 20,
                                                  width: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    AppColors.primary,
                                                    BlendMode.srcIn,
                                                  ),
                                                )
                                              : Image.asset(
                                                  item['icon'],
                                                  height: 15,
                                                  width: 15,
                                                  color: AppColors.primary,
                                                ),
                                        ),
                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            item['name'],
                                            style: AppTextStyles.inheritSemiBold
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                        ),

                                        IconButton(
                                          icon: SvgPicture.asset(
                                            AppAssets.Pencil,
                                            width: 18,
                                            height: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              editingPortfolioIndex = index;
                                              selectedPortfolioIndex =
                                                  Portfoliolname.indexOf(
                                                    item['name'],
                                                  );
                                              portfolioNameController.text =
                                                  item['name'];
                                              portfolioLinkController.text =
                                                  item['url'];
                                            });

                                            _openPortfoliole();
                                          },
                                        ),

                                        IconButton(
                                          icon: SvgPicture.asset(
                                            AppAssets.delete,
                                            width: 18,
                                            height: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              savedPortfolioLinks.removeAt(
                                                index,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            _buildAddTile(
                              title: "Add Portfolio Link (Optional)",
                              onTap: _openPortfoliole,
                            ),
                            const SizedBox(height: 20),

                            Container(
                              constraints: const BoxConstraints(minHeight: 220),
                              padding: const EdgeInsets.all(AppSpacing.base),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: AppRadii.xxlAll,
                                border: Border.all(color: AppColors.white24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// 🔹 HEADER
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Featured Work",
                                        style: AppTextStyles.bodyMediumStrong
                                            .copyWith(color: AppColors.white),
                                      ),

                                      if (featuredProjects.isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              editingProjectIndex =
                                                  null; // 🔥 new mode
                                              tempFeaturedImages
                                                  .clear(); // 🔥 empty images
                                              enter_work_titleController
                                                  .clear(); // 🔥 empty title
                                            });

                                            _featuredSheet();
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 28,
                                                width: 28,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      AppColors.goldPaleCream,
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Add another",
                                                style: AppTextStyles.body13
                                                    .copyWith(
                                                      color:
                                                          AppColors.white30,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  /// 🔹 EMPTY STATE
                                  if (featuredProjects.isEmpty)
                                    GestureDetector(
                                      onTap: _featuredSheet,
                                      child: Container(
                                        height: 150,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: AppRadii.lgAll,
                                          border: Border.all(
                                            color: AppColors.white24,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.add,
                                                color: AppColors.white,
                                              ), // 👈 icon
                                              const SizedBox(width: 8),
                                              Text(
                                                "Add",
                                                style: AppTextStyles
                                                    .inherit
                                                    .copyWith(
                                                      color: AppColors.white,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  /// 🔹 PROJECT LIST (MULTIPLE BLOCKS)
                                  if (featuredProjects.isNotEmpty)
                                    Column(
                                      children: featuredProjects.asMap().entries.map((
                                        entry,
                                      ) {
                                        int projectIndex = entry.key;
                                        List<File> images = entry.value;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: AppSpacing.base,
                                          ),
                                          height: 190,
                                          child: Stack(
                                            children: [
                                              /// 🔥 HORIZONTAL SCROLL IMAGES
                                              ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemCount: images.length,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: AppSpacing.sm,
                                                    ),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.75,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: AppSpacing.md,
                                                        ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          AppRadii.xxlAll,
                                                      child: Image.file(
                                                        images[index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              /// ✏️ EDIT + DELETE BUTTONS (DIRECT)
                                              Positioned(
                                                top: 8,
                                                right: 10,
                                                child: Row(
                                                  children: [
                                                    /// EDIT
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          tempFeaturedImages =
                                                              List.from(images);
                                                          editingProjectIndex =
                                                              projectIndex;

                                                          enter_work_titleController
                                                                  .text =
                                                              (projectIndex <
                                                                  featuredProjectsTitles
                                                                      .length)
                                                              ? featuredProjectsTitles[projectIndex]
                                                              : "";
                                                        });

                                                        _featuredSheet();
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        margin:
                                                            const EdgeInsets.only(
                                                              right: AppSpacing
                                                                  .xs,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color: AppColors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          size: 16,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),

                                                    /// DELETE
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          featuredProjects
                                                              .removeAt(
                                                                projectIndex,
                                                              );
                                                          if (projectIndex <
                                                              featuredProjectsTitles
                                                                  .length) {
                                                            featuredProjectsTitles
                                                                .removeAt(
                                                                  projectIndex,
                                                                );
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: AppColors
                                                                  .error
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.delete,
                                                          size: 16,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: AppSpacing.md,
                                                  top: AppSpacing.sm,
                                                ),
                                                child: Text(
                                                  (projectIndex <
                                                          featuredProjectsTitles
                                                              .length)
                                                      ? featuredProjectsTitles[projectIndex]
                                                      : "",
                                                  textAlign: TextAlign.left,
                                                  style: AppTextStyles
                                                      .inherit14Strong
                                                      .copyWith(
                                                        color:
                                                            AppColors.white,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                  /// 🔹 IMAGE LIST
                                  if (featuredImages.isNotEmpty)
                                    SizedBox(
                                      height: 180,
                                      width: 900,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: featuredImages.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              Container(
                                                width: 140,
                                                margin: const EdgeInsets.only(
                                                  right: AppSpacing.smd,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: AppRadii.lgAll,
                                                  child: Image.file(
                                                    featuredImages[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),

                                              /// 🔥 DELETE BUTTON ON IMAGE
                                              Positioned(
                                                top: 6,
                                                right: 16,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      featuredImages.removeAt(
                                                        index,
                                                      );
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 24,
                                                    width: 24,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: AppColors
                                                              .surfaceMid,
                                                        ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 14,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(AppSpacing.base),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: AppRadii.xxlAll,
                                border: Border.all(color: AppColors.white24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// 🔹 HEADER
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Upload Certifications",
                                        style: AppTextStyles.inherit14Strong
                                            .copyWith(color: AppColors.white),
                                      ),

                                      if (certificateFiles.isNotEmpty)
                                        InkWell(
                                          onTap: _pickCertificate,
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.add,
                                                size: 18,
                                                color: AppColors.goldPaleCream,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Add another",
                                                style: AppTextStyles
                                                    .bodyCompactMedium
                                                    .copyWith(
                                                      color: AppColors
                                                          .goldPaleCream,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  /// 🔹 EMPTY STATE (UPLOAD BOX)
                                  if (certificateFiles.isEmpty)
                                    GestureDetector(
                                      onTap: _pickCertificate,
                                      child: Container(
                                        height: 90,
                                        decoration: BoxDecoration(
                                          borderRadius: AppRadii.lgAll,
                                          border: Border.all(
                                            color: AppColors.white24,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Upload",
                                            style: AppTextStyles.inherit
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  /// 🔹 FILE LIST
                                  if (certificateFiles.isNotEmpty)
                                    Column(
                                      children: List.generate(
                                        certificateFiles.length,
                                        (index) {
                                          final file = certificateFiles[index];
                                          final fileName = file.path
                                              .split('/')
                                              .last;

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: AppSpacing.smd,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md,
                                              vertical: AppSpacing.smd,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceMid,
                                              borderRadius: AppRadii.lgAll,
                                              border: Border.all(
                                                color: AppColors.white24,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                /// FILE ICON
                                                const Icon(
                                                  Icons.link,
                                                  color: AppColors.white,
                                                ),

                                                const SizedBox(width: 10),

                                                /// FILE NAME
                                                Expanded(
                                                  child: Text(
                                                    fileName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles
                                                        .inherit
                                                        .copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  ),
                                                ),

                                                /// VIEW
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove_red_eye,
                                                    color: AppColors.white,
                                                  ),
                                                  onPressed: () {
                                                    CommonFileViewer.open(
                                                      context: context,
                                                      filePath: file.path,
                                                      isNetwork: false,
                                                    );
                                                  },
                                                ),

                                                /// DELETE
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: AppColors.white,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      certificateFiles.removeAt(
                                                        index,
                                                      );
                                                    });
                                                  },
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

                            SizedBox(height: 16),

                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.base,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: AppRadii.xxlAll,
                                    border: Border.all(
                                      color: AppColors.white24,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// TITLE
                                      Text(
                                        "Upload Documents",
                                        style: AppTextStyles.inherit14Strong
                                            .copyWith(color: AppColors.white),
                                      ),

                                      const SizedBox(height: 12),

                                      /// RESUME
                                      _documentBlock(
                                        label: "Upload Resume/CV",
                                        file: documentFile,
                                        onUpload: _pickDocument,
                                        onDelete: () {
                                          setState(() => documentFile = null);
                                        },
                                      ),

                                      const SizedBox(height: 12),

                                      /// PORTFOLIO
                                      _documentBlock(
                                        label: "Upload Portfolio",
                                        file: portfolioFile,
                                        onUpload: _pickPortfolio,
                                        onDelete: () {
                                          setState(() => portfolioFile = null);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                /*      onPressed: () {


                       */
                                /* Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Mainscreen(), // change screen name
                          ),
                        );*/
                                /*
                      }
                      ,*/
                                onPressed: isLoggingIn
                                    ? null
                                    : () {
                                        debugPrint("🟢 CREATE PROFILE CLICKED");
                                        _fetchSingup3();
                                      },

                                /*  onPressed:
                      isLoggingIn
                          ? null
                          : () {
                        debugPrint("🟢 NEXT BUTTON CLICKED");
                        _fetchSingup3();
                      },*/
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),
                                child: Text(
                                  "Create Profile",
                                  style: AppTextStyles.displayLabel16.copyWith(
                                    color: AppColors.textHeading,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// LOGIN TEXT
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: AppTextStyles.inherit.copyWith(
                                      color: AppColors.white30,
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      context.pushNamed(RouteNames.login);
                                    },
                                    child: Text(
                                      "Login",
                                      style: AppTextStyles.inheritSemiBold
                                          .copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                      Positioned(
                        top: -24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base,
                            ),
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMid,
                              borderRadius: AppRadii.lgAll,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.12),
                                width: 1,
                              ),
                              boxShadow: AppShadows.ctaDark,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColors.white30,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Tell Us About Yourself & Add Details",
                                  style: AppTextStyles.body11MediumLetter02
                                      .copyWith(color: AppColors.white30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -30,
                        left: 20,
                        right: 20,
                        child: _userPreviewCard(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoggingIn) AppLoader(),
        ],
      ),
    );
  }

  /// 🔹 COMMON TILE
  Widget _buildAddTile({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          /// ➕ CIRCULAR PLUS
          Container(
            height: 30,
            width: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: const Icon(Icons.add, color: AppColors.black, size: 16),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Text(
            title,
            style: AppTextStyles.body15.copyWith(color: AppColors.white30),
          ),
        ],
      ),
    );
  }

  Widget _documentBlock({
    required String label,
    required File? file,
    required VoidCallback onUpload,
    required VoidCallback onDelete,
  }) {
    return file == null
        ? GestureDetector(
            onTap: onUpload,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: AppRadii.lgAll,
                border: Border.all(
                  color: AppColors.white24,
                  style: BorderStyle.solid, // dashed jaisa look
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload, color: AppColors.white24),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTextStyles.inherit14.copyWith(
                        color: AppColors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        /// 🔥 FILE PREVIEW MODE
        : Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smd,
            ),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: AppColors.white24),
            ),
            child: Row(
              children: [
                /// FILE ICON
                const Icon(
                  Icons.insert_drive_file,
                  color: AppColors.white,
                  size: 22,
                ),

                const SizedBox(width: 10),

                /// FILE NAME
                Expanded(
                  child: Text(
                    file.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.inherit.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),

                /// VIEW
                IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    CommonFileViewer.open(
                      context: context,
                      filePath: file.path,
                      isNetwork: false,
                    );
                  },
                ),

                /// DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.white),
                  onPressed: onDelete,
                ),
              ],
            ),
          );
  }

  // void _openSocialSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColors.transparent,
  //     isScrollControlled: true,
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           return Padding(
  //             padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom,
  //             ),
  //             child: SingleChildScrollView(
  //
  //               child:
  //               Column(
  //                 children: [
  //
  //
  //                   Container(
  //                     padding: const EdgeInsets.all(20),
  //                     decoration: const BoxDecoration(
  //                       color: AppColors.background,
  //                       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Center(
  //                           child: Container(
  //                             height: 5,
  //                             width: 40,
  //                             margin:  EdgeInsets.only(bottom: 12),
  //                             decoration: BoxDecoration(
  //                               color: AppColors.white24,
  //                               borderRadius: AppRadii.xsAll,
  //                             ),
  //                           ),
  //                         ),
  //                         /// HEADER
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text(
  //                                 "Add Social Links",
  //                                 style: TextStyle(color: AppColors.white, fontSize: 16,fontFamily: "Unbounded",fontWeight: FontWeight.w500,)
  //                             ),
  //                             IconButton(
  //                               onPressed: () => Navigator.pop(context),
  //                               icon: const Icon(Icons.close, color: AppColors.white),
  //                             )
  //                           ],
  //                         ),
  //
  //                         Text(
  //                             "Add links that showcase your work, recognition,\npersonality and more!",
  //                             style: TextStyle(color: AppColors.white30, fontSize: 14,fontFamily: "Outfit",fontWeight: FontWeight.w400,)
  //                         ),
  //                         SizedBox(height: 20),
  //
  //                         Divider(color: AppColors.dividerDark,
  //
  //                         ),
  //                         SizedBox(height: 20),
  //                         /// ✅ SOCIAL ICONS
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             _socialImage(index: 0, imagePath: socialIcons[0], setModalState: setModalState),
  //                             _socialImage(index: 1, imagePath: socialIcons[1], setModalState: setModalState),
  //                             _socialImage(index: 2, imagePath: socialIcons[2], setModalState: setModalState),
  //                             _socialImage(index: 3, imagePath: socialIcons[3], setModalState: setModalState),
  //                             _socialImage(index: 4, imagePath: socialIcons[4], setModalState: setModalState),
  //                           ],
  //                         ),
  //
  //                         const SizedBox(height: 20),
  //
  //                         CustomTextField(
  //                           label: "Name of the Link*",
  //                           controller: nameLinkController,
  //                         ),
  //
  //                         const SizedBox(height: 20),
  //
  //                         CustomTextField(
  //                           label: "Link URL*",
  //                           controller: linkController,
  //                           keyboardType: TextInputType.url,
  //                         ),
  //
  //                         const SizedBox(height: 24),
  //
  //                         SizedBox(
  //                           width: double.infinity,
  //                           height: 48,
  //                           child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: AppColors.primary,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: AppRadii.xlAll,
  //                               ),
  //                             ),
  //                             onPressed: () {
  //                               if (selectedSocialIndex == -1 ||
  //                                   linkController.text.trim().isEmpty) {
  //                                 _showSnack("Please select platform and enter link");
  //                                 return;
  //                               }
  //
  //                               final platformName = socialNames[selectedSocialIndex];
  //                               final iconPath = socialIcons[selectedSocialIndex];
  //                               final url = linkController.text.trim();
  //
  //                               setState(() {
  //                                 if (editingIndex != null) {
  //                                   // ✏️ UPDATE
  //                                   savedLinks[editingIndex!] = {
  //                                     "name": platformName,
  //                                     "url": url,
  //                                     "icon": iconPath,
  //                                   };
  //                                 } else {
  //                                   // ➕ ADD
  //                                   savedLinks.add({
  //                                     "name": platformName,
  //                                     "url": url,
  //                                     "icon": iconPath,
  //                                   });
  //                                 }
  //                               });
  //
  //                               // RESET
  //                               editingIndex = null;
  //                               selectedSocialIndex = -1;
  //                               nameLinkController.clear();
  //                               linkController.clear();
  //
  //                               Navigator.pop(context);
  //                             },
  //
  //                             child: const Text(
  //                               "Save Link",
  //                               style: TextStyle(
  //                                 color: AppColors.black,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //           );
  //
  //
  //
  //
  //         },
  //       );
  //     },
  //
  //   );
  //
  //
  // }
  /// 🔽 SOCIAL LINKS SHEET
  void _openSocialSheet() {
    // ✅ State ko function level par rakho — keyboard se affect nahi hoga
    bool showForm = savedLinks.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AnimatedPadding(
              // ✅ AnimatedPadding use karo
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadii.topMassive,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DRAG INDICATOR
                      Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.white24,
                            borderRadius: AppRadii.xsAll,
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Social Links",
                            style: AppTextStyles.displayLabel16.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "Add links that showcase your work, recognition,personality and more!",
                        style: AppTextStyles.body12.copyWith(
                          color: AppColors.white30,
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.dividerDark),
                      const SizedBox(height: 20),

                      /// ✅ ICONS ROW — HAMESHA VISIBLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _socialImage(
                            index: 0,
                            imagePath: socialIcons[0],
                            setModalState: setInnerState,
                          ),
                          _socialImage(
                            index: 1,
                            imagePath: socialIcons[1],
                            setModalState: setInnerState,
                          ),
                          _socialImage(
                            index: 2,
                            imagePath: socialIcons[2],
                            setModalState: setInnerState,
                          ),
                          _socialImage(
                            index: 3,
                            imagePath: socialIcons[3],
                            setModalState: setInnerState,
                          ),
                          _socialImage(
                            index: 4,
                            imagePath: socialIcons[4],
                            setModalState: setInnerState,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// ✅ SAVED LINKS LIST
                      if (savedLinks.isNotEmpty) ...[
                        Text(
                          "${savedLinks.length}/6",
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.white24,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...savedLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.smd,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.lgAll,
                              border: Border.all(color: AppColors.white24),
                              color: AppColors.black10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.09, // ✅ screen ka 9%
                                  height:
                                      MediaQuery.of(context).size.width *
                                      0.09, // ✅ har screen pe same ratio
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: Transform.rotate(
                                    angle: pi / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                item['icon'].toString().endsWith('.svg')
                                    ? SvgPicture.asset(
                                        item['icon'],
                                        height: 20,
                                        width: 20,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.borderGold,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : Image.asset(
                                        item['icon'],
                                        height: 20,
                                        width: 20,
                                        color: AppColors.white,
                                      ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: AppTextStyles.inherit
                                        .copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              AppTextStyles.fontFamilyBody,
                                        ),
                                  ),
                                ),

                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),

                                  child: IconButton(
                                    icon: SvgPicture.asset(AppAssets.Pencil),

                                    // icon: const Icon(Icons.edit,
                                    //     color: AppColors.white, size: 18),
                                    onPressed: () {
                                      setInnerState(() {
                                        showForm = true;
                                        editingIndex = index;
                                        selectedSocialIndex = socialNames
                                            .indexOf(item['name']);
                                        nameLinkController.text = item['name'];
                                        linkController.text = item['url'];
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 7),

                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),

                                  child: IconButton(
                                    icon: SvgPicture.asset(AppAssets.delete),
                                    // icon: const Icon(Icons.delete,
                                    //     color: AppColors.redAccent, size: 18),
                                    onPressed: () {
                                      setInnerState(() {
                                        setState(() {
                                          savedLinks.removeAt(index);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 10),
                      ],

                      /// ✅ FORM FIELDS
                      if (showForm) ...[
                        CustomTextField(
                          label: "Name of the Link*",
                          controller: nameLinkController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Behance / X, Instagram, etc.",
                          controller: linkController,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            onPressed: () {
                              if (selectedSocialIndex == -1 ||
                                  linkController.text.trim().isEmpty) {
                                _showSnack(
                                  "Please select platform and enter link",
                                );
                                return;
                              }

                              final platformName =
                                  socialNames[selectedSocialIndex];
                              final iconPath = socialIcons[selectedSocialIndex];
                              final url = linkController.text.trim();

                              setState(() {
                                if (editingIndex != null) {
                                  savedLinks[editingIndex!] = {
                                    "name": platformName,
                                    "url": url,
                                    "icon": iconPath,
                                  };
                                } else {
                                  savedLinks.add({
                                    "name": platformName,
                                    "url": url,
                                    "icon": iconPath,
                                  });
                                }
                              });

                              setInnerState(() {
                                showForm = false; // ✅ yeh kaam karega kyunki
                                // showForm function scope mein hai
                                editingIndex = null;
                                selectedSocialIndex = -1;
                                nameLinkController.clear();
                                linkController.clear();
                              });
                            },
                            child: Text(
                              "Save Link",
                              style: AppTextStyles.inheritSemiBold.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],

                      /// ✅ ADD ANOTHER + SAVE
                      if (!showForm) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setInnerState(() {
                              showForm = true;
                              selectedSocialIndex = -1;
                              nameLinkController.clear();
                              linkController.clear();
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.black,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Add another link",
                                style: AppTextStyles.body14.copyWith(
                                  color: AppColors.white30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Save",
                              style: AppTextStyles.inheritSemiBold.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // void _openPortfoliole() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColors.transparent,
  //     isScrollControlled: true,
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           return Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: const BoxDecoration(
  //               color: AppColors.surfaceStats,
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //
  //                 /// Drag Indicator
  //                 Center(
  //                   child: Container(
  //                     height: 4,
  //                     width: 40,
  //                     margin: const EdgeInsets.only(bottom: 14),
  //                     decoration: BoxDecoration(
  //                       color: AppColors.white24,
  //                       borderRadius: AppRadii.xsAll,
  //                     ),
  //                   ),
  //                 ),
  //
  //                 /// Header
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       "Add Portfolio Links",
  //                       style: TextStyle(
  //                         color: AppColors.white,
  //                         fontSize: 16,
  //                         fontFamily: "Unbounded",
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                     IconButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       icon: const Icon(Icons.close, color: AppColors.white),
  //                     )
  //                   ],
  //                 ),
  //
  //                 const SizedBox(height: 6),
  //
  //                 const Text(
  //                   "Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.",
  //                   style: TextStyle(
  //                     color: AppColors.white70,
  //                     fontSize: 13,
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 20),
  //
  //                 /// ICONS ROW
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: List.generate(
  //                     Portfolioicons.length,
  //                         (index) => InkWell(
  //                       onTap: () {
  //                         setModalState(() {
  //                           selectedPortfolioIndex = index;
  //                         });
  //                       },
  //                       child: AnimatedContainer(
  //                         duration: const Duration(milliseconds: 200),
  //                         height: 52,
  //                         width: 52,
  //                         decoration: BoxDecoration(
  //                           borderRadius: AppRadii.xlAll,
  //                           border: Border.all(
  //                             color: selectedPortfolioIndex == index
  //                                 ? AppColors.primary
  //                                 : AppColors.white24,
  //                           ),
  //                           color: selectedPortfolioIndex == index
  //                               ? AppColors.primary.withValues(alpha: 0.15)
  //                               : AppColors.transparent,
  //                         ),
  //                         child: Center(
  //                           child: Portfolioicons[index].toString().endsWith('.svg')  // ✅ index use karo, item nahi
  //                               ? SvgPicture.asset(
  //                             Portfolioicons[index],
  //                             height: 22,
  //                             width: 22,
  //                             colorFilter: ColorFilter.mode(
  //                               selectedPortfolioIndex == index
  //                                   ? AppColors.primary
  //                                   : AppColors.white,
  //                               BlendMode.srcIn,
  //                             ),
  //                           )
  //                               : Image.asset(
  //                             Portfolioicons[index],
  //                             height: 22,
  //                             width: 22,
  //                             color: selectedPortfolioIndex == index
  //                                 ? AppColors.primary
  //                                 : AppColors.white,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 20),
  //
  //                 /// SINGLE INPUT FIELD (LIKE IMAGE)
  //                 // TextField(
  //                 //   controller: portfolioLinkController,
  //                 //   style: const TextStyle(color: AppColors.white),
  //                 //   decoration: InputDecoration(
  //                 //     hintText: "Name of the Link",
  //                 //     hintStyle: const TextStyle(color: AppColors.white54),
  //                 //     contentPadding: const EdgeInsets.symmetric(
  //                 //       horizontal: 20,
  //                 //       vertical: 16,
  //                 //     ),
  //                 //     enabledBorder: OutlineInputBorder(
  //                 //       borderRadius: AppRadii.xlAll,
  //                 //       borderSide: const BorderSide(color: AppColors.white24),
  //                 //     ),
  //                 //     focusedBorder: OutlineInputBorder(
  //                 //       borderRadius: AppRadii.xlAll,
  //                 //       borderSide:
  //                 //       BorderSide(color: AppColors.primary),
  //                 //     ),
  //                 //   ),
  //                 // ),
  //                 CustomTextField(label:"Name of the Link", controller:portfolioLinkController),
  //
  //                 const SizedBox(height: 24),
  //
  //                 /// SAVE BUTTON
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 50,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.goldSoft,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: AppRadii.xlAll,
  //                       ),
  //                     ),
  //                     onPressed: () {
  //                       if (selectedPortfolioIndex == -1 ||
  //                           portfolioLinkController.text.trim().isEmpty) {
  //                         _showSnack("Select platform & enter link");
  //                         return;
  //                       }
  //
  //                       setState(() {
  //                         savedPortfolioLinks.add({
  //                           "name": Portfoliolname[selectedPortfolioIndex],
  //                           "url": portfolioLinkController.text.trim(),
  //                           "icon": Portfolioicons[selectedPortfolioIndex],
  //                         });
  //                       });
  //
  //                       selectedPortfolioIndex = -1;
  //                       portfolioLinkController.clear();
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text(
  //                       "Save Link",
  //                       style: TextStyle(
  //                         color: AppColors.black,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 10),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _openPortfoliole() {
    bool showForm = savedPortfolioLinks.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceStats,
                    borderRadius: AppRadii.topHeader,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DRAG INDICATOR
                      Center(
                        child: Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: AppSpacing.mld),
                          decoration: BoxDecoration(
                            color: AppColors.white24,
                            borderRadius: AppRadii.xsAll,
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Portfolio Links",
                            style: AppTextStyles.displayLabel16.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.",
                        style: AppTextStyles.inherit13.copyWith(
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ✅ ICONS ROW — HAMESHA VISIBLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          Portfolioicons.length,
                          (index) => InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedPortfolioIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                borderRadius: AppRadii.xlAll,
                                border: Border.all(
                                  color: selectedPortfolioIndex == index
                                      ? AppColors.primary
                                      : AppColors.white24,
                                ),
                                color: selectedPortfolioIndex == index
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.transparent,
                              ),
                              child: Center(
                                child:
                                    Portfolioicons[index].toString().endsWith(
                                      '.svg',
                                    )
                                    ? SvgPicture.asset(
                                        Portfolioicons[index],
                                        height: 22,
                                        width: 22,
                                        colorFilter: ColorFilter.mode(
                                          selectedPortfolioIndex == index
                                              ? AppColors.primary
                                              : AppColors.white,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : Image.asset(
                                        Portfolioicons[index],
                                        height: 22,
                                        width: 22,
                                        color: selectedPortfolioIndex == index
                                            ? AppColors.primary
                                            : AppColors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ✅ SAVED PORTFOLIO LINKS LIST
                      if (savedPortfolioLinks.isNotEmpty) ...[
                        Text(
                          "${savedPortfolioLinks.length}/3",
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.white24,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...savedPortfolioLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.smd,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.lgAll,
                              border: Border.all(color: AppColors.white24),
                              color: AppColors.textSubtle,
                            ),
                            child: Row(
                              children: [
                                /// DRAG BOX
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: Transform.rotate(
                                    angle: pi / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,

                                      size: 18,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                /// PLATFORM ICON
                                item['icon'].toString().endsWith('.svg')
                                    ? SvgPicture.asset(
                                        item['icon'],
                                        height: 20,
                                        width: 20,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.primary,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : Image.asset(
                                        item['icon'],
                                        height: 20,
                                        width: 20,
                                        color: AppColors.primary,
                                      ),

                                const SizedBox(width: 10),

                                /// NAME
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: AppTextStyles.inherit
                                        .copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              AppTextStyles.fontFamilyBody,
                                        ),
                                  ),
                                ),

                                /// EDIT BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    // icon: const Icon(Icons.edit,
                                    //     color: AppColors.white, size: 18),
                                    icon: SvgPicture.asset(
                                      AppAssets.Pencil,
                                      width: 18,
                                      height: 18,
                                    ),

                                    onPressed: () {
                                      setModalState(() {
                                        showForm = true;
                                        editingPortfolioIndex = index;
                                        selectedPortfolioIndex =
                                            Portfoliolname.indexOf(
                                              item['name'],
                                            );
                                        portfolioLinkController.text =
                                            item['url'];
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 7),

                                /// DELETE BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: SvgPicture.asset(
                                      AppAssets.delete,
                                      width: 18,
                                      height: 18,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        setState(() {
                                          savedPortfolioLinks.removeAt(index);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 10),
                      ],

                      /// ✅ FORM FIELDS
                      if (showForm) ...[
                        CustomTextField(
                          label: "Name of the Link",
                          controller: portfolioLinkController,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldSoft,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            onPressed: () {
                              if (selectedPortfolioIndex == -1 ||
                                  portfolioLinkController.text.trim().isEmpty) {
                                _showSnack("Select platform & enter link");
                                return;
                              }

                              setState(() {
                                if (editingPortfolioIndex != null) {
                                  savedPortfolioLinks[editingPortfolioIndex!] = {
                                    "name":
                                        Portfoliolname[selectedPortfolioIndex],
                                    "url": portfolioLinkController.text.trim(),
                                    "icon":
                                        Portfolioicons[selectedPortfolioIndex],
                                  };
                                } else {
                                  savedPortfolioLinks.add({
                                    "name":
                                        Portfoliolname[selectedPortfolioIndex],
                                    "url": portfolioLinkController.text.trim(),
                                    "icon":
                                        Portfolioicons[selectedPortfolioIndex],
                                  });
                                }
                              });

                              setModalState(() {
                                showForm = false;
                                editingPortfolioIndex = null;
                                selectedPortfolioIndex = -1;
                                portfolioLinkController.clear();
                              });
                            },
                            child: Text(
                              "Save Link",
                              style: AppTextStyles.inheritSemiBold.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],

                      /// ✅ ADD ANOTHER + FINAL SAVE
                      if (!showForm) ...[
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () {
                            setModalState(() {
                              showForm = true;
                              selectedPortfolioIndex = -1;
                              portfolioLinkController.clear();
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.black,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Add another link",
                                style: AppTextStyles.body14.copyWith(
                                  color: AppColors.white30,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldSoft,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Save",
                              style: AppTextStyles.inheritSemiBold.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _socialImage({
    required int index,
    required String imagePath,
    required void Function(void Function()) setModalState,
  }) {
    final bool isSelected = selectedSocialIndex == index;

    return InkWell(
      borderRadius: AppRadii.xxlAll,
      onTap: () {
        setModalState(() {
          selectedSocialIndex = index;
          nameLinkController.text = socialNames[index];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          /// ✅ BACKGROUND COLOR CHANGE HERE
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.transparent,

          borderRadius: AppRadii.xxlAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white24,
            width: isSelected ? 1.5 : 0.8,
          ),

          /// optional glow
          boxShadow: isSelected ? AppShadows.goldCta : const [],
        ),
        child: Center(
          child: imagePath.endsWith('.svg')
              ? SvgPicture.asset(
                  imagePath,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.primary : AppColors.white,
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  imagePath,
                  height: 22,
                  width: 22,
                  color: isSelected ? AppColors.primary : AppColors.white,
                ),
        ),
      ),
    );
  }

  Widget _PortfolioImage({
    required int index,
    required String imagePath,
    required void Function(void Function()) setModalState,
  }) {
    final bool isSelected = selectedPortfolioIndex == index;

    return InkWell(
      onTap: () {
        setModalState(() {
          selectedPortfolioIndex = index;
          portfolioNameController.text = Portfoliolname[index];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.transparent,
          borderRadius: AppRadii.xxlAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white24,
          ),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 22,
            width: 22,
            color: isSelected ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }

  void _featuredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadii.topMassive,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔘 TOP DRAG INDICATOR
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white24,
                          borderRadius: AppRadii.xsAll,
                        ),
                      ),
                    ),

                    /// 🟢 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Featured Work",
                          style: AppTextStyles.displayLabel16.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.white),
                        ),
                      ],
                    ),

                    Text(
                      "For best results, use a PNG, JPG, Video or\nGIF image etc.",
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.white30,
                      ),
                    ),

                    SizedBox(height: 16),
                    Divider(color: AppColors.dividerDark),
                    SizedBox(height: 20),

                    /// ✏️ WORK TITLE
                    CustomTextField(
                      label: "Enter Work Title*",
                      controller: enter_work_titleController,
                    ),
                    SizedBox(height: 16),

                    GestureDetector(
                      /*  onTap: () async {
                        if (tempFeaturedImages.length >= 5) {
                          _showSnack("Maximum 5 images allowed");
                          return;
                        }
                        final file = await CommonUploader.pickFromGallery();

                        if (file != null) {
                          setModalState(() {
                            tempFeaturedImages.add(file);
                          });
                        }
                      },*/
                      onTap: () async {
                        final file = await CommonUploader.pickFromGallery();

                        if (file != null) {
                          setModalState(() {
                            tempFeaturedImages.add(file);
                          });
                        }
                      },
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: AppRadii.radiusXxl,
                          color: AppColors.white24,
                          strokeWidth: 1,
                          dashPattern: [4, 4],
                        ),
                        child: Container(
                          height: 190,
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            //    color: AppColors.surfaceStats,
                            borderRadius: AppRadii.xxlAll,
                          ),
                          child: tempFeaturedImages.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.upload,
                                      color: AppColors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Upload new image, video, or browse",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyMediumStrong
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height:
                                      300, // ✅ 🔥 height increase after image add
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: tempFeaturedImages.length + 1,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1,
                                        ),
                                    itemBuilder: (context, index) {
                                      /// ➕ ADD BUTTON (always last)
                                      if (index == tempFeaturedImages.length) {
                                        return GestureDetector(
                                          /*  onTap: () async {
                                      if (tempFeaturedImages.length >= 5) {
                                        _showSnack("Maximum 5 images allowed");
                                        return;
                                      }
                                      final file =
                                      await CommonUploader.pickFromGallery();

                                      if (file != null) {
                                        setModalState(() {
                                          tempFeaturedImages.add(file);
                                        });
                                      }
                                    },*/
                                          onTap: () async {
                                            final file =
                                                await CommonUploader.pickFromGallery();

                                            if (file != null) {
                                              setModalState(() {
                                                tempFeaturedImages.add(file);
                                              });
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: AppRadii.lgAll,
                                              border: Border.all(
                                                color: AppColors.white24,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.add,
                                                color: AppColors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      /// 🖼 IMAGE (NO REMOVE ICON)
                                      return Stack(
                                        children: [
                                          /// 🖼 IMAGE
                                          ClipRRect(
                                            borderRadius: AppRadii.lgAll,
                                            child: Image.file(
                                              tempFeaturedImages[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),

                                          /// ❌ REMOVE ICON (BACK AGAIN)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: GestureDetector(
                                              onTap: () {
                                                setModalState(() {
                                                  tempFeaturedImages.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                height: 24,
                                                width: 24,
                                                decoration: BoxDecoration(
                                                  color: AppColors.black
                                                      .withValues(alpha: 0.7),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 14,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    /*    /// 🏷️ TAG SECTION
                    Row(
                      children: [
                        Expanded(                        // ✅ ADD Expanded
                          child: GestureDetector(
                            onTap: () => _openAddTagSheet(setModalState),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ...selectedTags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.black,
                                      borderRadius: AppRadii.hugeAll,
                                      border: Border.all(color: AppColors.white24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(tag, style: const TextStyle(color: AppColors.white, fontSize: 12)),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            setModalState(() { selectedTags.remove(tag); });
                                            setState(() { selectedTags.remove(tag); });
                                          },
                                          child: const Icon(Icons.close, size: 14, color: AppColors.white70),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.black26,
                                    borderRadius: AppRadii.hugeAll,
                                    border: Border.all(color: AppColors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.local_offer_outlined, size: 16, color: AppColors.white),
                                      SizedBox(width: 6),
                                      Text("# Add Tags", style: TextStyle(color: AppColors.white, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),  // ✅ close Expanded
                      ],
                    ),*/
                    SizedBox(height: 24),

                    /// 💾 SAVE BUTTON (ONLY ENABLE WHEN EXACTLY 5 IMAGES)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Builder(
                        builder: (context) {
                          bool isValid =
                              enter_work_titleController.text
                                  .trim()
                                  .isNotEmpty &&
                              tempFeaturedImages.length >= 5;

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isValid
                                  ? AppColors.primary
                                  : AppColors.lavenderGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),

                            onPressed: () {
                              if (!isValid) {
                                _showSnack("Minimum 5 images required");
                                return;
                              }

                              setState(() {
                                if (editingProjectIndex != null) {
                                  /// 🔥 EDIT MODE
                                  featuredProjects[editingProjectIndex!] =
                                      List.from(tempFeaturedImages);

                                  // title bhi update karo
                                  if (editingProjectIndex! <
                                      featuredProjectsTitles.length) {
                                    featuredProjectsTitles[editingProjectIndex!] =
                                        enter_work_titleController.text.trim();
                                  }
                                } else {
                                  /// ➕ ADD MODE
                                  featuredProjects.add(
                                    List.from(tempFeaturedImages),
                                  );
                                  featuredProjectsTitles.add(
                                    enter_work_titleController.text.trim(),
                                  );
                                }

                                /// 🔁 RESET
                                tempFeaturedImages.clear();
                                enter_work_titleController.clear();
                                editingProjectIndex = null;
                              });

                              Navigator.pop(context);
                            },

                            child: Text(
                              "Save",
                              style: AppTextStyles.inheritSemiBold.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAddTagSheet(StateSetter setFeaturedModalState) {
    TextEditingController tagController = TextEditingController();
    List<String> tempTags = List.from(selectedTags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceStats,
                  borderRadius: AppRadii.topMassive,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Drag
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white24,
                          borderRadius: AppRadii.xsAll,
                        ),
                      ),
                    ),

                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Tag",
                          style: AppTextStyles.displayStrong16w600.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Help people find your work",
                      style: AppTextStyles.inherit13.copyWith(
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagController,
                            style: AppTextStyles.inherit.copyWith(
                              color: AppColors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type tag and press + or Enter",
                              hintStyle: AppTextStyles.inherit.copyWith(
                                color: AppColors.white24,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.mld,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadii.lgAll,
                                borderSide: const BorderSide(
                                  color: AppColors.white24,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadii.lgAll,
                                borderSide: const BorderSide(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              final tag = value.trim();
                              if (tag.isNotEmpty && !tempTags.contains(tag)) {
                                setModalState(() {
                                  tempTags.add(tag);
                                  tagController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        // const SizedBox(width: 8),
                        // // ✅ ADD BUTTON so user doesn't need to press Enter
                        // GestureDetector(
                        //   onTap: () {
                        //     final tag = tagController.text.trim();
                        //     if (tag.isNotEmpty && !tempTags.contains(tag)) {
                        //       setModalState(() {
                        //         tempTags.add(tag);
                        //         tagController.clear();
                        //       });
                        //     }
                        //   },
                        //   child: Container(
                        //     height: 50,
                        //     width: 50,
                        //     decoration: BoxDecoration(
                        //       color: AppColors.goldSoft,
                        //       borderRadius: AppRadii.lgAll,
                        //     ),
                        //     child: const Icon(Icons.add, color: AppColors.black),
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Live Chips Preview
                    if (tempTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: AppRadii.hugeAll,
                              border: Border.all(color: AppColors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: AppTextStyles.inherit.copyWith(
                                    color: AppColors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempTags.remove(tag);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.white24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    /// Save
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldSoft,
                          foregroundColor: AppColors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.mld,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.xlAll,
                          ),
                        ),
                        onPressed: () {
                          // ✅ Agar textfield mein kuch likha hai to pehle add karo
                          final currentText = tagController.text.trim();
                          if (currentText.isNotEmpty &&
                              !tempTags.contains(currentText)) {
                            tempTags.add(currentText);
                            tagController.clear();
                          }

                          final List<String> savedTags = List<String>.from(
                            tempTags,
                          );
                          setFeaturedModalState(() {
                            selectedTags = savedTags;
                          });
                          setState(() {
                            selectedTags = savedTags;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save",
                          style: AppTextStyles.inheritSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _userPreviewCard() {
    final firstName = widget.firstName?.trim() ?? "";
    final lastName = widget.lastName?.trim() ?? "";
    final email = widget.email?.trim() ?? "";
    final image = widget.profileImage;

    if (firstName.isEmpty &&
        lastName.isEmpty &&
        email.isEmpty &&
        image == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.smd,
      ),
      margin: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.xxlAll,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔵 PROFILE IMAGE
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.border,
            backgroundImage: image != null ? FileImage(image) : null,
            child: image == null
                ? const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.lavenderGrey,
                  )
                : null,
          ),

          const SizedBox(width: 14),

          /// 📝 NAME + EMAIL + BUTTON COLUMN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  "$firstName $lastName",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body15Strong.copyWith(
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 4),

                /// EMAIL
                Text(
                  email.isEmpty ? "Your Email" : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body12.copyWith(
                    color: AppColors.surfaceMid,
                  ),
                ),

                const SizedBox(height: 10),

                /// BUTTON ROW
                Row(
                  children: [
                    /// VIEW DETAILS BUTTON
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
                              builder: (_) => ViewDetailsScreen(
                                firstName: widget.firstName ?? "",
                                lastName: widget.lastName ?? "",
                                email: widget.email ?? "",
                                location: widget.location ?? "",
                                workingDistance: widget.workingDistance ?? "",
                                profileImage: widget.profileImage,

                                primaryRole: widget.primaryRole,
                                experience: widget.experience,
                                hourlyRate: widget.hourlyRate,
                                bio: widget.bio,
                                skills: widget.skills,
                                equipments: widget.equipments,

                                featuredImages: featuredImages,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.black,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.hugeAll,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "View Details",
                            style: AppTextStyles.bodySmallMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// COMPLETION PERCENT
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppRadii.hugeAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${_calculateStep3Progress()}%Completed",
                        style: AppTextStyles.bodySmallStrong.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
