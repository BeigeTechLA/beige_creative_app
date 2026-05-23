import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../model_class/myprofile_model.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../app/colors.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../widgets/commonFileViewer.dart' show CommonFileViewer;
import '../widgets/common_uploader.dart';

class Resume extends StatefulWidget {
  const Resume({super.key});

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
bool isloading =true;
File? selectedFile;

Data? Myprofile_user;
  @override
  void initState() {
    super.initState();
    fetchresumedata();
  }

Future<void> fetchresumedata() async {
  try {
    setState(() {
      isloading = true;
    });

    final rawResponse =
    await ApiService().postData(ApiEndpoints.profiledetails, {});

    /// ✅ RAW PRINT (direct API)
    print("RAW RESUME 👉 ${rawResponse['data']['resume_files']}");
    print("RAW COUNT 👉 ${rawResponse['data']['resume_files']?.length}");

    final response = Myprofilemodel.fromJson(rawResponse);

    if (response.error == false) {
      setState(() {
        Myprofile_user = response.data;
      });

      /// ✅ MODEL PRINT (correct way)
      print("MODEL COUNT 👉 ${response.data.resumeFiles.length}");

      for (var file in response.data.resumeFiles) {
        print("📄 ID 👉 ${file.crewFilesId}");
        print("📄 PATH 👉 ${file.filePath}");
        print("📄 TYPE 👉 ${file.fileType}");
      }
    } else {
      print("❌ API ERROR: ${response.message}");
    }
  } catch (e) {
    print("❌ ERROR 👉 $e");
  } finally {
    setState(() {
      isloading = false;
    });
  }
}
  Future<void> _addResume() async {
  if (selectedFile == null) {
    print("❌ No file selected");
    return;
  }

  setState(() => isloading = true);

  try {
    final response = await ApiService().postMultipartData(
      ApiEndpoints.upload_resume,
      {},
      selectedFile,
    );

    debugPrint("📥 RESPONSE => $response");

    if (response != null && response['error'] == false) {
      print("✅ Upload Success");

      fetchresumedata(); // 🔥 refresh list
    } else {
      print("❌ Upload Failed");
    }
  } catch (e) {
    print("🔥 ERROR => $e");
  } finally {
    setState(() => isloading = false);
  }
}
Future<void> deleteData(int id) async {
  final response = await ApiService().deleteData(
    "${ApiEndpoints.delete_allfiles}/$id",
  );

  if (response["error"] == false) {
    print("✅ Deleted Successfully");

    fetchresumedata(); // refresh list
  } else {
    print("❌ Delete Failed");
  }
}
  @override
  Widget build(BuildContext context) {
    final resumeList = Myprofile_user?.resumeFiles ?? [];

    return Scaffold(
      body:  SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(
                          AppAssets.back,
                          height: 24,color: AppColors.white,),
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
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: TextField(
                            style: const TextStyle(color: AppColors.white),
                            decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: const TextStyle(color: AppColors.white24),
                              prefixIcon: const Icon(Icons.search, color: AppColors.white24),
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
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: AppColors.white),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Myprofile_user?.resumeFiles.length ?? 0,
                      itemBuilder: (context, index) {
                        final cert = Myprofile_user!.resumeFiles[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceShadow,
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
                                  child: cert.filePath.endsWith(".pdf")
                                      ? const Icon(
                                    Icons.picture_as_pdf,
                                    color: AppColors.error,
                                    size: 30,
                                  )
                                      : Image.network(
                                    "${ApiService.imageURL}${cert.filePath}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(
                                          AppAssets.image_holder,
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
                                      cert.filePath.split('/').last, // file name

                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),

                                    const SizedBox(height: 4),

                                    /*  Text(
                                    "${cert["date"]} • ${cert["type"]}",
                                    style: const TextStyle(
                                        color: AppColors.white54,
                                        fontSize: 11),
                                  ),
          */
                                    const SizedBox(height: 6),
                                    /*
                                  Text(
                                    cert["count"]!,
                                    style: const TextStyle(
                                        color: AppColors.white54,
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
                                    child: const Icon(Icons.more_vert,
                                        color: AppColors.white),
                                  ),

                                  const SizedBox(height: 15),

                                  /* Text(
                                  cert["size"]!,
                                  style: const TextStyle(
                                      color: AppColors.white54,
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

                  if (resumeList.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          openUploadDialog();
                        },
                        child: const Text(
                          "Add resume",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
void openUploadDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceShadow,
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
                Center(
                  child:  Text(
                    "Upload your File",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Unbounded",
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.close, color: AppColors.white),
                )
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: AppColors.white24),
          /*  /// CAMERA
            uploadOption(
              svgPath: AppAssets.scanner,
              title: "Scan from Camera",
              onTap: () async {
                Navigator.pop(context);

                final file = await CommonUploader.pickFromCamera();

                if (file != null) {
                  setState(() {
                    selectedFile = file; // ✅ set first
                  });

                  print("Camera File: ${file.path}");

                  await _addcertificate(); // ✅ then call API
                }
              },
            ),
            const Divider(color: AppColors.dividerDark),
*/
            /// GALLERY

       /*     uploadOption(
              svgPath: AppAssets.gallery,
              title: "Import from Gallery",
              onTap: () async {
                Navigator.pop(context);

                final file = await CommonUploader.pickFromGallery();

                if (file != null) {
                  setState(() {
                    selectedFile = file;
                  });

                  print("Gallery File: ${file.path}");

                  await _addcertificate();
                }
              },
            ),
            const Divider(color: AppColors.dividerDark),*/
            /// FILES

            /// FILES
            uploadOption(
              svgPath: AppAssets.document,
              title: "Import from Files",
              onTap: () async {
                context.pop();

                final file = await CommonUploader.pickFile();

                if (file != null) {
                  setState(() {
                    selectedFile = file;
                  });

                  print("Picked File: ${file.path}");

                  await _addResume();
                }
              },
            ),
          ],
        ),
      );
    },
  );
}


Widget uploadOption({required String svgPath, required String title, required VoidCallback onTap,}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            svgPath,
            height: 22,
            width: 22,
            // optional
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.white,
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
    backgroundColor: AppColors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceShadow,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                Navigator.pop(context);

                final file = await CommonUploader.pickFile();

                if (file != null) {
                  setState(() {
                    selectedFile = file;
                  });

                  print("Picked File: ${file.path}");

                  await _addResume();
                }
              },
              child: Row(
                children: const [
                  Icon(Icons.refresh, color: AppColors.white),
                  SizedBox(width: 12),
                  Text(
                    "Replace",
                    style: TextStyle(color:AppColors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                print("🔥 VIEW CLICKED");

                context.pop();
                print("URL 👉 ${ApiService.imageURL}${cert.filePath}");

                CommonFileViewer.open(
                  context: context,
                  filePath: "${ApiService.imageURL}${cert.filePath}",
                  isNetwork: true,
                );
              },
              child: Row(
                children: const [
                  Icon(Icons.visibility, color: AppColors.white),
                  SizedBox(width: 12),
                  Text(
                    "View Details",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// DELETE
            InkWell(
              onTap: () {
                context.pop();

                 deleteData(cert.crewFilesId); // 👈 ID pass karo
              },
              child: Row(
                children: const [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 12),
                  Text(
                    "Delete",
                    style: TextStyle(color:AppColors.white, fontSize: 14),
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
