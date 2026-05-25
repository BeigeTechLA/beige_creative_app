import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/shadows.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
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
                    style: AppTextStyles.displayLabel16,
                  ),

                  const Spacer(),

                ],
              ),
            ),

            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Row(
                children: [

                  /// 🔍 Search Container (Full Width)
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMid,
                        borderRadius: AppRadii.xlAll,
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
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                              decoration: InputDecoration(
                                hintText: "Search File, User...",
                                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white38),
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
                        color:AppColors.surfaceMid,
                        borderRadius: AppRadii.lgAll,
                        /*border: Border.all(
                          color: AppColors.white.withOpacity(0.06),
                        ),*/
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          loding ? AppAssets.grid : AppAssets.list,
                          height: 22,
                          width: 22,
                          color: AppColors.white,
                          /*colorFilter: const ColorFilter.mode(
                            AppColors.white,
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
                      color: AppColors.primary,
                    ),
                    insets: const EdgeInsets.symmetric(horizontal: AppSpacing.s25),
                  ),

                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.white30,

                  labelStyle: AppTextStyles.body14Medium,


                  tabs: const [
                    Tab(text: "All Files"),
                    Tab(text: "Recent Files"),
                  ],
                ),

                /// 👇 Full Width Bottom Divider Line
                Container(
                  height: 2,
                  color: AppColors.dividerDark,
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
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Center(
                child: InkWell(

                  onTap: () {
                    showCreateFolderSheet();
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.mldAll,
                      boxShadow: AppShadows.card,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: AppColors.black, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Add / Create",
                          style: AppTextStyles.body14Medium.copyWith(
                            color: AppColors.textHeading,
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
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Drag line
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white24,
                      borderRadius: AppRadii.mldAll,
                    ),
                  ),
                ),

                /// Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Create Folder",
                      style: AppTextStyles.displayLabel16,
                    ),

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  "Create new folder for users",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white30,
                  ),
                ),


                Divider(
                  color: AppColors.dividerDark,
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
                                color: AppColors.white24),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: () =>
                              context.pop(),

                          child: const Text(
                            "Cancel",
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
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
                            padding: EdgeInsets.zero,
                            backgroundColor:
                            AppColors.primary,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              AppRadii.xxlAll,
                            ),
                          ),
                          onPressed:

                          () {

                          },
                          child: const Text(
                            "Create Folder",
                            style: AppTextStyles.displayLabel13.copyWith(
                              color: AppColors.black,
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
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
            margin: const EdgeInsets.only(bottom: AppSpacing.mld),
            padding: const EdgeInsets.all(AppSpacing.s22),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.portfolioCompactAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Folder Title Row
                Row(
                  children: [
                    Icon(Icons.folder,
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      "Lana #123456",
                      style: AppTextStyles.bodyCompactStrong.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.white),
                      color: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.xxxlAll,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.smd),
                  decoration: BoxDecoration(
                    color: AppColors.circleGradientTop,
                    borderRadius: AppRadii.hugeAll,
                  ),
                  child: const Text(
                    "Corporate Event",
                    style: AppTextStyles.bodySmallMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),

                Divider(
                  color: AppColors.dividerDark,
                  thickness: 0.8,

                ),
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.softLightBlue,
                      child: Text("DP",
            style: AppTextStyles.bodyLargeMedium.copyWith(
              color: AppColors.black,
            ),)
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Opened 2 hours ago",
                      style: AppTextStyles.bodyLargeMedium.copyWith(
                        color: AppColors.white30,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: 20,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.mld),
              padding: const EdgeInsets.all(AppSpacing.s22),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: AppRadii.portfolioCompactAll,
              ),
              child: Row(
                children: const [
                  Icon(Icons.folder, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Lana #123456",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                  Icon(Icons.more_vert, color: AppColors.white),
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
            color: isDelete ? AppColors.error : AppColors.white,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDelete ? AppColors.error : AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}