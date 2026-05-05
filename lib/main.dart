import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SplashScreen/splash_screen.dart';
import 'config/env.dart';
import 'utility/ColorCode.dart';

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set environment
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  AppConfig.setEnvironment(environment);
  */
/* Stripe.publishableKey =
  "pk_test_51S5czd54hnPNgHXUq7sunp8uvTDW4ln6aw8Y3bP249JZmx4xuvoIED4mZTuNIkAFcOoCApICfgv9dM4VbbleJo7L00GqNEkj3I";
*//*

  // ✅ Read login state
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));

}
*/
Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.init(environment);
  // Stripe.publishableKey = Env.stripePublishableKey;

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: ThemeData(

        scaffoldBackgroundColor: ColorCode.backgroundColor,
        appBarTheme:  AppBarTheme(
          backgroundColor: ColorCode.backgroundColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark(
          background: ColorCode.backgroundColor,
          primary: Colors.white,
        ),
      ),


      // ✅ Correct navigation logic
      // home: isLoggedIn
      //     ?  Mainscreen()
      //     :  SplashScreen(),

          home:
            SplashScreen(),

    );
  }
}











