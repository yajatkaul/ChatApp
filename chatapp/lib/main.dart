import 'package:chatapp/auth/login.dart';
import 'package:chatapp/pages/home.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<String?> _getSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_cookie');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        home: FutureBuilder<String?>(
          future: _getSessionCookie(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading session"));
            } else {
              if (snapshot.data != null) {
                return const HomePage();
              } else {
                return const LoginPage();
              }
            }
          },
        ),
      ),
    );
  }
}
