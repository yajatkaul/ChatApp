import 'dart:convert';

import 'package:chatapp/pages/home.dart';
import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/showToast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _displaynameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text;
    final String displayName = _displaynameController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Example API request
    final response = await http.post(
      Uri.parse('$serverURL/api/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }, // Replace with your API endpoint
      body: jsonEncode(<String, String>{
        'displayName': displayName,
        'userName': username,
        'password': password,
        'confirmPassword': confirmPassword
      }),
    );

    if (response.statusCode == 200) {
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_cookie', cookie);
      }

      if (mounted) {
        showToast("Logged in successfully", true, context);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      if (mounted) {
        final responseBody = jsonDecode(response.body);
        final resultMessage = responseBody['error'] ?? 'Internal Server Error';
        showToast(resultMessage, false, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sign Up Page"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _displaynameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "DisplayName",
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Confirm Password",
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                child: const Text("Sign Up"))
          ],
        ),
      ),
    );
  }
}
