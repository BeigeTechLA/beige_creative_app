import 'package:flutter/material.dart';
import '../utility/colorcode.dart';
import 'pre_production_screen.dart';

class PostProductionScreen extends StatefulWidget {
  const PostProductionScreen({super.key});

  @override
  State<PostProductionScreen> createState() =>
      _PostProductionScreenState();
}

class _PostProductionScreenState
    extends State<PostProductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            /// 🔝 HEADER
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
                    "Lana #123456",
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
                        color: Colors.white54),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                            color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                              color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📄 LIST
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return InkWell(
                    borderRadius:
                    BorderRadius.circular(22),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  PreProductionScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin:
                      const EdgeInsets.only(bottom: 14),
                      padding:
                      const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: ColorCode.k282828,
                        borderRadius:
                        BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: const [
                              Icon(Icons.folder,
                                  color: ColorCode
                                      .kButtonColor),
                              SizedBox(width: 8),
                              Text(
                                "Lana #123456",
                                style: TextStyle(
                                  color:
                                  ColorCode.white,
                                  fontSize: 13,
                                  fontFamily:
                                  "Outfit",
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.more_vert,
                                  color:
                                  ColorCode.white),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "02 Files",
                            style: TextStyle(
                              color: ColorCode
                                  .kButtonColor,
                              fontSize: 12,
                              fontFamily: "Outfit",
                            ),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: ColorCode
                                  .kCircleGradientTop,
                              borderRadius:
                              BorderRadius.circular(
                                  20),
                            ),
                            child: const Text(
                              "Corporate Event",
                              style: TextStyle(
                                color:
                                ColorCode.white,
                                fontSize: 12,
                                fontFamily:
                                "Outfit",
                              ),
                            ),
                          ),

                          const Divider(
                            color: ColorCode
                                .kDividerWhite12,
                            thickness: 0.8,
                          ),

                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                ColorCode
                                    .kSoftLightBlue,
                                child: Text(
                                  "DP",
                                  style: TextStyle(
                                      color:
                                      ColorCode
                                          .black),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Opened 2 hours ago",
                                style: TextStyle(
                                  color: ColorCode
                                      .kWhiteOpacity70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}