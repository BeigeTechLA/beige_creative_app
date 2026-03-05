import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utility/ColorCode.dart';
import '../../widgets/custom_text_field.dart';

class FeaturedWorkList extends StatefulWidget {
  const FeaturedWorkList({super.key});

  @override
  State<FeaturedWorkList> createState() => _FeaturedWorkListState();
}

class _FeaturedWorkListState extends State<FeaturedWorkList> {
  List<Map<String, dynamic>> featuredWorks = [];
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  List<Map<String, String>> socialLinks = [];
  List<File> selectedImages = [];
  List<String> tags = [];

  List<Map<String, String>> works = [
    {
      "image": "assets/home/img.png",
      "title": "New Year Concert 2025",
      "tag": "Live Events"
    }
  ];
  TextEditingController tagController = TextEditingController();
  TextEditingController EnterWorkTitleController = TextEditingController();
  Future pickImage() async {

    final List<XFile>? images = await picker.pickMultiImage(
      imageQuality: 80,
    );

    if (images != null) {
      setState(() {
        selectedImages = images.map((e) => File(e.path)).toList();
      });
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
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final item = works[0];
                      return Container(

                       margin: const EdgeInsets.only(bottom: 16),
                       height: 250,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(18),
                         image: DecorationImage(
                           image: AssetImage(item["image"]!),
                           fit: BoxFit.cover,
                         ),
                       ),

                       child: Stack(
                         children: [

                           /// EDIT + DELETE
                           Positioned(
                             top: 10,
                             right: 10,
                             child: Row(
                               children: [

                                 Container(
                                     padding:  EdgeInsets.all(12),
                                   decoration: const BoxDecoration(
                                     color: ColorCode.grey,
                                     shape: BoxShape.circle,
                                   ),
                                   child:
                                   Image(image: AssetImage("assets/icons/edit.png",),color: ColorCode.white,)
                                 ),

                                 const SizedBox(width: 8),

                                 Container(
                                     padding:  EdgeInsets.all(12),
                                   decoration: const BoxDecoration(
                                     color: ColorCode.grey,
                                     shape: BoxShape.circle,
                                   ),
                                     child:
                                     Image(image: AssetImage("assets/icons/delete.png"))
                                 ),

                               ],
                             ),
                           ),

                           /// TITLE + TAG
                           Positioned(
                             bottom: 15,
                             left: 15,
                             right: 15,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [

                                 Text(
                                   item["title"]!,
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
                                     item["tag"]!,
                                     style:  TextStyle(
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
                    openFeaturedWork();
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
                          pickImage();
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
                              openAddTagDialog();
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
}
