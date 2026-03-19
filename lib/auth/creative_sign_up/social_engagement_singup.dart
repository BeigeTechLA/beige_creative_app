import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/custom_text_field.dart';
import '../ProfileDetailsScreen .dart';
import '../login/login.dart';

class SocialEngagementSingup extends StatefulWidget {
  final int ?crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? location;          // ✅ ADD
  final String? workingDistance;
  final int step2Progress;

  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;

  const SocialEngagementSingup({
    super.key,
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName, this.location,
    this.workingDistance,

    this.primaryRole = "",
    this.experience = "",
    this.hourlyRate = "",
    this.bio = "",
    this.skills = "",
    this.equipments = "", required this.step2Progress,
  });

  @override
  State<SocialEngagementSingup> createState() =>_SocialEngagementSingupState();
}

class _SocialEngagementSingupState extends State<SocialEngagementSingup> {

  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  final TextEditingController enter_work_titleController = TextEditingController();

  int selectedPortfolioIndex = -1;
  int? editingPortfolioIndex;

  final TextEditingController portfolioNameController = TextEditingController();
  final TextEditingController portfolioLinkController = TextEditingController();

  List<Map<String, dynamic>> savedPortfolioLinks = [];


  int selectedSocialIndex = -1;
  int? editingIndex;

  List<String> selectedTags = [];

  String? fileType; // image / video

  File? featuredFile;
  bool isVideo = false;

  bool isLoggingIn =false;


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
  List<File> tempFeaturedImages = [];

  bool isPicking = false;
  List<File> certificateFiles = [];

  final List<String> Portfoliolname  = [
    "Vimeo",
    "YouTube",
    "Google Drive",
  ];

  final List<String> Portfolioicons = [
    "assets/icons/vimeo-icon 1.png",
    "assets/icons/YouTube.png",
    "assets/icons/Google_Drive.png",
  ];



  final List<String> socialNames = [
    "Facebook",
    "Instagram",
    "TikTok",
    "Behance",
    "Website",
  ];


  final List<String> socialIcons = [
    "assets/icons/facbook_iIcon.png",
    "assets/icons/ins_icon.png",
    "assets/icons/ticktok.png",
    "assets/icons/behance.png",
    "assets/icons/webside.png",
  ];

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
      final Map<String, dynamic> payload = {
        "crew_member_id": widget.crewMemberId.toString(),

        /// 🔹 JSON FIELDS (STRINGIFIED)
        "certifications": jsonEncode(
          certificateFiles.map((e) => e.path.split('/').last).toList(),
        ),

        "social_media_links": jsonEncode(
          savedLinks.map((e) => {
            "platform": e['name'].toString().toLowerCase(),
            "url": normalizeUrl(e['url']),
          }).toList(),
        ),

        "featured_work": jsonEncode(
          featuredImages.map((e) => {
            "work_title": enter_work_titleController.text.trim(),
            "tags": selectedTags,
          }).toList(),
        ),
      };

      /// 🔹 FILE MAP
      final Map<String, List<File>> files = {
        "certifications": certificateFiles,
        "recent_work_media": featuredImages,
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

      final response = await ApiService().postMultipartStep3(
        ApiService().baseUrl + ApiEndpoints.register_step3, // ✅ FULL URL
        fields: payload.map((k, v) => MapEntry(k, v.toString())),

        resume: documentFile,
        portfolio: portfolioFile,

        certificates: certificateFiles,
        recentWorks: featuredImages,
        recentWorkIndexes: List.generate(
          featuredImages.length,
              (i) => i,
        ),
      );


      debugPrint("📥 STEP-3 RESPONSE => $response");

      if (response != null && response['error'] == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  Login()),
        );
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
  Map<String, List<String>> _buildRecentWorkIndexes() {
    final Map<String, List<String>> map = {};

    for (int i = 0; i < featuredImages.length; i++) {
      map.putIfAbsent("recent_work_media_index", () => []);
      map["recent_work_media_index"]!.add(i.toString());
    }
    return map;
  }



