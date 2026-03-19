import 'package:beige_creative_app/FileManager/post_pre_production_screen.dart';
import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';
import '../widgets/custom_text_field.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController folderController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();


  @override
  void dispose() {
    _tabController.dispose();
    folderController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: [

            /// 🔝 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [

                  /// MENU
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Image.asset(
                        "assets/home/menu-02.png",
                        width: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// TITLE
                  const Text(
                    "File Manager",
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

            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.white54),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search File, User...",
                          hintStyle:
                          TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📂 TABS
            Column(
              children: [

                TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.label,

                  /// 👇 Custom Rounded Indicator
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3,
                      color: ColorCode.kButtonColor,
                    ),
                    insets: const EdgeInsets.symmetric(horizontal: 25),
                  ),

                  labelColor: ColorCode.kButtonColor,
                  unselectedLabelColor: ColorCode.kWhiteOpacity70,

                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Outfit",

                  ),


                  tabs: const [
                    Tab(text: "All Files"),
                    Tab(text: "Recent Files"),
                  ],
                ),

                /// 👇 Full Width Bottom Divider Line
                Container(
                  height: 2,
                  color: Colors.white12,
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 📄 LIST
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _fileList(),
                  _fileList(),
                ],
              ),
            ),
            /// 👇 Bottom Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: InkWell(

                  onTap: () {
                    showCreateFolderSheet();
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: ColorCode.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Add / Create",
                          style: TextStyle(
                            color: ColorCode.kHeadingColor,
                            fontSize: 14,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        )


        );

  }
  void showCreateFolderSheet() {
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

                /// Drag line
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Create Folder",
                      style: TextStyle(
                        color: ColorCode.white,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  "Create new folder for users",
                  style: TextStyle(
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 12,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                  ),
                ),


                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,

                ),
                SizedBox(height: 12),
                CustomTextField(label: "Folder Name",controller:folderController ,),
                const SizedBox(height: 15),
                CustomTextField(label: "Category",controller: categoryController,),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style:
                          OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.white24),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Unbounded",
                              fontWeight:
                              FontWeight.w500,
                              color: ColorCode.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor:
                            const Color(0xFFE8D1AB),
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:

                          () {

                          },
                          child: const Text(
                            "Create Folder",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: "Unbounded",
                              fontWeight:
                              FontWeight.w500,
                              color: ColorCode.black,
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
  /// 📁 FILE CARD LIST
  Widget _fileList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  PostPreProductionScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: ColorCode.k282828,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Folder Title Row
                Row(
                  children: [
                    Icon(Icons.folder,
                        color: ColorCode.kButtonColor),
                    const SizedBox(width: 8),
                    const Text(
                      "Lana #123456",
                      style: TextStyle(
                        color: ColorCode.white,
                        fontSize: 13,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.more_vert,
                        color: ColorCode.white),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "02 Files",
                  style: TextStyle(
                    color: ColorCode.kButtonColor,
                    fontSize: 12,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: ColorCode.kCircleGradientTop,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Corporate Event",
                    style: TextStyle(
                      color: ColorCode.white,
                      fontSize: 12,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Divider(
                  color: ColorCode.kDividerWhite12,
                  thickness: 0.8,

                ),
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ColorCode.kSoftLightBlue,
                      child: Text("DP",
            style: TextStyle(
          color: ColorCode.black,
          fontSize: 16,
          fontFamily: "Outfit",
          fontWeight: FontWeight.w500,
          ),)
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Opened 2 hours ago",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 16,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}