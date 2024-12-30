import 'dart:io';

import 'package:chatapp/pages/user/hooks/updateUser.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? galleryPic;
  bool selectedFromGallery = false;
  XFile? image;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;
    if (userName != null) {
      _usernameController.text = userName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                UpdateUser().updateDetails(
                    context, _usernameController.text, galleryPic, image);
              },
              icon: const Icon(
                Icons.check_circle,
                size: 35,
                color: Colors.green,
              ))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    galleryPic = File(image!.path);
                    selectedFromGallery = true;
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Provider.of<UserProvider>(context).profilePic == null &&
                        !selectedFromGallery
                    ? Image.network(
                        "https://i.pinimg.com/736x/f6/bc/9a/f6bc9a75409c4db0acf3683bab1fab9c.jpg",
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    : !selectedFromGallery
                        ? Image.network(
                            Provider.of<UserProvider>(context).profilePic!,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            galleryPic!,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
