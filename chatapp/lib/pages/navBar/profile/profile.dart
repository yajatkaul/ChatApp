import 'package:chatapp/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  _logout(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).onLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                _logout(context);
              },
              child: const Text("Logout"))
        ],
      ),
    );
  }
}
