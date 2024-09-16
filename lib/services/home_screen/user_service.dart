import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class UserService {
  final SharedPreferences prefs;
  final String baseUrl;

  UserService(this.prefs, {required this.baseUrl});

  Future<String?> loadUserId() async {
    return prefs.getString('user_id');
  }

  Future<void> saveUserId(String userId) async {
    await prefs.setString('user_id', userId);
  }

  Future<void> registerUser(String? userId, {Color? color}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'color': color?.value.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveUserId(data['userId']);
      }
    } catch (e) {
      // handle error
    }
  }

  Future<void> deregisterUser(String userId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/deregister'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      // handle error
    }
  }
}
