//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../custom/CustomTextFormField.dart';
// import '../custom/CustomToast.dart';
// import 'ColorCode.dart';
//
//
// class Utils
// {
//
//
//   static TextEditingController remarkController = TextEditingController();
//
//
//   static String dateFormat(DateTime date)
//   {
//     final DateFormat formatter = DateFormat('dd-MM-yyyy');
//     return formatter.format(date);
//   }
//
//   static String dateandtimeFormat(String date)
//   {
//     final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
//     DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm").parse(date);
//     return formatter.format(dateTime);
//   }
//
//   static String getMonthName(int month) {
//     switch (month) {
//       case 1:
//         return 'January';
//       case 2:
//         return 'February';
//       case 3:
//         return 'March';
//       case 4:
//         return 'April';
//       case 5:
//         return 'May';
//       case 6:
//         return 'June';
//       case 7:
//         return 'July';
//       case 8:
//         return 'August';
//       case 9:
//         return 'September';
//       case 10:
//         return 'October';
//       case 11:
//         return 'November';
//       case 12:
//         return 'December';
//       default:
//         return '';
//     }
//   }
//
//   /*show toast message*/
//   static showCustomToast(String message, BuildContext context) {
//     OverlayEntry overlayEntry = OverlayEntry(
//       builder: (context) => CustomToast(message: message),
//     );
//
//     // Insert the overlay entry into the Overlay
//     Overlay.of(context).insert(overlayEntry);
//
//     // Remove the overlay entry after 2 seconds
//     Future.delayed(Duration(seconds: 2), () {
//       overlayEntry.remove();
//     });
//   }
//
// /*  static Future<void> showToast(String msg) async {
//     Fluttertoast.showToast(
//         msg: msg,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: getColor(ColorCode.wine),
//         textColor: getColor(ColorCode.white),
//         fontSize: 16.0);
//   }*/
//
//   static Future<void> showToast(String msg,BuildContext context) async {
//     if(Platform.isWindows){
//       final snackBar = SnackBar(content: Text('$msg'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }else{
//       Fluttertoast.showToast(
//           msg: msg,
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: getColor(ColorCode.wine),
//           textColor: getColor(ColorCode.white),
//           fontSize: 16.0);
//     }
//   }
//
// /*  static Future<void> showToast(String msg,BuildContext context) async {
//     if(Platform.isWindows){
//       final snackBar = SnackBar(content: Text('$msg'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }else{
//       Fluttertoast.showToast(
//           msg: msg,
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: getColor(ColorCode.wine),
//           textColor: getColor(ColorCode.white),
//           fontSize: 16.0);
//     }
//   }*/
//
//
//   /*date range calculate*/
//   static String dateRangeCalculator(int deductingHours)
//   {
//     DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
//     DateTime currentdatetime = DateTime.now();
//
//     int d = (deductingHours * 3600 * 1000);
//     int sc = DateTime.now().millisecondsSinceEpoch;
//     int c = sc - d;
//
//     DateTime date = DateTime.fromMillisecondsSinceEpoch(c);
//
//     return "${dateFormat.format(currentdatetime)},${dateFormat.format(date)}";
//   }
//
//
//
//   /*check internet connection*/
//   static Future<bool> checkInternet() async {
//     bool isConnected=false;
//     try {
//       final List<InternetAddress> result =
//       await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         isConnected = true;
//       }
//     } on SocketException catch (_) {
//       isConnected = false;
//       //return false;
//     }
//     return isConnected;
//   }
//
//   static TextStyle headerStyle()
//   {
//     return TextStyle(color: getColor(ColorCode.black),decoration: TextDecoration.none,fontSize: 25.sp,fontFamily: 'Gilroy_bold');
//   }
//
//   static TextStyle headersignin(String color)
//   {
//     return TextStyle(color: getColor(color),decoration: TextDecoration.none,fontSize: 25.sp,fontFamily: 'Gilroy_bold');
//   }
//
//   static TextStyle subheader(String color)
//   {
//     return TextStyle(color: getColor(color),decoration: TextDecoration.none,fontSize: 15,fontFamily: 'Gilroy_medium');
//   }
//
//   static Container textFieldheader(String title)
//   {
//     return Container(padding: EdgeInsets.only(left: 5.w),child: Text(title,style: TextStyle(color: getColor(ColorCode.grey),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_bold'),),);
//   }
//
//   static TextStyle subheaderwithbold(String color)
//   {
//     return TextStyle(color: getColor(color),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_semi_bold');
//   }
//
//   static Material textWithclick(String text,String color)
//   {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         child:Text(text,style:TextStyle(color: getColor(color),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_semi_bold')),
//         onTap: ()
//         {
//         },
//       ),
//     );
//   }
//
//
//   /*get color code from hex*/
//   static Color getColor(String hexColor) {
//     hexColor = hexColor.toUpperCase().replaceAll('#', '');
//
//     if (hexColor.length == 6) {
//       hexColor = 'FF$hexColor';
//     }
//
//     return Color(int.parse(hexColor, radix: 16));
//   }
//
//   static AppBar customAppBar(String title, GlobalKey<ScaffoldState> scaffoldKey)
//   {
//     return AppBar(
//       centerTitle: true,
//       title: Text(title,style: TextStyle(color: getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 19.sp,fontFamily: 'Gilroy_semi_bold')),
//       leading: Builder(builder: (context)=>IconButton(onPressed: (){
//         scaffoldKey.currentState?.openDrawer();
//       }, icon: const Icon(Icons.menu,size: 29,color: Colors.white))),
//       backgroundColor: Utils.getColor(ColorCode.wine),
//     );
//   }
//
//   static drawerMenuClose(GlobalKey<ScaffoldState> scaffoldKey)
//   {
//     scaffoldKey.currentState?.closeDrawer();
//   }
//
//
//   static AppBar customAppBarWithBack(String title,String subtitle)
//   {
//     return AppBar(
//       centerTitle: true,
//       title: subtitle!="" ? Column(
//         children: [
//           Text(title,style: TextStyle(color: getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Gilroy_semi_bold')),
//           SizedBox(height: 2.h),
//           Text(subtitle,style: TextStyle(color: getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 11,fontWeight: FontWeight.bold,fontFamily: 'Gilroy_medium')),
//         ],
//       ) : Text(title,style: TextStyle(color: getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 19,fontWeight: FontWeight.bold,fontFamily: 'Gilroy_semi_bold')),
//       leading: Builder(builder: (context)=>IconButton(onPressed: (){
//         Get.back();
//       }, icon: const Icon(Icons.arrow_back_ios_new,size: 25,color: Colors.white))),
//       backgroundColor: Utils.getColor(ColorCode.wine),
//     );
//   }
//
//   static void noInternetBottomsheet()
//   {
//     Get.bottomSheet(
//         StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return SafeArea(
//                 child: SingleChildScrollView(
//                   child: Wrap(
//                     children: [
//                       Container(
//                           margin: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Utils.getColor(ColorCode.white),
//                             borderRadius: const BorderRadius.all(Radius.circular(15)),
//                           ),
//                           child:Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 10.h,),
//                               Align(
//                                 alignment: Alignment.topCenter,
//                                 child: Container(
//                                   width: 50.w,
//                                   height: 3.h,
//                                   decoration: BoxDecoration(
//                                     color: Utils.getColor(ColorCode.grey_white),
//                                     borderRadius: const BorderRadius.all(Radius.circular(2)),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 10.h,),
//                               Align(alignment: Alignment.topCenter,child: Text("No Internet",style: TextStyle(color:Utils.getColor(ColorCode.black),decoration: TextDecoration.none,fontSize: 17.sp,fontFamily: 'Gilroy_bold'))),
//                               Container(
//                                   padding: EdgeInsets.only(top: 10.h,bottom: 10.h,left: 15.w,right: 15.w),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//
//                                       SizedBox(width: 2.w,),
//                                       Expanded(
//                                           child:Column(
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Column(
//                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                                       children: [
//                                                         SizedBox(height: 3.h,),
//                                                         SizedBox(
//                                                           height: 100.h,
//                                                           width: 100.w,
//                                                           child: ClipRRect(
//                                                               borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
//                                                               child: Image.asset('assets/icons/ic_no_internet.png',fit: BoxFit.fill)),
//                                                         ),
//                                                         SizedBox(height: 3.h,),
//                                                         Text("Check your network connection and try again.",textAlign: TextAlign.center,style: TextStyle(color:Utils.getColor(ColorCode.black),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_medium')),
//                                                         SizedBox(height: 20.h,),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           )
//                                       ),
//                                     ],
//                                   )
//                               ),
//
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                           borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15),bottomLeft: Radius.circular(15)),
//                                           color:Utils.getColor(ColorCode.red).withOpacity(0.9)
//                                       ),
//                                       height: 45.h,
//                                       child: Material(
//                                         color: Colors.transparent,
//                                         child: InkWell(
//                                           child:Center(child: Text("Close",style:TextStyle(color: Utils.getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_semi_bold'))),
//                                           onTap: ()
//                                           {
//                                             Get.back();
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ],
//                           )
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//         ),
//         isDismissible: false,
//         barrierColor: Colors.transparent.withOpacity(0.2),
//         isScrollControlled: true,
//         ignoreSafeArea: false,
//         enableDrag: true
//     );
//   }
//
//   static void logoutBottomsheet()
//   {
//     Get.bottomSheet(
//         StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return SafeArea(
//                 child: SingleChildScrollView(
//                   child: Wrap(
//                     children: [
//                       Container(
//                           margin: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Utils.getColor(ColorCode.white),
//                             borderRadius: const BorderRadius.all(Radius.circular(15)),
//                           ),
//                           child:Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 10.h,),
//                               Align(
//                                 alignment: Alignment.topCenter,
//                                 child: Container(
//                                   width: 50.w,
//                                   height: 3.h,
//                                   decoration: BoxDecoration(
//                                     color: Utils.getColor(ColorCode.grey_white),
//                                     borderRadius: const BorderRadius.all(Radius.circular(2)),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 10.h,),
//                               Align(alignment: Alignment.topCenter,child: Text('lbl_logout'.tr,style: TextStyle(color:Utils.getColor(ColorCode.black),decoration: TextDecoration.none,fontSize: 17.sp,fontFamily: 'Gilroy_bold'))),
//                               Container(
//                                   padding: EdgeInsets.only(top: 10.h,bottom: 10.h,left: 15.w,right: 15.w),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//
//                                       SizedBox(width: 2.w,),
//                                       Expanded(
//                                           child:Column(
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Column(
//                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                                       children: [
//                                                         SizedBox(height: 10.h,),
//                                                         Text('msg_logout_msg'.tr,textAlign: TextAlign.center,style: TextStyle(color:Utils.getColor(ColorCode.black),decoration: TextDecoration.none,fontSize: 16.sp,fontFamily: 'Gilroy_semi_bold')),
//                                                         SizedBox(height: 20.h,),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           )
//                                       ),
//                                     ],
//                                   )
//                               ),
//
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                           borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15)),
//                                           color:Utils.getColor(ColorCode.wine).withOpacity(0.9)
//                                       ),
//                                       height: 45.h,
//                                       child: Material(
//                                         color: Colors.transparent,
//                                         child: InkWell(
//                                           child:Center(child: Text('lbl_cancel'.tr,style:TextStyle(color: Utils.getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_semi_bold'))),
//                                           onTap: ()
//                                           {
//                                             Get.back();
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 45.h,width: 1.w,),
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                           borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
//                                           color:Utils.getColor(ColorCode.red).withOpacity(0.9)
//                                       ),
//                                       height: 45.h,
//                                       child: Material(
//                                         color: Colors.transparent,
//                                         child: InkWell(
//                                           child:Center(child: Text('lbl_logout'.tr,style:TextStyle(color: Utils.getColor(ColorCode.white),decoration: TextDecoration.none,fontSize: 15.sp,fontFamily: 'Gilroy_semi_bold'))),
//                                           onTap: ()
//                                           {
//                                             Get.back();
//                                             // Get.offAllNamed(RouteInfo.signinscreen);
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ],
//                           )
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//         ),
//         isDismissible: false,
//         barrierColor: Colors.transparent.withOpacity(0.2),
//         isScrollControlled: true,
//         ignoreSafeArea: false,
//         enableDrag: true
//     );
//   }
// }