  Future<void> _pickPortfolio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        portfolioFile = File(result.files.single.path!);
      });
    }
  }


  bool isImageFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }



  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void viewFile(File file) {

    final ext = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      // 🔥 IMAGE VIEWER
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.black),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(file),
              ),
            ),
          ),
        ),
      );
    } else {
      // 🔥 PDF / DOC / ANY FILE
      OpenFile.open(file.path);
    }
  }
  int _calculateStep3Progress() {
    int totalFields = 5;
    int filled = 0;

    if (savedLinks.isNotEmpty) filled++;
    if (featuredImages.isNotEmpty) filled++;
    if (certificateFiles.isNotEmpty) filled++;
    if (documentFile != null) filled++;
    if (portfolioFile != null) filled++;

    double step3Percent = (filled / totalFields) * 30;

    return widget.step2Progress + step3Percent.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
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
                                  "assets/images/Rectangle_574057023.png",
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
                                        Navigator.pop(context);
                                      },
                                      child: Image.asset(
                                        "assets/icons/Reply.png",
                                        height: 24,
                                        color: Colors.white,
                                      ),
                                    ),

                                    /// 📄 STEP COUNT
                                    const Text(
                                      "3/3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w500,
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
                                  children:  [

                                    Text(
                                      "Social Engagement",
                                      style: TextStyle(
                                        fontFamily: "Unbounded",
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ColorCode.white,
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      "Complete your profile and connect with \ntop studios and filmmakers.",

                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Outfit",
                                        fontSize: 14,
                                        color: ColorCode.kWhiteOpacity70,
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
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: index <= 2
                                                ? ColorCode.kButtonColor
                                                : ColorCode.kSubtextColor,
                                            borderRadius: BorderRadius.circular(20),
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
                                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: ColorCode.bcakgroundcolor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.06),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    if (savedLinks.isNotEmpty)
                      Column(
                        children: savedLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                /// ICON
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: ColorCode.kButtonColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    item['icon'],
                                    color: ColorCode.kButtonColor,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// NAME
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                /// ✏️ EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      editingIndex = index;
                                      selectedSocialIndex =
                                          socialNames.indexOf(item['name']);
                                      nameLinkController.text = item['name'];
                                      linkController.text = item['url'];
                                    });

                                    _openSocialSheet();
                                  },
                                ),

                                /// 🗑 DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                                        children: savedPortfolioLinks.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final item = entry.value;

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.white24),
                                              color: Colors.black26,
                                            ),
                                            child: Row(
                                              children: [

                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    color: ColorCode.kButtonColor.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Image.asset(
                                                    item['icon'],
                                                    color: ColorCode.kButtonColor,
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                Expanded(
                                                  child: Text(
                                                    item['name'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),

                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Colors.white),
                                                  onPressed: () {
                                                    setState(() {
                                                      editingPortfolioIndex = index;
                                                      selectedPortfolioIndex =
                                                          Portfoliolname.indexOf(item['name']);
                                                      portfolioNameController.text = item['name'];
                                                      portfolioLinkController.text = item['url'];
                                                    });

                                                    _openPortfoliole();
                                                  },
                                                ),

                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                  onPressed: () {
                                                    setState(() {
                                                      savedPortfolioLinks.removeAt(index);
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
                                      constraints: const BoxConstraints(
                                        minHeight: 220,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: ColorCode.bcakgroundcolor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          /// 🔹 HEADER
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Featured Work",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              InkWell(
                                                onTap: _featuredSheet,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 28,
                                                      width: 28,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFF4E1C1),
                                                      ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        size: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      "Add another",
                                                      style: TextStyle(
                                                        color: ColorCode.kWhiteOpacity70,
                                                        fontSize: 13,
                                                        fontFamily: "Outfit",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 14),

                                          /// 🔹 EMPTY STATE
                                          if (featuredImages.isEmpty)
                                            GestureDetector(
                                              onTap: _featuredSheet,
                                              child: Container(
                                                height: 150,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white38),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Add",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          /// 🔹 IMAGE LIST
                                          if (featuredImages.isNotEmpty)
                                            SizedBox(
                                              height: 150,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: featuredImages.length,
                                                itemBuilder: (context, index) {
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        width: 140,
                                                        margin: const EdgeInsets.only(right: 10),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(12),
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
                                                              featuredImages.removeAt(index);
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 24,
                                                            width: 24,
                                                            decoration: const BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.black54,
                                                            ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              size: 14,
                                                              color: Colors.white,
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorCode.bcakgroundcolor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// 🔹 HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Upload Certifications",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              if (certificateFiles.isNotEmpty)
                                InkWell(
                                  onTap: _pickCertificate,
                                  child: Row(
                                    children: const [
                                      Icon(Icons.add, size: 18, color: Color(0xFFF4E1C1)),
                                      SizedBox(width: 4),
                                      Text(
                                        "Add another",
                                        style: TextStyle(
                                          color: Color(0xFFF4E1C1),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Upload",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                          /// 🔹 FILE LIST
                          if (certificateFiles.isNotEmpty)
                            Column(
                              children: List.generate(certificateFiles.length, (index) {
                                final file = certificateFiles[index];
                                final fileName = file.path.split('/').last;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    children: [

                                      /// FILE ICON
                                      const Icon(Icons.link, color: Colors.white),

                                      const SizedBox(width: 10),

                                      /// FILE NAME
                                      Expanded(
                                        child: Text(
                                          fileName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),

                                      /// VIEW
                                      IconButton(
                                        icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                                        onPressed: () => viewFile(file),
                                      ),


                                      /// DELETE
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            certificateFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ),




                    SizedBox(height: 16),


                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorCode.bcakgroundcolor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// TITLE
                              const Text(
                                "Upload Documents",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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


                       *//* Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Mainscreen(), // change screen name
                          ),
                        );*//*
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
                          backgroundColor: ColorCode.kButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Create Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            color: ColorCode.kHeadingColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// LOGIN TEXT
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                            color: ColorCode.kWhiteOpacity70,
                          ),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: ColorCode.kButtonColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: ColorCode.k282828,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 28,
                                          width: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color: ColorCode.kWhiteOpacity70,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Tell Us About Yourself & Add Details",
                                          style: TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: ColorCode.kWhiteOpacity70,
                                            letterSpacing: 0.2,
                                          ),
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
                        )]
                  )
              ),
              if (isLoggingIn)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          "assets/lottie/Untitled_file.json",
                          height: 120,
                          repeat: true,
                        ),
                        const SizedBox(height: 16),

                      ],
                    ),
                  ),
                ),
            ]
        )
    );
  }

  /// 🔹 COMMON TILE
  Widget _buildAddTile({
    required String title,
    required VoidCallback onTap,
  }) {
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
              color: Colors.white,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 16,
            ),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Text(
            title,
            style: const TextStyle(
              color: ColorCode.kWhiteOpacity70,
              fontSize: 15,
              fontFamily: "Outfit",
            ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white24,
            style: BorderStyle.solid, // dashed jaisa look
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    )

    /// 🔥 FILE PREVIEW MODE
        : Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [

          /// FILE ICON
          const Icon(Icons.insert_drive_file,
              color: Colors.white, size: 22),

          const SizedBox(width: 10),

          /// FILE NAME
          Expanded(
            child: Text(
              file.path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          /// VIEW
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.white),
            onPressed: () => viewFile(file),
          ),


          /// DELETE
          IconButton(
            icon: const Icon(Icons.delete,
                color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }



  /// 🔽 SOCIAL LINKS SHEET
  void _openSocialSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(

                child:
                Column(
                  children: [


                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: ColorCode.bcakgroundcolor,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              height: 5,
                              width: 40,
                              margin:  EdgeInsets.only(bottom: 12),
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
                               Text(
                                "Add Social Links",
                                style: TextStyle(color: Colors.white, fontSize: 16,fontFamily: "Unbounded",fontWeight: FontWeight.w500,)
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: Colors.white),
                              )
                            ],
                          ),

                          Text(
                              "Add links that showcase your work, recognition,\npersonality and more!",
                              style: TextStyle(color: ColorCode.kWhiteOpacity70, fontSize: 14,fontFamily: "Outfit",fontWeight: FontWeight.w400,)
                          ),
                           SizedBox(height: 20),

                          Divider(color: ColorCode.kDividerWhite12,

                          ),
                          SizedBox(height: 20),
                          /// ✅ SOCIAL ICONS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _socialImage(index: 0, imagePath: socialIcons[0], setModalState: setModalState),
                              _socialImage(index: 1, imagePath: socialIcons[1], setModalState: setModalState),
                              _socialImage(index: 2, imagePath: socialIcons[2], setModalState: setModalState),
                              _socialImage(index: 3, imagePath: socialIcons[3], setModalState: setModalState),
                              _socialImage(index: 4, imagePath: socialIcons[4], setModalState: setModalState),
                            ],
                          ),

                          const SizedBox(height: 20),

                          CustomTextField(
                            label: "Name of the Link*",
                            controller: nameLinkController,
                          ),

                          const SizedBox(height: 20),

                          CustomTextField(
                            label: "Link URL*",
                            controller: linkController,
                            keyboardType: TextInputType.url,
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
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
                                  _showSnack("Please select platform and enter link");
                                  return;
                                }

                                final platformName = socialNames[selectedSocialIndex];
                                final iconPath = socialIcons[selectedSocialIndex];
                                final url = linkController.text.trim();

                                setState(() {
                                  if (editingIndex != null) {
                                    // ✏️ UPDATE
                                    savedLinks[editingIndex!] = {
                                      "name": platformName,
                                      "url": url,
                                      "icon": iconPath,
                                    };
                                  } else {
                                    // ➕ ADD
                                    savedLinks.add({
                                      "name": platformName,
                                      "url": url,
                                      "icon": iconPath,
                                    });
                                  }
                                });

                                // RESET
                                editingIndex = null;
                                selectedSocialIndex = -1;
                                nameLinkController.clear();
                                linkController.clear();

                                Navigator.pop(context);
                              },

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



  void _openPortfoliole() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Drag Indicator
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

                  /// Header
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
                      )
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ICONS ROW
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
                            child: Image.asset(
                              Portfolioicons[index],
                              height: 22,
                              color: selectedPortfolioIndex == index
                                  ? ColorCode.kButtonColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SINGLE INPUT FIELD (LIKE IMAGE)
                  // TextField(
                  //   controller: portfolioLinkController,
                  //   style: const TextStyle(color: Colors.white),
                  //   decoration: InputDecoration(
                  //     hintText: "Name of the Link",
                  //     hintStyle: const TextStyle(color: Colors.white54),
                  //     contentPadding: const EdgeInsets.symmetric(
                  //       horizontal: 20,
                  //       vertical: 16,
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //       borderSide: const BorderSide(color: Colors.white24),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //       borderSide:
                  //       BorderSide(color: ColorCode.kButtonColor),
                  //     ),
                  //   ),
                  // ),
                  CustomTextField(label:"Name of the Link", controller:portfolioLinkController),

                  const SizedBox(height: 24),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEAD3A1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (selectedPortfolioIndex == -1 ||
                            portfolioLinkController.text.trim().isEmpty) {
                          _showSnack("Select platform & enter link");
                          return;
                        }

                        setState(() {
                          savedPortfolioLinks.add({
                            "name": Portfoliolname[selectedPortfolioIndex],
                            "url": portfolioLinkController.text.trim(),
                            "icon": Portfolioicons[selectedPortfolioIndex],
                          });
                        });

                        selectedPortfolioIndex = -1;
                        portfolioLinkController.clear();
                        Navigator.pop(context);
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

                  const SizedBox(height: 10),
                ],
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
      borderRadius: BorderRadius.circular(16),
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
              ? ColorCode.kButtonColor.withOpacity(0.2)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorCode.kButtonColor
                : Colors.white24,
            width: isSelected ? 1.5 : 0.8,
          ),

          /// optional glow
          boxShadow: isSelected
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
          child: Image.asset(
            imagePath,
            height: 22,
            width: 22,
            color: isSelected
                ? ColorCode.kButtonColor
                : Colors.white,
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
              ? ColorCode.kButtonColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorCode.kButtonColor
                : Colors.white24,
          ),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 22,
            width: 22,
            color: isSelected
                ? ColorCode.kButtonColor
                : Colors.white,
          ),
        ),
      ),
    );
  }
  void _featuredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration:  BoxDecoration(
                color: ColorCode.bcakgroundcolor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        margin:  EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    /// 🟢 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Featured Work",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Unbounded ",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:  Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),

                     Text(
                      "For best results, use a PNG, JPG, Video or\nGIF image etc.",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Outfit"

                      ),
                    ),

                     SizedBox(height: 16),
                     Divider(color: ColorCode.kDividerWhite12),
                     SizedBox(height: 20),

                    /// ✏️ WORK TITLE
                    CustomTextField(
                      label: "Enter Work Title*",
                      controller: enter_work_titleController,
                    ),
                    SizedBox(height: 16),

                /*    GestureDetector(
                      onTap: () => _pickFeaturedMedia(setModalState),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: featuredFile == null
                            ? Column(
                          children: const [
                            Icon(Icons.upload, color: Colors.white, size: 28),
                            SizedBox(height: 10),
                            Text(
                              "Upload new image, video, or browse",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Choose a file in a 4:3, 5:4, 9:16, or 16:9\n"
                                  "aspect ratio. Max 10MB (images)\n500MB (videos).",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorCode.kWhiteOpacity70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            if (!isVideo)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9, // 🔥 change if needed
                                  child: Image.file(
                                    featuredFile!,
                                    width: double.infinity,
                                    fit: BoxFit.cover, // full container fill
                                  ),
                                ),
                              ),

                            if (isVideo)
                              Container(
                                height: 180,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),

                             SizedBox(height: 10),

                            const Text(
                              "Tap to change media",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),*/

                GestureDetector(
                  onTap: () => pickFeaturedImages(setModalState),
                  child: Container(
                    height: 190, // 🔥 fixed clean height
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: tempFeaturedImages.isEmpty

                    /// 🔹 EMPTY STATE
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.upload,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Upload new image, video, or browse",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),

                        Text(
                          "Choose 4:3, 5:4, 9:16, or 16:9.\nMax 10MB images, 500MB videos.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    )

                    /// 🔹 PREVIEW MODE
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tempFeaturedImages.length,
                      itemBuilder: (_, index) {
                        return Stack(
                          children: [

                            /// IMAGE
                            Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  tempFeaturedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            /// 🔥 CANCEL ICON (TOP RIGHT)
                            Positioned(
                              top: 6,
                              right: 16,
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    tempFeaturedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
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





                SizedBox(height: 16),

                    /// 🏷️ ADD TAGS
                    /// 🏷️ TAG SECTION
                GestureDetector(
                  onTap: _openAddTagSheet,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: selectedTags.isEmpty
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius:
                        BorderRadius.circular(20),
                        border:
                        Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: const [
                          Icon(Icons.local_offer_outlined,
                              size: 16,
                              color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "# Add Tags",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )
                        : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                      selectedTags.map((tag) {
                        return Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                            BorderRadius.circular(
                                20),
                            border: Border.all(
                                color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style:
                                const TextStyle(
                                    color:
                                    Colors.white,
                                    fontSize: 12),
                              ),
                              const SizedBox(
                                  width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTags
                                        .remove(tag);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color:
                                  Colors.white70,
                                ),
                              ),
                            ],

                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),


                    SizedBox(height: 24),

                    /// 💾 SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorCode.kButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            featuredImages.addAll(tempFeaturedImages);
                          });

                          tempFeaturedImages.clear();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
  void _openAddTagSheet() {
    TextEditingController tagController = TextEditingController();
    List<String> tempTags = List.from(selectedTags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
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
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    /// Header
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Tag",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              color: Colors.white),
                        )
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Help people find your work",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Input
                    TextField(
                      controller: tagController,
                      style:
                      const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type tag and press enter",
                        hintStyle:
                        TextStyle(color: Colors.white54),
                        contentPadding:
                        EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(
                              Radius.circular(12)),
                          borderSide: BorderSide(
                              color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(
                              Radius.circular(12)),
                          borderSide:
                          BorderSide(color: Colors.white),
                        ),
                      ),
                      onSubmitted: (value) {
                        final tag = value.trim();
                        if (tag.isNotEmpty &&
                            !tempTags.contains(tag)) {
                          setModalState(() {
                            tempTags.add(tag);
                            tagController.clear();
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    /// Live Chips Preview
                    if (tempTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempTags.map((tag) {
                          return Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                    color: Colors.white70,
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
                          backgroundColor:
                          const Color(0xFFEAD3A1),
                          foregroundColor: Colors.black,
                          padding:
                          const EdgeInsets.symmetric(
                              vertical: 14),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedTags = tempTags;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontWeight:
                              FontWeight.w600),
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
    final lastName  = widget.lastName?.trim() ?? "";
    final email     = widget.email?.trim() ?? "";
    final image     = widget.profileImage;

    if (firstName.isEmpty &&
        lastName.isEmpty &&
        email.isEmpty &&
        image == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// 🔵 PROFILE IMAGE
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: image != null ? FileImage(image) : null,
            child: image == null
                ? const Icon(Icons.person, size: 28, color: Colors.grey)
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
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                /// EMAIL
                Text(
                  email.isEmpty ? "Your Email" : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 12,
                    color: Colors.black54,
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
                              backgroundColor: Colors.transparent,
                              builder: (_) => ProfileDetailsScreen(
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
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ColorCode.kButtonColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// COMPLETION PERCENT
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child:  Text(
                        "${_calculateStep3Progress()}%Completed",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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

