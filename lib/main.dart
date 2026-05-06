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

        appBarTheme: const AppBarTheme(
          backgroundColor: ColorCode.backgroundColor,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        colorScheme: ColorScheme.dark(
          background: ColorCode.backgroundColor,
          primary: Colors.white,
        ),

        // ✅ REMOVE ALL CLICK EFFECTS
        splashFactory: NoSplash.splashFactory, // 🔥 MOST IMPORTANT
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,

        // ✅ Remove Ink ripple globally
        // useMaterial3: false, // sometimes M3 adds effects

        // ✅ Remove button overlay effect
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
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











