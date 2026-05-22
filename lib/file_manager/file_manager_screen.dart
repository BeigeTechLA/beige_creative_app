import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../utility/colorcode.dart';
import 'package:beige_creative_app/app/assets.dart';
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

  bool loding = true;

  @override
  void dispose() {
    _tabController.dispose();
    folderController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {

    super.initState();

    _tabController =
        TabController(
          length: 2,
          vsync: this,
        );
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
                   child: SvgPicture.asset(
                      AppAssets.menu,
                      width: 26,
                      height: 26,
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
              child: Row(
                children: [

                  /// 🔍 Search Container (Full Width)
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: ColorCode.k282828,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [

                          SvgPicture.asset(
                            AppAssets.search_icon,

                          ),
                          const SizedBox(width: 10),

                          /// TextField should be Expanded
                          const Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search File, User...",
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// 📱 Grid Button (Separate)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        loding = !loding;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color:ColorCode.k282828,
                        borderRadius: BorderRadius.circular(12),
                        /*border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),*/
                       /* boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],*/
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          loding ? AppAssets.grid : AppAssets.list,
                          height: 22,
                          width: 22,
                          color: ColorCode.white,
                          /*colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),*/
                        ),
                      ),
                    ),
                  )
                ],
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
                              context.pop(),

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
    if(loding){
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return InkWell(
        /*  onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  PostProductionScreen(),
              ),
            );
          },*/

          onTap: () {

            context.pushNamed(
              RouteNames.postProduction,
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: ColorCode.white),
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onSelected: (value) {
                        if (value == "open") {
                          print("Open");
                        } else if (value == "view") {
                          print("View Shoot Details");
                        } else if (value == "rename") {
                          print("Rename");
                        } else if (value == "share") {
                          print("Share");
                        } else if (value == "download") {
                          print("Download");
                        } else if (value == "delete") {
                          print("Delete");
                        }
                      },
                      itemBuilder: (context) => [

                        popupItem("open", Icons.folder_open, "Open"),
                        popupItem("view", Icons.remove_red_eye, "View Shoot Details"),
                        popupItem("rename", Icons.edit, "Rename"),

                        const PopupMenuDivider(),

                        popupItem("share", Icons.share, "Share"),
                        popupItem("download", Icons.download, "Download"),

                        const PopupMenuDivider(),

                        popupItem("delete", Icons.delete, "Delete", isDelete: true),
                      ],
                    ),
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
  } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: const [
                  Icon(Icons.folder, color: ColorCode.kButtonColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Lana #123456",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
          );
        },
      );

    }
  }
  PopupMenuItem<String> popupItem(
      String value,
      IconData icon,
      String text, {
        bool isDelete = false,
      }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDelete ? Colors.red : Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDelete ? Colors.red : Colors.white,
              fontFamily: "Outfit",
            ),
          ),
        ],
      ),
    );
  }
}