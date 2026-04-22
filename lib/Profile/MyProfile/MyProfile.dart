import 'dart:io';
import 'dart:ui' as ui;

import 'package:beige_creative_app/Model_Class/myprofilemodel.dart';
import 'package:beige_creative_app/auth/login/login.dart';
import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:beige_creative_app/service/api_service.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model_Class/myprofilemodel.dart';
import '../../auth/New_Creative_sing_up_follow/new_build_your_creative_profile.dart';
import '../../auth/ProfileDetailsScreen .dart';
import '../../service/shared_service.dart';
import '../../utility/ColorCode.dart';
import '../../utility/app_utils.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/custom_text_field.dart';
import '../AppPreferences/app_preferences.dart';
import '../Certificates/Certificates.dart';
import '../Featuredwork/featured_work_list.dart';
import '../ProfileDetils/profile_detils_1screen.dart';
import '../Resume/Resume.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  Future<void> editPortfolioLink() async {
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
  }
  String getPortfolioIcon(String key) {
    switch (key.toLowerCase()) {
      case "youtube":
        return AppImages.youtube;
      case "vimeo":
        return AppImages.v;
      case "google_drive":
        return AppImages.googledrive;
      default:
        return "assets/svg/Ball.svg";
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
        return {
          "platform": getPortfolioKey(e["name"]!),
          "url": e["url"],
        };
      }).toList();

      final response = await ApiService().postData(
        "creator/profile/add-portfolio-links",
        {
          "portfolio_links": formattedLinks,
        },
      );

      if (response["error"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Portfolio links added ✅")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Error")),
        );
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
  bool isSaving = false;

  bool isEditing = false;
  bool isUploadingImage = false;
  File? _image;
  int editingIndex = -1;
  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;
  double scale = 1.0;
  double startScale = 1.0;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;


  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      debugPrint("🟢 IMAGE PICKED: ${pickedFile.path}");

      /// 🔥 OPEN CROP SHEET
      openCustomCropSheet(file);
    }
  }

  void openCustomCropSheet(File imageFile) {
    Offset offset = Offset.zero;
    double scale = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [


                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color:ColorCode.kWhiteOpacity70,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Crop your Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      InkWell(
                        onTap: () => Navigator.pop(context), // ❌ close bottom sheet
                        borderRadius: BorderRadius.circular(20),
                        child:  Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: 20),

                  Divider(color: ColorCode.kDividerWhite12,),

                  /// 🔥 CIRCULAR PREVIEW AREA
                  Expanded(
                    child: Center(
                      child:GestureDetector(
                        onScaleStart: (details) {
                          startScale = scale;
                          startOffset = offset;
                        },
                        onScaleUpdate: (details) {
                          setSheetState(() {
                            scale = (startScale * details.scale).clamp(1.0, 4.0);
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
                    padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        /// 🔹 LEFT IMAGE ICON
                        SvgPicture.asset(
                          "assets/svg/crop_image.svg", // 👈 your image

                          height: 20,
                          width: 20,
                          /*  color: Colors.white.withOpacity(0.7), */// optional
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
                              activeTrackColor: ColorCode.kButtonColor,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: ColorCode.kButtonColor,
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
                          "assets/svg/crop_image.svg", // 👈 your image

                          height: 26,
                          width: 26,
                          /*  color: Colors.white.withOpacity(0.7), */// optional
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
                        backgroundColor: ColorCode.kButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        setSheetState(() {
                          isSaving = true;
                        });

                        final cropped = await _cropImage(
                          imageFile,
                          scale,
                          offset,
                        );

                        if (cropped != null) {
                          setState(() {
                            _profileImage = cropped;
                          });

                          debugPrint("✅ CROPPED IMAGE PATH: ${cropped.path}");

                         await _uploadImage();
                        }

                        setSheetState(() {
                          isSaving = false;
                        });

                        Navigator.pop(context);
                      },
                      child:  Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
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
  Future<File?> _cropImage(
      File imageFile,
      double scale,
      Offset offset,
      ) async {
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
      final cropped =
      await pic.toImage(cropSize.toInt(), cropSize.toInt());

      final data =
      await cropped.toByteData(format: ui.ImageByteFormat.png);

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

      final url =
          "${ApiService().baseUrl}creator/profile/upload-profile-photo";

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

    await ApiService().postData(
      ApiEndpoints.editprofile,
      {
        "social_media_links": formattedLinks,
      },
    );

    // STEP 3: refresh
    await fetchprofiledata();
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
        return AppImages.facebook;
      case "instagram":
        return AppImages.insta;
      case "tiktok":
        return AppImages.tiktok;
      case "behance":
        return AppImages.be;
      default:
        return "assets/svg/Ball.svg";
    }
  }
  Future<void> saveSocialLinksToApi() async {
    if (socialLinks.isEmpty) {
      TopMessage.show(context, "Add at least one link");
      return;
    }

    setState(() => isloading = true);

    try {
      final List<Map<String, String>> formattedLinks =
      socialLinks.map((e) {
        return {
          "platform": e["name"] ?? "",
          "url": e["url"] ?? "",
        };
      }).toList();

      final response = await ApiService().postData(
        ApiEndpoints.editprofile, // 👈 same endpoint
        {
          "social_media_links": formattedLinks,
        },
      );
      await fetchprofiledata();
      if (response == null) {
        TopMessage.show(context, "Server Error");
        return;
      }

      if (response["error"] == false) {
        TopMessage.show(context, "Social links updated");
        Navigator.pop(context); // close bottom sheet
      } else {
        TopMessage.show(
            context, response["message"] ?? "Failed to update");
      }
    } catch (e) {
      TopMessage.show(context, "Something went wrong");
    } finally {
      setState(() => isloading = false);
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
  bool isloading=false;


Data? Myprofile_user;

  Future<void> fetchprofiledata() async {
    try {
      setState(() {
        isloading = true;
      });

      final rawResponse =
      await ApiService().postData(ApiEndpoints.profiledetails, {});

      debugPrint("📦 RAW API RESPONSE: $rawResponse");

      final response = Myprofilemodel.fromJson(rawResponse);

      debugPrint("✅ PARSED RESPONSE: ${response.data}");

      if (response.error == false) {

        /// ✅ SOCIAL LINKS
        setSocialLinksFromApi(response.data.socialMediaLinks);

        /// ✅ PORTFOLIO LINKS
        final portfolio = response.data.crewMemberFiles
            .where((e) => e.fileType == "link")
            .toList();

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




  @override
  void initState() {
    super.initState();
    fetchprofiledata();
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
    // "assets/icons/facbook_iIcon.png",
    // "assets/icons/ins_icon.png",
    // "assets/icons/ticktok.png",
    // "assets/icons/behance.png",
    // "assets/icons/webside.png",
    AppImages.facebook,
    AppImages.insta,
    AppImages.tiktok,
    AppImages.be,
    "assets/svg/Ball.svg"
  ];

  final List<String> Portfoliolname  = [
    "Vimeo",
    "YouTube",
    "Google Drive",
  ];

  final List<String> Portfolioicons = [
    // "assets/icons/vimeo-icon 1.png",
    // "assets/icons/YouTube.png",
    // "assets/icons/Google_Drive.png",
    AppImages.v,
    AppImages.youtube,
    AppImages.googledrive,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: isloading?
          Center(
            child: CircularProgressIndicator(),
          )

      :SingleChildScrollView(
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
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.asset(
                      "assets/profile/Rectangle_49.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                /// 🔹 BACK BUTTON
                Positioned(
                  top: 90,
                  left: 16,
                  child:  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      AppImages.back, // make sure it's .svg file
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        ColorCode.kHeadingColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                /// 🔹 TITLE (CENTERED)
                const Positioned(
                  top:90 ,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: ColorCode.kHeadingColor,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
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
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(
                                _profileImage!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              )
                                  : (Myprofile_user?.user.profileImageUrl.isNotEmpty ?? false)
                                  ? Image.network(
                                "${ApiService.imageURL}${Myprofile_user!.user.profileImageUrl}",
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, size: 50);
                                },
                              )
                                  : SvgPicture.asset(
                                AppImages.User_Circle,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                          ),


                        ),
                        Positioned(
                          bottom: 0,
                          right: 2,
                          child: Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              // borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                debugPrint("🔥 EDIT CLICKED");




                                _pickImage();
                              },
                              child: Container(
                                width: 35,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  color: ColorCode.kGoldGradientLight,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  AppImages.myprofileeditphoto,
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
              style: TextStyle(
                fontFamily: "Outfit",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              maxLines: 2,
              "${Myprofile_user?.email ?? ''} | ${Myprofile_user?.location ?? ''}",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontFamily: "Outfit",
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 14),

            /// 🔹 EDIT BUTTON
            /*InkWell(
              onTap: () {
              *//*  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  EditProfile(),
                  ),
                );*//*
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color:  ColorCode.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: "Outfit",
                    color: ColorCode.kHeadingColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),*/
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:  Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoCard(
                        value:
                        "\$${double.tryParse(Myprofile_user?.hourlyRate ?? '0')?.toInt() ?? 0}",
                        title: "Per Hour",
                        icon: AppImages.doller,
                      ),

                      infoCard(
                        icon: AppImages.medal,
                        value:
                        "${(Myprofile_user?.yearsOfExperience ?? 0).toString().padLeft(2, '0')} yrs",
                        title: "Experience",
                      ),

                      infoCard(
                        icon: AppImages.map,
                        value: "${Myprofile_user?.workingDistance ?? ''}",
                        title: "Radius",
                      ),
                    ],
                  ),
                  SizedBox(height: 12,),
                  Wrap(
                    spacing: 10,
                    children: _buildSkillChips(
                      (Myprofile_user?.skills ?? [])
                          .map((e) => e.name)
                          .toList(),
                    ),
                  ),
                  Container(

                    margin: EdgeInsetsGeometry.only(top: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8FDE6), // light green bg
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1DAA23),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check,color: Colors.white,size: 6,),
                        ),
                        SizedBox(width: 6),
                        Text(
                          Myprofile_user?.isAvailable == 1 ? "Available" : "Unavailable",
                          style: TextStyle(
                            color: Myprofile_user?.isAvailable == 1
                                ? Color(0xFF1DAA23)
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding:  EdgeInsets.all(12),
                    child: Divider(color: ColorCode.kDividerWhite12,),
                  ),
                  Row(
                    children: [
                      Text("Social Link",style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                  const SizedBox(height: 14),
                  socialLinks.isEmpty
                      ? const Text(
                    "No social links added",
                    style: TextStyle(color: Colors.white54),
                  )
                      : Column(
                    children: socialLinks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                          color: const Color(0xFF2A2A2A),
                        ),
                        child: Row(
                          children: [

                            /// ICON
                            SvgPicture.asset(
                              item["icon"]!,
                              height: 20,
                              width: 20,
                              color: Colors.white,
                            ),

                            const SizedBox(width: 10),

                            /// NAME + URL
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"]!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    item["url"]!,
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),

                            /// ✏️ EDIT BUTTON
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              onPressed: () {
                                nameController.text = item["name"]!;
                                linkController.text = item["url"]!;
                                selectedSocialIndex = socialNames.indexOf(item["name"]!);
                                editingIndex = index;
                                isEditing = true;
                                openSocialDialog(startInEditMode: true);
                              },
                            ),

                            /// 🗑 DELETE BUTTON
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 18),
                                onPressed: () async {
                                  await deleteSocialLink(index); // 🔥 bas ye hi
                                },

                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// 🔹 BEHANCE BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Bē",
                              style: TextStyle(
                                color: Color(0xFFE8D1AB),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Behance",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Outfit",
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 EDIT BUTTON (Right Side)
                      InkWell(
                        onTap: () {
                          openSocialDialog();
                        },

                          borderRadius: BorderRadius.circular(12),
                        child: Container(

                         padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorCode.kButtonColor, // beige
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SvgPicture.asset(
                            AppImages.myprofile_edit,
                        /*    color: Color(0xff1D1D1B),
                            fit: BoxFit.cover,*/
                          )

                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [

                      Text("Portfolio Link",style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                  portfolioLinks.isEmpty
                      ? const Text(
                    "No portfolio links added",
                    style: TextStyle(color: Colors.white54),
                  )
                      : Column(
                    children: portfolioLinks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                          color: const Color(0xFF2A2A2A),
                        ),
                        child: Row(
                          children: [

                            /// ICON
                            SvgPicture.asset(
                              item["icon"]!,
                              height: 20,
                              width: 20,
                              color: const Color(0xffE8D1AB),
                            ),

                            const SizedBox(width: 10),

                            /// NAME + URL
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"]!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    item["url"]!,
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),

                            /// EDIT
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              onPressed: () {
                                editingIndex = index;           // 🔥 ADD THIS
                                linkController.text = item["url"]!;
                                selectedPortfolioIndex = Portfoliolname.indexOf(item["name"]!);
                                openPortfolioDialog(startInEditMode: true);
                              },
                            ),

                            /// DELETE
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              onPressed: () {
                                setState(() {
                                  portfolioLinks.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// 🔹 BEHANCE BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Bē",
                              style: TextStyle(
                                color: Color(0xFFE8D1AB),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "YouTube",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Outfit",
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 EDIT BUTTON (Right Side)
                      InkWell(
                        onTap: () {

                          openPortfolioDialog();
                        },

                        borderRadius: BorderRadius.circular(12),
                        child: Container(

                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorCode.kButtonColor, // beige
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child:  SvgPicture.asset(
                            AppImages.myprofile_edit,
                            /*    color: Color(0xff1D1D1B),
                            fit: BoxFit.cover,*/
                          )
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        color: ColorCode.bcakgroundcolor,
        child: InkWell(
          onTap: _showLogoutBottomSheet,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: ColorCode.kButtonColor, // beige color
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "Logout",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorCode.kHeadingColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF282828), // bg color
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2), // 20% opacity
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Outfit',
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _profileMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("My Account",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow(
                  AppImages.userid,
                  "Profile Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  ProfileDetils1screen(),
                      ),
                    );
                  },
                ),

       /*         Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Portfolio & Credentials",style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                ),
                _divider(),
                _menuRow("assets/profile/Gallery_Wide.png", "Featured Works", onTap: () {
                *//*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  BookingHistoryScreen(),
                    ),
                  );*//*
                }),
                _divider(),
                _menuRow("assets/profile/Icon_Frame.png", "Certificates"),
                _divider(),
                _menuRow("assets/profile/Document_Text.png", "Resume"),*/
              ],
            ),
          ),



          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Portfolio & Credentials",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [


                _menuRow(AppImages.gallery, "Featured Works", onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  FeaturedWorkList(),
                    ),
                  );
                }),
                _divider(),
                _menuRow(AppImages.certificates, "Certificates",onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  Certificates(),
                    ),
                  );
                },),
                _divider(),
                _menuRow(AppImages.resume, "Resume",onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  Resume(),
                    ),
                  );
                },),
              ],
            ),
          ),

          SizedBox(height: 10,),
          Padding(
            padding:  EdgeInsets.all(12),
            child: Divider(color: ColorCode.kDividerWhite12,),
          ),



          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Settings",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          SizedBox(height: 10,),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow("assets/svg/App.svg", "App Preferences",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  AppPreferences(),
                        ),
                      );
                    }),
                _divider(),
                _menuRow(AppImages.notificationsetting ,"Notifications Settings"),
                _divider(),
        /*        _menuRow(
                  "assets/Icons/Exit.png",
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(iconPath,width: 22,height: 22,color: ColorCode.white,)

                // Image.asset(
                //   iconPath,
                //   height: 22,
                //   width: 22,
                //   color: ColorCode.white,
                // ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
            // Image.asset(
            //   "assets/profile/path9429.png",
            //   height: 20,
            //   width: 20,
            //   color: ColorCode.white,
            // ),
          SvgPicture.asset(
            AppImages.goto, // make sure it's .svg file
            height: 17,
            width: 17,
            colorFilter: ColorFilter.mode(
              ColorCode.white,
              BlendMode.srcIn,
            ),
          )

          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.white12,
      ),
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
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8D1AB).withOpacity(0.40),
            const Color(0xFFE8D1AB).withOpacity(0.04),
            const Color(0xFFE8D1AB).withOpacity(0.28),
          ],
        ),
      ),

      /// 🔥 INNER DARK CONTAINER
      child: Padding(
        padding: const EdgeInsets.all(0.6), // 👈 border thickness (0.5px feel)
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              /// 🔝 TOP ICON TAB
              Positioned(
                top: -1,
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D1AB),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: SvgPicture.asset(
                    icon,
                    // width: 16,
                    // height: 16,
                    color: Colors.black,
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
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
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
      backgroundColor: Colors.transparent,
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
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: ColorCode.bcakgroundcolor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// DRAG INDICATOR
                      Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add Social Links",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),

                      const Text(
                        "Add links that showcase your work, recognition,\npersonality and more!",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 14,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: ColorCode.kDividerWhite12),
                      const SizedBox(height: 20),

                      /// SOCIAL ICONS ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          socialIcons.length,
                              (index) => InkWell(
                            borderRadius: BorderRadius.circular(16),
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
                                    ? ColorCode.kButtonColor.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedSocialIndex == index
                                      ? ColorCode.kButtonColor
                                      : Colors.white24,
                                  width: selectedSocialIndex == index ? 1.5 : 0.8,
                                ),
                                boxShadow: selectedSocialIndex == index
                                    ? [
                                  BoxShadow(
                                    color: ColorCode.kButtonColor.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                                    : [],
                              ),
                              child: Center(
                             child:  SvgPicture.asset(
                                  socialIcons[index],
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    selectedSocialIndex == index
                                        ? ColorCode.kButtonColor
                                        : Colors.white,
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
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontFamily: "Outfit",
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...socialLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                /// DRAG BOX
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.09,
                                  height: MediaQuery.of(context).size.width * 0.09,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159 / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      color: ColorCode.kButtonColor,
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
                                //   color: Colors.white,
                                // ),
                                SvgPicture.asset(item["icon"]!,width: 20,height: 20,color: Colors.white,),

                                const SizedBox(width: 10),

                                /// NAME
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ),

                                /// EDIT BUTTON
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white, size: 16),
                                    onPressed: () {
                                      setInnerState(() {
                                        showForm = true;
                                        selectedSocialIndex =
                                            socialNames.indexOf(item["name"]!);
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
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 16),
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
                        }).toList(),

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
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
            onPressed: () {
            if (selectedSocialIndex == -1 ||
            linkController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text("Please select platform and enter link"),
            backgroundColor: Colors.red,
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
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
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
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.black, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Add another link",
                                style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
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
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: saveSocialLinksToApi,
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
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
  void openPortfolioDialog({bool startInEditMode = false}) {
    bool showForm = portfolioLinks.isEmpty || startInEditMode;
    bool isUpdating = false; // local loading state inside the modal

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: ColorCode.bcakgroundcolor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add Portfolio Links",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 13,
                        ),
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
                                selectedPortfolioIndex = index;
                                nameController.text = Portfoliolname[index];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selectedPortfolioIndex == index
                                      ? ColorCode.kButtonColor
                                      : Colors.white24,
                                ),
                                color: selectedPortfolioIndex == index
                                    ? ColorCode.kButtonColor.withOpacity(0.15)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  Portfolioicons[index],
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    selectedPortfolioIndex == index
                                        ? ColorCode.kButtonColor
                                        : Colors.white,
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
                      if (editingIndex == -1 && portfolioLinks.isNotEmpty) ...[
                        Text(
                          "${portfolioLinks.length}/3",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontFamily: "Outfit",
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...portfolioLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159 / 2,
                                    child: const Icon(
                                      Icons.drag_indicator,
                                      size: 18,
                                      color: ColorCode.kButtonColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  item["icon"]!,
                                  height: 20,
                                  width: 20,
                                  color: const Color(0xffE8D1AB),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white, size: 16),
                                    onPressed: () {
                                      setModalState(() {
                                        showForm = true;
                                        // Case‑insensitive search for platform name
                                        selectedPortfolioIndex = Portfoliolname.indexWhere(
                                              (e) => e.toLowerCase() == item["name"]!.toLowerCase(),
                                        );
                                        if (selectedPortfolioIndex == -1)
                                          selectedPortfolioIndex = 0;
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
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff282828),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 16),
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
                        }).toList(),
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
                              backgroundColor: ColorCode.kButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isUpdating
                                ? null
                                : () async {
                              if (selectedPortfolioIndex == -1 ||
                                  linkController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Select platform & enter link"),
                                    backgroundColor: Colors.red,
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
                                      backgroundColor: Colors.red,
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
                                      backgroundColor: Colors.red,
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
                            },
                            child: isUpdating
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                                : const Text(
                              "Save Link",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
                              selectedPortfolioIndex = -1;
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
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.add, color: Colors.black, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Add another link",
                                style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                ),
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
                                backgroundColor: ColorCode.kButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: savePortfolioLinksToApi,
                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// DRAG INDICATOR
              Container(
                height: 5,
                width: 30,
                margin:  EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ColorCode.kWhiteOpacity70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),


              Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontFamily: "Outfit",
                ),
              ),
              SizedBox(height: 14),

              Divider(
                height: 1,
                color: ColorCode.kDividerWhite12,
              ),

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
                        side:  BorderSide(color: ColorCode.kWhiteOpacity60),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: "Unbounded",
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

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => Login()),
                              (route) => false,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:  ColorCode.kButtonColor,
                        padding:  EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "Yes, Logout",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorCode.kHeadingColor,
                          fontFamily: "Unbounded",
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
