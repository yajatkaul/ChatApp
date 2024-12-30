import 'dart:convert';

import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/showToast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DmProvider extends ChangeNotifier {
  List<dynamic> all_users = [];

  getAllUsers(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/dm/getUsersForMessage'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      all_users = jsonDecode(response.body);
      notifyListeners();
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false, context);
    }
  }
}
