import 'dart:convert';
import 'dart:io';

import 'package:beige_creative_app/widgets/app_loder.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../Model_Class/myprofile_model.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/colorcode.dart';
import '../utility/imges_icons.dart';
import '../widgets/Topmessgae.dart';
import '../widgets/commonImagePicker.dart';
import '../widgets/common_uploader.dart';
import '../widgets/custom_text_field.dart';

class FeaturedWorkList extends StatefulWidget {
  const FeaturedWorkList({super.key});

  @override
  State<FeaturedWorkList> createState() => _FeaturedWorkListState();
}

class _FeaturedWorkListState extends State<FeaturedWorkList> {
  List<File> tempFeaturedImages = [];
  List<String> selectedTags = [];
  List<File> featuredImages = [];
  List<dynamic> editingImages = [];
  bool isEditMode = false;
  bool isloading =true;
  final enter_work_titleController=TextEditingController();
  List<Map<String, dynamic>> featuredWorks = [];
  File? selectedImage;


  List<Map<String, String>> socialLinks = [];
  List<File> selectedImages = [];
  List<String> tags = [];
  List<List<File>> featuredProjects = []; // 🔥 each project = list of images
  List<String> featuredProjectsTitles = [];
  int? editingProjectIndex;
  int selectedPortfolioIndex = -1;
  int? editingPortfolioIndex;

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

      // ✅ FULL RAW RESPONSE
      debugPrint("📦 RAW API RESPONSE: $rawResponse");
      debugPrint("📦 RAW TYPE: ${rawResponse.runtimeType}");

      final response = Myprofilemodel.fromJson(rawResponse);

      debugPrint("✅ PARSED ERROR FLAG: ${response.error}");
      debugPrint("✅ PARSED MESSAGE: ${response.message}");
      debugPrint("✅ PARSED DATA: ${response.data}");

