//
// import 'package:get/get.dart';
//
// class sharedPref
// {
//
//   static String drawer_open_close = "drawer_open_close";
//   static String stringListKey = "string_list_key";
//
//
//   static String getStringPref(String keyName)
//   {
//     String value="";
//     GetStorage getStorage=GetStorage();
//     value = getStorage.read(keyName) ?? "";
//     return value;
//   }
//
//   static int getIntegerPref(String keyName)
//   {
//     int value;
//     GetStorage getStorage=GetStorage();
//     value = getStorage.read(keyName) ?? 0;
//     return value;
//   }
//
//   static saveStringPref(String keyName,String value)
//   {
//     GetStorage getStorage=GetStorage();
//     getStorage.write(keyName,value);
//   }
//
//   static saveIntegerPref(String keyName,int value)
//   {
//     GetStorage getStorage=GetStorage();
//     getStorage.write(keyName,value);
//   }
//
//   static double getDoublePref(String keyName)
//   {
//     double value;
//     GetStorage getStorage=GetStorage();
//     value = getStorage.read(keyName) ?? 0.0;
//     return value;
//   }
//
//   static saveDoublePref(String keyName,double value)
//   {
//     GetStorage getStorage=GetStorage();
//     getStorage.write(keyName,value);
//   }
//
//   static bool getBoolPref(String keyName)
//   {
//     bool value;
//     GetStorage getStorage=GetStorage();
//     value = getStorage.read(keyName) ?? false;
//     return value;
//   }
//
//   static saveBoolPref(String keyName,bool value)
//   {
//     GetStorage getStorage=GetStorage();
//     getStorage.write(keyName,value);
//   }
//
//   static List<String> getStringListPref(String keyName) {
//     List<String> value = [];
//     List<dynamic> jsonList = GetStorage().read(keyName);
//     value = jsonList.cast<String>().toList();
//     return value;
//   }
//
//   static saveStringListPref(String keyName, List<String> value) {
//     GetStorage getStorage = GetStorage();
//     getStorage.write(keyName, value);
//   }
//
//   static bool containKey(String keyName)
//   {
//     bool value;
//     GetStorage getStorage=GetStorage();
//     getStorage.read(keyName) == null ? value = false : value = true;
//     return value;
//   }
//
//   static removeAll()
//   {
//     //Remove all shared pref
//     GetStorage getStorage=GetStorage();
//     getStorage.erase();
//   }
//
//   static removeSingleValue(String keyName)
//   {
//     //Remove single shared pref value
//     GetStorage getStorage=GetStorage();
//     getStorage.remove(keyName);
//
//   }
// }