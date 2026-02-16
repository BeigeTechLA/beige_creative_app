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

class SocialEngagementSingup extends StatefulWidget {
  final int ?crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  const SocialEngagementSingup({super.key, this.crewMemberId, this.profileImage, this.email, this.firstName, this.lastName});

  @override
  State<SocialEngagementSingup> createState() =>_SocialEngagementSingupState();
}

class _SocialEngagementSingupState extends State<SocialEngagementSingup> {

  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  final TextEditingController enter_work_titleController = TextEditingController();
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
      /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  LoginScreen()),
        );*/
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
                                padding: const EdgeInsets.fromLTRB(20, 36, 20, 20), // 👈 top extra
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

                          /// HEADER
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

                          /// EMPTY STATE
                          if (featuredImages.isEmpty)
                            GestureDetector(
                              onTap: _featuredSheet,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: const Center(
                                  child: Text("Add", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),

                          /// 🔥 ROW IMAGE LIST (AFTER SAVE)
                          if (featuredImages.isNotEmpty)
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        featuredImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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

                          _buildField("Name of the Link", nameLinkController),
                          SizedBox(height: 20),
                          _buildField("Link URL", linkController),

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


  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5,                       // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5,                          // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),)
      ,);
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          /// 🔵 PROFILE IMAGE
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
            image != null ? FileImage(image) : null,
            child: image == null
                ? const Icon(Icons.person,
                size: 26, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 14),

          /// 📝 NAME + EMAIL
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email.isEmpty
                      ? "Your Email"
                      : email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


//Featured Work
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
                    _buildField(
                      "Enter Work Title",
                      enter_work_titleController,
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white24,
                        style: BorderStyle.solid, // agar dashed chahiye to custom painter lagega
                      ),
                    ),
                    child: tempFeaturedImages.isEmpty
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.upload,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 12),

                        /// MAIN TEXT
                        Text(
                          "Upload new image, video, or browse",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 8),

                        /// HELPER TEXT (👇 YE TUM CHAHTE THE)
                        Text(
                          "Choose a file in a 4:3, 5:4, 9:16, or 16:9 aspect ratio.\n"
                              "Max 10MB (images), 500MB (videos).",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    )

                    /// 🔥 PREVIEW MODE (ROW)
                        : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tempFeaturedImages.length,
                        itemBuilder: (_, index) {
                          return Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                tempFeaturedImages[index],
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),





                SizedBox(height: 16),

                    /// 🏷️ ADD TAGS
                    /// 🏷️ TAG SECTION
                    GestureDetector(
                      onTap: _openAddTagSheet, // 👉 edit ke liye bhi same sheet
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: selectedTags.isEmpty
                            ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.local_offer_outlined,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                "# Add Tags",
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                            : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedTags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: Colors.black,
                              labelStyle: const TextStyle(color: Colors.white),
                              deleteIconColor: Colors.white,
                              onDeleted: () {
                                setState(() {
                                  selectedTags.remove(tag);
                                });
                              },
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔘 TOP DRAG INDICATOR
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

                    /// 🟢 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          icon: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),

                     SizedBox(height: 8),

                     Text(
                      "Help people find your work",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 13,
                      ),
                    ),

                     SizedBox(height: 16),
                     Divider(color: ColorCode.kDividerWhite12),
                     SizedBox(height: 20),

                    /// TextField
                    TextField(
                      controller: tagController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        // label: "Tag",
                        hintText: "Type Tag and Press Enter",
                        hintStyle: TextStyle
                          (
                          fontSize: 14,
                          fontFamily: "Outfit",
                            color: Colors.white54


                        ),
                        contentPadding:  EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(                          borderRadius: BorderRadius.all(Radius.circular(12)),

                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty &&
                            !tempTags.contains(value.trim())) {
                          setModalState(() {
                            tempTags.add(value.trim());
                            tagController.clear();
                          });
                        }
                      },

                    ),

                    const SizedBox(height: 12),

                    /// Tags Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.black,
                          labelStyle:
                          const TextStyle(color: Colors.white),
                          deleteIconColor: Colors.white,
                          onDeleted: () {
                            setModalState(() {
                              tempTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAD3A1),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedTags = tempTags;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ),
                    if (selectedTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedTags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.black,
                            labelStyle: const TextStyle(color: Colors.white),
                            deleteIconColor: Colors.white,
                            onDeleted: () {
                              setState(() {
                                selectedTags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
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


//       body: Stack(
//         children: [
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding:  EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         InkWell(
//                           onTap: () => Navigator.pop(context),
//                           child: Image.asset(
//                             "assets/Icons/Reply.png",
//                             height: 24,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const Text(
//                           ""
//                               "3/3",
//                           style: TextStyle(color: Colors.white),
//                         )
//                       ],
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     /// 🔵 PROGRESS BAR
//                     Row(
//                       children: List.generate(
//                         3,
//                             (index) => Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.only(right: 6),
//                             height: 5,
//                             decoration: BoxDecoration(
//                               color: index <= 1
//                                   ? ColorCode.kButtonColor
//                                   : ColorCode.kSubtextColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     /// 📝 TITLE
//                     const Text(
//                       "Social Engagement",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontFamily: "Unbounded",
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     /// SUBTITLE
//                     const Text(
//                       "Complete your profile and connect with top studios\nand filmmakers.",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: "Outfit",
//                         color: ColorCode.kWhiteOpacity70,
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     ///  ADD SOCIAL LINKS
//                     ///
//                     if (savedLinks.isNotEmpty)
//                       Column(
//                         children: savedLinks.asMap().entries.map((entry) {
//                           final index = entry.key;
//                           final item = entry.value;
//
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(color: Colors.white24),
//                               color: Colors.black26,
//                             ),
//                             child: Row(
//                               children: [
//                                 /// ICON
//                                 Container(
//                                   height: 40,
//                                   width: 40,
//                                   decoration: BoxDecoration(
//                                     color: ColorCode.kButtonColor.withOpacity(0.15),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Image.asset(
//                                     item['icon'],
//                                     color: ColorCode.kButtonColor,
//                                   ),
//                                 ),
//
//                                 const SizedBox(width: 12),
//
//                                 /// NAME
//                                 Expanded(
//                                   child: Text(
//                                     item['name'],
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//
//                                 /// ✏️ EDIT
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.white),
//                                   onPressed: () {
//                                     setState(() {
//                                       editingIndex = index;
//                                       selectedSocialIndex =
//                                           socialNames.indexOf(item['name']);
//                                       nameLinkController.text = item['name'];
//                                       linkController.text = item['url'];
//                                     });
//
//                                     _openSocialSheet();
//                                   },
//                                 ),
//
//                                 /// 🗑 DELETE
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.redAccent),
//                                   onPressed: () {
//                                     setState(() {
//                                       savedLinks.removeAt(index);
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//
//                     _buildAddTile(
//                       title: "Add Social Links",
//                       onTap: _openSocialSheet,
//                     ),
//                     const SizedBox(height: 20),
//
//
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: ColorCode.bcakgroundcolor,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.white24),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//                           /// HEADER
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 "Featured Work",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//
//                               InkWell(
//                                 onTap: _featuredSheet,
//                                 child: Row(
//                                   children: const [
//                                     Icon(Icons.add, size: 18, color: Color(0xFFF4E1C1)),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       "Add another",
//                                       style: TextStyle(
//                                         color: Color(0xFFF4E1C1),
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 12),
//
//                           /// EMPTY STATE
//                           if (featuredImages.isEmpty)
//                             GestureDetector(
//                               onTap: _featuredSheet,
//                               child: Container(
//                                 height: 120,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: Colors.white38),
//                                 ),
//                                 child: const Center(
//                                   child: Text("Add", style: TextStyle(color: Colors.white)),
//                                 ),
//                               ),
//                             ),
//
//                           /// 🔥 ROW IMAGE LIST (AFTER SAVE)
//                           if (featuredImages.isNotEmpty)
//                             SizedBox(
//                               height: 110,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: featuredImages.length,
//                                 itemBuilder: (context, index) {
//                                   return Container(
//                                     width: 140,
//                                     margin: const EdgeInsets.only(right: 10),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(12),
//                                       child: Image.file(
//                                         featuredImages[index],
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//
//
//
//
//
//                     SizedBox(height: 16),
//
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: ColorCode.bcakgroundcolor,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.white24),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//                           /// 🔹 HEADER
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 "Upload Certifications",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//
//                               if (certificateFiles.isNotEmpty)
//                                 InkWell(
//                                   onTap: _pickCertificate,
//                                   child: Row(
//                                     children: const [
//                                       Icon(Icons.add, size: 18, color: Color(0xFFF4E1C1)),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         "Add another",
//                                         style: TextStyle(
//                                           color: Color(0xFFF4E1C1),
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 12),
//
//                           /// 🔹 EMPTY STATE (UPLOAD BOX)
//                           if (certificateFiles.isEmpty)
//                             GestureDetector(
//                               onTap: _pickCertificate,
//                               child: Container(
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: Colors.white38),
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     "Upload",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                           /// 🔹 FILE LIST
//                           if (certificateFiles.isNotEmpty)
//                             Column(
//                               children: List.generate(certificateFiles.length, (index) {
//                                 final file = certificateFiles[index];
//                                 final fileName = file.path.split('/').last;
//
//                                 return Container(
//                                   margin: const EdgeInsets.only(bottom: 10),
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black26,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.white24),
//                                   ),
//                                   child: Row(
//                                     children: [
//
//                                       /// FILE ICON
//                                       const Icon(Icons.link, color: Colors.white),
//
//                                       const SizedBox(width: 10),
//
//                                       /// FILE NAME
//                                       Expanded(
//                                         child: Text(
//                                           fileName,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//
//                                       /// VIEW
//                                       IconButton(
//                                         icon: const Icon(Icons.remove_red_eye, color: Colors.white),
//                                         onPressed: () => viewFile(file),
//                                       ),
//
//
//                                       /// DELETE
//                                       IconButton(
//                                         icon: const Icon(Icons.delete, color: Colors.white),
//                                         onPressed: () {
//                                           setState(() {
//                                             certificateFiles.removeAt(index);
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }),
//                             ),
//                         ],
//                       ),
//                     ),
//
//
//
//
//                     SizedBox(height: 16),
//
//
//                     Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: ColorCode.bcakgroundcolor,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.white24),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//
//                               /// TITLE
//                               const Text(
//                                 "Upload Documents",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//
//                               const SizedBox(height: 12),
//
//                               /// RESUME
//                               _documentBlock(
//                                 label: "Upload Resume/CV",
//                                 file: documentFile,
//                                 onUpload: _pickDocument,
//                                 onDelete: () {
//                                   setState(() => documentFile = null);
//                                 },
//                               ),
//
//                               const SizedBox(height: 12),
//
//                               /// PORTFOLIO
//                               _documentBlock(
//                                 label: "Upload Portfolio",
//                                 file: portfolioFile,
//                                 onUpload: _pickPortfolio,
//                                 onDelete: () {
//                                   setState(() => portfolioFile = null);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 12),
//
//
//
//                     SizedBox(
//                       width: double.infinity,
//                       height: 55,
//                       child: ElevatedButton(
//                         /*      onPressed: () {
//
//
//                        *//* Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => Mainscreen(), // change screen name
//                           ),
//                         );*//*
//                       }
//                       ,*/
//                         onPressed: isLoggingIn
//                             ? null
//                             : () {
//                           debugPrint("🟢 CREATE PROFILE CLICKED");
//                           _fetchSingup3();
//                         },
//
//                         /*  onPressed:
//                       isLoggingIn
//                           ? null
//                           : () {
//                         debugPrint("🟢 NEXT BUTTON CLICKED");
//                         _fetchSingup3();
//                       },*/
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: ColorCode.kButtonColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         child: const Text(
//                           "Create Profile",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontFamily: "Unbounded",
//                             color: ColorCode.kHeadingColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     /// LOGIN TEXT
//                     Center(
//                       child: Text.rich(
//                         TextSpan(
//                           text: "Already have an account? ",
//                           style: const TextStyle(
//                             color: ColorCode.kWhiteOpacity70,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: "Login",
//                               style: TextStyle(
//                                 color: ColorCode.kButtonColor,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (isLoggingIn)
//             Positioned.fill(
//               child: AbsorbPointer(
//                 absorbing: true,
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.4),
//                     alignment: Alignment.center,
//                     child: Lottie.asset(
//                       "assets/lottie/Untitled_file.json",
//                       width: 140,
//                       height: 140,
//                       repeat: true,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//
//       ),

}

