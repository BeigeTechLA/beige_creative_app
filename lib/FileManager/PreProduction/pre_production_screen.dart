import 'package:beige_creative_app/FileManager/PreProduction/pre_production_controller.dart';
import 'package:flutter/material.dart';

import '../../utility/ColorCode.dart';
import '../shoot_details_screen.dart';

class PreProductionScreen extends StatefulWidget {
  const PreProductionScreen({super.key});

  @override
  State<PreProductionScreen> createState() => _PreProductionScreenState();
}

class _PreProductionScreenState extends State<PreProductionScreen> {

  final FileUploadController files_con = FileUploadController();

  List<Map<String, dynamic>> files = [
    {"name": "Example.pdf", "isPdf": true},
    {"name": "Example.docx", "isPdf": false},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:
      Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/icons/Reply.png",
                    height: 24,
                    color: ColorCode.white,
                  ),
                ),
                const Spacer(),
                const Text(
                  "Pre Production",
                  style: TextStyle(
                    color: ColorCode.white,
                    fontSize: 16,
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 45,
              padding:
              const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search,
                      color: ColorCode.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                            color: ColorCode.kWhiteOpacity70,),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                final bool isPdf = index % 2 == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorCode.k282828,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔝 File Name Row
                      Row(
                        children: [
                          Icon(
                            isPdf ? Icons.picture_as_pdf : Icons.description,
                            color: isPdf ? Colors.redAccent : Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPdf ? "Example.pdf" : "Example.docx",
                            style: const TextStyle(
                              color: ColorCode.white,
                              fontSize: 13,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.more_vert,
                              color: ColorCode.white),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// 📄 Preview Box
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorCode.kCircleGradientTop,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPdf
                                  ? Colors.redAccent
                                  : Colors.blue,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPdf ? "Pdf" : "Doc",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Divider(
                        color: ColorCode.kDividerWhite12,
                        thickness: 0.8,
                      ),

                      const SizedBox(height: 8),

                      /// 👤 Footer Row
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                            ColorCode.kSoftLightBlue,
                            child: Text(
                              "DP",
                              style: TextStyle(
                                color: ColorCode.black,
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Opened 2 hours ago",
                            style: TextStyle(
                              color: ColorCode.kWhiteOpacity70,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      )
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: ColorCode.backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// 🔝 View Shoot Details
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  ShootDetailsScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "View Shoot Details",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorCode.white,
                      decoration: TextDecoration.underline
                    ),
                  ),
                  const SizedBox(height: 4),

                ],
              ),
            ),

            const SizedBox(height: 18),

            /// ⬇ Upload Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload, color: Colors.black),
                label: const Text(
                  "Upload Files",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCode.kButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  showUploadDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔝 Drag line
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: ColorCode.kWhiteOpacity70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// 🔝 Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upload Files",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  "Files will be uploaded to the folder Lana Guzman",
                  style: TextStyle(
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 12,
                    fontFamily: "Outfit",
                  ),
                ),
                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,

                ),
                const SizedBox(height: 20),

                /// 📂 Upload Box
                InkWell(
                  onTap: () async {

                    final pickedFile = await files_con.pickFile();

                    if (pickedFile != null) {
                      setState(() {
                        files.add(pickedFile);
                      });
                    }


                  },
                  child: Container(
                    height: 230,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorCode.k282828,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // 🔥 vertical center
                        crossAxisAlignment: CrossAxisAlignment.center, // 🔥 horizontal center
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/icons/upload-filled.png",
                            height: 40,
                          ),
                  
                          const SizedBox(height: 16),
                  
                          RichText(
                            textAlign: TextAlign.center, // 🔥 text center
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "Drag your files here or ",
                                  style: TextStyle(
                                    color: ColorCode.white,
                                    fontSize: 16,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: "Browse",
                                  style: TextStyle(
                                    color: ColorCode.kButtonColor,
                                    fontSize: 16,
                                    fontFamily: "Outfit",
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// 🔘 Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Unbounded",
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                            ColorCode.kButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Upload Files",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Unbounded",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
