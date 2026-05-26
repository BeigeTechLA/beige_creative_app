import 'package:flutter/material.dart';


import 'app/router.dart';
import 'app/theme.dart';
import 'config/env.dart';
import 'service/prefs_service.dart';

Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.init(environment);

  await PrefsService.init();

  final bool isLoggedIn = PrefsService.isLoggedIn;

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