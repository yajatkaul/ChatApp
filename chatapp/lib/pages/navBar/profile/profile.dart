import 'package:chatapp/pages/user/profile.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
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
      appBar: AppBar(title: const Text("Profile"), actions: <Widget>[
        IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: const Icon(Icons.logout)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image(
                          image: NetworkImage(
                              Provider.of<UserProvider>(context, listen: true)
                                      .profilePic ??
                                  defaultImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      Provider.of<UserProvider>(context, listen: true)
                          .displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                    child: const Text("Edit profile"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
