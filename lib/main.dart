import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/themes/app_theme.dart';
import 'screens/introduction_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // app runs only in portrait mode.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SharedPreferences instance
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // check if introduction animation has been seen
  bool hasSeenIntroduction = prefs.getBool('hasSeenIntroduction') ?? false;

  runApp(MyApp(hasSeenIntroduction: hasSeenIntroduction));
}

class MyApp extends StatelessWidget {
  final bool hasSeenIntroduction;

  const MyApp({super.key, required this.hasSeenIntroduction});

  @override
  Widget build(BuildContext context) {
    // setting up system UI
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppTheme.nearlyBlack,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: AppTheme.nearlyBlack,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.android,
      ),
      home: hasSeenIntroduction
          ? const HomeScreen()
          : const IntroductionAnimationScreen(),
    );
  }
}
