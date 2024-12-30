import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chatapp/pages/home.dart';
import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/showToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Login {
  login(BuildContext context, String username, String password) async {
    final response = await http.post(
      Uri.parse('$serverURL/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'displayName': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_cookie', cookie);
      }

      showToast("Logged in successfully", true, context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      final responseBody = jsonDecode(response.body);
      final resultMessage = responseBody['error'] ?? 'Internal Server Error';
      showToast(resultMessage, false, context);
    }
  }
}
