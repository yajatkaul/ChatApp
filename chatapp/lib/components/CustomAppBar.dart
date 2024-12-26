import 'dart:convert';

import 'package:chatapp/pages/user/profile.dart';
import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/showToast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? profilePic;

  Future<void> _getDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/user/getUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        profilePic = responseBody['profilePic'];
      });
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false, context);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Home page"),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                profilePic == null
                    ? "https://i.pinimg.com/736x/f6/bc/9a/f6bc9a75409c4db0acf3683bab1fab9c.jpg"
                    : profilePic!,
                fit: BoxFit.cover,
              ),
            ))
      ],
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }
}
