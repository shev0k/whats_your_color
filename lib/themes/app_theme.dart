import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Updated colors for AMOLED theme with lavender/purple accents
  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color.fromRGBO(10, 10, 10, 1); // Darker for AMOLED
  static const Color grey = Color(0xFF2A2A2A); // Dark grey for AMOLED
  static const Color dark_grey = Color(0xFF1A1A1A); // Even darker grey

  // Accent colors
  static const Color lavender = Color(0xFFB388FF); // Lavender accent
  static const Color purple = Color(0xFF7C4DFF); // Purple accent

  static const Color darkText = Color(0xFFB0BEC5); // Lighter grey for text
  static const Color darkerText = Color(0xFFECEFF1); // Nearly white for titles
  static const Color lightText = Color(0xFFB3B3B3); // Light grey for secondary text
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF37474F);
  static const Color chipBackground = Color(0xFF263238); // Darker background for chips
  static const Color spacer = Color(0xFF212121); // Spacer color closer to black
  static const String fontName = 'WorkSans';

  static const TextTheme textTheme = TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyMedium: body2,
    bodyLarge: body1,
    bodySmall: caption,
  );

  static const TextStyle display1 = TextStyle( // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle( // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle( // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle( // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle( // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle( // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // Light text color
  );
}
