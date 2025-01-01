import 'package:chatapp/pages/user/profile.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
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
                Provider.of<UserProvider>(context).profilePic == null
                    ? defaultImage
                    : Provider.of<UserProvider>(context).profilePic!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ))
      ],
    );
  }
}
