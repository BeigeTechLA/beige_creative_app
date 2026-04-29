import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Model_Class/Creatordashboarddetailsmodel.dart' hide Data;
import '../../Model_Class/myprofilemodel.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/commonFileViewer.dart';

class Certificates extends StatefulWidget {
  const Certificates({super.key});

  @override
  State<Certificates> createState() => _CertificatesState();
}

class _CertificatesState extends State<Certificates> {

  List<Map<String, String>> certificates = [
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
   bool isloading =true;
  // Data? Myprofile_user;


   Data? Myprofile_user;

  @override
  void initState() {
    super.initState();
    fetchcertificates();
  }
  Future<void> fetchcertificates() async {
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
                  Text("Certificates",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "Unbounded",fontSize: 16),)
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
                  itemCount: Myprofile_user?.certificateFiles.length ?? 0,

                  itemBuilder: (context, index) {

                    final cert = Myprofile_user!.certificateFiles[index];

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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 55,
                              width: 55,
                              child: Image.network(
                                "${ApiService.imageURL}${cert.filePath}",
                                fit: BoxFit.cover,

                                /// ✅ ERROR → SVG PLACEHOLDER
                                errorBuilder: (context, error, stackTrace) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/svg/image_holder.svg",
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },


                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          /// DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert.filePath.split('/').last,
                                  style: const TextStyle(
                                    fontFamily: "Outfit",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),

                                const SizedBox(height: 4),
/*
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
                                ),*/
                              ],
                            ),
                          ),

                          /// SIZE + MENU
                          Column(
                            children: [
                               GestureDetector(
                                onTap: () {
                                  _openOptions(cert);
                                },
                                child: const Icon(Icons.more_vert, color: Colors.white54),
                              ),

                              const SizedBox(height: 15),
/*
                              Text(
                                cert["size"]!,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11),
                              )*/
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
                    "Add New Certificate",
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
  void _openOptions(CrewFile cert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1F1F1F),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// VIEW DETAILS
              InkWell(
                onTap: () {
                  Navigator.pop(context);

                  CommonFileViewer.open(
                    context: context,
                    filePath: "${ApiService.imageURL}${cert.filePath}",
                    isNetwork: true,
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.visibility, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "View Details",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DELETE
              InkWell(
                onTap: () {
                  Navigator.pop(context);

                },
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      "Delete",
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
