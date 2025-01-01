import 'package:chatapp/pages/user/profile.dart';
import 'package:chatapp/providers/user_provider.dart';
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
                    ? "https://i.pinimg.com/736x/f6/bc/9a/f6bc9a75409c4db0acf3683bab1fab9c.jpg"
                    : Provider.of<UserProvider>(context).profilePic!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ))
      ],
    );
  }
}
