import 'dart:io';
import 'dart:ui' as ui;

import 'package:beige_creative_app/model_class/myprofile_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../app/route_names.dart';
import '../auth/sign_up/signup1_screen.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/shared_service.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/shadows.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../widgets/top_message.dart';
import '../widgets/app_loder.dart';
import '../widgets/common_uploader.dart';
import '../widgets/custom_text_field.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  bool isSaving = false;

  bool isEditing = false;
  bool isUploadingImage = false;
  int editingIndex = -1;
  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;
  double scale = 1.0;
  double startScale = 1.0;
  File? _profileImage;

  /* Future<void> editPortfolioLink() async {
    final item = portfolioLinks[editingIndex];
    final id = item["id"];
    final url = item["url"];                    // ✅ take from list, not controller
    final platform = getPortfolioKey(item["name"]!);

    try {
      final response = await ApiService().postData(
        "creator/profile/edit-portfolio-link/$id",
        {
          "url": url,
          "platform": platform,
          "title": item["name"],
        },
      );

      if (response["error"] == false) {
        editingIndex = -1;                      // ✅ reset
        await fetchprofiledata();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Edit error: $e");
    }
  }*/
  String getPortfolioIcon(String key) {
    switch (key.toLowerCase()) {
      case "youtube":
        return AppAssets.youtube;
      case "vimeo":
        return AppAssets.v;
      case "google_drive":
        return AppAssets.googledrive;
      default:
        return AppAssets.Ball;
    }
  }

  Future<void> savePortfolioLinksToApi() async {
    if (portfolioLinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one portfolio link")),
      );
      return;
    }

    setState(() => isloading = true);

    try {
      final formattedLinks = portfolioLinks.map((e) {
        return {"platform": getPortfolioKey(e["name"]!), "url": e["url"]};
      }).toList();

      final response = await ApiService().postData(
        "creator/profile/add-portfolio-links",
        {"portfolio_links": formattedLinks},
      );

      if (response["error"] == false) {
        await fetchprofiledata();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Portfolio links added ✅")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response["message"] ?? "Error")));
      }
    } catch (e) {
      debugPrint("Portfolio API error: $e");
    } finally {
      setState(() => isloading = false);
    }
  }

  String getPortfolioKey(String name) {
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

  String formatPortfolioName(String key) {
    switch (key.toLowerCase()) {
      case "youtube":
        return "YouTube";
      case "vimeo":
        return "Vimeo";
      case "google_drive":
        return "Google Drive";
      default:
        return key;
    }
  }

  Future<void> _handlePortfolioSaveLink({
    required StateSetter setModalState,
    required void Function(bool) setUpdating,
    required bool Function() getUpdating,
    VoidCallback? onAdded,
  }) async {
    if (selectedPortfolioIndex == -1 || linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select platform & enter link"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // ✅ EDIT MODE
    if (editingIndex != -1) {
      final id = portfolioLinks[editingIndex]["id"]?.toString();
      if (id == null || id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid link ID"),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setUpdating(true);

      try {
        final response = await ApiService().postData(
          "creator/profile/edit-portfolio-link/$id",
          {
            "url": linkController.text.trim(),
            "platform": getPortfolioKey(Portfoliolname[selectedPortfolioIndex]),
            "title": Portfoliolname[selectedPortfolioIndex],
          },
        );

        if (response["error"] == false) {
          await fetchprofiledata();
          if (mounted) Navigator.pop(context);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response["message"] ?? "Edit failed")),
            );
          }
        }
      } catch (e) {
        debugPrint("Edit error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Network error. Please try again."),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setUpdating(false);
      }
      return;
    }

    // ✅ ADD MODE — sirf local list update
    setModalState(() {
      setState(() {
        portfolioLinks.add({
          "id": "",
          "name": Portfoliolname[selectedPortfolioIndex],
          "url": linkController.text.trim(),
          "icon": Portfolioicons[selectedPortfolioIndex],
        });
      });
      editingIndex = -1;
      selectedPortfolioIndex = -1;
      nameController.clear();
      linkController.clear();
      onAdded?.call();
    });
  }

  Future<void> _pickImage() async {
    final File? file = await CommonUploader.pickFromGallery();

    if (file != null) {
      debugPrint("🟢 IMAGE PICKED: ${file.path}");

      /// 🔥 OPEN CROP SHEET
      openCustomCropSheet(file);
    }
  }

  void openCustomCropSheet(File imageFile) {
    Offset offset = Offset.zero;
    double scale = 1.0;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: AppColors.surfaceCropSheet,
                borderRadius: AppRadii.topRound,
              ),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white30,
                        borderRadius: AppRadii.xxxlAll,
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Crop your Profile",
                        style: AppTextStyles.body18Medium.copyWith(
                          color: AppColors.white,
                        ),
                      ),

                      InkWell(
                        onTap: () => context.pop(), // ❌ close bottom sheet
                        borderRadius: AppRadii.hugeAll,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Divider(color: AppColors.dividerDark),

                  /// 🔥 CIRCULAR PREVIEW AREA
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onScaleStart: (details) {
                          startScale = scale;
                          startOffset = offset;
                        },
                        onScaleUpdate: (details) {
                          setSheetState(() {
                            scale = (startScale * details.scale).clamp(
                              1.0,
                              4.0,
                            );
                            // offset = startOffset + details.focalPointDelta;
                            offset += details.focalPointDelta;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            /// IMAGE (NOW CLIPPED)
                            ClipRect(
                              child: SizedBox(
                                width: 320,
                                height: 320,
                                child: ClipRect(
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..translate(offset.dx, offset.dy)
                                      ..scale(scale),
                                    child: Image.file(
                                      imageFile,
                                      width: 340,
                                      height: 340,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// CIRCLE OVERLAY
                            IgnorePointer(
                              child: CustomPaint(
                                size: const Size(320, 320),
                                painter: CircleHolePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔥 ZOOM SLIDER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        /// 🔹 LEFT IMAGE ICON
                        SvgPicture.asset(
                          AppAssets.Image_zoom,
                          height: 20,
                          width: 20,
                          /*  color: AppColors.white.withValues(alpha: 0.7), */
                          // optional
                        ),

                        const SizedBox(width: 10),

                        /// 🔹 SLIDER
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.white.withValues(
                                alpha: 0.3,
                              ),
                              thumbColor: AppColors.primary,
                            ),
                            child: Slider(
                              min: 1,
                              max: 5,
                              value: scale,
                              onChanged: (v) {
                                setSheetState(() => scale = v);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// 🔹 LEFT IMAGE ICON
                        SvgPicture.asset(
                          AppAssets.Image_zoom,

                          // 👈 your image
                          height: 26,
                          width: 26,
                          /*  color: AppColors.white.withValues(alpha: 0.7), */
                          // optional
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheetState(() {
                                isSaving = true;
                              });

                              try {
                                final cropped = await _cropImage(
                                  imageFile,
                                  scale,
                                  offset,
                                );

                                if (cropped != null) {
                                  setState(() {
                                    _profileImage = cropped;
                                  });

                                  await _uploadImage();
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                debugPrint("❌ Error: $e");
                              } finally {
                                if (context.mounted) {
                                  setSheetState(() {
                                    isSaving = false;
                                  });
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.black,
                                ),
                              ),
                            )
                          : const Text(
                              "Save",
                              style: AppTextStyles.displayLabel14,
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

  Future<File?> _cropImage(File imageFile, double scale, Offset offset) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      // UI size (crop widget size)
      const double uiSize = 360;
      const double cropUI = 260; // jitna UI me crop box hai

      final imgW = image.width.toDouble();
      final imgH = image.height.toDouble();

      // Ratio (safe for portrait + landscape)
      final ratioX = imgW / uiSize;
      final ratioY = imgH / uiSize;
      final ratio = ratioX < ratioY ? ratioX : ratioY;

      // Real image crop size
      final cropSize = (cropUI * ratio) / scale;

      // Center based crop
      double dx = (imgW / 2) - (cropSize / 2) - (offset.dx * ratio);
      double dy = (imgH / 2) - (cropSize / 2) - (offset.dy * ratio);

      // Prevent overflow
      dx = dx.clamp(0.0, imgW - cropSize);
      dy = dy.clamp(0.0, imgH - cropSize);

      // Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      // ✅ NO CLIP — PURE RECTANGLE IMAGE
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(dx, dy, cropSize, cropSize),
        Rect.fromLTWH(0, 0, cropSize, cropSize),
        paint,
      );

      final pic = recorder.endRecording();
      final cropped = await pic.toImage(cropSize.toInt(), cropSize.toInt());

      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(data!.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("❌ Crop failed: $e");
      return null;
    }
  }

  String getPlatformKey(String name) {
    switch (name.toLowerCase()) {
      case "facebook":
        return "facebook";
      case "instagram":
        return "instagram";
      case "tiktok":
        return "tiktok";
      case "behance":
        return "behance";
      default:
        return name.toLowerCase();
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) {
      debugPrint("❌ No image selected");
      return;
    }

    try {
      setState(() {
        isUploadingImage = true;
      });

      final filePath = _profileImage!.path;
      final fileName = filePath.split('/').last;

      debugPrint("📤 Uploading Image...");
      debugPrint("📁 Path: $filePath");
      debugPrint("📄 FileName: $fileName");

      FormData formData = FormData.fromMap({
        "crew_member_id": Myprofile_user?.crewMemberId, //
        "profile_photo": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final dio = Dio();
      final headers = await ApiService().createAuthorizationHeader();

      final url = "${ApiService().baseUrl}creator/profile/upload-profile-photo";

      debugPrint("🌐 API URL: $url");
      debugPrint("🔑 Headers: $headers");

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            ...headers,
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      debugPrint("✅ RESPONSE STATUS: ${response.statusCode}");
      debugPrint("📦 RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200) {
        debugPrint("🎉 IMAGE UPLOAD SUCCESS");
        await fetchprofiledata();
      } else {
        debugPrint("❌ Upload failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Upload error: $e");
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  Future<void> deleteSocialLink(int index) async {
    // STEP 1: remove from list
    setState(() {
      socialLinks.removeAt(index);
    });

    // STEP 2: API ko updated list bhej
    final formattedLinks = socialLinks.map((e) {
      return {
        "platform": getPlatformKey(e["name"]!), // 🔥 yaha use karna hai
        "url": e["url"],
      };
    }).toList();

    await ApiService().postData(ApiEndpoints.editprofile, {
      "social_media_links": formattedLinks,
    });

    // STEP 3: refresh
    await fetchprofiledata();
  }

  Future<void> deleteData(int id) async {
    final response = await ApiService().deleteData(
      "${ApiEndpoints.delete_allfiles}/$id",
    );

    if (response["error"] == false) {
      setState(() {
        portfolioLinks.removeWhere((e) => e["id"].toString() == id.toString());
      });

      await fetchprofiledata();

      print("✅ Deleted Successfully");
    } else {
      print("❌ Delete Failed");
    }
  }

  Future<void> saveSocialLinksToApi() async {
    if (socialLinks.isEmpty) {
      TopMessage.show(context, "Add at least one link");
      return;
    }

    setState(() => isloading = true);

    try {
      /// 🔥 FORMAT DATA FOR API
      final List<Map<String, String>> formattedLinks = socialLinks.map((e) {
        return {"platform": e["name"] ?? "", "url": e["url"] ?? ""};
      }).toList();

      debugPrint("SOCIAL LINKS PAYLOAD =====> $formattedLinks");

      /// 🔥 API CALL
      final response = await ApiService().postData(ApiEndpoints.editprofile, {
        "social_media_links": formattedLinks,
      });

      debugPrint("SOCIAL API RESPONSE =====> $response");

      await fetchprofiledata();

      if (response == null) {
        TopMessage.show(context, "Server Error");
        return;
      }

      if (response["error"] == false) {
        // TopMessage.show(context, "Social links updated successfully");

        Navigator.pop(context);
      } else {
        TopMessage.show(context, response["message"] ?? "Failed to update");
      }
    } catch (e) {
      debugPrint("SOCIAL LINK ERROR =====> $e");

      TopMessage.show(context, "Something went wrong");
    } finally {
      setState(() => isloading = false);
    }
  }

  void setSocialLinksFromApi(Map<String, dynamic> links) {
    //final links = userData.socialMediaLinks;
    if (links.isEmpty) {
      setState(() {
        socialLinks = [];
      });
      return;
    }

    List<Map<String, String>> tempList = [];

    links.forEach((key, value) {
      tempList.add({
        "name": key[0].toUpperCase() + key.substring(1),
        "url": value.toString(),
        "icon": getIcon(key),
      });
    });

    setState(() {
      socialLinks = tempList;
    });
  }

  void setPortfolioLinksFromApi(List<CrewFile> links) {
    final tempList = links.where((item) => item.fileType == "link").map((item) {
      final platformKey = item.tag.isNotEmpty ? item.tag : item.title;

      return {
        "id": item.crewFilesId.toString(),
        "name": formatPortfolioName(platformKey),
        "url": item.filePath,
        "icon": getPortfolioIcon(platformKey),
      };
    }).toList();

    setState(() {
      portfolioLinks = tempList;
    });
  }

  String formatName(String key) {
    switch (key.toLowerCase()) {
      case "facebook":
        return "Facebook";
      case "instagram":
        return "Instagram";
      case "tiktok":
        return "TikTok";
      case "behance":
        return "Behance";
      default:
        return key;
    }
  }

  String getIcon(String key) {
    switch (key.toLowerCase()) {
      case "facebook":
        return AppAssets.facebook;
      case "instagram":
        return AppAssets.insta;
      case "tiktok":
        return AppAssets.tiktok;
      case "behance":
        return AppAssets.be;
      default:
        return AppAssets.Ball;
    }
  }

  List<Widget> _buildSkillChips(List<String> skills) {
    List<Widget> chips = [];

    // 👉 First 2 skills show
    for (int i = 0; i < skills.length && i < 2; i++) {
      chips.add(_skillChip("Skill ${i + 1}"));
    }

    // 👉 Remaining count
    if (skills.length > 2) {
      int remaining = skills.length - 2;

      chips.add(_skillChip("+$remaining"));
    }

    return chips;
  }

  bool isloading = false;

  Data? Myprofile_user;

  @override
  void initState() {
    super.initState();
    fetchprofiledata();
  }

  Future<void> fetchprofiledata() async {
    try {
      setState(() {
        isloading = true;
      });

      final rawResponse = await ApiService().postData(
        ApiEndpoints.profiledetails,
        {},
      );

      debugPrint("📦 RAW API RESPONSE: $rawResponse");

      final response = Myprofilemodel.fromJson(rawResponse);

      debugPrint("✅ PARSED RESPONSE: ${response.data}");

      if (response.error == false) {
        /// ✅ SOCIAL LINKS
        setSocialLinksFromApi(response.data.socialMediaLinks);

        /// ✅ PORTFOLIO LINKS
        final portfolio =
            (response.data.portfolioLinks.isNotEmpty
                    ? response.data.portfolioLinks
                    : response.data.crewMemberFiles)
                .where((e) => e.fileType == "link")
                .toList();
        setPortfolioLinksFromApi(portfolio);

        debugPrint("🎯 Portfolio Count: ${portfolio.length}");

        /// ✅ IMPORTANT CHANGE (USE NESTED USER)
        setState(() {
          Myprofile_user = response.data;
        });
      } else {
        debugPrint("❌ API ERROR: ${response.message}");
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  List<Map<String, String>> socialLinks = [];
  int selectedSocialIndex = -1;

  List<Map<String, String>> portfolioLinks = [];
  int selectedPortfolioIndex = -1;
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
  ];

  final List<String> Portfoliolname = ["Vimeo", "YouTube", "Google Drive"];

  final List<String> Portfolioicons = [
    AppAssets.v,
    AppAssets.youtube,
    AppAssets.googledrive,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ///  HEADER SECTION
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// 🔹 BACKGROUND HEADER
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: AppRadii.bottomHeader,
                        child: SvgPicture.asset(
                          AppAssets.rectangle_profile,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    /// 🔹 BACK BUTTON
                    Positioned(
                      top: 90,
                      left: 16,
                      child: InkWell(
                        onTap: () => context.pop(true),
                        child: SvgPicture.asset(
                          AppAssets.back, // make sure it's .svg file
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            AppColors.textHeading,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                    /// 🔹 TITLE (CENTERED)
                    const Positioned(
                      top: 90,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "My Profile",
                          style: AppTextStyles.displayLabel16,
                        ),
                      ),
                    ),

                    /// 🔹 PROFILE IMAGE (CUT INTO CURVE)
                    Positioned(
                      bottom: -20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                            padding: const EdgeInsets.all(AppSpacing.xxs),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.border,
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          width: 96,
                                          height: 96,
                                          fit: BoxFit.cover,
                                        )
                                      : (Myprofile_user
                                                ?.profileImageUrl
                                                .isNotEmpty ??
                                            false)
                                      ? Image.network(
                                          "${ApiService.imageURL}${Myprofile_user!.profileImageUrl}",
                                          width: 96,
                                          height: 96,
                                          fit: BoxFit.cover,
                                        )
                                      : SvgPicture.asset(
                                          AppAssets.User_Circle,
                                          width: 96,
                                          height: 96,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 2,
                              child: Material(
                                color: AppColors.transparent,
                                child: GestureDetector(
                                  // borderRadius: AppRadii.roundAll,
                                  onTap: () {
                                    debugPrint("🔥 EDIT CLICKED");

                                    _pickImage();
                                  },
                                  child: Container(
                                    width: 35,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.white,
                                      ),
                                      color: AppColors.borderGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppAssets.edit_circle,
                                      height: 18,
                                      width: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                /// 🔹 USER INFO
                Text(
                  "${Myprofile_user?.firstName ?? ''} ${Myprofile_user?.lastName ?? ''}",
                  style: AppTextStyles.body20Medium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// EMAIL
                      Flexible(
                        child: Text(
                          Myprofile_user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: AppColors.white60,
                          ),
                        ),
                      ),

                      /// |
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Text(
                          "|",
                          style: AppTextStyles.inherit14.copyWith(
                            color: AppColors.white60,
                          ),
                        ),
                      ),

                      /// LOCATION
                      Flexible(
                        child: Text(
                          Myprofile_user?.location ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: AppColors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// 🔹 EDIT BUTTON
                /*InkWell(
                onTap: () {
                */
                /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  EditProfile(),
                    ),
                  );*/
                /*
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color:  AppColors.white,
                    borderRadius: AppRadii.massiveAll,
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: "Outfit",
                      color: AppColors.textHeading,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),*/
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          infoCard(
                            value:
                                "\$${double.tryParse(Myprofile_user?.hourlyRate ?? '0')?.toInt() ?? 0}",
                            title: "Per Hour",
                            icon: AppAssets.doller,
                          ),

                          infoCard(
                            icon: AppAssets.medal,
                            value:
                                "${(Myprofile_user?.yearsOfExperience ?? 0).toString().padLeft(2, '0')} yrs",
                            title: "Experience",
                          ),

                          infoCard(
                            icon: AppAssets.map,
                            value: Myprofile_user?.workingDistance ?? '',
                            title: "Radius",
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: _buildSkillChips(
                          (Myprofile_user?.skills ?? [])
                              .map((e) => e.name)
                              .toList(),
                        ),
                      ),

                      /*        Container(

                      margin: EdgeInsetsGeometry.only(top: 17),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.softMint, // light green bg
                        borderRadius: AppRadii.hugeAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.greenBright,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check,color: AppColors.white,size: 6,),
                          ),
                          SizedBox(width: 6),
                          Text(
                            Myprofile_user?.isAvailable == 1 ? "Available" : "Unavailable",
                            style: TextStyle(
                              color: Myprofile_user?.isAvailable == 1
                                  ? AppColors.greenBright
                                  : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),*/
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Divider(color: AppColors.dividerDark),
                      ),
                      Row(
                        children: [
                          Text(
                            "Social Link",
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      socialLinks.isEmpty
                          ? const Text(
                              "No social links added",
                              style: AppTextStyles.inherit,
                            )
                          : Column(
                              children: socialLinks.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final item = entry.value;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.smd),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.smd,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    border: Border.all(
                                      color: AppColors.white24,
                                    ),
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: Row(
                                    children: [
                                      /// ICON
                                      SvgPicture.asset(
                                        item["icon"]!,
                                        height: 20,
                                        width: 20,
                                        color: AppColors.white,
                                      ),

                                      const SizedBox(width: 10),

                                      /// NAME + URL
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["name"]!,
                                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                                            ),
                                            Text(
                                              item["url"]!,
                                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white24),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// ✏️ EDIT BUTTON
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.white,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          nameController.text = item["name"]!;
                                          linkController.text = item["url"]!;
                                          selectedSocialIndex = socialNames
                                              .indexOf(item["name"]!);
                                          editingIndex = index;
                                          isEditing = true;
                                          openSocialDialog(
                                            startInEditMode: true,
                                          );
                                        },
                                      ),

                                      /// 🗑 DELETE BUTTON
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          await deleteSocialLink(
                                            index,
                                          ); // 🔥 bas ye hi
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// 🔹 BEHANCE BUTTON
                          /* Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.xlAll,
                            border: Border.all(color: AppColors.dividerDark),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Bē",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Behance",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontFamily: "Outfit",
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),*/

                          /// 🔹 EDIT BUTTON (Right Side)
                          InkWell(
                            onTap: () {
                              openSocialDialog();
                            },

                            borderRadius: AppRadii.lgAll,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.primary, // beige
                                borderRadius: AppRadii.compactCardAll,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.myprofile_edit,
                                /*    color: AppColors.onPrimary,
                              fit: BoxFit.cover,*/
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Portfolio Link",
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      portfolioLinks.isEmpty
                          ? const Text(
                              "No portfolio links added",
                              style: AppTextStyles.inherit,
                            )
                          : Column(
                              children: portfolioLinks.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final item = entry.value;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.smd),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.smd,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    border: Border.all(
                                      color: AppColors.white24,
                                    ),
                                    color: AppColors.surfaceVariant,
                                  ),
                                  child: Row(
                                    children: [
                                      /// ICON
                                      SvgPicture.asset(
                                        item["icon"]!,
                                        height: 20,
                                        width: 20,
                                        color: AppColors.primary,
                                      ),

                                      const SizedBox(width: 10),

                                      /// NAME + URL
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["name"]!,
                                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                                            ),
                                            Text(
                                              item["url"]!,
                                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white24),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// EDIT
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.white,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          editingIndex = index; // 🔥 ADD THIS
                                          linkController.text = item["url"]!;
                                          selectedPortfolioIndex =
                                              Portfoliolname.indexOf(
                                                item["name"]!,
                                              );
                                          openPortfolioDialog(
                                            startInEditMode: true,
                                          );
                                        },
                                      ),

                                      /// DELETE
                                      /// DELETE
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final id = int.parse(
                                            item["id"].toString(),
                                          );

                                          debugPrint("DELETE ID ======> $id");

                                          await deleteData(id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// 🔹 BEHANCE BUTTON
                          /*   Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.xlAll,
                            border: Border.all(color: AppColors.dividerDark),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Bē",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "YouTube",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontFamily: "Outfit",
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),*/

                          /// 🔹 EDIT BUTTON (Right Side)
                          InkWell(
                            onTap: () {
                              openPortfolioDialog();
                            },

                            borderRadius: AppRadii.lgAll,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.primary, // beige
                                borderRadius: AppRadii.compactCardAll,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.myprofile_edit,
                                /*    color: AppColors.onPrimary,
                              fit: BoxFit.cover,*/
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _profileMenuCard(),

                const SizedBox(height: 30),
              ],
            ),
          ),
          if (isloading) AppLoader(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.smd, AppSpacing.base, AppSpacing.xl),
        color: AppColors.background,
        child: InkWell(
          onTap: _showLogoutBottomSheet,
          borderRadius: AppRadii.xxlAll,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary, // beige color
              borderRadius: AppRadii.xxlAll,
            ),
            child: const Center(
              child: Text(
                "Logout",
                style: AppTextStyles.displayLabel14Strong,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.dropdownIconInset),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid, // bg color
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2), // 20% opacity
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.body12,
      ),
    );
  }

  Widget _profileMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  "My Account",
                  style: AppTextStyles.displayLabel14.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Column(
              children: [
                _menuRow(
                  AppAssets.userid,
                  "Profile Details",
                  onTap: () {
                    context.pushNamed(RouteNames.profileDetails);
                  },
                ),

                /*         Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Portfolio & Credentials",style: TextStyle(
                          color: AppColors.white,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                ),
                _divider(),
                _menuRow(AppAssets.gallery, "Featured Works", onTap: () {
                */
                /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  BookingHistoryScreen(),
                    ),
                  );*/
                /*
                }),
                _divider(),
                _menuRow(AppAssets.certificates, "Certificates"),
                _divider(),
                _menuRow(AppAssets.resume, "Resume"),*/
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  "Portfolio & Credentials",
                  style: AppTextStyles.displayLabel14.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Column(
              children: [
                _menuRow(
                  AppAssets.gallery,
                  "Featured Works",
                  onTap: () {
                    context.pushNamed(RouteNames.featuredWorks);
                  },
                ),
                _divider(),
                _menuRow(
                  AppAssets.certificates,
                  "certificates",
                  onTap: () {
                    context.pushNamed(RouteNames.certificates);
                  },
                ),
                _divider(),
                _menuRow(
                  AppAssets.resume,
                  "resume",
                  onTap: () {
                    context.pushNamed(RouteNames.resume);
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Divider(color: AppColors.dividerDark),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  "Settings",
                  style: AppTextStyles.displayLabel14.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Column(
              children: [
                _menuRow(
                  AppAssets.appperference,
                  "App Preferences",
                  onTap: () {
                    context.pushNamed(RouteNames.appPreferences);
                  },
                ),
                _divider(),
                _menuRow(
                  AppAssets.notificationsetting,
                  "Notifications Settings",
                ),

                /* _divider(),*/
                /*        _menuRow(
                  AppAssets.iconExit,
                  "Logout",
                  onTap: _showLogoutBottomSheet,
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(String iconPath, String title, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: AppRadii.hugeAll,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: AppColors.calendarGrid,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  color: AppColors.white,
                ),

                // Image.asset(
                //   iconPath,
                //   height: 22,
                //   width: 22,
                //   color: AppColors.white,
                // ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body14,
              ),
            ),
            // ),
            SvgPicture.asset(
              AppAssets.goto, // make sure it's .svg file
              height: 10,
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Divider(height: 1, color: AppColors.dividerDark),
    );
  }

  Widget infoCard({
    required String icon,
    required String value,
    required String title,
  }) {
    return Container(
      width: 105,
      height: 120,

      /// 🌈 GRADIENT BORDER
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.40),
            AppColors.primary.withValues(alpha: 0.04),
            AppColors.primary.withValues(alpha: 0.28),
          ],
        ),
      ),

      /// 🔥 INNER DARK CONTAINER
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.fine), // 👈 border thickness (0.5px feel)
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: AppRadii.statsInnerAll,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              /// 🔝 TOP ICON TAB
              Positioned(
                top: -1,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.bottomXl,
                  ),
                  child: SvgPicture.asset(
                    icon,
                    // width: 16,
                    // height: 16,
                    color: AppColors.black,
                  ),
                ),
              ),

              /// 🧾 TEXT CONTENT
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    value,
                    style: AppTextStyles.bodyLargeMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openSocialDialog({bool startInEditMode = false}) {
    bool showForm = socialLinks.isEmpty || startInEditMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AnimatedPadding(
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
                          const Text(
                            "Add Social Links",
                            style: AppTextStyles.displayLabel16,
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

                      const Text(
                        "Add links that showcase your work, recognition,\npersonality and more!",
                        style: AppTextStyles.bodyMedium,
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.dividerDark),
                      const SizedBox(height: 20),

                      /// SOCIAL ICONS ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          socialIcons.length,
                          (index) => InkWell(
                            borderRadius: AppRadii.xxlAll,
                            onTap: () {
                              setInnerState(() {
                                selectedSocialIndex = index;
                                nameController.text = socialNames[index];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: selectedSocialIndex == index
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.transparent,
                                borderRadius: AppRadii.xxlAll,
                                border: Border.all(
                                  color: selectedSocialIndex == index
                                      ? AppColors.primary
                                      : AppColors.white24,
                                  width: selectedSocialIndex == index
                                      ? 1.5
                                      : 0.8,
                                ),
                                boxShadow: selectedSocialIndex == index
                                    ? AppShadows.goldCta
                                    : const [],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  socialIcons[index],
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    selectedSocialIndex == index
                                        ? AppColors.primary
                                        : AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SAVED LINKS LIST
                      if (!isEditing && socialLinks.isNotEmpty) ...[
                        Text(
                          "${socialLinks.length}/6",
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.white24,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...socialLinks.asMap().entries.map((entry) {
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
                              color: AppColors.black,
                            ),
                            child: Row(
                              children: [
                                /// DRAG BOX
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.09,
                                  height:
                                      MediaQuery.of(context).size.width * 0.09,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159 / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                /// ICON
                                // Image.asset(
                                //   item["icon"]!,
                                //   height: 20,
                                //   width: 20,
                                //   color: AppColors.white,
                                // ),
                                SvgPicture.asset(
                                  item["icon"]!,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.white,
                                ),

                                const SizedBox(width: 10),

                                /// NAME
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: AppTextStyles.body14Medium.copyWith(color: AppColors.white),
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
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setInnerState(() {
                                        showForm = true;
                                        selectedSocialIndex = socialNames
                                            .indexOf(item["name"]!);
                                        nameController.text = item["name"]!;
                                        linkController.text = item["url"]!;
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
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setInnerState(() {
                                        setState(() {
                                          socialLinks.removeAt(index);
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

                      /// FORM FIELDS
                      if (showForm) ...[
                        CustomTextField(
                          label: "Name of the Link*",
                          controller: nameController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Link URL*",
                          controller: linkController,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select platform and enter link",
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final name = socialNames[selectedSocialIndex];
                              final icon = socialIcons[selectedSocialIndex];
                              final url = linkController.text.trim();

                              setInnerState(() {
                                setState(() {
                                  /// 🔥 EDIT OR ADD LOGIC
                                  if (editingIndex != -1) {
                                    // ✅ EDIT
                                    socialLinks[editingIndex] = {
                                      "name": name,
                                      "url": url,
                                      "icon": icon,
                                    };
                                  } else {
                                    // ✅ ADD
                                    socialLinks.add({
                                      "name": name,
                                      "url": url,
                                      "icon": icon,
                                    });
                                  }
                                });

                                /// 🔥 RESET STATE (VERY IMPORTANT)
                                showForm = false;
                                selectedSocialIndex = -1;
                                isEditing = false;
                                editingIndex = -1;

                                nameController.clear();
                                linkController.clear();
                              });
                            },
                            child: const Text(
                              "Save Link",
                              style: AppTextStyles.buttonMedium,
                            ),
                          ),
                        ),
                      ],

                      /// ADD ANOTHER + SAVE
                      if (!showForm) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setInnerState(() {
                              showForm = true;
                              selectedSocialIndex = -1;
                              nameController.clear();
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
                              const Text(
                                "Add another link",
                                style: AppTextStyles.bodyMedium,
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
                            onPressed: saveSocialLinksToApi,
                            child: const Text(
                              "Save",
                              style: AppTextStyles.buttonMedium,
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

  void openPortfolioDialog({bool startInEditMode = false}) {
    bool showForm = portfolioLinks.isEmpty || startInEditMode;
    bool isUpdating = false; // local loading state inside the modal

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
                    color: AppColors.background,
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
                          const Text(
                            "Add Portfolio Links",
                            style: AppTextStyles.displayLabel16,
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
                      const Text(
                        "Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.",
                        style: AppTextStyles.inherit13,
                      ),
                      const SizedBox(height: 20),

                      /// PORTFOLIO ICONS ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          Portfolioicons.length,
                          (index) => InkWell(
                            onTap: () {
                              setModalState(() {
                                showForm = true;
                                editingIndex = -1;
                                selectedPortfolioIndex = index;
                                nameController.text = Portfoliolname[index];
                                linkController.clear();
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
                                child: SvgPicture.asset(
                                  Portfolioicons[index],
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    selectedPortfolioIndex == index
                                        ? AppColors.primary
                                        : AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// ✅ SAVED PORTFOLIO LINKS LIST – only show when NOT editing (like social links)
                      if (!showForm &&
                          editingIndex == -1 &&
                          portfolioLinks.isNotEmpty) ...[
                        Text(
                          "${portfolioLinks.length}/3",
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.white24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...portfolioLinks.asMap().entries.map((entry) {
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
                              color: AppColors.black,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159 / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  item["icon"]!,
                                  height: 20,
                                  width: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: AppTextStyles.body14Medium.copyWith(
                                      color: AppColors.white,
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
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        showForm = true;
                                        // Case‑insensitive search for platform name
                                        selectedPortfolioIndex =
                                            Portfoliolname.indexWhere(
                                              (e) =>
                                                  e.toLowerCase() ==
                                                  item["name"]!.toLowerCase(),
                                            );
                                        if (selectedPortfolioIndex == -1) {
                                          selectedPortfolioIndex = 0;
                                        }
                                        nameController.text = item["name"]!;
                                        linkController.text = item["url"]!;
                                        editingIndex = index;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    color: AppColors.surfaceMid,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        setState(() {
                                          portfolioLinks.removeAt(index);
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

                      /// FORM FIELDS (for both add and edit)
                      if (showForm) ...[
                        CustomTextField(
                          label: "Link URL",
                          controller: linkController,
                        ),
                        const SizedBox(height: 24),
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
                            onPressed: isUpdating
                                ? null
                                : () => _handlePortfolioSaveLink(
                                    setModalState: setModalState,
                                    setUpdating: (val) =>
                                        setModalState(() => isUpdating = val),
                                    getUpdating: () => isUpdating,
                                    onAdded: () => showForm = false,
                                  ),
                            /*  onPressed: isUpdating
                                ? null
                                : () async {
                              if (selectedPortfolioIndex == -1 ||
                                  linkController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Select platform & enter link"),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              // ✅ EDIT MODE: call API directly
                              if (editingIndex != -1) {
                                final id = portfolioLinks[editingIndex]["id"]?.toString();
                                if (id == null || id.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Invalid link ID"),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                final platform = getPortfolioKey(Portfoliolname[selectedPortfolioIndex]);
                                final url = linkController.text.trim();

                                setModalState(() => isUpdating = true);

                                try {
                                  final response = await ApiService().postData(
                                    "creator/profile/edit-portfolio-link/$id",
                                    {
                                      "url": url,
                                      "platform": platform,
                                      "title": Portfoliolname[selectedPortfolioIndex],
                                    },
                                  );

                                  if (response["error"] == false) {
                                    await fetchprofiledata();
                                    if (mounted) Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(response["message"] ?? "Edit failed")),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint("Edit error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Network error. Please try again."),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                } finally {
                                  if (mounted) setModalState(() => isUpdating = false);
                                }
                                return;
                              }

                              // ✅ ADD MODE: local update (show final "Save" button later)
                              setModalState(() {
                                setState(() {
                                  portfolioLinks.add({
                                    "id": "",
                                    "name": Portfoliolname[selectedPortfolioIndex],
                                    "url": linkController.text.trim(),
                                    "icon": Portfolioicons[selectedPortfolioIndex],
                                  });
                                });
                                showForm = false;
                                selectedPortfolioIndex = -1;
                                nameController.clear();
                                linkController.clear();
                              });
                            },*/
                            child: isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.black,
                                    ),
                                  )
                                : const Text(
                                    "Save Link",
                                    style: AppTextStyles.buttonMedium,
                                  ),
                          ),
                        ),
                      ],

                      /// ADD ANOTHER + FINAL SAVE (only for add mode)
                      if (!showForm) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setModalState(() {
                              showForm = true;
                              editingIndex = -1;
                              selectedPortfolioIndex = 0;
                              nameController.text =
                                  Portfoliolname[selectedPortfolioIndex];
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
                              const Text(
                                "Add another link",
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// ✅ Final "Save" button only for adding new links (not for edit)
                        if (editingIndex == -1)
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
                              onPressed: savePortfolioLinksToApi,
                              child: const Text(
                                "Save",
                                style: AppTextStyles.buttonMedium,
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

  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: AppRadii.topMassive,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// DRAG INDICATOR
              Container(
                height: 5,
                width: 30,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.white30,
                  borderRadius: AppRadii.nanoAll,
                ),
              ),

              Text(
                "Logout",
                style: AppTextStyles.displayLabel15Strong.copyWith(
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Are you sure you want to log out?",
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 14),

              Divider(height: 1, color: AppColors.dividerDark),

              SizedBox(height: 10),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.white60),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xlAll,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: AppTextStyles.displayLabel14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// LOGOUT
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SharedService.logout(); // 🔥 clear all prefs

                        context.goNamed(RouteNames.login);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xlAll,
                        ),
                      ),
                      child: Text(
                        "Yes, Logout",
                        style: AppTextStyles.displayLabel14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textHeading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
