import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'app/router.dart';
import 'app/theme.dart';
import 'config/env.dart';

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

      theme: AppTheme.dark(),
    );
  }
}