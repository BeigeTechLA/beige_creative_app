import 'package:flutter/material.dart';

import '../../utility/ColorCode.dart';

class Resume extends StatefulWidget {
  const Resume({super.key});

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {

  List<Map<String, String>> Resume = [
    {
      "title": "Certified Photographer.pdf",
      "date": "03 Dec 2024",
      "type": "PDF File",
      "count": "1 Page",
      "size": "1MB"
    },
    {
      "title": "Photography Excellence Award",
      "date": "03 Dec 2024",
      "type": "Docx File",
      "count": "2 Pages",
      "size": "1MB"
    },
    {
      "title": "Skill Development Certificate",
      "date": "03 Dec 2024",
      "type": "PDF File",
      "count": "3 Pages",
      "size": "1MB"
    },
    {
      "title": "Certified Visual Creator",
      "date": "03 Dec 2024",
      "type": "Image File",
      "count": "1 Images",
      "size": "1MB"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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

              Row(
                children: [
                  Text("Resume",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "Unbounded",fontSize: 16),)
                ],
              ),
              SizedBox(height: 20,),
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
              Expanded(
                child: ListView.builder(
                  itemCount: Resume.length,
                  itemBuilder: (context, index) {
                    final cert = Resume[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [

                          /// FILE IMAGE
                          Container(
                            height: 55,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.description,
                                color: Colors.black54),
                          ),

                          const SizedBox(width: 10),

                          /// DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert["title"]!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "${cert["date"]} • ${cert["type"]}",
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  cert["count"]!,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),

                          /// SIZE + MENU
                          Column(
                            children: [
                              const Icon(Icons.more_vert,
                                  color: Colors.white54),

                              const SizedBox(height: 15),

                              Text(
                                cert["size"]!,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
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
                    openUploadDialog();

                  },

                  child: const Text(
                    "Add Resume",
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
  void openUploadDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1F1F1F),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// TITLE + CLOSE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Upload your File",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Unbounded",
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// CAMERA
              uploadOption(
                icon: Icons.camera_alt_outlined,
                title: "Scan from Camera",
              ),

              const Divider(color: Colors.white12),

              /// GALLERY
              uploadOption(
                icon: Icons.photo_library_outlined,
                title: "Import from Gallery",
              ),

              const Divider(color: Colors.white12),

              /// FILES
              uploadOption(
                icon: Icons.insert_drive_file_outlined,
                title: "Import from Files",
              ),
            ],
          ),
        );
      },
    );
  }
  Widget uploadOption({required IconData icon, required String title}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