      if (response.error == false) {

        setState(() {
          Myprofile_user = response.data;
        });

        // ✅ FEATURED WORK FILES COUNT + DATA
        debugPrint("🖼 FEATURED WORK COUNT: ${response.data?.featuredWorkFiles.length}");

        for (int i = 0; i < (response.data?.featuredWorkFiles.length ?? 0); i++) {
          final item = response.data!.featuredWorkFiles[i];
          debugPrint("🖼 ITEM[$i] => filePath: ${item.filePath} | fileType: ${item.fileType} | tag: ${item.tag}");
        }

      } else {
        debugPrint("❌ API ERROR: ${response.message}");
      }
    } catch (e, stack) {
      debugPrint("❌ EXCEPTION: $e");
      debugPrint("❌ STACK: $stack");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> _addrecentwork() async {
    print("🚀 API FUNCTION START");

    if (enter_work_titleController.text.trim().isEmpty) {
      _showSnack("Please enter title");
      return;
    }

    if (featuredImages.isEmpty) {
      _showSnack("Please select at least 1 image");
      return;
    }

    // ✅ PAYLOAD DEBUG
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📦 PAYLOAD:");
    print("   🔹 title   => ${enter_work_titleController.text.trim()}");
    print("   🔹 tag     => ${jsonEncode(selectedTags)}");
    print("   🔹 files[] => ${featuredImages.length} image(s) — but passing only 1 (featuredImages.first)");
    print("   🔹 file[0] => ${featuredImages.first.path.split('/').last}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    setState(() => isloading = true);

    try {
      final response = await ApiService().postMultipartDataMultiple(
        ApiEndpoints.upload_recent_work,
        {
          "title": enter_work_titleController.text.trim(),
          "tag": jsonEncode(selectedTags),
        },
        featuredImages,
      );

      debugPrint("📥 RESPONSE => $response");

      if (response != null && response['error'] == false) {
        print("✅ Upload Success");
        // _showSnack("Upload Success");

        featuredImages.clear();
        tempFeaturedImages.clear();
        selectedTags.clear();
        enter_work_titleController.clear();

        fetchprofiledata();
        context.pop();

      } else {
        print("❌ Upload Failed");
        _showSnack(response?['message'] ?? "Upload Failed");
      }

    } catch (e) {
      print("🔥 ERROR => $e");
      _showSnack("Something went wrong");
    } finally {
      setState(() => isloading = false);
    }
  }
  Future<void> deleteData(int id) async {
    try {
      setState(() {
        isloading = true;
      });

      print("🗑 DELETE ID => $id");

      final response = await ApiService().deleteData(
        "${ApiEndpoints.delete_allfiles}/$id",
      );

      print("📥 DELETE RESPONSE => $response");

      if (response != null && response["error"] == false) {

        // _showSnack(response["message"] ?? "Deleted Successfully");

        /// refresh api
        await fetchprofiledata();

      } else {

        _showSnack(response["message"] ?? "Delete Failed");
      }

    } catch (e) {

      print("❌ DELETE ERROR => $e");

      _showSnack("Something went wrong");

    } finally {

      setState(() {
        isloading = false;
      });
    }
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);
  }


  TextEditingController tagController = TextEditingController();
  TextEditingController EnterWorkTitleController = TextEditingController();
// ✅ FIXED: Accept setModalState so modal UI updates properly
  void pickImage(StateSetter setModalState) async {
    final images = await CommonImagePicker.pickMultiImage();

    if (images.isNotEmpty) {
      setModalState(() {
        selectedImages = images;
      });

      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child:
                        SvgPicture.asset(
                          AppImages.back,
                          // "assets/icons/back.png",
                          height: 24,
                          color: ColorCode.white,),
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
              /*    Row(
                    children: [

                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: TextField(
                            style: const TextStyle(color: ColorCode.white),
                            decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: const TextStyle(color: ColorCode.white54),
                              prefixIcon: const Icon(Icons.search, color: ColorCode.white54),
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
                        child: const Icon(Icons.tune, color: ColorCode.white),
                      )
                    ],
                  ),*/
                  SizedBox(height: 10,),
                  Expanded(
                    child: Builder(
                      builder: (context) {

                        if (Myprofile_user == null ||
                            Myprofile_user!.featuredWorkFiles.isEmpty) {

                          return const Center(
                            child: Text(
                              "No Featured Work",
                              style: TextStyle(
                                color: ColorCode.white24,
                              ),
                            ),
                          );
                        }

                        /// ✅ GROUP BY TITLE
                        Map<String, List<dynamic>> groupedData = {};

                        for (var item in Myprofile_user!.featuredWorkFiles) {

                          String title = item.title ?? "Untitled";

                          if (!groupedData.containsKey(title)) {
                            groupedData[title] = [];
                          }

                          groupedData[title]!.add(item);
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: groupedData.entries.map((entry) {

                              String title = entry.key;
                              List<dynamic> images = entry.value;

                              return Container(
                                // margin: const EdgeInsets.only(bottom: 25),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [


                                    /// ✅ HORIZONTAL IMAGE ROW
                                    Container(
                                      height: 250,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),

                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1F1F1F),
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Stack(
                                        children: [

                                          /// HORIZONTAL IMAGE SCROLL
                                          ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: images.length,

                                            itemBuilder: (context, index) {

                                              final imageData = images[index];

                                              return Container(
                                                width: 320,
                                                margin: const EdgeInsets.only(right: 12),

                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(18),

                                                  child: Image.network(
                                                    "${ApiService.imageURL}${imageData.filePath}",
                                                    fit: BoxFit.cover,

                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: ColorCode.lightGrey,
                                                        child: const Icon(Icons.image),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          /// TOP RIGHT ICONS
                                          Positioned(
                                            top: 10,
                                            right: 10,

                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {

                                                    setState(() {

                                                      isEditMode = true;

                                                      /// ✅ TITLE
                                                      enter_work_titleController.text =
                                                          title;

                                                      /// ✅ OLD NETWORK IMAGES
                                                      editingImages =
                                                          List.from(images);

                                                      /// ✅ CLEAR NEW IMAGES
                                                      tempFeaturedImages.clear();
                                                    });

                                                    _featuredSheet();
                                                  },

                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: ColorCode.black.withOpacity(0.5),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      color: ColorCode.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 8),

                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: ColorCode.black.withOpacity(0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      /// FIRST IMAGE ID
                                                      final imageData = images.first;

                                                      await deleteData(imageData.crewFilesId);

                                                    },
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: ColorCode.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          /// BOTTOM TITLE
                                          Positioned(
                                            left: 15,
                                            bottom: 15,

                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                    color: ColorCode.white,
                                                    fontSize: 18,
                                                    fontFamily: "Outfit",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                const SizedBox(height: 8),


                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                 /* SizedBox(
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
                  ),*/
                ],
              ),
            ),
          ),


          if(isloading)
            AppLoader()
        ],

      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),

        child: SizedBox(
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
      ),
    );
  }
/*  void openFeaturedWork() {

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorCode.transparent,
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
                  color: ColorCode.backgroundColor,
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
                            color: ColorCode.white24,
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
                              color: ColorCode.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: ColorCode.white),
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
                            border: Border.all(color: ColorCode.white24),
                          ),

                          child: selectedImages.isEmpty
                              ? Column(
                            children: const [

                              Icon(Icons.upload, color: ColorCode.white, size: 30),

                              SizedBox(height: 10),

                              Text(
                                "Upload New Image, Video, Or Browse",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorCode.white,
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
                                        backgroundColor: ColorCode.red,
                                        child: Icon(Icons.close,
                                            color: ColorCode.white, size: 12),
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
                                    border: Border.all(color: ColorCode.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      Text(
                                        tag,
                                        style: const TextStyle(
                                          color: ColorCode.white,
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
                                          color: ColorCode.white,
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
                                border: Border.all(color: ColorCode.white24),
                                color: ColorCode.transparent,
                              ),
                              child: const Row(
                                children: [

                                  Icon(Icons.local_offer, size: 14, color: ColorCode.white),

                                  SizedBox(width: 6),

                                  Text(
                                    "# Add Tags",
                                    style: TextStyle(
                                      color: ColorCode.white,
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
  }*/
 /* void openAddTagDialog() {

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorCode.transparent,
      isScrollControlled: true,
      builder: (_) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: ColorCode.backgroundColor,
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
                        color: ColorCode.white24,
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
                              color: ColorCode.white,
                              fontSize: 16,
                              fontFamily: "Unbounded",
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Help people find your work",
                            style: TextStyle(
                              color: ColorCode.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        icon: const Icon(Icons.close, color: ColorCode.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TEXTFIELD
                  TextField(
                    controller: tagController,
                    style: const TextStyle(color: ColorCode.white),
                    decoration: InputDecoration(
                      hintText: "Type Tag and Press Enter",
                      hintStyle: const TextStyle(color: ColorCode.white54),
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
                        backgroundColor: ColorCode.black,
                        labelStyle: const TextStyle(color: ColorCode.white),
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
                          color: ColorCode.black,
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
  }*/
  void _featuredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorCode.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            /// ✅ TOTAL IMAGE COUNT
            int totalImages =
                editingImages.length + tempFeaturedImages.length;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorCode.backgroundColor,
                borderRadius:
                const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    /// 🔘 TOP BAR
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin:
                        const EdgeInsets.only(
                            bottom: 12),
                        decoration: BoxDecoration(
                          color: ColorCode.white24,
                          borderRadius:
                          BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    /// 🟢 HEADER
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          "Featured Work",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        IconButton(
                          onPressed: () {

                            context.pop();
                          },

                          icon: const Icon(
                            Icons.close,
                            color: ColorCode.white,
                          ),
                        ),
                      ],
                    ),

                    const Text(
                      "For best results, use PNG, JPG or GIF.",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 14,
                        fontFamily: "Outfit",
                      ),
                    ),

                    const SizedBox(height: 16),

                    Divider(
                      color: ColorCode.kDividerWhite12,
                    ),

                    const SizedBox(height: 20),

                    /// ✏️ TITLE
                    CustomTextField(
                      label: "Enter Work Title*",
                      controller:
                      enter_work_titleController,
                    ),

                    const SizedBox(height: 16),

                    /// ✅ IMAGE SECTION
                    DottedBorder(
                      options:
                      RoundedRectDottedBorderOptions(
                        radius:
                        const Radius.circular(16),
                        color: ColorCode.white24,
                        strokeWidth: 1,
                        dashPattern: [4, 4],
                      ),

                      child: Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: totalImages == 0
                            ? GestureDetector(
                          onTap: () async {

                            final file =
                            await CommonUploader.pickFromGallery();

                            if (file != null) {

                              setModalState(() {

                                tempFeaturedImages.add(file);
                              });
                            }
                          },

                          child: SizedBox(
                            height: 220,
                            width: double.infinity,

                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [

                                SvgPicture.asset(
                                  AppImages.Upload, //  your svg path
                                  color: ColorCode.white,
                                  width: 24,
                                  height: 24,
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  "Upload New Image, Video,Or Browse",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    color: ColorCode.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  "Choose a file in a 4:3, 5:4, 9:16,\nor 16:9 aspect ratio.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    color: ColorCode.kWhiteOpacity70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                        /// ✅ GRID
                            : SizedBox(
                          height: 320,

                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),

                            /// ✅ UNLIMITED IMAGES
                            itemCount: totalImages + 1,

                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),

                            itemBuilder: (context, index) {

                              /// ➕ ADD BUTTON
                              if (index == totalImages) {

                                return GestureDetector(
                                  onTap: () async {

                                    final file =
                                    await CommonUploader
                                        .pickFromGallery();

                                    if (file != null) {

                                      setModalState(() {

                                        /// ✅ ADD IMAGE
                                        tempFeaturedImages.add(file);
                                      });
                                    }
                                  },

                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(12),

                                      border: Border.all(
                                        color: ColorCode.white24,
                                      ),
                                    ),

                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        color: ColorCode.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              /// ✅ NETWORK IMAGE
                              if (index < editingImages.length) {

                                final image =
                                editingImages[index];

                                return Stack(
                                  children: [

                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(12),

                                      child: Image.network(
                                        "${ApiService.imageURL}${image.filePath}",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),

                                    Positioned(
                                      top: 6,
                                      right: 6,

                                      child: GestureDetector(
                                        onTap: () {

                                          setModalState(() {

                                            editingImages.removeAt(index);
                                          });
                                        },

                                        child: Container(
                                          height: 24,
                                          width: 24,

                                          decoration: BoxDecoration(
                                            color: ColorCode.black.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),

                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: ColorCode.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              /// ✅ LOCAL IMAGE
                              final localIndex =
                                  index - editingImages.length;

                              return Stack(
                                children: [

                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(12),

                                    child: Image.file(
                                      tempFeaturedImages[localIndex],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),

                                  Positioned(
                                    top: 6,
                                    right: 6,

                                    child: GestureDetector(
                                      onTap: () {

                                        setModalState(() {

                                          tempFeaturedImages
                                              .removeAt(localIndex);
                                        });
                                      },

                                      child: Container(
                                        height: 24,
                                        width: 24,

                                        decoration: BoxDecoration(
                                          color: ColorCode.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),

                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: ColorCode.white,
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

                    const SizedBox(height: 24),

                    /// 💾 SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton(

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          totalImages >= 5
                              ? ColorCode
                              .kButtonColor
                              : ColorCode.grey,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                14),
                          ),
                        ),

                        onPressed: () async {

                          /// TITLE CHECK
                          if (enter_work_titleController.text
                              .trim()
                              .isEmpty) {

                            _showSnack("Please enter title");
                            return;
                          }

                          /// TOTAL IMAGES
                          List<File> allImages =
                          List.from(tempFeaturedImages);

                          int totalImages =
                              editingImages.length +
                                  tempFeaturedImages.length;

                          if (totalImages < 5) {

                            _showSnack(
                                "Minimum 5 images required");

                            return;
                          }

                          /// ✅ ONLY NEW IMAGES API
                          featuredImages = allImages;

                          /// ✅ API CALL
                          if (featuredImages.isNotEmpty) {
                            await _addrecentwork();
                          }

                          /// ✅ RESET
                          setState(() {

                            tempFeaturedImages.clear();

                            editingImages.clear();

                            isEditMode = false;

                            /// ❌ TITLE CLEAR REMOVE
                            // enter_work_titleController.clear();
                          });

                          context.pop();
                          /// ✅ REFRESH
                          fetchprofiledata();
                        },

                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: ColorCode.black,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }  void _openAddTagSheet(StateSetter setFeaturedModalState) {
    TextEditingController tagController = TextEditingController();
    List<String> tempTags = List.from(selectedTags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorCode.transparent,
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
                          color: ColorCode.white24,
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
                            color: ColorCode.white,
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close,
                              color: ColorCode.white),
                        )
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Help people find your work",
                      style: TextStyle(
                        color: ColorCode.white24,
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
                            style: const TextStyle(color: ColorCode.white),
                            decoration: const InputDecoration(
                              hintText: "Type tag and press + or Enter",
                              hintStyle: TextStyle(color: ColorCode.white24),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: ColorCode.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: ColorCode.white),
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
                        //     child: const Icon(Icons.add, color: ColorCode.black),
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
                              color: ColorCode.black,
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: ColorCode.white24),
                            ),
                            child: Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    color: ColorCode.white,
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
                                    color: ColorCode.white24,
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
                          foregroundColor: ColorCode.black,
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
                          context.pop();
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
