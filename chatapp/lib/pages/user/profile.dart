import 'dart:convert';
import 'dart:io';

import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/showToast.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _updateDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    final String username = _usernameController.text;

    if (galleryPic != null) {
      uploadImage(File(image!.path), sessionCookie);
    }

    final response = await http.post(
      Uri.parse('$serverURL/api/user/updateUsername'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode(<String, String>{
        'displayName': username,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['result'], true, context);
      Navigator.pop(context);
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false, context);
    }
  }

  Future<void> uploadImage(File image, String? cookie) async {
    final url = Uri.parse('$serverURL/api/user/updatePFP');

    var request = http.MultipartRequest('POST', url);

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    request.headers['Cookie'] = cookie!;

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      ),
    );

    try {
      await request.send();
    } catch (e) {
      print('Error occurred while uploading image: $e');
    }
  }

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
                _updateDetails(context);
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
