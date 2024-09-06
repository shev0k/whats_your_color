import 'package:flutter/material.dart';

class HexColor extends Color {
  // Constructor that takes a hex color string (e.g., "#FFFFFF") and converts it to a Color object
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  // A helper method that converts a hex string into an integer value that Flutter's Color class can use
  static int _getColorFromHex(String hexColor) {
    // Remove the '#' character if it exists in the string
    hexColor = hexColor.toUpperCase().replaceAll('#', '');

    // If the string is 6 characters long, assume it's an RGB hex color and add 'FF' at the start for full opacity
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }

    // Convert the hex string into an integer value and return it
    return int.parse(hexColor, radix: 16);
  }
}
