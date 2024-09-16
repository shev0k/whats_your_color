import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ColorService {
  final SharedPreferences prefs;
  final String baseUrl;

  ColorService(this.prefs, {required this.baseUrl});

  Future<Color?> loadSelectedColor() async {
    int? savedColorValue = prefs.getInt('selected_color');
    if (savedColorValue != null) {
      return Color(savedColorValue);
    }
    return null;
  }

  Future<void> saveSelectedColor(Color color) async {
    await prefs.setInt('selected_color', color.value);
  }

  Future<void> sendColorToServer(Color color, String userId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/color'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'color': color.value.toString()}),
      );
    } catch (e) {
      // no-op
    }
  }
}
