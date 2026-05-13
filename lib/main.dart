import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'app/router.dart';
import 'config/env.dart';
import 'utility/colorcode.dart';

Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.init(environment);

  final prefs = await SharedPreferences.getInstance();

  bool isLoggedIn =
      prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {

  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(

      debugShowCheckedModeBanner: false,

      title: 'BEIGE',

      routerConfig: appRouter,

      theme: ThemeData(

        scaffoldBackgroundColor:
        ColorCode.backgroundColor,

        appBarTheme: const AppBarTheme(
          backgroundColor:
          ColorCode.backgroundColor,

          iconTheme:
          IconThemeData(color: Colors.white),

          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        colorScheme: ColorScheme.dark(
          background:
          ColorCode.backgroundColor,

          primary: Colors.white,
        ),

        splashFactory:
        NoSplash.splashFactory,

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,

        elevatedButtonTheme:
        ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            splashFactory:
            NoSplash.splashFactory,
          ),
        ),

        textButtonTheme:
        TextButtonThemeData(
          style: TextButton.styleFrom(
            splashFactory:
            NoSplash.splashFactory,
          ),
        ),

        outlinedButtonTheme:
        OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            splashFactory:
            NoSplash.splashFactory,
          ),
        ),
      ),
    );
  }
}