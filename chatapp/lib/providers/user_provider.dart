import 'dart:convert';

import 'package:chatapp/pages/auth/login.dart';
import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  String? id;
  String? displayName;
  String? profilePic;
  String? sessionCookie;

  onLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');

    await http.get(
      Uri.parse('$serverURL/api/auth/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    id = null;
    displayName = null;
    profilePic = null;
    sessionCookie = null;
    notifyListeners();
  }

  getDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/user/getUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['profilePic'] == null) {
        profilePic = null;
      } else {
        profilePic = '$serverURL/api/${responseBody['profilePic']}';
      }
      id = responseBody['_id'];
      displayName = responseBody['displayName'];

      notifyListeners();
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false, context);
    }
  }
}
