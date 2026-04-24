import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../Model_Class/myprofilemodel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/custom_text_field.dart';

class FeaturedWorkList extends StatefulWidget {
  const FeaturedWorkList({super.key});

  @override
  State<FeaturedWorkList> createState() => _FeaturedWorkListState();
}

class _FeaturedWorkListState extends State<FeaturedWorkList> {
  List<File> tempFeaturedImages = [];
  List<String> selectedTags = [];
  List<File> featuredImages = [];

bool isloading =true;
  final enter_work_titleController=TextEditingController();
  List<Map<String, dynamic>> featuredWorks = [];
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  List<Map<String, String>> socialLinks = [];
  List<File> selectedImages = [];
  List<String> tags = [];



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

      final rawResponse =
      await ApiService().postData(ApiEndpoints.profiledetails, {});

      debugPrint("📦 RAW API RESPONSE: $rawResponse");

      final response = Myprofilemodel.fromJson(rawResponse);

      debugPrint("✅ PARSED RESPONSE: ${response.data}");

      if (response.error == false) {

        /// ✅ SOCIAL LINKS

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


  List<Map<String, String>> works = [
    {
      "image": "assets/home/img.png",
      "title": "New Year Concert 2025",
      "tag": "Live Events"
    }
  ];
  Future<void> pickFeaturedImages(Function setModalState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      compressionQuality: 0,  // ✅ THIS stops the crash — disables compression
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
  TextEditingController tagController = TextEditingController();
  TextEditingController EnterWorkTitleController = TextEditingController();
// ✅ FIXED: Accept setModalState so modal UI updates properly
  Future<void> pickImage(StateSetter setModalState) async {
    final List<XFile>? images = await picker.pickMultiImage(
      imageQuality: 80,
    );

    if (images != null) {
      setModalState(() {
        selectedImages = images.map((e) => File(e.path)).toList();
      });
      setState(() {}); // sync parent state too if needed
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
          Row(
            children: [
              InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset("assets/icons/back.png", height: 24,color: ColorCode.white,),
              ),
            ],
          ),
              SizedBox(height: 10,),
              Row(
                children: [
                 Text("Featured work",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "Unbounded",fontSize: 16),)
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [

                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// FILTER BUTTON
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  )
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: Myprofile_user?.featuredWorkFiles.length ?? 0,

                    itemBuilder: (context, index) {
                      final featuredWorkdata = Myprofile_user!.featuredWorkFiles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [

                              /// ✅ IMAGE OR PLACEHOLDER
                              Positioned.fill(
                                child: (featuredWorkdata.filePath.isNotEmpty)
                                    ? Image.network(
                                  "${ApiService.imageURL}${featuredWorkdata.filePath}",
                                  fit: BoxFit.cover,

                                  /// 🔥 ERROR → SVG
                             /*     errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: SvgPicture.asset(
                                        AppImages.image_holder,
                                      ),
                                    );
                                  },*/
                                )
                                    : Center(
                                  child: SvgPicture.asset(
                                    AppImages.image_holder,
                                  ),
                                ),
                              ),

                              Stack(
                                children: [

                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Row(
                                      children: [

                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: const BoxDecoration(
                                            color: ColorCode.grey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image(
                                            image: AssetImage("assets/icons/edit.png"),
                                            color: ColorCode.white,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: const BoxDecoration(
                                            color: ColorCode.grey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image(
                                            image: AssetImage("assets/icons/delete.png"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 15,
                                    left: 15,
                                    right: 15,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          featuredWorkdata.fileType,
                                          style: const TextStyle(
                                            fontFamily: "Outfit",
                                            color: ColorCode.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: ColorCode.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            featuredWorkdata.tag.isNotEmpty
                                                ? featuredWorkdata.tag
                                                : "No Tag",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: "Outfit",
                                              color: ColorCode.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                  },),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {
                    _featuredSheet();

                  },

                  child: const Text(
                    "Add Featured Works",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                      color: ColorCode.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void openFeaturedWork() {

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

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ColorCode.bcakgroundcolor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// DRAG HANDLE
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
                            "Featured Work",
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
                        "Upload images of your best work (png, jpg, jpeg,\nwebp - Max5).",
                        style: TextStyle(
                          color: ColorCode.kWhiteOpacity70,
                          fontSize: 14,
                          fontFamily: "Outfit",
                        ),
                      ),

                      const SizedBox(height: 20),

                      Divider(color: ColorCode.kDividerWhite12),
                      const SizedBox(height: 20),

                      /// NAME FIELD
                      CustomTextField(
                        label: "Name of the Link",
                        controller: EnterWorkTitleController,
                      ),

                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          pickImage(setModalState);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),

                          child: selectedImages.isEmpty
                              ? Column(
                            children: const [

                              Icon(Icons.upload, color: Colors.white, size: 30),

                              SizedBox(height: 10),

                              Text(
                                "Upload New Image, Video, Or Browse",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Outfit",
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "Choose a file in a 4:3, 5:4, 9:16, or 16:9\naspect ratio.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 13,
                                  fontFamily: "Outfit",
                                ),
                              ),
                            ],
                          )

                          /// IMAGES GRID
                              : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: selectedImages.map((image) {
                              return Stack(
                                children: [

                                  Container(
                                    height: 198,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  /// REMOVE BUTTON
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImages.remove(image);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close,
                                            color: Colors.white, size: 12),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// ADD ANOTHER LINK
                      Row(
                        children: [

                          /// TAG LIST
                          if (tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: tags.map((tag) {

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ColorCode.k282828,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      Text(
                                        tag,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(width: 6),

                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            tags.remove(tag);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                );

                              }).toList(),
                            ),

                          const SizedBox(width: 8),

                          /// EDIT TAG BUTTON
                          GestureDetector(
                            onTap: () {
                              _featuredSheet();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white24),
                                color: Colors.transparent,
                              ),
                              child: const Row(
                                children: [

                                  Icon(Icons.local_offer, size: 14, color: Colors.white),

                                  SizedBox(width: 6),

                                  Text(
                                    "# Add Tags",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 20),

                      /// SAVE BUTTON
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


                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 14,
                              color: ColorCode.kHeadingColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
  void openAddTagDialog() {

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
                color: ColorCode.bcakgroundcolor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HANDLE
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

                  /// TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Tag",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Help people find your work",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TEXTFIELD
                  TextField(
                    controller: tagController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type Tag and Press Enter",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setModalState(() {
                          tags.add(value);
                        });
                        tagController.clear();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  /// TAG LIST
                  Wrap(
                    spacing: 8,
                    children: tags.map((tag) {

                      return Chip(
                        label: Text(tag),
                        backgroundColor: Colors.black,
                        labelStyle: const TextStyle(color: Colors.white),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setModalState(() {
                            tags.remove(tag);
                          });
                        },
                      );

                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
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
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontFamily: "Unbounded",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10)
                ],
              ),
            );
          },
        );
      },
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
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(16),
                          color: Colors.white24,
                          strokeWidth: 1,
                          dashPattern: [4, 4],
                        ),
                        child: Container(
                          height: 190,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            //    color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: tempFeaturedImages.isEmpty
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload, color: Colors.white, size: 28),
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
                              : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tempFeaturedImages.length,
                            itemBuilder: (_, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 130,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        tempFeaturedImages[index],
                                        fit: BoxFit.cover,//
                                      ),
                                    ),
                                  ),
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
                    ),





                    SizedBox(height: 16),

                    /// 🏷️ ADD TAGS
                    /// 🏷️ TAG SECTION
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
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            setModalState(() { selectedTags.remove(tag); });
                                            setState(() { selectedTags.remove(tag); });
                                          },
                                          child: const Icon(Icons.close, size: 14, color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.local_offer_outlined, size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text("# Add Tags", style: TextStyle(color: Colors.white, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),  // ✅ close Expanded
                      ],
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
                        // Save button in _featuredSheet
                        // REPLACE WITH:
                        onPressed: () {
                          final imagesToAdd = List<File>.from(tempFeaturedImages); // ✅ copy first
                          setModalState(() {
                            tempFeaturedImages.clear();//
                          });
                          setState(() {
                            featuredImages.addAll(imagesToAdd); // ✅ use copy
                          });
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

  void _openAddTagSheet(StateSetter setFeaturedModalState) {
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type tag and press + or Enter",
                              hintStyle: TextStyle(color: Colors.white54),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.white),
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
                        //       color: const Color(0xFFEAD3A1),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     child: const Icon(Icons.add, color: Colors.black),
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
                          // ✅ Agar textfield mein kuch likha hai to pehle add karo
                          final currentText = tagController.text.trim();
                          if (currentText.isNotEmpty && !tempTags.contains(currentText)) {
                            tempTags.add(currentText);
                            tagController.clear();
                          }

                          final List<String> savedTags = List<String>.from(tempTags);
                          setFeaturedModalState(() {
                            selectedTags = savedTags;
                          });
                          setState(() {
                            selectedTags = savedTags;
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
}
